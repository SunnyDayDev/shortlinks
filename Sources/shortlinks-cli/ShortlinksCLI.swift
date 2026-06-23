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
        abstract: Strings.CLI.rootAbstract,
        subcommands: [Add.self, ListCmd.self, Remove.self, Open.self, Resolve.self]
    )
}

/// Глобальные опции всех подкоманд. `--lang <code>` переопределяет язык вывода (выше
/// приоритетом, чем `LANG`/`LC_*`/системные предпочтения). Применяется при разборе,
/// до выполнения команды. См. `Localization` (решение 4a).
struct GlobalOptions: ParsableArguments {
    @Option(name: .long, help: ArgumentHelp(Strings.CLI.langHelp, valueName: "code"))
    var lang: String?

    func validate() throws {
        if let lang { Localization.overrideLanguage = lang }
    }
}

// MARK: - add

struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "add", abstract: Strings.CLI.addAbstract)

    @OptionGroup var global: GlobalOptions

    @Argument(help: ArgumentHelp(Strings.CLI.addTarget))
    var target: String

    @Option(help: ArgumentHelp(Strings.CLI.addSlug))
    var slug: String?

    @Flag(help: ArgumentHelp(Strings.CLI.addOnce))
    var once = false

    @Flag(help: ArgumentHelp(Strings.CLI.addReuse))
    var reuse = false

    @Option(help: ArgumentHelp(Strings.CLI.addTTL))
    var ttl: String = "never"

    @Option(help: ArgumentHelp(Strings.CLI.addPassword))
    var password: String?

    @Option(name: [.customShort("g"), .long], help: ArgumentHelp(Strings.CLI.addTag))
    var tag: [String] = []

    func run() throws {
        if once && reuse {
            throw ValidationError(Strings.CLI.errBothFlags)
        }
        guard let lifetime = Lifetime(rawValue: ttl) else {
            throw ValidationError(Strings.CLI.errTTL)
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
    static let configuration = CommandConfiguration(commandName: "list", abstract: Strings.CLI.listAbstract)

    @OptionGroup var global: GlobalOptions

    @Option(help: ArgumentHelp(Strings.CLI.listFilter))
    var filter: String = "all"

    @Option(help: ArgumentHelp(Strings.CLI.listTag))
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
            print(Strings.CLI.listEmpty)
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
    static let configuration = CommandConfiguration(commandName: "rm", abstract: Strings.CLI.rmAbstract)

    @OptionGroup var global: GlobalOptions

    @Argument(help: ArgumentHelp(Strings.CLI.slugHelp))
    var slug: String

    func run() throws {
        let removed = LinkStore(watch: false).delete(slug: slug)
        if removed {
            print(Strings.CLI.removed(Scheme.url(forSlug: slug)))
        } else {
            throw CLIError.notFound(slug)
        }
    }
}

// MARK: - resolve

struct Resolve: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "resolve", abstract: Strings.CLI.resolveAbstract)

    @OptionGroup var global: GlobalOptions

    @Argument(help: ArgumentHelp(Strings.CLI.slugHelp))
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
    static let configuration = CommandConfiguration(commandName: "open", abstract: Strings.CLI.openAbstract)

    @OptionGroup var global: GlobalOptions

    @Argument(help: ArgumentHelp(Strings.CLI.slugHelp))
    var slug: String

    @Option(help: ArgumentHelp(Strings.CLI.openPassword))
    var password: String?

    @Flag(help: ArgumentHelp(Strings.CLI.openDeleteOnConsume))
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
        case .notFound(let slug): return Strings.CLI.errNotFound(slug)
        case .unavailable: return Strings.CLI.errUnavailable
        case .passwordRequired: return Strings.CLI.errPasswordRequired
        }
    }
}
