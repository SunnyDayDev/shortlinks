import SwiftUI

extension View {
    /// Контейнер прокручиваемого экрана: единые внешние отступы + максимальная ширина
    /// контента. Заменяет повтор `.padding(...).frame(maxWidth:)` в Detail/Settings/
    /// HowItWorks — размеры экрана живут здесь, а не в каждом вью.
    func screenContainer(
        maxWidth: CGFloat,
        top: CGFloat = Spacing.s18,
        bottom: CGFloat = Spacing.s32
    ) -> some View {
        self
            .padding(.horizontal, Spacing.s24)
            .padding(.top, top)
            .padding(.bottom, bottom)
            .frame(maxWidth: maxWidth, alignment: .leading)
    }
}
