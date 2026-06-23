import Foundation

/// Отображаемые строки: композиция поверх реестра `Strings`. Сырых пользовательских
/// литералов здесь нет — только логика сборки из локализованных кусков.
public enum Format {
    /// Русское склонение по числу: `forms = [одна, две, пять]`. Используется как фолбэк
    /// для plural-ключей каталога, когда каталог недоступен (см. `Strings`/`Localization`).
    public static func plural(_ n: Int, _ forms: [String]) -> String {
        let a = n % 10, b = n % 100
        if a == 1 && b != 11 { return forms[0] }
        if a >= 2 && a <= 4 && (b < 10 || b >= 20) { return forms[1] }
        return forms[2]
    }

    public static func opensText(_ n: Int) -> String { Strings.opensCount(n) }

    public static func kindLabel(_ kind: LinkKind) -> String {
        kind == .once ? Strings.Kind.once : Strings.Kind.reuse
    }

    public static func statusLabel(_ status: LinkStatus) -> String {
        switch status {
        case .active: return Strings.Status.active
        case .viewed: return Strings.Status.viewed
        case .disabled: return Strings.Status.disabled
        case .expired: return Strings.Status.expired
        }
    }

    /// Дата/время в текущей локали (согласована с языком интерфейса — см. `Localization.locale`).
    public static func dateTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Localization.locale
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }

    /// Текст срока действия для карточки.
    public static func expiresText(_ link: Link, now: Date = Date()) -> String {
        guard let expiresAt = link.expiresAt else { return Strings.Expiry.none }
        if expiresAt <= now { return Strings.Expiry.expired }
        return dateTime(expiresAt)
    }

    /// Подпись-описание для строки списка.
    public static func subtitle(_ link: Link, now: Date = Date()) -> String {
        let kind = kindLabel(link.kind)
        switch link.status(now: now) {
        case .active:
            if link.kind == .once {
                if let e = link.expiresAt {
                    return Strings.Subtitle.onceExpires(kind, shortExpiry(e, now: now))
                }
                return Strings.Subtitle.onceNoExpiry(kind)
            }
            return Strings.Subtitle.reuse(kind, opensText(link.opens))
        case .viewed:
            return Strings.Subtitle.viewed(kind)
        case .disabled:
            return Strings.Subtitle.disabled(kind)
        case .expired:
            return Strings.Subtitle.expired(kind)
        }
    }

    private static func shortExpiry(_ date: Date, now: Date) -> String {
        let interval = date.timeIntervalSince(now)
        if interval <= 0 { return Strings.Expiry.soon }
        let hours = Int(interval / 3600)
        if hours < 1 { return Strings.Expiry.lessThanHour }
        if hours < 24 { return Strings.Expiry.hours(hours) }
        let days = hours / 24
        return Strings.Expiry.days(days)
    }
}
