import Foundation

/// Статус доступности CLI-команды из терминала.
public enum CLIInstallStatus: Equatable {
    /// Симлинк указывает на вложенный в текущий бандл бинарь. `path` — путь к симлинку.
    case installed(path: String)
    /// Симлинка нет.
    case notInstalled
    /// По пути посторонний объект или симлинк на другой бандл. `reason` — пояснение.
    case conflict(reason: String)
}

/// Ошибки управления доступностью CLI.
public enum CLIInstallError: Error, CustomStringConvertible {
    /// По пути установки лежит посторонний объект, который небезопасно трогать.
    case foreignObject(String)

    public var description: String {
        switch self {
        case .foreignObject(let path):
            return "Путь \(path) занят посторонним объектом — он не будет изменён"
        }
    }
}

/// Управляет доступностью вложенного в бандл CLI `shortlinks` из терминала через
/// симлинк в пользовательском каталоге (`~/.local/bin`, без прав администратора).
///
/// Симлинк (а не копия) гарантирует, что CLI всегда соответствует текущему бандлу:
/// обновили приложение — обновился и CLI. Логика вынесена в `ShortlinksCore`, чтобы
/// быть переиспользуемой и тестируемой без UI.
public struct CLIInstaller {
    /// Путь к вложенному в бандл бинарю (`<bundle>/Contents/MacOS/shortlinks`).
    public let bundledBinaryURL: URL
    /// Каталог установки симлинка (`~/.local/bin`).
    public let installDir: URL
    /// Имя команды/симлинка.
    public let binaryName: String

    /// Полный путь к симлинку (`~/.local/bin/shortlinks`).
    public var symlinkURL: URL { installDir.appendingPathComponent(binaryName) }

    public init(bundledBinaryURL: URL, installDir: URL, binaryName: String = "shortlinks") {
        self.bundledBinaryURL = bundledBinaryURL
        self.installDir = installDir
        self.binaryName = binaryName
    }

