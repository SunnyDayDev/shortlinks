## 1. Инфраструктура локализации и иконок

- [x] 1.1 В ShortlinksCore добавить локатор `Bundle.shortlinks` (приложение → `Bundle.main`;
  встроенный CLI → `Contents/Resources` через `Bundle.main.bundleURL/../Resources`,
  `Bundle(url:)`; фолбэк → `.main`). Безопасен, если каталог не найден.
- [x] 1.2 Создать `Sources/ShortlinksApp/Localizable.xcstrings` с dev-регионом `ru`. Завести
  plural-ключи (CLDR one/few/many/other): переходы, часы, дни, «Удалить N ссылок» и счётчик
  «Выбрано: N». Non-plural ключи опираются на `defaultValue` в коде (заполнение переводов —
  будущая итерация).
- [x] 1.3 Создать `public enum Strings` в ShortlinksCore: вложенные namespace
  (`Common`, `Status`, `Create`, `List`, `Detail`, `Redirect`, `Settings`, `Sidebar`,
  `HowItWorks`, `Toast`, `CLI`). Каждый аксессор —
  `String(localized:defaultValue:bundle:.shortlinks, comment:)`. На этом шаге — каркас +
  `Common`/`Status`; остальные namespace наполняются в группах 2–4 при миграции каждой
  поверхности.
- [x] 1.4 Создать реестр `enum Icons` в `Sources/ShortlinksApp/DesignSystem/` (сгруппированные
  константы имён всех ~16 SF Symbols: навигация, действия, фильтры сайдбара, статусы,
  предупреждения/ошибки).
- [x] 1.5 `project.yml`: добавить ресурс `Localizable.xcstrings` в таргет ShortlinksApp,
  выставить `CFBundleDevelopmentRegion: ru` и `CFBundleLocalizations: [ru]`; выполнить
  `xcodegen generate`.
- [x] 1.6 Слой выбора локали в ShortlinksCore: приоритет `--lang` → `LC_ALL`/`LC_MESSAGES`/
  `LANG` → системные предпочтения → язык-источник; POSIX-маппинг (`ru_RU.UTF-8`→`ru`),
  `C`/`POSIX`/нераспознанное → источник; выбор `<lang>.lproj` через
  `preferredLocalizations(from:forPreferences:)`. Слой отдаёт и bundle/язык для строк, и
  согласованную `Locale` для форматтеров.

## 2. Миграция ShortlinksCore

- [x] 2.1 `Format.swift`: лейблы `kindLabel`/`statusLabel`, тексты подзаголовков и срока →
  `Strings.Status.*`/`Strings.Common.*`. Счётчики (`opensText`, часы/дни в `shortExpiry`)
  перевести на plural-ключи каталога; ручной `Format.plural` ретайрить (удалить либо свести к
  тонкой обёртке над `String(localized:)`).
- [x] 2.2 `Format.expiresText`: заменить `Locale(identifier: "ru_RU")` в `DateFormatter` на
  `Locale` из слоя выбора локали (1.6).
- [x] 2.3 `Scheme.swift`: лейблы целей («Открыть в браузере»/«…файл»/«…в приложении»/«Показать
  содержимое») → `Strings.Common.*`.
- [x] 2.4 Проверка: ShortlinksCore собирается; в `Format.swift`/`Scheme.swift` нет
  пользовательских строковых литералов.

## 3. Миграция приложения (вью, тосты, иконки)

- [x] 3.1 Заменить сырые имена SF Symbols на `Icons.*` на всех call-site’ах
  (`Image(systemName:)`, `Label(_, systemImage:)`, `IconTile(systemName:)`) в `Views/*`,
  `MainView.swift`, `Badges.swift`, `SidebarView.swift`, `SettingsView.swift`.
- [x] 3.2 Перенести строки вью в `Strings.*` и заменить литералы: `CreateSheet`, `LinkListView`
  (вкл. пустое состояние и контекст-меню), `LinkDetailView`, `RedirectOverlay`, `SettingsView`,
  `SidebarView`, `HowItWorksView`, `MainView` (заголовки, поиск, алерт CLI, plural «Удалить N
  ссылок», «Выбрано: N»).
- [x] 3.3 Перенести тосты `AppModel` в `Strings.Toast.*` (вкл. интерполяции «Скопировано: …»,
  ошибки установки/удаления CLI, «Открыто · ссылка сгорела»).
- [x] 3.4 Проверка (grep по `Sources/ShortlinksApp/Views` + `MainView.swift`): нет строковых
  литералов в `Text("…")`, `Button("…")`, `.navigationTitle("…")`, `.help("…")`,
  плейсхолдерах и в аргументах `systemName:`/`systemImage:`.

## 4. Миграция CLI

- [x] 4.1 `ShortlinksCLI.swift`: `abstract`/`help` корневой команды и подкоманд (add/list/rm/
  resolve/open, включая `--help` опций) → `Strings.CLI.*`.
- [x] 4.2 Вывод и ошибки: `print(...)` («Ссылок нет.», «Удалено: …»), `ValidationError(...)`,
  `CLIError.description` → `Strings.CLI.*`. Технические литералы (значения фильтров `all/active/
  once/expired`, `once/reuse`, схемы) НЕ трогать.
- [x] 4.3 Реализовать выбор языка CLI: глобальная опция `--lang` (через `@OptionGroup`/
  родительскую команду) + чтение `LC_ALL`/`LC_MESSAGES`/`LANG`; override локали из слоя 1.6
  применяется в точке входа (env — в самом начале `main`, до рендера `--help`).
- [x] 4.4 Проверка: `shortlinks-cli` собирается (Release); `shortlinks --help` показывает
  русский текст; `LANG=C shortlinks list` и `shortlinks --lang ru list` не падают и дают
  русский вывод; пользовательских строковых литералов в `ShortlinksCLI.swift` не осталось.

## 5. Сборка, тесты, верификация

- [x] 5.1 Дополнить `ShortlinksCoreTests`: формы склонений через каталог (`opensText` для
  n ∈ {1,2,5,11,21,101}), лейблы статусов/типов, `expiresText`; тест на безопасный фолбэк
  `Bundle.shortlinks` (не падает, отдаёт `defaultValue`); выбор языка — POSIX-маппинг
  (`ru_RU.UTF-8`→`ru`, `C`/`POSIX`→источник) и порядок приоритетов
  (`--lang` > `LC_*`/`LANG` > система > источник).
- [x] 5.2 `xcodebuild test -scheme ShortlinksCoreTests -destination 'platform=macOS'
  CODE_SIGNING_ALLOWED=NO` — зелёные.
- [x] 5.3 `xcodebuild -scheme ShortlinksApp build` и `xcodebuild -scheme shortlinks-cli
  -configuration Release build` — успешно.
- [x] 5.4 Визуальная сверка: запустить приложение, пройтись по экранам — русский текст и вид
  совпадают с домиграционными и макетом `_design/`.

## 6. Документация и спеки

- [x] 6.1 Обновить `CLAUDE.md` (Конвенции): строки → реестр `Strings` + `Localizable.xcstrings`,
  иконки → реестр `Icons`; кратко — локатор бандла для встроенного CLI и dev-регион `ru`.
- [x] 6.2 `openspec validate extract-strings-and-icons --strict` — без ошибок. Синхронизация
  спеков и архивирование (`/opsx:sync` + `/opsx:archive`) — перед открытием PR.
