import SwiftUI
import ShortlinksCore

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
