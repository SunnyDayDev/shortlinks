import SwiftUI

/// Пункт навигации в сайдбаре: иконочная плитка + заголовок + опц. счётчик, с
/// подсветкой активного состояния. Владеет своими размерами/отступами.
struct SidebarItem: View {
    let title: String
    let systemImage: String
    let tint: Color
    var count: Int?
    var active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s8) {
                IconTile(systemName: systemImage, tint: tint)
                Text(title)
                    .font(Typography.bodyMedium)
                    .lineLimit(1)
                Spacer(minLength: Spacing.s4)
                if let count {
                    Text("\(count)")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.s8).padding(.vertical, Spacing.s6)
            .background(active ? Theme.selectionBg : .clear, in: RoundedRectangle(cornerRadius: Radius.md))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.s8)
    }
}
