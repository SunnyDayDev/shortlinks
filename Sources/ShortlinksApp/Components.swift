import SwiftUI
import ShortlinksCore

/// Бейдж статуса (как пилюля в макете).
struct StatusPill: View {
    let status: LinkStatus
    var body: some View {
        let c = Theme.statusColors(status)
        Text(Format.statusLabel(status))
            .font(.system(size: 11.5, weight: .semibold))
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(c.bg, in: Capsule())
            .foregroundStyle(c.fg)
    }
}

/// Иконка-квадрат с трёхбуквенным кодом типа цели.
struct TargetIcon: View {
    let target: String
    var size: CGFloat = 38
    var body: some View {
        Text(Scheme.detect(target).code)
            .font(.system(size: size * 0.29, weight: .semibold, design: .monospaced))
            .foregroundStyle(Theme.iconFg)
            .frame(width: size, height: size)
            .background(Theme.iconBg, in: RoundedRectangle(cornerRadius: size * 0.24))
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
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(Color(hex: 0x3F6BB5))
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Color(hex: 0x2A6FDB, alpha: 0.12), in: RoundedRectangle(cornerRadius: 6))
    }
}

/// Простой flow-layout для тегов (macOS 14 Layout API).
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxWidth && x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        let maxX = bounds.maxX
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxX && x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
    }
}
