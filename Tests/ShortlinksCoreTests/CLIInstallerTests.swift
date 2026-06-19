import XCTest
@testable import ShortlinksCore

final class CLIInstallerTests: XCTestCase {
    private var tmp: URL!
    private var installDir: URL!
    private var bundledBinary: URL!

    override func setUpWithError() throws {
        tmp = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("cli-installer-tests-\(UUID().uuidString)", isDirectory: true)
        installDir = tmp.appendingPathComponent(".local/bin", isDirectory: true)
        // Имитируем вложенный в бандл бинарь по реальному пути …/Shortlinks.app/Contents/Helpers/shortlinks.
        bundledBinary = tmp
            .appendingPathComponent("Shortlinks.app/Contents/Helpers", isDirectory: true)
            .appendingPathComponent("shortlinks")
        try FileManager.default.createDirectory(
            at: bundledBinary.deletingLastPathComponent(), withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: bundledBinary.path, contents: Data("bin".utf8))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tmp)
    }

    private func makeInstaller() -> CLIInstaller {
        CLIInstaller(bundledBinaryURL: bundledBinary, installDir: installDir)
    }

    func testFirstInstall() throws {
        let installer = makeInstaller()
        XCTAssertEqual(installer.status(), .notInstalled)

        try installer.install()

        // Каталог создан, симлинк указывает на вложенный бинарь.
        let dest = try FileManager.default.destinationOfSymbolicLink(atPath: installer.symlinkURL.path)
        XCTAssertEqual(URL(fileURLWithPath: dest).standardizedFileURL.path,
                       bundledBinary.standardizedFileURL.path)
        if case .installed = installer.status() {} else {
            XCTFail("ожидался статус installed, получили \(installer.status())")
        }
    }

    func testInstallIsIdempotent() throws {
        let installer = makeInstaller()
        try installer.install()
        XCTAssertNoThrow(try installer.install())   // повтор не бросает
        if case .installed = installer.status() {} else {
            XCTFail("ожидался статус installed после повторной установки")
        }
    }

    func testOverwriteSymlinkToAnotherBundle() throws {
        let installer = makeInstaller()
        // Симлинк указывает на ДРУГОЙ бандл Shortlinks.
        let otherBinary = tmp
            .appendingPathComponent("Other/Shortlinks.app/Contents/Helpers", isDirectory: true)
            .appendingPathComponent("shortlinks")
        try FileManager.default.createDirectory(
            at: otherBinary.deletingLastPathComponent(), withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: otherBinary.path, contents: Data("other".utf8))
        try FileManager.default.createDirectory(at: installDir, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: installer.symlinkURL, withDestinationURL: otherBinary)

        if case .conflict = installer.status() {} else {
            XCTFail("ожидался статус conflict до перезаписи")
        }

        try installer.install()   // должен перезаписать на текущий бандл

        let dest = try FileManager.default.destinationOfSymbolicLink(atPath: installer.symlinkURL.path)
        XCTAssertEqual(URL(fileURLWithPath: dest).standardizedFileURL.path,
                       bundledBinary.standardizedFileURL.path)
    }

    func testForeignFileIsProtected() throws {
        let installer = makeInstaller()
        try FileManager.default.createDirectory(at: installDir, withIntermediateDirectories: true)
        // Посторонний обычный файл по пути симлинка.
        FileManager.default.createFile(atPath: installer.symlinkURL.path, contents: Data("user".utf8))

        if case .conflict = installer.status() {} else {
            XCTFail("ожидался статус conflict для постороннего файла")
        }
        XCTAssertThrowsError(try installer.install())   // не перезаписываем чужой файл
        XCTAssertThrowsError(try installer.uninstall()) // не удаляем чужой файл

        // Файл на месте и не тронут.
        XCTAssertEqual(try Data(contentsOf: installer.symlinkURL), Data("user".utf8))
    }

    func testUninstallRemovesSymlink() throws {
        let installer = makeInstaller()
        try installer.install()
        XCTAssertNoThrow(try installer.uninstall())
        XCTAssertEqual(installer.status(), .notInstalled)
        // Повторный uninstall без симлинка — без ошибки.
        XCTAssertNoThrow(try installer.uninstall())
    }
}
