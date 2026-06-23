import SwiftUI

/// Иконочная плитка: SF Symbol светлым глифом на цветной скруглённой подложке.
/// Повторяющийся паттерн из сайдбара, экрана настроек и т.п. Размер глифа
/// пропорционален размеру плитки, поэтому во вью не остаётся сырых кеглей.
struct IconTile: View {
    let systemName: String
    var tint: Color
    var size: CGFloat = 20
    var glyphRatio: CGFloat = 0.5
    var weight: Font.Weight = .bold
    var radius: CGFloat = Radius.sm

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * glyphRatio, weight: weight))
            .foregroundStyle(Theme.onAccent)
            .frame(width: size, height: size)
            .background(tint, in: RoundedRectangle(cornerRadius: radius))
    }
}