    /// Конфигурация для реального приложения: вложенный бинарь от `Bundle.main` и
    /// `~/.local/bin` в качестве каталога установки.
    public static func standard() -> CLIInstaller {
        let bundled = Bundle.main.bundleURL
            .appendingPathComponent("Contents/MacOS", isDirectory: true)
            .appendingPathComponent("shortlinks")
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".local/bin", isDirectory: true)
        return CLIInstaller(bundledBinaryURL: bundled, installDir: dir)
    }

    // MARK: - Статус

    /// Текущий статус доступности CLI.
    public func status() -> CLIInstallStatus {
        let fm = FileManager.default
        let path = symlinkURL.path
        // attributesOfItem использует lstat — не следует по симлинку, видит и битый симлинк.
        guard (try? fm.attributesOfItem(atPath: path)) != nil else { return .notInstalled }
        guard let dest = try? fm.destinationOfSymbolicLink(atPath: path) else {
            return .conflict(reason: "По пути \(prettyPath) лежит посторонний файл")
        }
        let destURL = resolvedDestination(dest)
        if samePath(destURL, bundledBinaryURL) {
            return .installed(path: prettyPath)
        }
        if isShortlinksBinary(destURL) {
            return .conflict(reason: "Симлинк указывает на другой бандл Shortlinks: \(destURL.path)")
        }
        return .conflict(reason: "По пути \(prettyPath) симлинк на посторонний объект")
    }

    // MARK: - Установка

    /// Идемпотентно делает CLI доступным: создаёт `~/.local/bin` при отсутствии и
    /// (пере)создаёт симлинк на вложенный бинарь. Бросает `foreignObject`, если по пути
    /// лежит посторонний объект (не симлинк Shortlinks).
    public func install() throws {
        let fm = FileManager.default
        try fm.createDirectory(at: installDir, withIntermediateDirectories: true)

        let path = symlinkURL.path
        if (try? fm.attributesOfItem(atPath: path)) != nil {
            guard let dest = try? fm.destinationOfSymbolicLink(atPath: path) else {
                throw CLIInstallError.foreignObject(prettyPath)   // обычный файл — не трогаем
            }
            let destURL = resolvedDestination(dest)
            if samePath(destURL, bundledBinaryURL) {
                return                                            // уже корректно — идемпотентно
            }
            guard isShortlinksBinary(destURL) else {
                throw CLIInstallError.foreignObject(prettyPath)   // чужой симлинк — не трогаем
            }
            try fm.removeItem(at: symlinkURL)                     // симлинк на другой бандл — перезапишем
        }
        try fm.createSymbolicLink(at: symlinkURL, withDestinationURL: bundledBinaryURL)
    }

    /// Безопасно удаляет симлинк, только если он указывает на бандл Shortlinks.
    /// Бросает `foreignObject`, если по пути посторонний объект.
    public func uninstall() throws {
        let fm = FileManager.default
        let path = symlinkURL.path
        guard (try? fm.attributesOfItem(atPath: path)) != nil else { return }   // нечего удалять
        guard let dest = try? fm.destinationOfSymbolicLink(atPath: path) else {
            throw CLIInstallError.foreignObject(prettyPath)
        }
        guard isShortlinksBinary(resolvedDestination(dest)) else {
            throw CLIInstallError.foreignObject(prettyPath)
        }
        try fm.removeItem(at: symlinkURL)
    }

    // MARK: - PATH

    /// Готовая строка для добавления каталога установки в `PATH`.
    public var pathExportLine: String {
        "export PATH=\"$HOME/.local/bin:$PATH\""
    }

    /// Находится ли каталог установки в `PATH` пользователя. Проверяется через
    /// login-шелл (`$SHELL -lic 'echo $PATH'`), т.к. PATH GUI-процесса (из launchd)
    /// не отражает шелл-профиль. Fail-safe: при ошибке/таймауте возвращает `false`
    /// (лучше показать подсказку лишний раз, чем скрыть нужную).
    public func installDirOnPATH() -> Bool {
        guard let raw = userPATH() else { return false }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let target = installDir.standardizedFileURL.path
        for entry in raw.split(separator: ":") {
            var e = String(entry)
            if e == "~" { e = home }
            else if e.hasPrefix("~/") { e = home + e.dropFirst() }
            if URL(fileURLWithPath: e).standardizedFileURL.path == target { return true }
        }
        return false
    }

    /// PATH из login-шелла пользователя, либо `nil` при ошибке/таймауте.
    private func userPATH() -> String? {
        let shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: shellPath)
        process.arguments = ["-lic", "echo $PATH"]
        let outPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = Pipe()
        do { try process.run() } catch { return nil }

        let sem = DispatchSemaphore(value: 0)
        DispatchQueue.global().async { process.waitUntilExit(); sem.signal() }
        if sem.wait(timeout: .now() + 2.0) == .timedOut {
            process.terminate()
            return nil
        }
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Вспомогательное

    /// Абсолютный URL цели симлинка (учитывает относительную цель).
    private func resolvedDestination(_ dest: String) -> URL {
        if dest.hasPrefix("/") { return URL(fileURLWithPath: dest).standardizedFileURL }
        return installDir.appendingPathComponent(dest).standardizedFileURL
    }

    private func samePath(_ a: URL, _ b: URL) -> Bool {
        a.standardizedFileURL.path == b.standardizedFileURL.path
    }

    /// Эвристика: цель — вложенный в бандл Shortlinks бинарь
    /// (`…/Shortlinks.app/Contents/MacOS/<binaryName>`).
    private func isShortlinksBinary(_ url: URL) -> Bool {
        url.lastPathComponent == binaryName
            && url.path.contains("Shortlinks.app/Contents/MacOS")
    }

    private var prettyPath: String {
        (symlinkURL.path as NSString).abbreviatingWithTildeInPath
    }
}
