import SwiftUI
import ShortlinksCore

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var handlerOn = false

    var body: some View {
        @Bindable var model = model
        VStack(alignment: .leading, spacing: 0) {
            groupLabel(Strings.Settings.sectionHandler)
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text(Strings.Settings.handlerTitle).font(Typography.bodyEmphasis)
                        Text(Strings.Settings.handlerHint)
                            .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: $handlerOn).labelsHidden().toggleStyle(.switch)
                        .onChange(of: handlerOn) { _, on in if on { model.setDefaultHandler(true) } }
                }
            }

            groupLabel(Strings.Settings.sectionRedirect).padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text(Strings.Settings.redirectTitle).font(Typography.bodyMedium)
                        Text(Strings.Settings.redirectHint)
                            .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: Spacing.s12)
                    Picker("", selection: $model.redirectMode) {
                        Text(Strings.Settings.redirectInstant).tag(RedirectMode.instant)
                        Text(Strings.Settings.redirectConfirm).tag(RedirectMode.confirm)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: Size.pickerWidth)
                }
            }

            groupLabel(Strings.Settings.sectionDefaults).padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    Text(Strings.Settings.defaultsType).font(Typography.bodyMedium)
                    Spacer()
                    Picker("", selection: $model.defKind) {
                        Text(Strings.Kind.once).tag(LinkKind.once)
                        Text(Strings.Kind.reuse).tag(LinkKind.reuse)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: Size.pickerWidth)
                }
                Divider()
                SettingsRow {
                    Text(Strings.Common.lifetimeTitle).font(Typography.bodyMedium)
                    Spacer()
                    Picker("", selection: $model.defLifetime) {
                        Text(Strings.LifetimeLabel.h1).tag(Lifetime.h1)
                        Text(Strings.LifetimeLabel.h24).tag(Lifetime.h24)
                        Text(Strings.LifetimeLabel.d7).tag(Lifetime.d7)
                        Text(Strings.LifetimeLabel.never).tag(Lifetime.never)
                    }.pickerStyle(.segmented).labelsHidden().frame(width: Size.pickerWideWidth)
                }
                Divider()
                SettingsToggleRow(title: Strings.Settings.defaultsAskPassword, isOn: $model.defPassword)
                Divider()
                SettingsToggleRow(title: Strings.Settings.defaultsCopyOnCreate, isOn: $model.copyOnCreate)
                Divider()
                SettingsToggleRow(title: Strings.Settings.defaultsDeleteOnConsume, isOn: $model.deleteOnConsume)
            }

            groupLabel(Strings.Settings.sectionSync).padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text(Strings.Settings.syncTitle).font(Typography.bodyEmphasis)
                        Text(model.iCloudAvailable
                             ? Strings.Settings.syncAvailable
                             : Strings.Settings.syncUnavailable)
                            .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(get: { model.syncEnabled }, set: { model.setSync($0) }))
                        .labelsHidden().toggleStyle(.switch)
                        .disabled(!model.iCloudAvailable)
                }
            }

            groupLabel(Strings.Settings.sectionCLI).padding(.top, Spacing.s22)
            SettingsCard {
                SettingsRow {
                    VStack(alignment: .leading, spacing: Spacing.s4) {
                        Text(Strings.Settings.cliTitle).font(Typography.bodyEmphasis)
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

            groupLabel(Strings.Settings.sectionPrivacy).padding(.top, Spacing.s22)
            HStack(alignment: .top, spacing: Spacing.s12) {
                IconTile(systemName: Icons.Status.privacy, tint: Theme.activeAccent, size: Size.tileLg, weight: .semibold, radius: Radius.md)
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text(Strings.Settings.privacyTitle).font(Typography.bodyEmphasis)
                    Text(Strings.Settings.privacyBody)
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
            Text(Strings.Settings.cliInstalled(path))
                .font(Typography.caption).foregroundStyle(Theme.activeAccent)
        case .notInstalled:
            Text(Strings.Settings.cliNotInstalled)
                .font(Typography.caption).foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        case .conflict(let reason):
            Text(Strings.Settings.cliConflict(reason))
                .font(Typography.caption).foregroundStyle(Theme.destructive)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var cliActionButton: some View {
        switch model.cliStatus {
        case .installed:
            Button(Strings.Settings.cliUninstall) { model.uninstallCLI() }
        case .notInstalled, .conflict:
            Button(Strings.Settings.cliInstall) { model.installCLI() }
                .buttonStyle(.borderedProminent).tint(Theme.accent)
        }
    }

    private var cliPathHint: some View {
        VStack(alignment: .leading, spacing: Spacing.s6) {
            Text(Strings.Settings.cliPathHint)
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
                    Image(systemName: Icons.Action.copyPath)
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
