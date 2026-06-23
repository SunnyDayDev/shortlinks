import SwiftUI
import ShortlinksCore

/// Иконка-квадрат с трёхбуквенным кодом типа цели. В режиме `masked` (защищённая
/// ссылка) показывает замок вместо кода — тип цели тоже не раскрываем.
struct TargetIcon: View {
    let target: String
    var size: CGFloat = 38
    var masked = false
    var body: some View {
        Group {
            if masked {
                Image(systemName: Icons.Status.privacy)
                    .font(.system(size: size * 0.34, weight: .semibold))
            } else {
                Text(Scheme.detect(target).code)
                    .font(.system(size: size * 0.29, weight: .semibold, design: .monospaced))
            }
        }
        .foregroundStyle(Theme.iconFg)
        .frame(width: size, height: size)
        .background(Theme.iconBg, in: RoundedRectangle(cornerRadius: size * 0.24))
    }
}
