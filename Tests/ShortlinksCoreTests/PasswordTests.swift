import XCTest
@testable import ShortlinksCore

final class PasswordTests: XCTestCase {
    func testHashFormatSaltColonHex() {
        let stored = Password.hash("secret", salt: "abc")
        let parts = stored.split(separator: ":", maxSplits: 1)
        XCTAssertEqual(parts.count, 2)
        XCTAssertEqual(String(parts[0]), "abc")
        XCTAssertEqual(parts[1].count, 64)                       // sha256 → 64 hex-символа
        XCTAssertTrue(parts[1].allSatisfy { $0.isHexDigit })
    }

    func testVerifyCorrectPassword() {
        let stored = Password.hash("hunter2")
        XCTAssertTrue(Password.verify("hunter2", against: stored))
    }

    func testVerifyWrongPassword() {
        let stored = Password.hash("hunter2")
        XCTAssertFalse(Password.verify("wrong", against: stored))
    }

    func testVerifyMalformedHash() {
        XCTAssertFalse(Password.verify("x", against: "no-colon-here"))
    }

    func testDifferentSaltsProduceDifferentHashes() {
        let a = Password.hash("same", salt: "s1")
        let b = Password.hash("same", salt: "s2")
        XCTAssertNotEqual(a, b)
        // Но обе проверяются своим паролем.
        XCTAssertTrue(Password.verify("same", against: a))
        XCTAssertTrue(Password.verify("same", against: b))
    }
}
