import SwiftUI
import AppKit
import CoreServices
import Observation
import ShortlinksCore

enum Filter: Equatable {
    case all, active, once, expired
    case tag(String)
}

enum Screen { case library, settings, how }
enum RedirectPhase { case ready, blocked, consumed }

/// Форма создания ссылки.
struct CreateForm {
    var target = ""
    var slug = ""
    var kind: LinkKind = .once
    var lifetime: Lifetime = .h24
    var passwordOn = false
    var password = ""
    var tags: [String] = []
    var tagInput = ""
}

@Observable
final class AppModel {
    static let shared = AppModel()

    private let store: LinkStore
    var links: [Link] = []

    var screen: Screen = .library
    var filter: Filter = .all
    var query = ""
    var selectedId: String?
    var showCreate = false
    var form = CreateForm()
    var toast: String?

    // Redirect overlay
    var redirectSlug: String?
    var redirectPhase: RedirectPhase = .ready
    var redirectNotFound = false
    var redirectPasswordInput = ""

    // Settings (persisted)
    var defKind: LinkKind { didSet { Prefs.defKind = defKind } }
    var defLifetime: Lifetime { didSet { Prefs.defLifetime = defLifetime } }
    var defPassword: Bool { didSet { Prefs.defPassword = defPassword } }
    var copyOnCreate: Bool { didSet { Prefs.copyOnCreate = copyOnCreate } }
    var deleteOnConsume: Bool { didSet { Prefs.deleteOnConsume = deleteOnConsume } }

    var syncEnabled: Bool = StorageLocation.isSyncEnabled
    var iCloudAvailable: Bool { StorageLocation.isICloudAvailable }

    private var toastTask: Task<Void, Never>?

    private init() {
        store = LinkStore()
        defKind = Prefs.defKind
        defLifetime = Prefs.defLifetime
        defPassword = Prefs.defPassword
        copyOnCreate = Prefs.copyOnCreate
        deleteOnConsume = Prefs.deleteOnConsume
        store.changeHandler = { [weak self] in self?.reload() }
        reload()
    }

    // MARK: - Derived

    func reload() { links = store.load() }

    var counts: (all: Int, active: Int, once: Int, expired: Int) {
        let now = Date()
        return (
            links.count,
            links.filter { $0.status(now: now) == .active }.count,
            links.filter { $0.kind == .once }.count,
            links.filter { let s = $0.status(now: now); return s == .expired || s == .viewed }.count
        )
    }

    var tagCounts: [(name: String, count: Int)] {
        var dict: [String: Int] = [:]
        for link in links { for t in link.tags { dict[t, default: 0] += 1 } }
        return dict.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }

    var filteredLinks: [Link] {
        let now = Date()
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return links.filter { link in
            switch filter {
            case .all: break
            case .active: if link.status(now: now) != .active { return false }
            case .once: if link.kind != .once { return false }
            case .expired:
                let s = link.status(now: now)
                if s != .expired && s != .viewed { return false }
            case .tag(let t): if !link.tags.contains(t) { return false }
            }
            if !q.isEmpty {
                let hit = link.slug.lowercased().contains(q)
                    || link.target.lowercased().contains(q)
                    || link.tags.contains { $0.contains(q) }
                if !hit { return false }
            }
            return true
        }
    }

    var selectedLink: Link? {
        guard let id = selectedId else { return nil }
        return links.first { $0.id == id }
    }

    var redirectLink: Link? {
        guard let slug = redirectSlug else { return nil }
        return links.first { $0.slug == slug }
    }

    var toolbarTitle: String {
        if let link = selectedLink { return link.fullURL }
        switch screen {
        case .settings: return "Настройки"
        case .how: return "Как это работает"
        case .library:
            switch filter {
            case .all: return "Все ссылки"
            case .active: return "Активные"
            case .once: return "Одноразовые"
            case .expired: return "Истёкшие"
            case .tag(let t): return "#\(t)"
            }
        }
    }

    // MARK: - Navigation

    func setFilter(_ f: Filter) { screen = .library; filter = f; selectedId = nil }
    func goScreen(_ s: Screen) { screen = s; selectedId = nil }
    func openDetail(_ id: String) { screen = .library; selectedId = id }
    func back() { selectedId = nil }

    // MARK: - Create

    func openCreate() {
        form = CreateForm(
            target: "",
            slug: Slug.generate(),
            kind: defKind,
            lifetime: defLifetime,
            passwordOn: defPassword,
            password: "",
            tags: [],
            tagInput: ""
        )
        showCreate = true
    }

    func regenSlug() { form.slug = Slug.generate() }

    func addTag() {
        let t = normTag(form.tagInput)
        guard !t.isEmpty else { return }
        if !form.tags.contains(t) { form.tags.append(t) }
        form.tagInput = ""
    }

