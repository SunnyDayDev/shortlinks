import ArgumentParser
import Foundation
import ShortlinksCore
#if canImport(AppKit)
import AppKit
#endif

@main
struct ShortlinksCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "shortlinks",
        abstract: "Локальные короткие ссылки sl://link/<slug>",
        subcommands: [Add.self, ListCmd.self, Remove.self, Open.self, Resolve.self]
    )
}

// MARK: - add

struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "add", abstract: "Создать короткую ссылку")

    @Argument(help: "Цель перехода: https://, file://, app-scheme:// или путь")
    var target: String

    @Option(help: "Короткий slug (по умолчанию случайный)")
    var slug: String?

    @Flag(help: "Одноразовая ссылка («сгорает» после первого перехода)")
    var once = false

    @Flag(help: "Многоразовая ссылка (по умолчанию)")
    var reuse = false

    @Option(help: "Срок действия: 1h | 24h | 7d | never")
    var ttl: String = "never"

    @Option(help: "Пароль, запрашиваемый перед переходом")
    var password: String?

    @Option(name: [.customShort("g"), .long], help: "Тег (можно повторять)")
    var tag: [String] = []

    func run() throws {
        if once && reuse {
            throw ValidationError("Укажите только один из флагов --once / --reuse")
        }
        guard let lifetime = Lifetime(rawValue: ttl) else {
            throw ValidationError("Некорректный --ttl. Допустимо: 1h, 24h, 7d, never")
        }
        let kind: LinkKind = once ? .once : .reuse
        let finalSlug = Slug.normalizeForSave(slug ?? Slug.generate())
        let link = Link.make(
            target: target,
            slug: finalSlug,
            kind: kind,
            lifetime: lifetime,
            password: password,
            tags: tag
        )
        LinkStore(watch: false).add(link)
        print(link.fullURL)
    }
}

// MARK: - list

struct ListCmd: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "list", abstract: "Показать ссылки")

    @Option(help: "Фильтр: all | active | once | expired")
    var filter: String = "all"

    @Option(help: "Только с этим тегом")
    var tag: String?

    func run() {
        let now = Date()
        var links = LinkStore(watch: false).load()
        if let tag {
            links = links.filter { $0.tags.contains(tag) }
        }
        switch filter {
        case "active": links = links.filter { $0.status(now: now) == .active }
        case "once": links = links.filter { $0.kind == .once }
        case "expired": links = links.filter { let s = $0.status(now: now); return s == .expired || s == .viewed }
        default: break
        }
        if links.isEmpty {
            print("Ссылок нет.")
            return
        }
        for link in links {
            let status = Format.statusLabel(link.status(now: now))
            let kind = link.kind == .once ? "once " : "reuse"
            print("\(link.fullURL)  [\(kind) · \(status)]  → \(link.target)")
        }
    }
}

// MARK: - rm

struct Remove: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "rm", abstract: "Удалить ссылку по slug")

    @Argument(help: "slug ссылки")
    var slug: String

    func run() throws {
        let removed = LinkStore(watch: false).delete(slug: slug)
        if removed {
            print("Удалено: \(Scheme.url(forSlug: slug))")
        } else {
            throw CLIError.notFound(slug)
        }
    }
}

// MARK: - resolve

struct Resolve: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "resolve", abstract: "Напечатать цель ссылки")

    @Argument(help: "slug ссылки")
    var slug: String

    func run() throws {
        guard let link = LinkStore(watch: false).resolve(slug: slug) else {
            throw CLIError.notFound(slug)
        }
        print(link.target)
    }
}

// MARK: - open

struct Open: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "open", abstract: "Открыть цель ссылки")

    @Argument(help: "slug ссылки")
    var slug: String

    @Option(help: "Пароль, если ссылка защищена")
    var password: String?

    @Flag(help: "Удалить одноразовую сразу после перехода")
    var deleteOnConsume = false

    func run() throws {
        let store = LinkStore(watch: false)
        guard let link = store.resolve(slug: slug) else { throw CLIError.notFound(slug) }
        guard link.status() == .active else { throw CLIError.unavailable }
        if let hash = link.passwordHash {
            guard let password, Password.verify(password, against: hash) else {
                throw CLIError.passwordRequired
            }
        }
        guard let opened = store.consume(slug: slug, deleteOnConsume: deleteOnConsume) else {
            throw CLIError.unavailable
        }
        openTarget(opened.target)
    }

    private func openTarget(_ target: String) {
        #if canImport(AppKit)
        if let url = URL(string: target), url.scheme != nil {
            NSWorkspace.shared.open(url)
        } else if target.hasPrefix("/") {
            NSWorkspace.shared.open(URL(fileURLWithPath: target))
        } else {
            print(target)
        }
        #else
        print(target)
        #endif
    }
}

// MARK: - errors

enum CLIError: Error, CustomStringConvertible {
    case notFound(String)
    case unavailable
    case passwordRequired

    var description: String {
        switch self {
        case .notFound(let slug): return "Ссылка не найдена: \(slug)"
        case .unavailable: return "Ссылка недоступна (истекла или уже потреблена)"
        case .passwordRequired: return "Требуется верный --password"
        }
    }
}
