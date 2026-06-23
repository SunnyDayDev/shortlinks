import Foundation

/// Слой локализации ShortlinksCore — переиспользуется приложением и CLI.
///
/// Пользовательские строки берутся из String Catalog (`Localizable.xcstrings`), который
/// собирается в ресурсы приложения (`<App>.app/Contents/Resources/<lang>.lproj`).
/// Встроенный в бандл CLI (`Contents/Helpers/shortlinks`) резолвит тот же каталог из
/// бандла приложения. Когда каталог недоступен (standalone-сборка CLI, юнит-тесты) —
/// строка отдаётся из значения-источника (`defaultValue`, русский). См. [[localization]].
///
/// Выбор языка (решение 4a дизайна), приоритет сверху вниз:
/// 1. `overrideLanguage` (CLI `--lang`);
/// 2. POSIX-переменные `LC_ALL` → `LC_MESSAGES` → `LANG`;
/// 3. системные предпочтения (`AppleLanguages`);
/// 4. язык-источник (фолбэк на `defaultValue`).
public enum Localization {
    /// Переопределение языка из CLI (`--lang`). Имеет наивысший приоритет.
    /// Устанавливается в точке входа CLI до первого обращения к строкам.
    public static var overrideLanguage: String?

    // MARK: - Бандл каталога

    /// Бандл, содержащий каталог: само приложение либо `.app`, в который вложен CLI.
    /// Для standalone-сборки/тестов вернётся `Bundle.main` без локализаций.
    private static let containerBundle: Bundle = {
        var url = Bundle.main.bundleURL
        while url.path != "/" {
            if url.pathExtension == "app", let bundle = Bundle(url: url) { return bundle }
            url.deleteLastPathComponent()
        }
        return .main
    }()

    /// Языковой `.lproj`-бандл для выбранного языка; `nil`, если каталог недоступен.
    /// Строки и склонения грузятся из конкретного `<lang>.lproj` — предсказуемо и без
    /// зависимости от кеша `preferredLocalizations`.
    static func lprojBundle() -> Bundle? {
        let available = containerBundle.localizations.filter { $0 != "Base" }
        guard !available.isEmpty else { return nil }
        let best = Bundle.preferredLocalizations(from: available, forPreferences: preferredLanguages()).first
            ?? containerBundle.developmentLocalization
        guard let lang = best,
              let path = containerBundle.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return nil }
        return bundle
    }

    // MARK: - Выбор языка (решение 4a)

    /// Предпочитаемые языки по приоритету: `--lang` → `LC_ALL`/`LC_MESSAGES`/`LANG`
    /// → системные предпочтения. `C`/`POSIX`/нераспознанное игнорируются.
    static func preferredLanguages() -> [String] {
        if let override = overrideLanguage, let code = languageCode(override) { return [code] }
        let env = ProcessInfo.processInfo.environment
        for key in ["LC_ALL", "LC_MESSAGES", "LANG"] {
            if let value = env[key], let code = languageCode(value) { return [code] }
        }
        return Locale.preferredLanguages
    }

    /// Язык из значения локали (`ru_RU.UTF-8` → `ru`); `nil` для `C`/`POSIX`/пустого.
    static func languageCode(_ value: String) -> String? {
        let beforeDot = value.split(separator: ".").first.map(String.init) ?? value
        let lang = beforeDot.split(whereSeparator: { $0 == "_" || $0 == "-" }).first.map(String.init) ?? beforeDot
        guard !lang.isEmpty,
              lang.caseInsensitiveCompare("C") != .orderedSame,
              lang.caseInsensitiveCompare("POSIX") != .orderedSame else { return nil }
        return lang.lowercased()
    }

    /// Локаль для форматтеров (даты/числа), согласованная с выбранным языком.
    public static var locale: Locale {
        Locale(identifier: preferredLanguages().first ?? "ru")
    }

    // MARK: - Доступ к строкам

    /// Локализованная строка с русским значением-источником по умолчанию.
    static func string(_ key: StaticString, _ defaultValue: String.LocalizationValue) -> String {
        String(localized: key, defaultValue: defaultValue, bundle: lprojBundle() ?? .main, locale: locale)
    }

    /// Локализованное склонение по числу из plural-правил каталога; `nil`, если
    /// каталог/ключ недоступны (тогда вызывающий применяет русский фолбэк).
    static func plural(_ key: String, _ n: Int) -> String? {
        guard let bundle = lprojBundle() else { return nil }
        let sentinel = "\u{1}"
        let format = bundle.localizedString(forKey: key, value: sentinel, table: nil)
        guard format != sentinel else { return nil }
        return String.localizedStringWithFormat(format, n)
    }
}
