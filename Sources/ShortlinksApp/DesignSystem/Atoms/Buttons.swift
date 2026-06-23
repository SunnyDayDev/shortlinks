import SwiftUI

/// Размер кнопки дизайн-системы (высота/горизонтальный отступ).
enum DSButtonSize {
    case small   // компактные кнопки тулбара
    case medium  // обычные действия
    case large   // главное действие на экране

    var height: CGFloat {
        switch self {
        case .small: return Size.controlHeight   // 30
        case .medium: return 32
        case .large: return Size.actionHeight     // 36
        }
    }

    var hPadding: CGFloat {
        switch self {
        case .small: return Spacing.s12      // 13→s12
        case .medium: return Spacing.s16
        case .large: return Spacing.s18
        }
    }
}

/// Акцентная (главная) кнопка: заливка акцентом, светлый текст. Заменяет inline-копии
/// «accent-фон + белый текст + скругление», разбросанные ранее по экранам.
struct PrimaryButtonStyle: ButtonStyle {
    var size: DSButtonSize = .medium

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.bodyEmphasis)
            .foregroundStyle(Theme.onAccent)
            .padding(.horizontal, size.hPadding)
            .frame(height: size.height)
            .background(Theme.accent, in: RoundedRectangle(cornerRadius: Radius.md))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .contentShape(Rectangle())
    }
}

/// Вторичная кнопка: лёгкая заливка, акцентный текст.
struct SecondaryButtonStyle: ButtonStyle {
    var size: DSButtonSize = .medium

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.bodyEmphasis)
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, size.hPadding)
            .frame(height: size.height)
            .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: Radius.md))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Rectangle())
    }
}

/// Деструктивная кнопка: красный текст на мягкой красной подложке.
struct DestructiveButtonStyle: ButtonStyle {
    var size: DSButtonSize = .large

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typography.bodyEmphasis)
            .foregroundStyle(Theme.destructive)
            .padding(.horizontal, size.hPadding)
            .frame(height: size.height)
            .background(Theme.destructiveBg, in: RoundedRectangle(cornerRadius: Radius.md))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Rectangle())
    }
}
