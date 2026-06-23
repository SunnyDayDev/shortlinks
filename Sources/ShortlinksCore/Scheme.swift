import Foundation

/// Тип цели перехода — определяет иконку и подпись действия.
public enum TargetType: String, Sendable {
    case web
    case file
    case app
    case text

    /// Короткий код для бейджа (как в макете: web/doc/app/txt).
    public var code: String {
        switch self {
        case .web: return "web"
        case .file: return "doc"
        case .app: return "app"
        case .text: return "txt"
        }
    }

    public var openLabel: String {
        switch self {
        case .web: return Strings.Target.web
        case .file: return Strings.Target.file
        case .app: return Strings.Target.app
        case .text: return Strings.Target.text
        }
    }
}

public enum Scheme {
    /// Имя URL-схемы коротких ссылок.
    public static let name = "sl"

    public static func url(forSlug slug: String) -> String { "sl://link/\(slug)" }

    /// Извлечь slug из `sl://link/<slug>`; `nil`, если URL не подходит.
    public static func slug(fromURL url: URL) -> String? {
        guard url.scheme == name else { return nil }
        // sl://link/<slug...> — host = "link", path = "/<slug>"
        let host = url.host ?? ""
        var path = url.path
        if path.hasPrefix("/") { path.removeFirst() }
        if host == "link" {
            return path.isEmpty ? nil : path
        }
        // запасной разбор: sl://<slug>
        let combined = ([host] + [path]).filter { !$0.isEmpty }.joined(separator: "/")
        return combined.isEmpty ? nil : combined
    }

    /// Определить тип цели по строке (перенос `scheme()` из макета).
    public static func detect(_ target: String) -> TargetType {
        let s = target.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.range(of: "^https?:", options: [.regularExpression, .caseInsensitive]) != nil {
            return .web
        }
        if s.range(of: "^file:", options: [.regularExpression, .caseInsensitive]) != nil || s.hasPrefix("/") {
            return .file
        }
        if s.range(of: "://", options: .regularExpression) != nil {
            return .app
        }
        return .text
    }
}
