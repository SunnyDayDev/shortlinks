import SwiftUI

extension View {
    /// Карточка-поверхность: фон + рамка + скругление. Заменяет повторявшиеся вручную
    /// `infoCard`/`card`/grid-ячейку/фон строки списка.
    func card(
        fill: Color = Theme.surface,
        stroke: Color = Theme.separator,
        radius: CGFloat = Radius.xl
    ) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(stroke, lineWidth: 0.5))
    }

    /// Поле ввода: фон контента + рамка + скругление поля.
    func fieldBox(radius: CGFloat = Radius.md) -> some View {
        card(fill: Theme.content, radius: radius)
    }

    /// Моноширинный блок (адрес/цель/код): приглушённая подложка, опц. рамка.
    func codeBox(bordered: Bool = false, radius: CGFloat = Radius.lg) -> some View {
        background(Theme.codeBg, in: RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Theme.separator, lineWidth: bordered ? 0.5 : 0)
            )
    }
}
