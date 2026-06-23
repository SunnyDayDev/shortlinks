import SwiftUI

/// Секционный заголовок-капс (например «БИБЛИОТЕКА», «СИНХРОНИЗАЦИЯ»). Объединяет
/// прежние `groupLabel` (Настройки) и `sectionLabel` (Сайдбар). Внешние отступы
/// задаёт вызывающая сторона.
struct SectionLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(Typography.label)
            .foregroundStyle(Theme.textSecondary)
    }
}
