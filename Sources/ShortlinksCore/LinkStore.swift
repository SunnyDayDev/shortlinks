import Foundation

public enum StoreError: Error {
    case iCloudUnavailable
}

/// Хранилище ссылок поверх единого файла `links.json`.
///
/// Все изменения — координированное read-modify-write через `NSFileCoordinator` с
/// атомарной перезаписью, чтобы параллельные правки приложения и CLI не теряли друг
/// друга. Конфликтные версии iCloud сливаются по `id` (`ConflictMerge`). За каталогом
/// ведётся наблюдение, об изменениях извне сообщается через `changeHandler`.
public final class LinkStore {
    public private(set) var fileURL: URL

    /// Вызывается на главной очереди при изменениях файла извне.
    public var changeHandler: (() -> Void)?

    private let coordinator = NSFileCoordinator()
    private let queue = DispatchQueue(label: "com.shortlinks.store")
    private var dirSource: DispatchSourceFileSystemObject?
    private var dirFD: CInt = -1
    private var debounceWork: DispatchWorkItem?

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    public init(watch: Bool = true) {
        self.fileURL = StorageLocation.current()
        ensureDirectory()
        if watch { startWatching() }
    }

    deinit { stopWatching() }

    // MARK: - Reads

    /// Текущий список ссылок (с разрешением конфликтов).
    public func load() -> [Link] {
        var result: [Link] = []
        var coordError: NSError?
        coordinator.coordinate(readingItemAt: fileURL, options: [], error: &coordError) { url in
            result = readMerged(url)
        }
        return result
    }

    public func resolve(slug: String) -> Link? {
        load().first { $0.slug == slug }
    }

    // MARK: - Mutations

    /// Координированное изменение списка с атомарной записью.
    @discardableResult
    public func mutate<T>(_ body: (inout [Link]) -> T) -> T {
        ensureDirectory()
        var ret: T!
        var coordError: NSError?
        coordinator.coordinate(writingItemAt: fileURL, options: [], error: &coordError) { url in
            var links = readMerged(url)
            let conflicts = NSFileVersion.unresolvedConflictVersionsOfItem(at: url) ?? []
            ret = body(&links)
            writeAtomic(links, to: url)
            for version in conflicts { version.isResolved = true }
            try? NSFileVersion.removeOtherVersionsOfItem(at: url)
        }
        return ret
    }

    @discardableResult
    public func add(_ link: Link) -> Link {
        mutate { links in
            links.insert(link, at: 0)
            return link
        }
    }

    public func delete(id: String) {
        mutate { links in links.removeAll { $0.id == id } }
    }

    @discardableResult
    public func delete(slug: String) -> Bool {
        mutate { links in
            let before = links.count
            links.removeAll { $0.slug == slug }
            return links.count != before
        }
    }

    /// Регистрирует переход: для активной ссылки увеличивает счётчик, одноразовую
    /// помечает потреблённой (или удаляет при `deleteOnConsume`). Возвращает ссылку,
    /// которую следует открыть, или `nil`, если она недоступна/не найдена.
    @discardableResult
    public func consume(slug: String, deleteOnConsume: Bool, now: Date = Date()) -> Link? {
        mutate { links in
            guard let idx = links.firstIndex(where: { $0.slug == slug }) else { return nil }
            let link = links[idx]
            guard link.status(now: now) == .active else { return nil }
            if link.kind == .once {
                var consumed = link
                consumed.opens = 1
                consumed.consumedAt = now
                if deleteOnConsume {
                    links.remove(at: idx)
                } else {
                    links[idx] = consumed
                }
            } else {
                var updated = link
                updated.opens += 1
                links[idx] = updated
            }
            return link
        }
    }

    // MARK: - Sync location

    public func enableSync() throws {
        guard let target = StorageLocation.iCloudURL else { throw StoreError.iCloudUnavailable }
        try migrate(to: target)
    }

    public func disableSync() throws {
        try migrate(to: StorageLocation.localURL)
    }

    private func migrate(to dest: URL) throws {
        guard dest != fileURL else { return }
        let fm = FileManager.default
        try fm.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
        stopWatching()
        if fm.fileExists(atPath: fileURL.path) {
            if fm.fileExists(atPath: dest.path) { try? fm.removeItem(at: dest) }
            try fm.moveItem(at: fileURL, to: dest)
        }
        fileURL = dest
        startWatching()
    }

    // MARK: - File helpers

    private func readMerged(_ url: URL) -> [Link] {
        var versions: [[Link]] = []
        if let data = try? Data(contentsOf: url),
           let links = try? Self.decoder.decode([Link].self, from: data) {
            versions.append(links)
        }
        if let conflicts = NSFileVersion.unresolvedConflictVersionsOfItem(at: url) {
            for version in conflicts {
                if let data = try? Data(contentsOf: version.url),
                   let links = try? Self.decoder.decode([Link].self, from: data) {
                    versions.append(links)
                }
            }
        }
        switch versions.count {
        case 0: return []
        case 1: return versions[0]
        default: return ConflictMerge.merge(versions)
        }
    }

    private func writeAtomic(_ links: [Link], to url: URL) {
        guard let data = try? Self.encoder.encode(links) else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func ensureDirectory() {
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }

    // MARK: - Watching

    private func startWatching() {
        let dir = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fd = open(dir.path, O_EVTONLY)
        guard fd >= 0 else { return }
        dirFD = fd
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .rename, .delete, .extend],
            queue: queue
        )
        source.setEventHandler { [weak self] in self?.scheduleNotify() }
        source.setCancelHandler { [weak self] in
            guard let self else { return }
            if self.dirFD >= 0 { close(self.dirFD); self.dirFD = -1 }
        }
        dirSource = source
        source.resume()
    }

    private func stopWatching() {
        dirSource?.cancel()
        dirSource = nil
    }

    private func scheduleNotify() {
        debounceWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async { self?.changeHandler?() }
        }
        debounceWork = work
        queue.asyncAfter(deadline: .now() + 0.2, execute: work)
    }
}
