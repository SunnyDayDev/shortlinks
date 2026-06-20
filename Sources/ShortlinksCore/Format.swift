import Foundation

/// Отображаемые строки (перенос текстовых хелперов из макета).
public enum Format {
    /// Русское склонение по числу: `forms = [одна, две, пять]`.
    public static func plural(_ n: Int, _ forms: [String]) -> String {
        let a = n % 10, b = n % 100
        if a == 1 && b != 11 { return forms[0] }
        if a >= 2 && a <= 4 && (b < 10 || b >= 20) { return forms[1] }
        return forms[2]
    }

    public static func opensText(_ n: Int) -> String {
        "\(n) " + plural(n, ["переход", "перехода", "переходов"])
    }

    public static func kindLabel(_ kind: LinkKind) -> String {
        kind == .once ? "Одноразовая" : "Многоразовая"
    }

    public static func statusLabel(_ status: LinkStatus) -> String {
        switch status {
        case .active: return "Активна"
        case .viewed: return "Просмотрена"
        case .disabled: return "Деактивирована"
        case .expired: return "Истекла"
        }
    }

    /// Текст срока действия для карточки.
    public static func expiresText(_ link: Link, now: Date = Date()) -> String {
        guard let expiresAt = link.expiresAt else { return "Без срока" }
        if expiresAt <= now { return "Истёк" }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ru_RU")
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: expiresAt)
    }

    /// Подпись-описание для строки списка.
    public static func subtitle(_ link: Link, now: Date = Date()) -> String {
        let kind = kindLabel(link.kind)
        switch link.status(now: now) {
        case .active:
            if link.kind == .once {
                if let e = link.expiresAt {
                    return "\(kind) · истекает \(shortExpiry(e, now: now))"
                }
                return "\(kind) · без срока"
            }
            return "\(kind) · \(opensText(link.opens))"
        case .viewed:
            return "\(kind) · потреблена"
        case .disabled:
            return "\(kind) · деактивирована"
        case .expired:
            return "\(kind) · срок истёк"
        }
    }

    private static func shortExpiry(_ date: Date, now: Date) -> String {
        let interval = date.timeIntervalSince(now)
        if interval <= 0 { return "скоро" }
        let hours = Int(interval / 3600)
        if hours < 1 { return "менее часа" }
        if hours < 24 { return "\(hours) \(plural(hours, ["час", "часа", "часов"]))" }
        let days = hours / 24
        return "\(days) \(plural(days, ["день", "дня", "дней"]))"
    }
}
