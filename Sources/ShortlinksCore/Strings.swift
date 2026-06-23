import Foundation

/// Единый типизированный реестр пользовательских строк (приложение + ядро + CLI).
///
/// Русский текст — значение-источник (`defaultValue`); переводы добавляются в
/// `Localizable.xcstrings` без правок кода. Доступ к строкам — только через этот реестр:
/// во вью/CLI/презентационных хелперах ядра не должно оставаться сырых строковых
/// литералов. См. [[localization]] и `Localization`.
public enum Strings {

    // MARK: - Общие

    public enum Common {
        public static var cancel: String { L("common.cancel", "Отмена") }
        public static var delete: String { L("common.delete", "Удалить") }
        public static var done: String { L("common.done", "Готово") }
        public static var close: String { L("common.close", "Закрыть") }
        public static var copy: String { L("common.copy", "Копировать") }
        public static var newLink: String { L("common.newLink", "Новая ссылка") }
        public static var password: String { L("common.password", "Пароль") }
        public static var install: String { L("common.install", "Установить") }
        public static var notNow: String { L("common.notNow", "Не сейчас") }
        public static var lifetimeTitle: String { L("common.lifetime", "Срок действия") }
        public static var linkUnavailable: String { L("common.linkUnavailable", "Ссылка недоступна") }
    }

    // MARK: - Статусы и типы

    public enum Status {
        public static var active: String { L("status.active", "Активна") }
        public static var viewed: String { L("status.viewed", "Просмотрена") }
        public static var disabled: String { L("status.disabled", "Деактивирована") }
        public static var expired: String { L("status.expired", "Истекла") }
    }

    public enum Kind {
        public static var once: String { L("kind.once", "Одноразовая") }
        public static var reuse: String { L("kind.reuse", "Многоразовая") }
    }

    public enum Target {
        public static var web: String { L("target.web", "Открыть в браузере") }
        public static var file: String { L("target.file", "Открыть файл") }
        public static var app: String { L("target.app", "Открыть в приложении") }
        public static var text: String { L("target.text", "Показать содержимое") }
    }

    public enum LifetimeLabel {
        public static var h1: String { L("lifetime.h1", "1 ч") }
        public static var h24: String { L("lifetime.h24", "24 ч") }
        public static var d7: String { L("lifetime.d7", "7 дн") }
        public static var neverShort: String { L("lifetime.neverShort", "∞") }
        public static var never: String { L("lifetime.never", "Без срока") }
    }

    // MARK: - Срок действия / подпись строки списка (Format)

    public enum Expiry {
        public static var none: String { L("expiry.none", "Без срока") }
        public static var expired: String { L("expiry.expired", "Истёк") }
        public static var soon: String { L("expiry.soon", "скоро") }
        public static var lessThanHour: String { L("expiry.lessThanHour", "менее часа") }
        public static func hours(_ n: Int) -> String { P("expiry.hours", n, ["час", "часа", "часов"]) }
        public static func days(_ n: Int) -> String { P("expiry.days", n, ["день", "дня", "дней"]) }
    }

    public enum Subtitle {
        public static func onceExpires(_ kind: String, _ expiry: String) -> String {
            L("subtitle.onceExpires", "\(kind) · истекает \(expiry)")
        }
        public static func onceNoExpiry(_ kind: String) -> String {
            L("subtitle.onceNoExpiry", "\(kind) · без срока")
        }
        public static func reuse(_ kind: String, _ opens: String) -> String {
            L("subtitle.reuse", "\(kind) · \(opens)")
        }
        public static func viewed(_ kind: String) -> String {
            L("subtitle.viewed", "\(kind) · потреблена")
        }
        public static func disabled(_ kind: String) -> String {
            L("subtitle.disabled", "\(kind) · деактивирована")
        }
        public static func expired(_ kind: String) -> String {
            L("subtitle.expired", "\(kind) · срок истёк")
        }
    }

    /// Число переходов: «1 переход», «2 перехода», «5 переходов».
    public static func opensCount(_ n: Int) -> String {
        P("opens.count", n, ["переход", "перехода", "переходов"])
    }

    // MARK: - Меню-бар

    public enum Menu {
        public static var openWindow: String { L("menu.openWindow", "Открыть окно") }
        public static var noLinks: String { L("menu.noLinks", "Нет ссылок") }
        public static var quit: String { L("menu.quit", "Выйти") }
    }

    // MARK: - Главный экран / тулбар

