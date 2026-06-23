import SwiftUI
import AppKit
import ShortlinksCore

/// Обрабатывает `sl://` и управляет единственным окном через AppKit.
///
/// Окно создаётся лениво и показывается только по требованию. SwiftUI-сцена `Window`
/// здесь намеренно НЕ используется: она выводит окно при запуске, и тогда фоновый
/// переход по `sl://` мигал бы окном на доли секунды. Агент (`LSUIElement`) стартует
/// без окна; окно появляется лишь когда нужен UI (меню-бар, пароль, оверлей перехода).
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var mainWindow: NSWindow?
    /// Запущено ли приложение ради открытия `sl://` (а не кликом по иконке).
    /// `application(_:open:)` приходит после `didFinishLaunching`, поэтому решение о
    /// показе окна при обычном запуске откладываем на следующий тик рунлупа.
    private var didOpenURLAtLaunch = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Привязываем показ/скрытие окна до прихода любого `sl://` — без гонки с
        // онбордингом окна (раньше замыкание ставилось из MainView.onAppear).
        AppModel.shared.openMainWindow = { [weak self] in self?.showMainWindow() }
        AppModel.shared.hideMainWindow = { [weak self] in self?.mainWindow?.orderOut(nil) }
        // Обычный запуск (клик по иконке/Spotlight) показывает окно. Если запуск был
        // ради `sl://`, к этому моменту `application(_:open:)` уже выставит флаг.
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.didOpenURLAtLaunch else { return }
            AppModel.shared.surfaceForInteraction(forRedirect: false)
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        didOpenURLAtLaunch = true
        var surfaceUI = false
        for url in urls where AppModel.shared.handleIncoming(url) { surfaceUI = true }
        if surfaceUI {
            // Нужно взаимодействие (нет ссылки, пароль, недоступна, подтверждение) —
            // временно повысить политику до .regular и показать окно оверлея.
            AppModel.shared.surfaceForInteraction(forRedirect: true)
        }
        // Иначе фоновый переход уже выполнен: окно не создаётся вовсе, мигать нечему.
    }

    /// Повторный клик по иконке уже запущенного агента — показать/поднять окно.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        AppModel.shared.surfaceForInteraction(forRedirect: false)
        return true
    }

    /// Лениво создать и показать главное окно (хост SwiftUI через NSHostingController).
    func showMainWindow() {
        if mainWindow == nil {
            let hosting = NSHostingController(rootView: MainView().environment(AppModel.shared))
            let window = NSWindow(contentViewController: hosting)
            window.title = "Shortlinks"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: Size.windowWidth, height: Size.windowHeight))
            window.contentMinSize = NSSize(width: Size.windowMinWidth, height: Size.windowMinHeight)
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.center()
            mainWindow = window
        }
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    /// Закрытие окна возвращает приложение в фоновый режim (без иконки в Dock).
    func windowWillClose(_ notification: Notification) {
        AppModel.shared.returnToBackground()
    }
}

@main
struct ShortlinksApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var model = AppModel.shared

    var body: some Scene {
        MenuBarExtra("Shortlinks", systemImage: Icons.menuBar) {
            MenuBarContent()
                .environment(model)
        }
    }
}

struct MenuBarContent: View {
    @Environment(AppModel.self) private var model

    /// Поднять окно из меню-бара: агент (.accessory) → .regular, показать окно.
    /// `forRedirect: false` — окно открыто пользователем, авто-возврат в фон не нужен.
    private func surface() {
        model.surfaceForInteraction(forRedirect: false)
    }

    var body: some View {
        Button(Strings.Common.newLink) {
            surface()
            model.openCreate()
        }
        Button(Strings.Menu.openWindow) {
            surface()
        }
        Divider()
        let recent = Array(model.links.prefix(5))
        if recent.isEmpty {
            Text(Strings.Menu.noLinks).foregroundStyle(.secondary)
        } else {
            ForEach(recent) { link in
                Button(link.fullURL) {
                    surface()
                    model.openDetail(link.id)
                }
            }
        }
        Divider()
        Button(Strings.Menu.quit) { NSApplication.shared.terminate(nil) }
    }
}
