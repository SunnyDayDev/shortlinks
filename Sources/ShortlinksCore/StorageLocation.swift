import Foundation

/// Расчёт пути к единому файлу `links.json` (iCloud Drive vs локально).
///
/// Местоположение определяется наличием файла в iCloud Drive — так app и CLI
/// согласованно выбирают одно и то же хранилище без общих настроек. Переключение
/// синхронизации (`enableSync`/`disableSync` в `LinkStore`) перемещает файл.
public enum StorageLocation {
    public static let folderName = "Shortlinks"
    public static let fileName = "links.json"

    /// `~/Library/Mobile Documents/com~apple~CloudDocs/Shortlinks/links.json`,
    /// если контейнер iCloud Drive существует.
    public static var iCloudURL: URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let base = home
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs", isDirectory: true)
        guard FileManager.default.fileExists(atPath: base.path) else { return nil }
        return base
            .appendingPathComponent(folderName, isDirectory: true)
            .appendingPathComponent(fileName)
    }

    /// `~/Library/Application Support/Shortlinks/links.json`.
    public static var localURL: URL {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base
            .appendingPathComponent(folderName, isDirectory: true)
            .appendingPathComponent(fileName)
    }

    /// Доступен ли iCloud Drive в принципе.
    public static var isICloudAvailable: Bool { iCloudURL != nil }

    /// Включена ли сейчас синхронизация (файл лежит в iCloud Drive).
    public static var isSyncEnabled: Bool {
        guard let u = iCloudURL else { return false }
        return FileManager.default.fileExists(atPath: u.path)
    }

    /// Текущее активное местоположение: iCloud, если там есть файл, иначе локально.
    public static func current() -> URL {
        if let u = iCloudURL, FileManager.default.fileExists(atPath: u.path) { return u }
        return localURL
    }
}