    public enum Main {
        public static var search: String { L("main.search", "Поиск") }
        public static var deleteSelected: String { L("main.deleteSelected", "Удалить выбранные") }
        public static var selectMultiple: String { L("main.selectMultiple", "Выбрать несколько") }
        public static func selectedCount(_ n: Int) -> String { L("main.selectedCount", "Выбрано: \(n)") }
        /// «Удалить N ссылку/ссылки/ссылок?»
        public static func deleteConfirm(_ n: Int) -> String {
            Localization.plural("main.deleteConfirm", n)
                ?? "Удалить \(n) \(Format.plural(n, ["ссылку", "ссылки", "ссылок"]))?"
        }
    }

    public enum CLIOnboarding {
        public static var title: String { L("cliOnboarding.title", "Установить команду «shortlinks»?") }
        public static var body: String {
            L("cliOnboarding.body", "Команда станет доступна в терминале (симлинк в ~/.local/bin, без пароля администратора). Это можно сделать позже в Настройках.")
        }
    }

    // MARK: - Создание ссылки

    public enum Create {
        public static var subtitle: String { L("create.subtitle", "Цель хранится локально и открывается по короткому адресу.") }
        public static var targetLabel: String { L("create.targetLabel", "Цель перехода") }
        public static var targetPlaceholder: String { L("create.targetPlaceholder", "https://, sl-app://, file:// или путь") }
        public static var shortLabel: String { L("create.shortLabel", "Короткий адрес") }
        public static var namePlaceholder: String { L("create.namePlaceholder", "имя") }
        public static var random: String { L("create.random", "Случайный") }
        public static var typeLabel: String { L("create.typeLabel", "Тип") }
        public static var tagsLabel: String { L("create.tagsLabel", "Метки") }
        public static var addTag: String { L("create.addTag", "Добавить метку…") }
        public static var passwordProtect: String { L("create.passwordProtect", "Защитить паролем") }
        public static var passwordHint: String { L("create.passwordHint", "Запросить пароль перед переходом") }
        public static var submit: String { L("create.submit", "Создать ссылку") }
    }

    // MARK: - Список и пустое состояние

    public enum List {
        public static var open: String { L("list.open", "Открыть") }
        public static var copyAddress: String { L("list.copyAddress", "Скопировать адрес") }
        public static var activate: String { L("list.activate", "Активировать") }
        public static var deactivate: String { L("list.deactivate", "Деактивировать") }
        public static var emptyTitle: String { L("list.emptyTitle", "Здесь пока пусто") }
        public static var emptySubtitle: String { L("list.emptySubtitle", "Создайте короткую ссылку — она будет работать на этом Mac.") }
    }

    // MARK: - Карточка ссылки

    public enum Detail {
        public static var back: String { L("detail.back", "Все ссылки") }
        public static var redirectsTo: String { L("detail.redirectsTo", "Перенаправляет на") }
        public static var type: String { L("detail.type", "Тип") }
        public static var opens: String { L("detail.opens", "Переходов") }
        public static var password: String { L("detail.password", "Пароль") }
        public static var passwordOn: String { L("detail.passwordOn", "Включён") }
        public static var passwordOff: String { L("detail.passwordOff", "Нет") }
        public static var tags: String { L("detail.tags", "Метки") }
        public static var created: String { L("detail.created", "Создана") }
    }

    // MARK: - Оверлей перехода

    public enum Redirect {
        public static var confirmTitle: String { L("redirect.confirmTitle", "Открыть ссылку?") }
        public static var confirmBody: String { L("redirect.confirmBody", "Этот короткий адрес перенаправит вас на:") }
        public static var onceWarning: String { L("redirect.onceWarning", "Одноразовая ссылка. После перехода она станет недоступной.") }
        public static var consumedTitle: String { L("redirect.consumedTitle", "Открыто") }
        public static var consumedBody: String { L("redirect.consumedBody", "Переход выполнен. Эта одноразовая ссылка сгорела и больше недоступна.") }
        public static var notFound: String { L("redirect.notFound", "Короткая ссылка не найдена на этом Mac.") }
        public static var alreadyViewed: String { L("redirect.alreadyViewed", "Эта ссылка уже была просмотрена. Одноразовые ссылки нельзя открыть повторно.") }
        public static var expired: String { L("redirect.expired", "Срок действия ссылки истёк.") }
    }

    // MARK: - Настройки

    public enum Settings {
        public static var sectionHandler: String { L("settings.section.handler", "РАЗРЕШЕНИЕ ССЫЛОК") }
        public static var handlerTitle: String { L("settings.handler.title", "Обработчик схемы sl://") }
        public static var handlerHint: String { L("settings.handler.hint", "Приложение зарегистрировано как обработчик ссылок для этого Mac.") }

        public static var sectionRedirect: String { L("settings.section.redirect", "ПЕРЕХОД ПО ССЫЛКЕ") }
        public static var redirectTitle: String { L("settings.redirect.title", "Режим перехода") }
        public static var redirectHint: String { L("settings.redirect.hint", "«Сразу» открывает цель в фоне без диалога. Защищённые паролем и недоступные ссылки всегда показывают подтверждение.") }
        public static var redirectInstant: String { L("settings.redirect.instant", "Сразу") }
        public static var redirectConfirm: String { L("settings.redirect.confirm", "С подтверждением") }

