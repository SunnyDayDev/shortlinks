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
        .alert("Установить команду «shortlinks»?", isPresented: $model.showCLIOnboarding) {
            Button("Установить") { model.acceptCLIOnboarding() }
            Button("Не сейчас", role: .cancel) { model.declineCLIOnboarding() }
        } message: {
            Text("Команда станет доступна в терминале (симлинк в ~/.local/bin, без пароля администратора). Это можно сделать позже в Настройках.")
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
            "Удалить \(model.selection.count) \(Format.plural(model.selection.count, ["ссылку", "ссылки", "ссылок"]))?",
            isPresented: $showBulkDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) { model.deleteSelected() }
            Button("Отмена", role: .cancel) {}
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
            Text("Выбрано: \(model.selection.count)")
                .font(Typography.body)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Button(action: { withAnimation(.easeInOut(duration: 0.22)) { model.toggleEditing() } }) {
                Text("Готово")
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
                    Image(systemName: "magnifyingglass")
                        .font(Typography.glyphSmall)
                        .foregroundStyle(Theme.textSecondary)
                    TextField("Поиск", text: $model.query)
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
                        Image(systemName: model.editing ? "trash" : "square.and.pencil")
                            .font(Typography.glyphAction)
                            .foregroundStyle(editIconColor)
                            .frame(width: Size.controlHeight, height: Size.controlHeight)
                            .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: Radius.md))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(model.editing && !model.canDeleteSelected)
                    .help(model.editing ? "Удалить выбранные" : "Выбрать несколько")
                }
            }

            Button(action: { model.openCreate() }) {
                HStack(spacing: Spacing.s6) {
                    Image(systemName: "plus")
                    Text("Новая ссылка")
                }
            }
            .buttonStyle(PrimaryButtonStyle(size: .small))
        }
        .padding(.horizontal, Spacing.s16)
        .frame(height: Size.toolbarHeight)
    }
}
