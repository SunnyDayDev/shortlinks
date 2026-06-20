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

    /// Динамический цвет, адаптирующийся к светлой/тёмной теме.
    static func dyn(_ light: UInt, _ dark: UInt) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            let hex = isDark ? dark : light
            return NSColor(
                srgbRed: CGFloat((hex >> 16) & 0xff) / 255,
                green: CGFloat((hex >> 8) & 0xff) / 255,
                blue: CGFloat(hex & 0xff) / 255,
                alpha: 1
            )
        })
    }
}

/// Палитра по макету `_design/Одноразовые ссылки.dc.html`, адаптивная к теме.
enum Theme {
    // Брендовые акценты — одинаковы в обеих темах.
    static let accent = Color(hex: 0x2A6FDB)
    static let accentHover = Color(hex: 0x2360C0)
    static let onceAccent = Color(hex: 0xE08A2B)
    static let activeAccent = Color(hex: 0x28A55F)

    // Адаптивные поверхности и текст.
    static let cardBorder = Color(nsColor: .separatorColor)
    static let cardBg = Color(nsColor: .controlBackgroundColor)
    static let contentBg = Color(nsColor: .textBackgroundColor)
    static let sidebarBg = Color.dyn(0xF0F0F3, 0x252528)
    static let subtleCardBg = Color.dyn(0xFBFBFD, 0x202024)
    static let codeBg = Color.dyn(0xF4F5F7, 0x2A2A2F)
    static let iconBg = Color.dyn(0xECEEF2, 0x3A3A40)
    static let iconFg = Color.dyn(0x5B6478, 0xAEB4BF)
    static let onceText = Color.dyn(0x9A5A12, 0xE0A65A)
    static let secondaryText = Color.secondary
    /// Лёгкая заливка (поиск, мелкие кнопки) — адаптируется по primary.
    static let subtleFill = Color.primary.opacity(0.06)

    static func statusColors(_ status: LinkStatus) -> (bg: Color, fg: Color) {
        switch status {
        case .active: return (Color(hex: 0x28A55F, alpha: 0.16), Color.dyn(0x1D7A4A, 0x5FD191))
        case .viewed: return (Color.primary.opacity(0.08), Color.secondary)
        case .disabled: return (Color(hex: 0xE8A33D, alpha: 0.18), Color.dyn(0xB5791A, 0xF0B860))
        case .expired: return (Color(hex: 0xD2372D, alpha: 0.16), Color.dyn(0xC0392B, 0xFF6F62))
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
