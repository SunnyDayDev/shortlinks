import SwiftUI
import ShortlinksCore

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var handlerOn = false

    var body: some View {
        @Bindable var model = model
        VStack(alignment: .leading, spacing: 0) {
            groupLabel("РАЗРЕШЕНИЕ ССЫЛОК")
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text("Обработчик схемы sl://").font(Typography.bodyEmphasis)
                        Text("Приложение зарегистрировано как обработчик ссылок для этого Mac.")
                            .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: $handlerOn).labelsHidden().toggleStyle(.switch)
                        .onChange(of: handlerOn) { _, on in if on { model.setDefaultHandler(true) } }
                }
            }

            groupLabel("ПЕРЕХОД ПО ССЫЛКЕ").padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text("Режим перехода").font(Typography.bodyMedium)
                        Text("«Сразу» открывает цель в фоне без диалога. Защищённые паролем и недоступные ссылки всегда показывают подтверждение.")
                            .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: Spacing.s12)
                    Picker("", selection: $model.redirectMode) {
                        Text("Сразу").tag(RedirectMode.instant)
                        Text("С подтверждением").tag(RedirectMode.confirm)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: Size.pickerWidth)
                }
            }

            groupLabel("ПО УМОЛЧАНИЮ ДЛЯ НОВЫХ ССЫЛОК").padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    Text("Тип ссылки").font(Typography.bodyMedium)
                    Spacer()
                    Picker("", selection: $model.defKind) {
                        Text("Одноразовая").tag(LinkKind.once)
                        Text("Многоразовая").tag(LinkKind.reuse)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: Size.pickerWidth)
                }
                Divider()
                SettingsRow {
                    Text("Срок действия").font(Typography.bodyMedium)
                    Spacer()
                    Picker("", selection: $model.defLifetime) {
                        Text("1 ч").tag(Lifetime.h1)
                        Text("24 ч").tag(Lifetime.h24)
                        Text("7 дн").tag(Lifetime.d7)
                        Text("Без срока").tag(Lifetime.never)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: Size.pickerWideWidth)
                }
                Divider()
                SettingsToggleRow(title: "Запрашивать пароль", isOn: $model.defPassword)
                Divider()
                SettingsToggleRow(title: "Копировать после создания", isOn: $model.copyOnCreate)
                Divider()
                SettingsToggleRow(title: "Удалять одноразовую после перехода", isOn: $model.deleteOnConsume)
            }

            groupLabel("СИНХРОНИЗАЦИЯ").padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text("Синхронизация через iCloud Drive").font(Typography.bodyEmphasis)
                        Text(model.iCloudAvailable
                             ? "Ссылки хранятся в одном файле в вашем iCloud Drive и синхронизируются между устройствами."
                             : "iCloud Drive недоступен на этом Mac.")
                            .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(get: { model.syncEnabled }, set: { model.setSync($0) }))
                        .labelsHidden().toggleStyle(.switch)
                        .disabled(!model.iCloudAvailable)
                }
            }

            groupLabel("КОМАНДНАЯ СТРОКА").padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text("Команда shortlinks в терминале").font(Typography.bodyEmphasis)
                        cliStatusLine
                    }
                    Spacer(minLength: Spacing.s12)
                    cliActionButton
                }
                if model.cliShowPathHint {
                    Divider()
                    cliPathHint
                }
            }

            groupLabel("ПРИВАТНОСТЬ").padding(.top, Spacing.s22)
            HStack(alignment: .top, spacing: Spacing.s12) {
                IconTile(systemName: "lock.fill", tint: Theme.activeAccent, size: Size.tileLg, weight: .semibold, radius: Radius.md)
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text("Приватность по умолчанию").font(Typography.bodyEmphasis)
                    Text("Ссылки и их цели хранятся только на этом Mac. При включённой синхронизации они идут через ваш личный iCloud Drive — без аккаунтов сервиса и сторонних серверов.")
                        .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Spacing.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(fill: Theme.subtleCardBg)
        }
        .screenContainer(maxWidth: Size.settingsMaxWidth)
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
                .font(Typography.caption).foregroundStyle(Theme.activeAccent)
        case .notInstalled:
            Text("Не установлен. Установите, чтобы вызывать shortlinks из терминала.")
                .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        case .conflict(let reason):
            Text("Конфликт: \(reason)")
                .font(Typography.caption).foregroundStyle(Theme.destructive)
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
        VStack(alignment: .leading, spacing: Spacing.s6) {
            Text("Каталог ~/.local/bin не в PATH. Добавьте строку в профиль шелла (например ~/.zshrc):")
                .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text(model.cliPathExportLine)
                    .font(Typography.monoSmall)
                    .textSelection(.enabled)
                Spacer()
                Button {
                    model.copy(model.cliPathExportLine)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain).foregroundStyle(Theme.accent)
            }
            .padding(.horizontal, Spacing.s8).padding(.vertical, Spacing.s8)
            .codeBox()
        }
        .padding(.horizontal, Spacing.s16).padding(.vertical, Spacing.s14)
    }

    private func groupLabel(_ text: String) -> some View {
        SectionLabel(text)
            .padding(.bottom, Spacing.s8).padding(.leading, Spacing.s2)
    }
}
