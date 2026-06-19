import XCTest
@testable import ShortlinksCore

final class FormatTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_000_000)
    private let forms = ["переход", "перехода", "переходов"]

    func testPluralRussianRules() {
        XCTAssertEqual(Format.plural(1, forms), "переход")
        XCTAssertEqual(Format.plural(2, forms), "перехода")
        XCTAssertEqual(Format.plural(4, forms), "перехода")
        XCTAssertEqual(Format.plural(5, forms), "переходов")
        XCTAssertEqual(Format.plural(11, forms), "переходов")   // исключение
        XCTAssertEqual(Format.plural(21, forms), "переход")
        XCTAssertEqual(Format.plural(112, forms), "переходов")
        XCTAssertEqual(Format.plural(0, forms), "переходов")
    }

    func testOpensText() {
        XCTAssertEqual(Format.opensText(1), "1 переход")
        XCTAssertEqual(Format.opensText(3), "3 перехода")
    }

    func testKindAndStatusLabels() {
        XCTAssertEqual(Format.kindLabel(.once), "Одноразовая")
        XCTAssertEqual(Format.kindLabel(.reuse), "Многоразовая")
        XCTAssertEqual(Format.statusLabel(.active), "Активна")
        XCTAssertEqual(Format.statusLabel(.viewed), "Просмотрена")
        XCTAssertEqual(Format.statusLabel(.expired), "Истекла")
    }

    func testExpiresTextNeverAndPast() {
        let never = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .never, now: t0)
        XCTAssertEqual(Format.expiresText(never, now: t0), "Без срока")

        let expired = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .h1, now: t0)
        XCTAssertEqual(Format.expiresText(expired, now: t0.addingTimeInterval(7200)), "Истёк")
    }

    func testSubtitleVariants() {
        let reuse = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .never, now: t0)
        XCTAssertEqual(Format.subtitle(reuse, now: t0), "Многоразовая · 0 переходов")

        let onceNoExpiry = Link.make(target: "x", slug: "s", kind: .once, lifetime: .never, now: t0)
        XCTAssertEqual(Format.subtitle(onceNoExpiry, now: t0), "Одноразовая · без срока")

        var consumed = Link.make(target: "x", slug: "s", kind: .once, lifetime: .never, now: t0)
        consumed.consumedAt = t0
        XCTAssertEqual(Format.subtitle(consumed, now: t0), "Одноразовая · потреблена")

        let expired = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .h1, now: t0)
        XCTAssertEqual(Format.subtitle(expired, now: t0.addingTimeInterval(7200)), "Многоразовая · срок истёк")
    }

    func testSubtitleOnceWithExpiryMentionsHours() {
        let once = Link.make(target: "x", slug: "s", kind: .once, lifetime: .h24, now: t0)
        let text = Format.subtitle(once, now: t0)
        XCTAssertTrue(text.hasPrefix("Одноразовая · истекает "), text)
    }
}