        public static var sectionDefaults: String { L("settings.section.defaults", "ПО УМОЛЧАНИЮ ДЛЯ НОВЫХ ССЫЛОК") }
        public static var defaultsType: String { L("settings.defaults.type", "Тип ссылки") }
        public static var defaultsAskPassword: String { L("settings.defaults.askPassword", "Запрашивать пароль") }
        public static var defaultsCopyOnCreate: String { L("settings.defaults.copyOnCreate", "Копировать после создания") }
        public static var defaultsDeleteOnConsume: String { L("settings.defaults.deleteOnConsume", "Удалять одноразовую после перехода") }

        public static var sectionSync: String { L("settings.section.sync", "СИНХРОНИЗАЦИЯ") }
        public static var syncTitle: String { L("settings.sync.title", "Синхронизация через iCloud Drive") }
        public static var syncAvailable: String { L("settings.sync.available", "Ссылки хранятся в одном файле в вашем iCloud Drive и синхронизируются между устройствами.") }
        public static var syncUnavailable: String { L("settings.sync.unavailable", "iCloud Drive недоступен на этом Mac.") }

        public static var sectionCLI: String { L("settings.section.cli", "КОМАНДНАЯ СТРОКА") }
        public static var cliTitle: String { L("settings.cli.title", "Команда shortlinks в терминале") }
        public static func cliInstalled(_ path: String) -> String { L("settings.cli.installed", "Установлен · \(path)") }
        public static var cliNotInstalled: String { L("settings.cli.notInstalled", "Не установлен. Установите, чтобы вызывать shortlinks из терминала.") }
        public static func cliConflict(_ reason: String) -> String { L("settings.cli.conflict", "Конфликт: \(reason)") }
        public static var cliUninstall: String { L("settings.cli.uninstall", "Удалить CLI") }
        public static var cliInstall: String { L("settings.cli.install", "Установить CLI") }
        public static var cliPathHint: String { L("settings.cli.pathHint", "Каталог ~/.local/bin не в PATH. Добавьте строку в профиль шелла (например ~/.zshrc):") }

        public static var sectionPrivacy: String { L("settings.section.privacy", "ПРИВАТНОСТЬ") }
        public static var privacyTitle: String { L("settings.privacy.title", "Приватность по умолчанию") }
        public static var privacyBody: String { L("settings.privacy.body", "Ссылки и их цели хранятся только на этом Mac. При включённой синхронизации они идут через ваш личный iCloud Drive — без аккаунтов сервиса и сторонних серверов.") }
    }

    // MARK: - Сайдбар

    public enum Sidebar {
        public static var sectionLibrary: String { L("sidebar.section.library", "БИБЛИОТЕКА") }
        public static var all: String { L("sidebar.all", "Все ссылки") }
        public static var active: String { L("sidebar.active", "Активные") }
        public static var once: String { L("sidebar.once", "Одноразовые") }
        public static var expired: String { L("sidebar.expired", "Истёкшие") }
        public static var sectionTags: String { L("sidebar.section.tags", "ТЕГИ") }
        public static var settings: String { L("sidebar.settings", "Настройки") }
        public static var how: String { L("sidebar.how", "Как это работает") }
        public static var syncOn: String { L("sidebar.syncOn", "Синхронизируется через iCloud Drive") }
        public static var syncOff: String { L("sidebar.syncOff", "Хранится локально на этом Mac") }
    }

    // MARK: - Как это работает

    public enum HowItWorks {
        public static var title: String { L("how.title", "Короткая ссылка, которая живёт на вашем Mac") }
        public static var intro: String { L("how.intro", "Вы создаёте адрес вида sl://link/имя. Когда его открывают, система ловит схему и перенаправляет на полную цель — приложение, файл или сайт.") }
        public static var step1Title: String { L("how.step1.title", "Создаёте ссылку") }
        public static var step1Body: String { L("how.step1.body", "Указываете цель и получаете короткий адрес sl://link/…") }
        public static var step2Title: String { L("how.step2.title", "Делитесь") }
        public static var step2Body: String { L("how.step2.body", "Отправляете адрес любым способом — он короткий и не раскрывает цель.") }
        public static var step3Title: String { L("how.step3.title", "Переход") }
        public static var step3Body: String { L("how.step3.body", "Система открывает приложение или браузер по сохранённой цели.") }
        public static var step4Title: String { L("how.step4.title", "Сгорает") }
        public static var step4Body: String { L("how.step4.body", "Одноразовая ссылка становится недоступной после первого перехода.") }
    }

