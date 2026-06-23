import SwiftUI

/// Поле формы с подписью-меткой. Заменяет локальный хелпер `field` из CreateSheet.
struct LabeledField<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content

    init(_ label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s6) {
            Text(label)
                .font(Typography.captionEmphasis)
                .foregroundStyle(Theme.textSecondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
