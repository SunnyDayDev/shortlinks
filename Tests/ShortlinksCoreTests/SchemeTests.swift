import XCTest
@testable import ShortlinksCore

final class SchemeTests: XCTestCase {
    func testURLForSlug() {
        XCTAssertEqual(Scheme.url(forSlug: "abc"), "sl://link/abc")
    }

    func testSlugFromCanonicalURL() {
        let url = URL(string: "sl://link/my-slug")!
        XCTAssertEqual(Scheme.slug(fromURL: url), "my-slug")
    }

    func testSlugFromNestedPath() {
        let url = URL(string: "sl://link/foo/bar")!
        XCTAssertEqual(Scheme.slug(fromURL: url), "foo/bar")
    }

    func testSlugFallbackWithoutLinkHost() {
        let url = URL(string: "sl://just-slug")!
        XCTAssertEqual(Scheme.slug(fromURL: url), "just-slug")
    }

    func testSlugRejectsForeignScheme() {
        XCTAssertNil(Scheme.slug(fromURL: URL(string: "https://link/abc")!))
    }

    func testSlugNilWhenEmpty() {
        XCTAssertNil(Scheme.slug(fromURL: URL(string: "sl://link/")!))
    }

    func testDetectTargetTypes() {
        XCTAssertEqual(Scheme.detect("https://example.com"), .web)
        XCTAssertEqual(Scheme.detect("HTTP://EXAMPLE.COM"), .web)
        XCTAssertEqual(Scheme.detect("file:///tmp/x"), .file)
        XCTAssertEqual(Scheme.detect("/Users/me/file.txt"), .file)
        XCTAssertEqual(Scheme.detect("things:///add"), .app)
        XCTAssertEqual(Scheme.detect("просто текст"), .text)
    }
}
