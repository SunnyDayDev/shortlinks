import SwiftUI
import AppKit
import ShortlinksCore

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

/// Палитра по макету `_design/Одноразовые ссылки.dc.html` (акцент #2A6FDB).
enum Theme {
    static let accent = Color(hex: 0x2A6FDB)
    static let accentHover = Color(hex: 0x2360C0)
    static let onceAccent = Color(hex: 0xE08A2B)
    static let activeAccent = Color(hex: 0x28A55F)
    static let cardBorder = Color.black.opacity(0.10)
    static let iconBg = Color(hex: 0xECEEF2)
    static let iconFg = Color(hex: 0x5B6478)
    static let secondaryText = Color(hex: 0x3C3C43).opacity(0.6)

    static func statusColors(_ status: LinkStatus) -> (bg: Color, fg: Color) {
        switch status {
        case .active: return (Color(hex: 0x28A55F, alpha: 0.13), Color(hex: 0x1D7A4A))
        case .viewed: return (Color.black.opacity(0.06), Color(hex: 0x3C3C43, alpha: 0.7))
        case .expired: return (Color(hex: 0xD2372D, alpha: 0.10), Color(hex: 0xC0392B))
        }
    }
}

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
