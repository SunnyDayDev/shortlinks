import SwiftUI
import ShortlinksCore

struct MainView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openWindow) private var openWindow

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
        .onAppear { model.openMainWindow = { openWindow(id: "main") } }
    }

    private var content: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            ScrollView { contentBody }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
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
