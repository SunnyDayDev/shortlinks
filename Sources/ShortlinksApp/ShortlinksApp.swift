import SwiftUI
import AppKit
import ShortlinksCore

/// Обрабатывает `sl://` на уровне приложения, чтобы фоновый режим не выводил окно.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        var surfaceUI = false
        for url in urls where AppModel.shared.handleIncoming(url) { surfaceUI = true }
        if surfaceUI {
            // Нужно взаимодействие (нет ссылки, пароль, недоступна) — показать приложение.
            NSApp.activate(ignoringOtherApps: true)
            AppModel.shared.openMainWindow?()
        } else {
            // Фоновый переход выполнен — не удерживать фокус на приложении.
            NSApp.hide(nil)
        }
    }
}

@main
struct ShortlinksApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var model = AppModel.shared

    var body: some Scene {
        Window("Shortlinks", id: "main") {
            MainView()
                .environment(model)
                .frame(minWidth: 880, minHeight: 600)
        }
        .windowResizability(.contentMinSize)

        MenuBarExtra("Shortlinks", systemImage: "link") {
            MenuBarContent()
                .environment(model)
        }
    }
}

struct MenuBarContent: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Новая ссылка") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
            model.openCreate()
        }
        Button("Открыть окно") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }
        Divider()
        let recent = Array(model.links.prefix(5))
        if recent.isEmpty {
            Text("Нет ссылок").foregroundStyle(.secondary)
        } else {
            ForEach(recent) { link in
                Button(link.fullURL) {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                    model.openDetail(link.id)
                }
            }
        }
        Divider()
        Button("Выйти") { NSApplication.shared.terminate(nil) }
    }
}
