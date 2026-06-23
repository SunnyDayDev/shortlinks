import SwiftUI

/// Строка «метка — значение» в карточке деталей. Владеет шириной колонки-метки и
/// внутренними отступами, поэтому вью не несут этих размеров.
struct InfoRow: View {
    let label: String
    let value: String
    var mono = false

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .frame(width: Size.infoLabelWidth, alignment: .leading)
                .foregroundStyle(Theme.textSecondary)
            Text(value)
                .font(mono ? Typography.monoSmall : Typography.bodyMedium)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.s16).padding(.vertical, Spacing.s12)
    }
}
