import SwiftUI
import ShortlinksCore

/// Бейдж статуса (пилюля).
struct StatusPill: View {
    let status: LinkStatus
    var body: some View {
        let c = Theme.statusColors(status)
        Text(Format.statusLabel(status))
            .font(Typography.caption2Emphasis)
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(c.bg, in: Capsule())
            .foregroundStyle(c.fg)
    }
}

/// Тег-чип.
struct TagChip: View {
    let name: String
    var onRemove: (() -> Void)?
    var body: some View {
        HStack(spacing: 5) {
            Text("#\(name)")
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                }
                .buttonStyle(.plain)
            }
        }
        .font(Typography.caption2Emphasis)
        .foregroundStyle(Theme.tagText)
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Theme.tagBg, in: RoundedRectangle(cornerRadius: Radius.sm))
    }
}
