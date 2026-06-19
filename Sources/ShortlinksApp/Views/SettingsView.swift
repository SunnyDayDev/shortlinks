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

            groupLabel("ПЕРЕХОД ПО ССЫЛКЕ").padding(.top, 22)
            card {
                row {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Режим перехода").font(.system(size: 13, weight: .medium))
                        Text("«Сразу» открывает цель в фоне без диалога. Защищённые паролем и недоступные ссылки всегда показывают подтверждение.")
                            .font(.system(size: 12)).foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 12)
                    Picker("", selection: $model.redirectMode) {
                        Text("Сразу").tag(RedirectMode.instant)
                        Text("С подтверждением").tag(RedirectMode.confirm)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: 220)
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

            groupLabel("КОМАНДНАЯ СТРОКА").padding(.top, 22)
            card {
                row {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Команда shortlinks в терминале").font(.system(size: 13, weight: .semibold))
                        cliStatusLine
                    }
                    Spacer(minLength: 12)
                    cliActionButton
                }
                if model.cliShowPathHint {
                    Divider()
                    cliPathHint
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
                        .font(.system(size: 12.5)).foregroundStyle(Color.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.subtleCardBg, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 0.5))
        }
        .padding(.horizontal, 24).padding(.top, 18).padding(.bottom, 32)
        .frame(maxWidth: 640, alignment: .leading)
        .onAppear {
            handlerOn = model.isDefaultHandler
            model.refreshCLIStatus()
        }
    }

    // MARK: - CLI

    @ViewBuilder
    private var cliStatusLine: some View {
        switch model.cliStatus {
        case .installed(let path):
            Text("Установлен · \(path)")
                .font(.system(size: 12)).foregroundStyle(Theme.activeAccent)
        case .notInstalled:
            Text("Не установлен. Установите, чтобы вызывать shortlinks из терминала.")
                .font(.system(size: 12)).foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        case .conflict(let reason):
            Text("Конфликт: \(reason)")
                .font(.system(size: 12)).foregroundStyle(Color(hex: 0xD2372D))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var cliActionButton: some View {
        switch model.cliStatus {
        case .installed:
            Button("Удалить CLI") { model.uninstallCLI() }
        case .notInstalled, .conflict:
            Button("Установить CLI") { model.installCLI() }
                .buttonStyle(.borderedProminent).tint(Theme.accent)
        }
    }

    private var cliPathHint: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Каталог ~/.local/bin не в PATH. Добавьте строку в профиль шелла (например ~/.zshrc):")
                .font(.system(size: 12)).foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text(model.cliPathExportLine)
                    .font(.system(size: 12, design: .monospaced))
                    .textSelection(.enabled)
                Spacer()
                Button {
                    model.copy(model.cliPathExportLine)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain).foregroundStyle(Theme.accent)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(Theme.codeBg, in: RoundedRectangle(cornerRadius: 7))
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func groupLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.secondary)
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
