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
                .font(.system(size: 22, weight: .bold))
            Text("Вы создаёте адрес вида sl://link/имя. Когда его открывают, система ловит схему и перенаправляет на полную цель — приложение, файл или сайт.")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.65))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.top, 8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(steps, id: \.0) { step in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(step.0)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(step.3, in: RoundedRectangle(cornerRadius: 8))
                        Text(step.1).font(.system(size: 14, weight: .semibold)).padding(.top, 11)
                        Text(step.2)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 0.5))
                }
            }
            .padding(.top, 26)

            HStack(spacing: 14) {
                Text("sl://link/demo")
                    .font(.system(size: 13, design: .monospaced)).foregroundStyle(Theme.accent)
                Image(systemName: "arrow.right").foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.4))
                Text("https://example.com/very/long/target?token=…")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.75))
                    .lineLimit(1)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x2A6FDB, alpha: 0.05), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0x2A6FDB, alpha: 0.25), lineWidth: 0.5))
            .padding(.top, 24)
        }
        .padding(.horizontal, 24).padding(.top, 22).padding(.bottom, 32)
        .frame(maxWidth: 760, alignment: .leading)
    }
}
