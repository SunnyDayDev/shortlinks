import SwiftUI
import AppKit
import ShortlinksCore

/// Семантические цветовые токены — единый источник правды для оформления.
/// Вью ссылаются только сюда; сырые значения живут в `Palette`/`Color+Foundation`.
/// Чтобы сменить палитру или брендинг приложения, правьте этот файл и `Palette`.
enum Theme {
    // MARK: Акцент
    static let accent = Palette.brandBlue
    static let accentHover = Palette.brandBlueHover
    /// Текст/иконка поверх акцентной (цветной) заливки.
    static let onAccent = Color.white
    /// Фон выделенной строки (активный пункт сайдбара).
    static let selectionBg = Palette.brandBlue.opacity(0.14)

    // MARK: Бренд-акценты статусов
    static let onceAccent = Palette.once
    static let activeAccent = Palette.active
    static let onceText = Color.dyn(0x9A5A12, 0xE0A65A)
    /// Мягкая подложка предупреждения «одноразовая».
    static let onceBg = Palette.once.opacity(0.1)

    // MARK: Поверхности и разделители
    static let separator = Color(nsColor: .separatorColor)
    /// Фон карточки/строки списка.
    static let surface = Color(nsColor: .controlBackgroundColor)
    /// Фон основной области контента.
    static let content = Color(nsColor: .textBackgroundColor)
    /// Фон всплывающей панели-оверлея.
    static let overlay = Color(nsColor: .windowBackgroundColor)
    static let sidebarBg = Color.dyn(0xF0F0F3, 0x252528)
    static let subtleCardBg = Color.dyn(0xFBFBFD, 0x202024)
    static let codeBg = Color.dyn(0xF4F5F7, 0x2A2A2F)
    /// Затемнение фона под модальным оверлеем.
    static let scrim = Color.black.opacity(0.45)

    // MARK: Текст
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    /// Приглушённый глиф-плейсхолдер (например «sl://» в пустом состоянии).
    static let placeholderGlyph = Palette.neutral

    // MARK: Иконочные плитки
    static let iconBg = Color.dyn(0xECEEF2, 0x3A3A40)
    static let iconFg = Color.dyn(0x5B6478, 0xAEB4BF)
    /// Тинты иконок-плиток в сайдбаре.
    static let neutralIcon = Palette.neutral
    static let tagIcon = Palette.neutralTag
    static let settingsIcon = Palette.neutralGray
    static let helpIcon = Palette.slate

    // MARK: Destructive
    static let destructive = Palette.dangerFg
    static let destructiveBg = Palette.dangerBgTint.opacity(0.08)

    // MARK: Тег-чип
    static let tagText = Palette.brandBlueDeep
    static let tagBg = Palette.brandBlue.opacity(0.12)

    // MARK: Прочее
    /// Лёгкая заливка (поиск, мелкие кнопки) — адаптируется по primary.
    static let subtleFill = Color.primary.opacity(0.06)
    /// Подложка всплывающего тоста.
    static let toastBg = Palette.toast.opacity(0.92)
    /// Подложка/рамка информационного блока-примера (акцентный тинт).
    static let infoBg = Palette.brandBlue.opacity(0.05)
    static let infoBorder = Palette.brandBlue.opacity(0.25)

    // MARK: Статусы ссылок
    static func statusColors(_ status: LinkStatus) -> (bg: Color, fg: Color) {
        switch status {
        case .active: return (Palette.active.opacity(0.16), Color.dyn(0x1D7A4A, 0x5FD191))
        case .viewed: return (Color.primary.opacity(0.08), Color.secondary)
        case .disabled: return (Color(hex: 0xE8A33D, alpha: 0.18), Color.dyn(0xB5791A, 0xF0B860))
        case .expired: return (Palette.dangerBgTint.opacity(0.16), Palette.dangerFg)
        }
    }
}
