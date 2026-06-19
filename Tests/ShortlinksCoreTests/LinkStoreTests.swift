import XCTest
@testable import ShortlinksCore

final class LinkStoreTests: XCTestCase {
    private var dir: URL!
    private var store: LinkStore!
    private let t0 = Date(timeIntervalSince1970: 1_000_000)

    override func setUpWithError() throws {
        dir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("linkstore-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        store = LinkStore(fileURL: dir.appendingPathComponent("links.json"), watch: false)
    }

    override func tearDownWithError() throws {
        store = nil
        try? FileManager.default.removeItem(at: dir)
    }

    private func make(_ slug: String, kind: LinkKind = .reuse, lifetime: Lifetime = .never) -> Link {
        Link.make(target: "https://\(slug)", slug: slug, kind: kind, lifetime: lifetime, now: t0)
    }

    func testAddAndResolve() {
        store.add(make("a"))
        store.add(make("b"))
        XCTAssertEqual(store.load().count, 2)
        XCTAssertEqual(store.resolve(slug: "a")?.target, "https://a")
        XCTAssertNil(store.resolve(slug: "missing"))
    }

    func testWritesOnlyToProvidedFile() {
        store.add(make("a"))
        let file = dir.appendingPathComponent("links.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
        // Реальное хранилище пользователя не задействовано.
        XCTAssertNotEqual(file.path, StorageLocation.current().path)
    }

    func testDeleteById() {
        let link = make("a")
        store.add(link)
        store.delete(id: link.id)
        XCTAssertEqual(store.load().count, 0)
    }

    func testDeleteBySlug() {
        store.add(make("a"))
        XCTAssertTrue(store.delete(slug: "a"))
        XCTAssertFalse(store.delete(slug: "a"))                 // уже нет
        XCTAssertEqual(store.load().count, 0)
    }

    func testConsumeOnceMarksViewedAndIsSingleUse() {
        store.add(make("once", kind: .once))
        let opened = store.consume(slug: "once", deleteOnConsume: false, now: t0)
        XCTAssertEqual(opened?.slug, "once")
        XCTAssertEqual(store.resolve(slug: "once")?.status(now: t0), .viewed)
        // Повторное потребление недоступно.
        XCTAssertNil(store.consume(slug: "once", deleteOnConsume: false, now: t0))
    }

    func testConsumeOnceWithDeleteRemoves() {
        store.add(make("once", kind: .once))
        _ = store.consume(slug: "once", deleteOnConsume: true, now: t0)
        XCTAssertNil(store.resolve(slug: "once"))
        XCTAssertEqual(store.load().count, 0)
    }

    func testConsumeReuseIncrementsOpens() {
        store.add(make("reuse", kind: .reuse))
        _ = store.consume(slug: "reuse", deleteOnConsume: false, now: t0)
        _ = store.consume(slug: "reuse", deleteOnConsume: false, now: t0)
        XCTAssertEqual(store.resolve(slug: "reuse")?.opens, 2)
        XCTAssertEqual(store.resolve(slug: "reuse")?.status(now: t0), .active)
    }

    func testConsumeExpiredReturnsNil() {
        store.add(make("exp", kind: .reuse, lifetime: .h1))
        let later = t0.addingTimeInterval(7200)
        XCTAssertNil(store.consume(slug: "exp", deleteOnConsume: false, now: later))
    }

    func testConsumeMissingReturnsNil() {
        XCTAssertNil(store.consume(slug: "nope", deleteOnConsume: false, now: t0))
    }
}
