import XCTest
@testable import ShortlinksCore

/// Тесты слоя локализации: выбор языка (решение 4a), русский фолбэк строк/склонений
/// при отсутствии каталога (как в юнит-среде и standalone-CLI).
final class LocalizationTests: XCTestCase {

    override func tearDown() {
        Localization.overrideLanguage = nil   // не протекать между тестами
        super.tearDown()
    }

    // MARK: - POSIX → язык-код

    func testLanguageCodeFromPOSIXValue() {
        XCTAssertEqual(Localization.languageCode("ru_RU.UTF-8"), "ru")
        XCTAssertEqual(Localization.languageCode("en_US.UTF-8"), "en")
        XCTAssertEqual(Localization.languageCode("en-GB"), "en")
        XCTAssertEqual(Localization.languageCode("ru"), "ru")
        XCTAssertEqual(Localization.languageCode("RU"), "ru")   // нормализуется в нижний регистр
    }

    func testLanguageCodeIgnoresCAndPOSIX() {
        XCTAssertNil(Localization.languageCode("C"))
        XCTAssertNil(Localization.languageCode("POSIX"))
        XCTAssertNil(Localization.languageCode(""))
    }

    // MARK: - Приоритет выбора языка

    func testOverrideLanguageHasTopPriority() {
        Localization.overrideLanguage = "en"
        XCTAssertEqual(Localization.preferredLanguages().first, "en")
    }

    func testInvalidOverrideIsIgnored() {
        // `C`/`POSIX` как override игнорируются — список не начинается с них.
        Localization.overrideLanguage = "C"
        let langs = Localization.preferredLanguages()
        XCTAssertFalse(langs.isEmpty)
        XCTAssertNotEqual(langs.first?.lowercased(), "c")
    }

    func testLocaleNeverCrashes() {
        Localization.overrideLanguage = "ru"
        XCTAssertEqual(Localization.locale.identifier, "ru")
        Localization.overrideLanguage = nil
        XCTAssertFalse(Localization.locale.identifier.isEmpty)
    }

    // MARK: - Фолбэк без каталога

    func testPluralReturnsNilWithoutCatalog() {
        // В юнит-среде каталога нет → каталожный резолвер возвращает nil,
        // а вызывающий применяет русский фолбэк (см. ниже).
        XCTAssertNil(Localization.plural("opens.count", 5))
    }

    func testStringFallsBackToRussianDefault() {
        XCTAssertEqual(Strings.Common.cancel, "Отмена")
        XCTAssertEqual(Strings.Status.active, "Активна")
        XCTAssertEqual(Strings.CLI.listEmpty, "Ссылок нет.")
    }

    // MARK: - Склонения (русский фолбэк)

    func testOpensCountPluralForms() {
        XCTAssertEqual(Strings.opensCount(1), "1 переход")
        XCTAssertEqual(Strings.opensCount(2), "2 перехода")
        XCTAssertEqual(Strings.opensCount(5), "5 переходов")
        XCTAssertEqual(Strings.opensCount(11), "11 переходов")   // исключение 11–14
        XCTAssertEqual(Strings.opensCount(21), "21 переход")
        XCTAssertEqual(Strings.opensCount(101), "101 переход")
    }

    func testExpiryPluralForms() {
        XCTAssertEqual(Strings.Expiry.hours(2), "2 часа")
        XCTAssertEqual(Strings.Expiry.hours(5), "5 часов")
        XCTAssertEqual(Strings.Expiry.days(1), "1 день")
        XCTAssertEqual(Strings.Expiry.days(5), "5 дней")
    }

    func testDeleteConfirmPluralForms() {
        XCTAssertEqual(Strings.Main.deleteConfirm(1), "Удалить 1 ссылку?")
        XCTAssertEqual(Strings.Main.deleteConfirm(2), "Удалить 2 ссылки?")
        XCTAssertEqual(Strings.Main.deleteConfirm(5), "Удалить 5 ссылок?")
    }
}
