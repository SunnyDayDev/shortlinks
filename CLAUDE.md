# CLAUDE.md — Shortlinks

Локальный сервис коротких ссылок для macOS (нативное приложение + CLI). Короткий
адрес — кастомная схема `sl://link/<slug>`, которую приложение обрабатывает в macOS.
Опциональная синхронизация через файл в iCloud Drive.

## Команды

```bash
xcodegen generate                                   # пересобрать .xcodeproj из project.yml
xcodebuild -project Shortlinks.xcodeproj -scheme ShortlinksApp build
xcodebuild -project Shortlinks.xcodeproj -scheme shortlinks-cli -configuration Release build
xcodebuild test -project Shortlinks.xcodeproj -scheme ShortlinksCoreTests \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO   # юнит-тесты ShortlinksCore
```

`Shortlinks.xcodeproj` генерируется и НЕ коммитится — правьте `project.yml`, затем
`xcodegen generate`. После изменения списка файлов/таргетов всегда регенерируйте проект.

## Модули (`Sources/`)

- **ShortlinksCore** (framework) — вся доменная логика, переиспользуется app и CLI:
  - `Link` + `LinkKind`/`LinkStatus`, `StorageLocation`, `LinkStore`
    (CRUD над единым `links.json` через `NSFileCoordinator`, атомарная запись),
    `Slug`, `Scheme`, `Password` (соль+SHA-256), `ConflictMerge`.
  - Локализация: реестр строк `Strings` + `Localization` (bundle-локатор каталога и
    выбор языка) + `Format` (склонения/даты). String Catalog лежит в app-таргете
    (`Localizable.xcstrings`); встроенный CLI резолвит его из ресурсов приложения,
    standalone-CLI/тесты — фолбэк на `defaultValue` (русский). См. change
    `extract-strings-and-icons`.
- **ShortlinksApp** — SwiftUI `MenuBarExtra` + **единственное окно через AppKit**
  (`AppDelegate`, `NSWindow` + `NSHostingController`, лениво). Фоновый агент
  (`LSUIElement: true`) — без постоянной иконки в Dock. Сцена SwiftUI `Window` НЕ
  используется намеренно: она выводит окно при запуске, из-за чего тихий переход по
  `sl://` мигал бы окном. Обработка `sl://` — `AppDelegate.application(_:open:)`. Тихий
  фоновый переход (активная многоразовая ссылка без пароля) идёт вообще без создания
  окна; когда нужен UI (пароль/ненайдена/заблокирована/подтверждение) —
  `surfaceForInteraction` поднимает политику до `.regular` и показывает окно, а по
  закрытии оверлея/окна `AppModel.returnToBackground` прячет окно и возвращает
  `.accessory`. Обычный запуск (клик по иконке/Spotlight) и reopen показывают окно:
  `applicationShouldHandleReopen` + отложенная проверка в `didFinishLaunching`
  (флаг `didOpenURLAtLaunch` отличает запуск ради `sl://` от клика по иконке). Экраны —
  по дизайн-файлу `design/shortlinks.pen`.
- **shortlinks-cli** — `swift-argument-parser`; команды add/list/rm/open/resolve.
  CLI **вкладывается внутрь** `Shortlinks.app` (`Contents/Helpers/shortlinks`, copy-фаза
  app-таргета) — отдельная установка не нужна. Путь `Helpers` (не `Contents/MacOS`)
  выбран, чтобы имя `shortlinks` не конфликтовало с главным исполняемым `Shortlinks`
  на регистронезависимом APFS. Доступность из терминала включается из
  приложения (Настройки → «Командная строка» или онбординг при первом запуске): симлинк
  на вложенный бинарь в `~/.local/bin`. Логика — `CLIInstaller` в ShortlinksCore.
- **ShortlinksCoreTests** (`Tests/ShortlinksCoreTests`) — юнит-тесты доменной логики
  (Slug/Scheme/Password/Link/ConflictMerge/Format/LinkStore/CLIInstaller). `LinkStore`
  тестируется через `init(fileURL:watch:)` во временном файле. Новые тест-файлы требуют
  `xcodegen generate` (xcodegen ведёт явный список файлов).

## Тесты и CI

- Локально: `xcodebuild test -scheme ShortlinksCoreTests … CODE_SIGNING_ALLOWED=NO`
  (см. Команды). Подпись отключаем — самоподписанный серт для тест-бандла не нужен.
- CI: `.github/workflows/ci.yml` на `macos-14` ставит XcodeGen, генерирует проект и
  прогоняет `ShortlinksCoreTests` при PR в `main` и push в `main`. GUI-приложение на CI
  не собирается (нужен самоподписанный сертификат) — проверяется логика ядра.
- Required status checks технически не enforce'ятся (free private, как и branch
  protection) — красный CI блокирует мерж по договорённости.

## Ключевые решения (см. `openspec/changes/bootstrap-shortlinks/design.md`)

- Хранилище — **один файл** `links.json` (не SQLite, не файл-на-ссылку); запись через
  координированное read-modify-write; конфликты iCloud сливаются по `id` ссылки.
