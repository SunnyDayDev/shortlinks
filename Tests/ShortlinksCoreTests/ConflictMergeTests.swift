import XCTest
@testable import ShortlinksCore

final class ConflictMergeTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_000_000)

    private func link(
        _ id: String, createdAt: Date, opens: Int = 0, consumedAt: Date? = nil
    ) -> Link {
        Link(id: id, slug: id, target: "https://\(id)", kind: .reuse,
             opens: opens, createdAt: createdAt, consumedAt: consumedAt)
    }

    func testMergeUnionsDistinctIds() {
        let v1 = [link("a", createdAt: t0)]
        let v2 = [link("b", createdAt: t0.addingTimeInterval(10))]
        let merged = ConflictMerge.merge([v1, v2])
        XCTAssertEqual(Set(merged.map { $0.id }), ["a", "b"])
    }

    func testMergeOrdersByCreatedAtDescending() {
        let older = link("a", createdAt: t0)
        let newer = link("b", createdAt: t0.addingTimeInterval(100))
        let merged = ConflictMerge.merge([[older], [newer]])
        XCTAssertEqual(merged.map { $0.id }, ["b", "a"])         // новые сверху
    }

    func testResolveViewedBeatsActive() {
        let active = link("a", createdAt: t0, opens: 5)
        let viewed = link("a", createdAt: t0, consumedAt: t0)
        let merged = ConflictMerge.merge([[active], [viewed]])
        XCTAssertEqual(merged.count, 1)
        XCTAssertNotNil(merged[0].consumedAt)
    }

    func testResolveEarlierConsumedWins() {
        let early = link("a", createdAt: t0, consumedAt: t0)
        let late = link("a", createdAt: t0, consumedAt: t0.addingTimeInterval(50))
        let merged = ConflictMerge.merge([[late], [early]])
        XCTAssertEqual(merged[0].consumedAt, t0)
    }

    func testResolveActiveMoreOpensWins() {
        let few = link("a", createdAt: t0, opens: 1)
        let many = link("a", createdAt: t0, opens: 9)
        let merged = ConflictMerge.merge([[few], [many]])
        XCTAssertEqual(merged[0].opens, 9)
    }

    func testMergeEmpty() {
        XCTAssertEqual(ConflictMerge.merge([]).count, 0)
        XCTAssertEqual(ConflictMerge.merge([[]]).count, 0)
    }

    func testResolvePreservesNoteOfWinner() {
        // Слияние идёт целой записью по id: победитель (больше переходов) сохраняет своё описание.
        let few = Link(id: "a", slug: "a", target: "https://a", kind: .reuse,
                       opens: 1, createdAt: t0, note: "мало")
        let many = Link(id: "a", slug: "a", target: "https://a", kind: .reuse,
                        opens: 9, createdAt: t0, note: "много")
        let merged = ConflictMerge.merge([[few], [many]])
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].note, "много")
    }
}
