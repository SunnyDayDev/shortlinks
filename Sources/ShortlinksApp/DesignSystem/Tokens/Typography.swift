import SwiftUI

/// Типографическая шкала — единственное место, где заданы конкретные кегли и
/// начертания. Вью используют именованные токены вместо `.font(.system(size:))`.
///
/// Соответствие исходным кеглям (свёрнуты различия ≤0.5pt и близкие начертания как
/// визуально незаметные — см. design.md «визуальный паритет»):
///   22 bold → display · 16 bold/semibold → title · 15 bold → headline
///   15 semibold → subtitle · 14 semibold → sectionTitle · 14 reg/medium → bodyLarge
///   13 reg → body · 13 medium → bodyMedium · 13/13.5 semibold, 13 bold → bodyEmphasis
///   12/12.5 reg → caption · 12.5 medium → captionMedium · 12 semibold → captionEmphasis
///   11/11.5 reg → caption2 · 11.5 semibold → caption2Emphasis · 11 bold → label
enum Typography {
    // Текст (sans-serif)
    static let display = Font.system(size: 22, weight: .bold)
    static let title = Font.system(size: 16, weight: .bold)
    static let headline = Font.system(size: 15, weight: .bold)
    static let subtitle = Font.system(size: 15, weight: .semibold)
    static let sectionTitle = Font.system(size: 14, weight: .semibold)
    static let bodyLarge = Font.system(size: 14)
    static let body = Font.system(size: 13)
    static let bodyMedium = Font.system(size: 13, weight: .medium)
    static let bodyEmphasis = Font.system(size: 13, weight: .semibold)
    static let caption = Font.system(size: 12)
    static let captionMedium = Font.system(size: 12, weight: .medium)
    static let captionEmphasis = Font.system(size: 12, weight: .semibold)
    static let caption2 = Font.system(size: 11.5)
    static let caption2Emphasis = Font.system(size: 11.5, weight: .semibold)
    static let label = Font.system(size: 11, weight: .bold)

    // Моноширинные (короткие адреса, цели, код)
    static let monoTitle = Font.system(size: 18, weight: .semibold, design: .monospaced)
    static let monoHeadline = Font.system(size: 15, design: .monospaced)
    static let mono = Font.system(size: 13, design: .monospaced)
    static let monoSmall = Font.system(size: 12, design: .monospaced)

    // Глифы (отдельно стоящие SF Symbols вне компонентов)
    static let glyphLarge = Font.system(size: 44)
    static let glyphMedium = Font.system(size: 18)
    static let glyphAction = Font.system(size: 14, weight: .medium)
    static let glyphSmall = Font.system(size: 12)
}