    // MARK: - Тосты

    public enum Toast {
        public static var opened: String { L("toast.opened", "Открыто · ссылка сгорела") }
        public static var redirected: String { L("toast.redirected", "Переход выполнен") }
        public static var wrongPassword: String { L("toast.wrongPassword", "Неверный пароль") }
        public static func copied(_ text: String) -> String { L("toast.copied", "Скопировано: \(text)") }
        public static var icloudUnavailable: String { L("toast.icloudUnavailable", "iCloud Drive недоступен") }
        public static var cliInstalled: String { L("toast.cliInstalled", "CLI установлен") }
        public static var cliRemoved: String { L("toast.cliRemoved", "CLI удалён") }
    }

    // MARK: - CLI

    public enum CLI {
        public static var rootAbstract: String { L("cli.root.abstract", "Локальные короткие ссылки sl://link/<slug>") }
        public static var langHelp: String { L("cli.lang.help", "Язык вывода (например ru, en)") }
        public static var slugHelp: String { L("cli.slug.help", "slug ссылки") }

        public static var addAbstract: String { L("cli.add.abstract", "Создать короткую ссылку") }
        public static var addTarget: String { L("cli.add.target", "Цель перехода: https://, file://, app-scheme:// или путь") }
        public static var addSlug: String { L("cli.add.slug", "Короткий slug (по умолчанию случайный)") }
        public static var addOnce: String { L("cli.add.once", "Одноразовая ссылка («сгорает» после первого перехода)") }
        public static var addReuse: String { L("cli.add.reuse", "Многоразовая ссылка (по умолчанию)") }
        public static var addTTL: String { L("cli.add.ttl", "Срок действия: 1h | 24h | 7d | never") }
        public static var addPassword: String { L("cli.add.password", "Пароль, запрашиваемый перед переходом") }
        public static var addTag: String { L("cli.add.tag", "Тег (можно повторять)") }
        public static var errBothFlags: String { L("cli.add.errBothFlags", "Укажите только один из флагов --once / --reuse") }
        public static var errTTL: String { L("cli.add.errTTL", "Некорректный --ttl. Допустимо: 1h, 24h, 7d, never") }

        public static var listAbstract: String { L("cli.list.abstract", "Показать ссылки") }
        public static var listFilter: String { L("cli.list.filter", "Фильтр: all | active | once | expired") }
        public static var listTag: String { L("cli.list.tag", "Только с этим тегом") }
        public static var listEmpty: String { L("cli.list.empty", "Ссылок нет.") }

        public static var rmAbstract: String { L("cli.rm.abstract", "Удалить ссылку по slug") }
        public static func removed(_ url: String) -> String { L("cli.rm.removed", "Удалено: \(url)") }

        public static var resolveAbstract: String { L("cli.resolve.abstract", "Напечатать цель ссылки") }

        public static var openAbstract: String { L("cli.open.abstract", "Открыть цель ссылки") }
        public static var openPassword: String { L("cli.open.password", "Пароль, если ссылка защищена") }
        public static var openDeleteOnConsume: String { L("cli.open.deleteOnConsume", "Удалить одноразовую сразу после перехода") }

        public static func errNotFound(_ slug: String) -> String { L("cli.err.notFound", "Ссылка не найдена: \(slug)") }
        public static var errUnavailable: String { L("cli.err.unavailable", "Ссылка недоступна (истекла или уже потреблена)") }
        public static var errPasswordRequired: String { L("cli.err.passwordRequired", "Требуется верный --password") }
    }

    // MARK: - Установщик CLI (CLIInstaller)

    public enum CLIInstall {
        public static func foreignObject(_ path: String) -> String {
            L("cliInstall.foreignObject", "Путь \(path) занят посторонним объектом — он не будет изменён")
        }
        public static func conflictForeignFile(_ path: String) -> String {
            L("cliInstall.conflictForeignFile", "По пути \(path) лежит посторонний файл")
        }
        public static func conflictOtherBundle(_ path: String) -> String {
            L("cliInstall.conflictOtherBundle", "Симлинк указывает на другой бандл Shortlinks: \(path)")
        }
        public static func conflictForeignLink(_ path: String) -> String {
            L("cliInstall.conflictForeignLink", "По пути \(path) симлинк на посторонний объект")
        }
    }
}

// MARK: - Хелперы доступа

/// Короткий локализатор: ключ + русское значение-источник.
private func L(_ key: StaticString, _ ru: String.LocalizationValue) -> String {
    Localization.string(key, ru)
}

/// Склонение: из каталога, иначе русский фолбэк «N форма» по правилам `Format.plural`.
private func P(_ key: String, _ n: Int, _ forms: [String]) -> String {
    Localization.plural(key, n) ?? "\(n) \(Format.plural(n, forms))"
}
