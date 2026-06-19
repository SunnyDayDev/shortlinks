import SwiftUI
import AppKit
import ShortlinksCore

@main
struct ShortlinksApp: App {
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
