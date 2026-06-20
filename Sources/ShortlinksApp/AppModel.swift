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

/// Режим перехода по короткой ссылке.
enum RedirectMode: String { case instant, confirm }

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

    // Режим редактирования списка (множественный выбор)
    var editing = false
    var selection: Set<String> = []
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
    var redirectMode: RedirectMode { didSet { Prefs.redirectMode = redirectMode } }

    var syncEnabled: Bool = StorageLocation.isSyncEnabled
    var iCloudAvailable: Bool { StorageLocation.isICloudAvailable }

    // CLI (вложен в бандл, ставится симлинком в ~/.local/bin)
    private let cli = CLIInstaller.standard()
    var cliStatus: CLIInstallStatus = .notInstalled
    var cliShowPathHint = false
    var showCLIOnboarding = false
    var cliPathExportLine: String { cli.pathExportLine }

    /// Установлено сценой — открывает главное окно (для оверлея/подтверждения).
    var openMainWindow: (() -> Void)?

    private var toastTask: Task<Void, Never>?

    private init() {
        store = LinkStore()
        defKind = Prefs.defKind
        defLifetime = Prefs.defLifetime
        defPassword = Prefs.defPassword
        copyOnCreate = Prefs.copyOnCreate
        deleteOnConsume = Prefs.deleteOnConsume
        redirectMode = Prefs.redirectMode
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

    func setFilter(_ f: Filter) { screen = .library; filter = f; selectedId = nil; exitEditing() }
    func goScreen(_ s: Screen) { screen = s; selectedId = nil; exitEditing() }
    func openDetail(_ id: String) { screen = .library; selectedId = id }

    private func exitEditing() { editing = false; selection.removeAll() }
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
        withAnimation(.easeInOut(duration: 0.25)) {
            reload()
            if selectedId == id { selectedId = nil }
        }
    }

    // MARK: - Режим редактирования (множественный выбор)

    func toggleEditing() {
        editing.toggle()
        if !editing { selection.removeAll() }
    }

    func toggleSelect(_ id: String) {
        if selection.contains(id) { selection.remove(id) } else { selection.insert(id) }
    }

    var canDeleteSelected: Bool { !selection.isEmpty }

    func deleteSelected() {
        let ids = selection
        guard !ids.isEmpty else { return }
        store.delete(ids: ids)
        withAnimation(.easeInOut(duration: 0.25)) {
            reload()
            selection.removeAll()
            editing = false
            if let sel = selectedId, ids.contains(sel) { selectedId = nil }
        }
    }

    // MARK: - Деактивация / активация

    func deactivate(id: String) {
        store.setDisabled(id: id, true)
        reload()
    }

    func activate(id: String) {
        store.setDisabled(id: id, false)
        reload()
    }

    // MARK: - Redirect

    /// Точка входа для `sl://`. Возвращает `true`, если нужно показать окно/оверлей
    /// (подтверждение, пароль, ошибка); `false` — ссылка открыта в фоне.
    @discardableResult
    func handleIncoming(_ url: URL) -> Bool {
        guard let slug = Scheme.slug(fromURL: url) else { return false }
        reload()
        redirectPasswordInput = ""
        guard let link = links.first(where: { $0.slug == slug }) else {
            redirectSlug = slug
            redirectNotFound = true
            redirectPhase = .blocked
            return true
        }
        return route(link)
    }

    /// Открыть ссылку из интерфейса (кнопка «Открыть» в карточке).
    func openLink(_ link: Link) { _ = route(link) }

    /// Решает: открыть в фоне или показать оверлей. Пароль, недоступная и
    /// ненайденная ссылка всегда требуют оверлей.
    @discardableResult
    private func route(_ link: Link) -> Bool {
        redirectPasswordInput = ""
        redirectNotFound = false
        guard link.status() == .active else {
            redirectSlug = link.slug
            redirectPhase = .blocked
            return true
        }
        if link.isProtected || redirectMode == .confirm {
            redirectSlug = link.slug
            redirectPhase = .ready
            return true
        }
        performOpen(slug: link.slug)
        return false
    }

    /// Фоновое открытие: потребление + системное открытие цели, без оверлея.
    private func performOpen(slug: String) {
        guard let opened = store.consume(slug: slug, deleteOnConsume: deleteOnConsume) else { return }
        Opener.open(opened.target)
        reload()
        flashToast(opened.kind == .once ? "Открыто · ссылка сгорела" : "Переход выполнен")
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

    // MARK: - CLI

    /// Пересчитать статус CLI и необходимость подсказки про PATH.
    func refreshCLIStatus() {
        cliStatus = cli.status()
        if case .installed = cliStatus {
            cliShowPathHint = !cli.installDirOnPATH()
        } else {
            cliShowPathHint = false
        }
    }

    func installCLI() {
        do {
            try cli.install()
            refreshCLIStatus()
            flashToast("CLI установлен")
        } catch {
            flashToast("\(error)")
        }
    }

    func uninstallCLI() {
        do {
            try cli.uninstall()
            refreshCLIStatus()
            flashToast("CLI удалён")
        } catch {
            flashToast("\(error)")
        }
    }

    /// Один раз при первом запуске предлагает установить CLI, если он ещё не установлен.
    func maybeOfferCLIOnboarding() {
        guard !Prefs.cliOnboardingShown else { return }
        refreshCLIStatus()
        if case .installed = cliStatus {
            Prefs.cliOnboardingShown = true   // уже установлен — не предлагаем
            return
        }
        showCLIOnboarding = true
    }

    func acceptCLIOnboarding() {
        Prefs.cliOnboardingShown = true
        showCLIOnboarding = false
        installCLI()
    }

    func declineCLIOnboarding() {
        Prefs.cliOnboardingShown = true
        showCLIOnboarding = false
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
    static var redirectMode: RedirectMode {
        get { RedirectMode(rawValue: d.string(forKey: "redirectMode") ?? "instant") ?? .instant }
        set { d.set(newValue.rawValue, forKey: "redirectMode") }
    }
    static var cliOnboardingShown: Bool {
        get { d.bool(forKey: "cliOnboardingShown") }
        set { d.set(newValue, forKey: "cliOnboardingShown") }
    }
}
