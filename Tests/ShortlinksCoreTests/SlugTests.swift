import XCTest
@testable import ShortlinksCore

final class SlugTests: XCTestCase {
    func testCleanLowercasesAndReplacesInvalid() {
        XCTAssertEqual(Slug.clean("Hello World!"), "hello-world-")
        XCTAssertEqual(Slug.clean("a@b.c"), "a-b-c")          // каждый недопустимый символ → `-`
    }

    func testCleanCollapsesSlashesAndTrimsLeading() {
        XCTAssertEqual(Slug.clean("//foo///bar"), "foo/bar")
        XCTAssertEqual(Slug.clean("/leading"), "leading")
    }

    func testCleanKeepsAllowedChars() {
        XCTAssertEqual(Slug.clean("abc-123/xyz"), "abc-123/xyz")
    }

    func testNormalizeForSaveTrimsTrailingSlashAndWhitespace() {
        XCTAssertEqual(Slug.normalizeForSave("  foo/bar//  "), "foo/bar")
        XCTAssertEqual(Slug.normalizeForSave("path/"), "path")
    }

    func testNormalizeForSaveEmptyGeneratesSlug() {
        let s = Slug.normalizeForSave("   ")
        XCTAssertEqual(s.count, 6)
        XCTAssertTrue(s.allSatisfy { Slug.alphabet.contains($0) })
    }

    func testGenerateLengthAndAlphabet() {
        let s = Slug.generate(length: 12)
        XCTAssertEqual(s.count, 12)
        XCTAssertTrue(s.allSatisfy { Slug.alphabet.contains($0) })
        // Алфавит без визуально похожих символов.
        for ch in ["l", "o", "0", "1"] {
            XCTAssertFalse(Slug.alphabet.contains(Character(ch)), "алфавит не должен содержать \(ch)")
        }
    }
}
