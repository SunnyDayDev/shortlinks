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
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(Color(hex: 0x1C1C1E, alpha: 0.92), in: RoundedRectangle(cornerRadius: 9))
                        .padding(.bottom, 18)
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
        .background(Color(nsColor: .textBackgroundColor))
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
        return model.canDeleteSelected ? Color(hex: 0xC0392B) : Theme.secondaryText
    }

    private var bulkBar: some View {
        HStack(spacing: 12) {
            Text("Выбрано: \(model.selection.count)")
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
            Spacer()
            Button(action: { withAnimation(.easeInOut(duration: 0.22)) { model.toggleEditing() } }) {
                Text("Готово")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 14).frame(height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
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
        return HStack(spacing: 12) {
            Text(model.toolbarTitle)
                .font(.system(size: 15, weight: .bold))
                .lineLimit(1)
                .frame(maxWidth: 360, alignment: .leading)
            Spacer()
            if model.screen == .library && model.selectedLink == nil {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                    TextField("Поиск", text: $model.query)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                }
                .padding(.horizontal, 10)
                .frame(width: 200, height: 30)
                .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: 7))

                if !model.filteredLinks.isEmpty {
                    Button(action: {
                        if model.editing {
                            showBulkDeleteConfirm = true
                        } else {
                            withAnimation(.easeInOut(duration: 0.22)) { model.toggleEditing() }
                        }
                    }) {
                        Image(systemName: model.editing ? "trash" : "square.and.pencil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(editIconColor)
                            .frame(width: 30, height: 30)
                            .background(Theme.subtleFill, in: RoundedRectangle(cornerRadius: 7))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(model.editing && !model.canDeleteSelected)
                    .help(model.editing ? "Удалить выбранные" : "Выбрать несколько")
                }
            }

            Button(action: { model.openCreate() }) {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                    Text("Новая ссылка")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 13).frame(height: 30)
                .background(Theme.accent, in: RoundedRectangle(cornerRadius: 7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
}