    func removeTag(_ t: String) { form.tags.removeAll { $0 == t } }

    private func normTag(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespaces).lowercased()
            .replacingOccurrences(of: "[,/]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression)
    }

    func submitCreate() {
        let target = form.target.trimmingCharacters(in: .whitespaces)
        guard !target.isEmpty else { return }
        var tags = form.tags
        let pending = normTag(form.tagInput)
        if !pending.isEmpty && !tags.contains(pending) { tags.append(pending) }
        let slug = Slug.normalizeForSave(form.slug)
        let link = Link.make(
            target: target,
            slug: slug,
            kind: form.kind,
            lifetime: form.lifetime,
            password: form.passwordOn ? form.password : nil,
            tags: tags
        )
        store.add(link)
        reload()
        showCreate = false
        screen = .library
        filter = .all
        selectedId = link.id
        if copyOnCreate { copy(link.fullURL) }
    }

    func delete(id: String) {
        store.delete(id: id)
        reload()
        if selectedId == id { selectedId = nil }
    }

    // MARK: - Redirect

    func handleIncoming(_ url: URL) {
        guard let slug = Scheme.slug(fromURL: url) else { return }
        reload()
        redirectSlug = slug
        redirectPasswordInput = ""
        guard let link = links.first(where: { $0.slug == slug }) else {
            redirectNotFound = true
            redirectPhase = .blocked
            return
        }
        redirectNotFound = false
        redirectPhase = link.status() == .active ? .ready : .blocked
    }

    func confirmRedirect() {
        guard let slug = redirectSlug, let link = redirectLink else { return }
        if let hash = link.passwordHash {
            guard Password.verify(redirectPasswordInput, against: hash) else {
                flashToast("Неверный пароль")
                return
            }
        }
        guard let opened = store.consume(slug: slug, deleteOnConsume: deleteOnConsume) else {
            redirectPhase = .blocked
            reload()
            return
        }
        Opener.open(opened.target)
        reload()
        if opened.kind == .once {
            redirectPhase = .consumed
        } else {
            redirectSlug = nil
            flashToast("Переход выполнен")
        }
    }

    /// Показать оверлей перехода для существующей ссылки (кнопка «Открыть» в карточке).
    func presentRedirect(for link: Link) {
        redirectSlug = link.slug
        redirectPasswordInput = ""
        redirectNotFound = false
        redirectPhase = link.status() == .active ? .ready : .blocked
    }

    func closeRedirect() { redirectSlug = nil }

    // MARK: - Utilities

    func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        flashToast("Скопировано: \(text)")
    }

    func flashToast(_ text: String) {
        toast = text
        toastTask?.cancel()
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            if !Task.isCancelled { self.toast = nil }
        }
    }

    // MARK: - Sync

    func setSync(_ on: Bool) {
        do {
            if on { try store.enableSync() } else { try store.disableSync() }
            syncEnabled = StorageLocation.isSyncEnabled
            reload()
        } catch {
            syncEnabled = StorageLocation.isSyncEnabled
            flashToast("iCloud Drive недоступен")
        }
    }

    // MARK: - URL scheme handler

    var isDefaultHandler: Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        guard let handler = LSCopyDefaultHandlerForURLScheme(Scheme.name as CFString)?
            .takeRetainedValue() as String? else { return false }
        return handler.caseInsensitiveCompare(bundleID) == .orderedSame
    }

    func setDefaultHandler(_ on: Bool) {
        guard on, let bundleID = Bundle.main.bundleIdentifier else { return }
        LSSetDefaultHandlerForURLScheme(Scheme.name as CFString, bundleID as CFString)
    }
}

/// Настройки в `UserDefaults`.
enum Prefs {
    private static let d = UserDefaults.standard
    static var defKind: LinkKind {
        get { LinkKind(rawValue: d.string(forKey: "defKind") ?? "once") ?? .once }
        set { d.set(newValue.rawValue, forKey: "defKind") }
    }
    static var defLifetime: Lifetime {
        get { Lifetime(rawValue: d.string(forKey: "defLifetime") ?? "24h") ?? .h24 }
        set { d.set(newValue.rawValue, forKey: "defLifetime") }
    }
    static var defPassword: Bool {
        get { d.bool(forKey: "defPassword") }
        set { d.set(newValue, forKey: "defPassword") }
    }
    static var copyOnCreate: Bool {
        get { d.object(forKey: "copyOnCreate") == nil ? true : d.bool(forKey: "copyOnCreate") }
        set { d.set(newValue, forKey: "copyOnCreate") }
    }
    static var deleteOnConsume: Bool {
        get { d.bool(forKey: "deleteOnConsume") }
        set { d.set(newValue, forKey: "deleteOnConsume") }
    }
}
