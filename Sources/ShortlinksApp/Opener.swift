import AppKit

/// Открытие цели перехода средствами системы.
enum Opener {
    static func open(_ target: String) {
        let trimmed = target.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed), url.scheme != nil {
            NSWorkspace.shared.open(url)
        } else if trimmed.hasPrefix("/") {
            NSWorkspace.shared.open(URL(fileURLWithPath: trimmed))
        }
        // text-цель просто не открывается системой
    }
}
