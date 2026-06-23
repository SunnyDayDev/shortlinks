import SwiftUI

/// Карточка-секция настроек (поверхность вокруг группы строк).
struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        VStack(spacing: 0) { content() }
            .card()
    }
}

/// Строка настроек: горизонтальный ряд с едиными отступами.
struct SettingsRow<Content: View>: View {
    @ViewBuilder var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        HStack(spacing: Spacing.s14) { content() }
            .padding(.horizontal, Spacing.s16).padding(.vertical, Spacing.s14)
    }
}

/// Частый случай строки настроек: заголовок + переключатель.
struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsRow {
            Text(title).font(Typography.bodyMedium)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().toggleStyle(.switch)
        }
    }
}
