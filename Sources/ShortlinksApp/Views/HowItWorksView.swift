import SwiftUI

struct HowItWorksView: View {
    private let steps = [
        ("1", "Создаёте ссылку", "Указываете цель и получаете короткий адрес sl://link/…", Theme.accent),
        ("2", "Делитесь", "Отправляете адрес любым способом — он короткий и не раскрывает цель.", Theme.accent),
        ("3", "Переход", "Система открывает приложение или браузер по сохранённой цели.", Theme.accent),
        ("4", "Сгорает", "Одноразовая ссылка становится недоступной после первого перехода.", Theme.onceAccent),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Короткая ссылка, которая живёт на вашем Mac")
                .font(Typography.display)
            Text("Вы создаёте адрес вида sl://link/имя. Когда его открывают, система ловит схему и перенаправляет на полную цель — приложение, файл или сайт.")
                .font(Typography.bodyLarge)
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: Size.proseMaxWidth, alignment: .leading)
                .padding(.top, Spacing.s8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.s12), count: 2), spacing: Spacing.s12) {
                ForEach(steps, id: \.0) { step in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(step.0)
                            .font(Typography.bodyEmphasis)
                            .foregroundStyle(Theme.onAccent)
                            .frame(width: Size.stepBadge, height: Size.stepBadge)
                            .background(step.3, in: RoundedRectangle(cornerRadius: Radius.md))
                        Text(step.1).font(Typography.sectionTitle).padding(.top, Spacing.s12)
                        Text(step.2)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, Spacing.s6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.s16)
                    .card()
                }
            }
            .padding(.top, Spacing.s26)

            HStack(spacing: Spacing.s14) {
                Text("sl://link/demo")
                    .font(Typography.mono).foregroundStyle(Theme.accent)
                Image(systemName: "arrow.right").foregroundStyle(Theme.textSecondary)
                Text("https://example.com/very/long/target?token=…")
                    .font(Typography.mono)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }
            .padding(Spacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(fill: Theme.infoBg, stroke: Theme.infoBorder)
            .padding(.top, Spacing.s24)
        }
        .screenContainer(maxWidth: Size.howMaxWidth, top: Spacing.s22)
    }
}
