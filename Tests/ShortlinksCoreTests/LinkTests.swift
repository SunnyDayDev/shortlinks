import XCTest
@testable import ShortlinksCore

final class LinkTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_000_000)

    func testStatusActive() {
        let link = Link.make(target: "https://a", slug: "s", kind: .reuse, lifetime: .never, now: t0)
        XCTAssertEqual(link.status(now: t0), .active)
    }

    func testStatusExpired() {
        let link = Link.make(target: "https://a", slug: "s", kind: .reuse, lifetime: .h1, now: t0)
        XCTAssertEqual(link.status(now: t0.addingTimeInterval(3601)), .expired)
        XCTAssertEqual(link.status(now: t0.addingTimeInterval(3599)), .active)
    }

    func testStatusViewedWhenConsumed() {
        var link = Link.make(target: "https://a", slug: "s", kind: .once, lifetime: .never, now: t0)
        link.consumedAt = t0
        XCTAssertEqual(link.status(now: t0), .viewed)
    }

    func testStatusDisabledWhenDisabledAtSet() {
        var link = Link.make(target: "https://a", slug: "s", kind: .reuse, lifetime: .never, now: t0)
        link.disabledAt = t0
        XCTAssertEqual(link.status(now: t0), .disabled)
    }

    func testStatusPriorityViewedOverDisabledOverExpired() {
        // Деактивация имеет приоритет над истечением.
        var expiredAndDisabled = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .h1, now: t0)
        expiredAndDisabled.disabledAt = t0
        XCTAssertEqual(expiredAndDisabled.status(now: t0.addingTimeInterval(7200)), .disabled)

        // Потребление одноразовой имеет приоритет над деактивацией.
        var viewedAndDisabled = Link.make(target: "x", slug: "s", kind: .once, lifetime: .never, now: t0)
        viewedAndDisabled.consumedAt = t0
        viewedAndDisabled.disabledAt = t0
        XCTAssertEqual(viewedAndDisabled.status(now: t0), .viewed)
    }

    func testDecodesLegacyJSONWithoutDisabledAt() throws {
        // Старый формат записи без поля disabledAt читается как не деактивированная.
        let json = """
        {"id":"n1","slug":"s","target":"https://a","kind":"reuse","opens":0,
         "createdAt":"1970-01-12T13:46:40Z","tags":[]}
        """
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        let link = try decoder.decode(Link.self, from: Data(json.utf8))
        XCTAssertNil(link.disabledAt)
        XCTAssertEqual(link.status(now: t0), .active)
    }

    func testMakeComputesExpiresFromLifetime() {
        let link = Link.make(target: "https://a", slug: "s", kind: .once, lifetime: .h24, now: t0)
        XCTAssertEqual(link.expiresAt, t0.addingTimeInterval(86_400))
    }

    func testMakeNeverHasNoExpiry() {
        let link = Link.make(target: "https://a", slug: "s", kind: .once, lifetime: .never, now: t0)
        XCTAssertNil(link.expiresAt)
    }

    func testMakeHashesNonEmptyPasswordOnly() {
        let withPwd = Link.make(target: "x", slug: "s", kind: .once, lifetime: .never, password: "p", now: t0)
        XCTAssertNotNil(withPwd.passwordHash)
        XCTAssertTrue(withPwd.isProtected)

        let emptyPwd = Link.make(target: "x", slug: "s", kind: .once, lifetime: .never, password: "", now: t0)
        XCTAssertNil(emptyPwd.passwordHash)

        let noPwd = Link.make(target: "x", slug: "s", kind: .once, lifetime: .never, now: t0)
        XCTAssertNil(noPwd.passwordHash)
    }

    func testLifetimeSeconds() {
        XCTAssertEqual(Lifetime.h1.seconds, 3600)
        XCTAssertEqual(Lifetime.h24.seconds, 86_400)
        XCTAssertEqual(Lifetime.d7.seconds, 604_800)
        XCTAssertNil(Lifetime.never.seconds)
    }

    func testCodableRoundTrip() throws {
        let link = Link.make(target: "https://a", slug: "s", kind: .once, lifetime: .h24, tags: ["x"], now: t0)
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Link.self, from: encoder.encode(link))
        XCTAssertEqual(decoded, link)
    }

    func testNoteRoundTrip() throws {
        let link = Link.make(target: "https://a", slug: "s", kind: .reuse,
                             lifetime: .never, note: "Бриф по дизайну", now: t0)
        XCTAssertEqual(link.note, "Бриф по дизайну")
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Link.self, from: encoder.encode(link))
        XCTAssertEqual(decoded.note, "Бриф по дизайну")
        XCTAssertEqual(decoded, link)
    }

    func testDecodesLegacyJSONWithoutNote() throws {
        // Старый формат без поля note читается как ссылка без описания.
        let json = """
        {"id":"n1","slug":"s","target":"https://a","kind":"reuse","opens":0,
         "createdAt":"1970-01-12T13:46:40Z","tags":[]}
        """
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        let link = try decoder.decode(Link.self, from: Data(json.utf8))
        XCTAssertNil(link.note)
    }

    func testMakeTrimsAndNilsEmptyNote() {
        let blank = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .never, note: "   \n ", now: t0)
        XCTAssertNil(blank.note)

        let padded = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .never, note: "  привет  ", now: t0)
        XCTAssertEqual(padded.note, "привет")

        let none = Link.make(target: "x", slug: "s", kind: .reuse, lifetime: .never, now: t0)
        XCTAssertNil(none.note)
    }
}
