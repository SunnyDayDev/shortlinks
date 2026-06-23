import SwiftUI
import AppKit

// MARK: - Низкоуровневые конструкторы цвета
//
// ЕДИНСТВЕННОЕ место в приложении, где допустимы сырые цветовые литералы
// (`Color(hex:)`, `Color.dyn`). Вью обязаны брать цвета из семантических токенов
// (`Theme`), а не отсюда — см. `ColorTokens.swift`.

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

/// Foundation-палитра: «сырые» брендовые и нейтральные значения по макету
/// `_design/Одноразовые ссылки.dc.html`. Не используется во вью напрямую — только как
/// основа для семантических токенов `Theme`. Менять брендинг/палитру нужно здесь.
enum Palette {
    // Бренд-акценты (одинаковы в обеих темах).
    static let brandBlue = Color(hex: 0x2A6FDB)
    static let brandBlueHover = Color(hex: 0x2360C0)
    static let brandBlueDeep = Color(hex: 0x3F6BB5)   // текст тег-чипа
    static let once = Color(hex: 0xE08A2B)            // оранжевый «одноразовая»
    static let active = Color(hex: 0x28A55F)          // зелёный «активная»

    // Красные (destructive / истёкшая).
    static let dangerFg = Color.dyn(0xC0392B, 0xFF6F62)
    static let dangerBgTint = Color(hex: 0xD2372D)

    // Нейтральные иконочные тинты сайдбара.
    static let neutral = Color(hex: 0x9AA0AC)         // истёкшие (свёрнут дрейф 0x9AA0AA)
    static let neutralTag = Color(hex: 0xC3C7D0)      // теги
    static let neutralGray = Color(hex: 0x8E8E93)     // настройки (≈ systemGray)
    static let slate = Color(hex: 0x5B6F95)           // «как это работает»

    // Тёмная подложка тоста (намеренно тёмная в обеих темах).
    static let toast = Color(hex: 0x1C1C1E)
}