- Схема `sl://` вместо HTTP-сервера; регистрация через `CFBundleURLTypes`.
- Приложение — фоновый агент (`LSUIElement`), переход по `sl://` тихий. Полностью «не
  запускать приложение» при открытии `sl://` **нельзя**: macOS резолвит кастомную схему
  через LaunchServices и обязана запустить процесс-обработчик. Достижимо лишь убрать
  видимость запуска (иконку в Dock, перехват фокуса) — см. change `deeplink-silent-open`.
- Без entitlements (нет App Sandbox / iCloud-capability) — бесплатный Apple ID.
- Подпись — самоподписанный сертификат, `CODE_SIGN_STYLE: Manual`.
- Одноразовая ссылка по умолчанию «сгорает» (`viewed`); удаление — опция в Настройках.
- Swift language mode 5 (`SWIFT_VERSION: 5.0`) — чтобы не упираться в strict concurrency.

## Конвенции

- **Дизайн** — источник правды: Pencil-файл `design/shortlinks.pen` (акцент `#2A6FDB`).
  Файл — обычный JSON (`version`/`themes`/`variables`/`children`/`fileToken`): читается и
  диффается штатно. **Авторские правки — через Pencil MCP** (чтобы сохранять инварианты:
  уникальные `id`, целостность `ref`/`descendants`, схему `version`); ручная правка JSON —
  только при разрешении merge-конфликта. Внутри: страница «Design System» (токены + мастера
  компонентов) и экраны, собранные из их инстансов. Токены/компоненты зеркалят код
  `DesignSystem` под согласованными именами (`accent` ↔ `Theme.accent`, `space-16` ↔
  `Spacing.s16`, `Button/Primary` ↔ `PrimaryButtonStyle`). Изменение UI строится из
  существующих токенов/компонентов; новый токен/компонент добавляется парно — в дизайн-файл
  и в код. См. changes `adopt-pencil-design-system`, `pen-merge-safety`.
- **Мерж `.pen`** безопасен (автомерж), только если: правки в *разных* top-level `children`
  (разные экраны/области; добавление нового ребёнка — тоже ок); все `$var` есть в
  `variables`; `id` глобально уникальны; каждый `ref`/`descendants` разрешается; правки
  `variables`/`themes` аддитивны и `version` совпадает. Все мастера и токены — в одном
  ребёнке «Design System», поэтому две ветки, обе меняющие дизайн-систему, конфликтуют →
  ручной мерж. Иначе — ручное разрешение в JSON или выбор одного варианта файла целиком
  (`git checkout --ours/--theirs`). Проверка: `python3 design/validate_pen.py`.
- Доменную логику добавлять в ShortlinksCore, а не дублировать в app/CLI.
- **Строки** — только через реестр `Strings` (ShortlinksCore) поверх `Localizable.xcstrings`;
  русский — язык-источник (`defaultValue`). Не хардкодить пользовательские литералы во
  вью/CLI/`Format`. Склонения — plural-вариации каталога с фолбэком `Format.plural`. Перевод
  на новый язык — запись в каталог + `CFBundleLocalizations` в `project.yml`, без правок кода.
  Язык: системный, плюс `LANG`/`LC_*`/`--lang` в CLI (приоритет — см. `Localization`).
- **Иконки** — только через реестр `Icons` (DesignSystem); не хардкодить имена SF Symbols во вью.
- Идентификаторы: схема `sl`, bundle id приложения `com.tsikin.Shortlinks`.

## Git-процесс (gitflow)

`main` — стабильная ветка. **Прямые коммиты в `main` запрещены** — любой функционал,
исправление или правка ведётся в отдельной ветке и вливается в `main` через Pull Request.

- **Ветка под каждое изменение**, ответвляется от свежего `main`. Именование:
  `feat/<kebab>` (функционал), `fix/<kebab>` (исправление), `chore/<kebab>`
  (обслуживание), `docs/<kebab>` (документация/спеки). Напр. `feat/links-export`.
- **Мерж только через PR** с осмысленными заголовком и описанием (что и зачем).
  Мержить можно только при зелёных проверках — как минимум сборка и, если затронуты
  спеки, `openspec validate`.
- **Слияние** — merge-commit (`gh pr merge <n> --merge --delete-branch`): сохраняет
  связь PR↔коммиты. После мержа ветка удаляется, локальный `main` подтягивается
  (`git checkout main && git pull --ff-only`).
- **UI и дизайн-файл**: PR, меняющий внешний вид приложения, включает обновление
  `design/shortlinks.pen`; если визуальных изменений нет — отметить это в описании PR.
- **Branch protection** для `main` технически **не включена**: на бесплатном плане
  GitHub она недоступна для приватного репозитория (нужен GitHub Pro или публичный
  репо). Поэтому правило «только через PR» соблюдается по договорённости, а не
  принудительно. При переходе на Pro/публичный репо — включить требование PR.

## Рабочий процесс (OpenSpec)

Планы и спеки — в `openspec/`. Активное изменение: `bootstrap-shortlinks`. Прогресс —
чекбоксы в `openspec/changes/bootstrap-shortlinks/tasks.md`. Команды: `/opsx:apply`,
`/opsx:archive`.
