import Foundation

/// Тип ссылки: одноразовая («сгорает» после первого перехода) или многоразовая.
public enum LinkKind: String, Codable, Sendable, CaseIterable {
    case once
    case reuse
}

/// Вычисляемый статус ссылки.
public enum LinkStatus: String, Sendable {
    case active   // доступна для перехода
    case viewed   // одноразовая, уже потреблена («сгорела»)
    case disabled // вручную деактивирована пользователем
    case expired  // истёк срок действия
}

/// Срок жизни новой ссылки.
public enum Lifetime: String, Codable, Sendable, CaseIterable {
    case h1 = "1h"
    case h24 = "24h"
    case d7 = "7d"
    case never = "never"

    /// Длительность в секундах; `nil` — без срока.
    public var seconds: TimeInterval? {
        switch self {
        case .h1: return 3600
        case .h24: return 86_400
        case .d7: return 604_800
        case .never: return nil
        }
    }
}

/// Короткая ссылка. Сериализуется в `links.json`.
public struct Link: Codable, Identifiable, Sendable, Hashable {
    public var id: String
    public var slug: String
    public var target: String
    public var kind: LinkKind
    public var opens: Int
    public var createdAt: Date
    public var expiresAt: Date?       // nil = без срока
    public var consumedAt: Date?      // проставляется при потреблении одноразовой
    public var passwordHash: String?  // формат "salt:hex(sha256(salt+password))"
    public var tags: [String]
    public var disabledAt: Date?      // момент ручной деактивации; nil = активна

    public init(
        id: String,
        slug: String,
        target: String,
        kind: LinkKind,
        opens: Int = 0,
        createdAt: Date,
        expiresAt: Date? = nil,
        consumedAt: Date? = nil,
        passwordHash: String? = nil,
        tags: [String] = [],
        disabledAt: Date? = nil
    ) {
        self.id = id
        self.slug = slug
        self.target = target
        self.kind = kind
        self.opens = opens
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.consumedAt = consumedAt
        self.passwordHash = passwordHash
        self.tags = tags
        self.disabledAt = disabledAt
    }

    /// Статус относительно момента `now`. Приоритет: потреблена → деактивирована →
    /// истекла → активна.
    public func status(now: Date = Date()) -> LinkStatus {
        if consumedAt != nil { return .viewed }
        if disabledAt != nil { return .disabled }
        if let expiresAt, expiresAt <= now { return .expired }
        return .active
    }

    public var isProtected: Bool { passwordHash != nil }
    public var fullURL: String { Scheme.url(forSlug: slug) }

    /// Фабрика новой ссылки с вычислением `expiresAt` из срока жизни.
    public static func make(
        target: String,
        slug: String,
        kind: LinkKind,
        lifetime: Lifetime,
        password: String? = nil,
        tags: [String] = [],
        now: Date = Date()
    ) -> Link {
        let expires = lifetime.seconds.map { now.addingTimeInterval($0) }
        let hash = password.flatMap { $0.isEmpty ? nil : Password.hash($0) }
        return Link(
            id: "n" + String(Int(now.timeIntervalSince1970 * 1000)),
            slug: slug,
            target: target,
            kind: kind,
            opens: 0,
            createdAt: now,
            expiresAt: expires,
            consumedAt: nil,
            passwordHash: hash,
            tags: tags
        )
    }
}
