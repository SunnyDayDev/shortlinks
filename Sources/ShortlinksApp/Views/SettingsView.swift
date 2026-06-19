import SwiftUI
import ShortlinksCore

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var handlerOn = false

    var body: some View {
        @Bindable var model = model
        VStack(alignment: .leading, spacing: 0) {
            groupLabel("РАЗРЕШЕНИЕ ССЫЛОК")
            card {
                row {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Обработчик схемы sl://").font(.system(size: 13, weight: .semibold))
                        Text("Приложение зарегистрировано как обработчик ссылок для этого Mac.")
                            .font(.system(size: 12)).foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                    Toggle("", isOn: $handlerOn).labelsHidden().toggleStyle(.switch)
                        .onChange(of: handlerOn) { _, on in if on { model.setDefaultHandler(true) } }
                }
            }

            groupLabel("ПО УМОЛЧАНИЮ ДЛЯ НОВЫХ ССЫЛОК").padding(.top, 22)
            card {
                row {
                    Text("Тип ссылки").font(.system(size: 13, weight: .medium))
                    Spacer()
                    Picker("", selection: $model.defKind) {
                        Text("Одноразовая").tag(LinkKind.once)
                        Text("Многоразовая").tag(LinkKind.reuse)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: 220)
                }
                Divider()
                row {
                    Text("Срок действия").font(.system(size: 13, weight: .medium))
                    Spacer()
                    Picker("", selection: $model.defLifetime) {
                        Text("1 ч").tag(Lifetime.h1)
                        Text("24 ч").tag(Lifetime.h24)
                        Text("7 дн").tag(Lifetime.d7)
                        Text("Без срока").tag(Lifetime.never)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: 280)
                }
                Divider()
                toggleRow("Запрашивать пароль", isOn: $model.defPassword)
                Divider()
                toggleRow("Копировать после создания", isOn: $model.copyOnCreate)
                Divider()
                toggleRow("Удалять одноразовую после перехода", isOn: $model.deleteOnConsume)
            }

            groupLabel("СИНХРОНИЗАЦИЯ").padding(.top, 22)
            card {
                row {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Синхронизация через iCloud Drive").font(.system(size: 13, weight: .semibold))
                        Text(model.iCloudAvailable
                             ? "Ссылки хранятся в одном файле в вашем iCloud Drive и синхронизируются между устройствами."
                             : "iCloud Drive недоступен на этом Mac.")
                            .font(.system(size: 12)).foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(get: { model.syncEnabled }, set: { model.setSync($0) }))
                        .labelsHidden().toggleStyle(.switch)
                        .disabled(!model.iCloudAvailable)
                }
            }

            groupLabel("ПРИВАТНОСТЬ").padding(.top, 22)
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Theme.activeAccent, in: RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Приватность по умолчанию").font(.system(size: 13, weight: .semibold))
                    Text("Ссылки и их цели хранятся только на этом Mac. При включённой синхронизации они идут через ваш личный iCloud Drive — без аккаунтов сервиса и сторонних серверов.")
                        .font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0xFBFBFD), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 0.5))
        }
        .padding(.horizontal, 24).padding(.top, 18).padding(.bottom, 32)
        .frame(maxWidth: 640, alignment: .leading)
        .onAppear { handlerOn = model.isDefaultHandler }
    }

    private func groupLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color(hex: 0x3C3C43, alpha: 0.5))
            .padding(.bottom, 8).padding(.leading, 2)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 0.5))
    }

    private func row<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 14) { content() }
            .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        row {
            Text(title).font(.system(size: 13, weight: .medium))
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().toggleStyle(.switch)
        }
    }
}
