import SwiftUI
import ShortlinksCore

struct MainView: View {
    @Environment(AppModel.self) private var model
    @State private var showBulkDeleteConfirm = false

    var body: some View {
        @Bindable var model = model
        ZStack {
            HStack(spacing: 0) {
                SidebarView()
                Divider()
                content
            }

            if model.redirectSlug != nil {
                RedirectOverlay()
            }

            if let toast = model.toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(Typography.captionMedium)
                        .foregroundStyle(Theme.onAccent)
                        .padding(.horizontal, Spacing.s16).padding(.vertical, Spacing.s8)
                        .background(Theme.toastBg, in: RoundedRectangle(cornerRadius: Radius.md))
                        .padding(.bottom, Spacing.s18)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.18), value: model.toast)
        .sheet(isPresented: $model.showCreate) { CreateSheet() }
        .alert(Strings.CLIOnboarding.title, isPresented: $model.showCLIOnboarding) {
            Button(Strings.Common.install) { model.acceptCLIOnboarding() }
            Button(Strings.Common.notNow, role: .cancel) { model.declineCLIOnboarding() }
        } message: {
            Text(Strings.CLIOnboarding.body)
        }
        .onAppear {
            model.maybeOfferCLIOnboarding()
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            ScrollView { contentBody }
            if isListVisible && model.editing {
                bulkBar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.content)
        .confirmationDialog(
            Strings.Main.deleteConfirm(model.selection.count),
            isPresented: $showBulkDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(Strings.Common.delete, role: .destructive) { model.deleteSelected() }
            Button(Strings.Common.cancel, role: .cancel) {}
        }
    }

    /// Виден ли список ссылок (а не карточка/настройки).
    private var isListVisible: Bool {
        model.screen == .library && model.selectedLink == nil
    }

    /// Цвет иконки-переключателя режима в тулбаре.
    private var editIconColor: Color {
        guard model.editing else { return Theme.accent }
        return model.canDeleteSelected ? Theme.destructive : Theme.textSecondary
    }

    private var bulkBar: some View {
        HStack(spacing: Spacing.s12) {
            Text(Strings.Main.selectedCount(model.selection.count))
                .font(Typography.body)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Button(action: { withAnimation(.easeInOut(duration: 0.22)) { model.toggleEditing() } }) {
                Text(Strings.Common.done)
                    .font(Typography.bodyEmphasis)
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, Spacing.s12).frame(height: Size.controlHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.s16)
        .frame(height: Size.bulkBarHeight)
        .background(.bar)
        .overlay(Divider(), alignment: .top)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    @ViewBuilder
    private var contentBody: some View {
        if model.selectedLink != nil {
            LinkDetailView()
        } else {
            switch model.screen {
            case .library: LinkListView()
            case .settings: SettingsView()
            case .how: HowItWorksView()
            }
        }
    }

    private var toolbar: some View {
        @Bindable var model = model
        return HStack(spacing: Spacing.s12) {
            Text(model.toolbarTitle)
                .font(Typography.headline)
                .lineLimit(1)
                .frame(maxWidth: Size.toolbarTitleMaxWidth, alignment: .leading)
            Spacer()
            if model.screen == .library && model.selectedLink == nil {
                HStack(spacing: Spacing.s6) {
                    Image(systemName: Icons.Action.search)
                        .font(Typography.glyphSmall)
                        .foregroundStyle(Theme.textSecondary)
                    TextField(Strings.Main.search, text: $model.query)
                        .textFieldStyle(.plain)
                        .font(Typography.body)
                }
                .padding(.horizontal, Spacing.s8)
                .frame(width: Size.searchWidth, height: Size.controlHeight)
                .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: Radius.md))

                if !model.filteredLinks.isEmpty {
                    Button(action: {
                        if model.editing {
                            showBulkDeleteConfirm = true
                        } else {
                            withAnimation(.easeInOut(duration: 0.22)) { model.toggleEditing() }
                        }
                    }) {
                        Image(systemName: model.editing ? Icons.Action.delete : Icons.Action.edit)
                            .font(Typography.glyphAction)
                            .foregroundStyle(editIconColor)
                            .frame(width: Size.controlHeight, height: Size.controlHeight)
                            .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: Radius.md))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(model.editing && !model.canDeleteSelected)
                    .help(model.editing ? Strings.Main.deleteSelected : Strings.Main.selectMultiple)
                }
            }

            Button(action: { model.openCreate() }) {
                HStack(spacing: Spacing.s6) {
                    Image(systemName: Icons.Action.add)
                    Text(Strings.Common.newLink)
                }
            }
            .buttonStyle(PrimaryButtonStyle(size: .small))
        }
        .padding(.horizontal, Spacing.s16)
        .frame(height: Size.toolbarHeight)
    }
}
