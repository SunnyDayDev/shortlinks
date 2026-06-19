# CLAUDE.md — Shortlinks

Локальный сервис коротких ссылок для macOS (нативное приложение + CLI). Короткий
адрес — кастомная схема `sl://link/<slug>`, которую приложение обрабатывает в macOS.
Опциональная синхронизация через файл в iCloud Drive.

## Команды

```bash
xcodegen generate                                   # пересобрать .xcodeproj из project.yml
xcodebuild -project Shortlinks.xcodeproj -scheme ShortlinksApp build
xcodebuild -project Shortlinks.xcodeproj -scheme shortlinks-cli -configuration Release build
```

`Shortlinks.xcodeproj` генерируется и НЕ коммитится — правьте `project.yml`, затем
`xcodegen generate`. После изменения списка файлов/таргетов всегда регенерируйте проект.

## Модули (`Sources/`)

- **ShortlinksCore** (framework) — вся доменная логика, переиспользуется app и CLI:
  - `Link` + `LinkKind`/`LinkStatus`, `StorageLocation`, `LinkStore`
    (CRUD над единым `links.json` через `NSFileCoordinator`, атомарная запись),
    `Slug`, `Scheme`, `Password` (соль+SHA-256), `ConflictMerge`.
- **ShortlinksApp** — SwiftUI: `MenuBarExtra` + `Window`, `ActivationPolicy.accessory`;
  экраны по макету `_design/`; обработка `.onOpenURL` для `sl://`.
- **shortlinks-cli** — `swift-argument-parser`; команды add/list/rm/open/resolve.

## Ключевые решения (см. `openspec/changes/bootstrap-shortlinks/design.md`)

- Хранилище — **один файл** `links.json` (не SQLite, не файл-на-ссылку); запись через
  координированное read-modify-write; конфликты iCloud сливаются по `id` ссылки.
- Схема `sl://` вместо HTTP-сервера; регистрация через `CFBundleURLTypes`.
- Без entitlements (нет App Sandbox / iCloud-capability) — бесплатный Apple ID.
- Подпись — самоподписанный сертификат, `CODE_SIGN_STYLE: Manual`.
- Одноразовая ссылка по умолчанию «сгорает» (`viewed`); удаление — опция в Настройках.
- Swift language mode 5 (`SWIFT_VERSION: 5.0`) — чтобы не упираться в strict concurrency.

## Конвенции

- Цвета/вёрстка экранов — по макету `_design/Одноразовые ссылки.dc.html` (акцент `#2A6FDB`).
- Доменную логику добавлять в ShortlinksCore, а не дублировать в app/CLI.
- Идентификаторы: схема `sl`, bundle id приложения `com.tsikin.Shortlinks`.

## Рабочий процесс (OpenSpec)

Планы и спеки — в `openspec/`. Активное изменение: `bootstrap-shortlinks`. Прогресс —
чекбоксы в `openspec/changes/bootstrap-shortlinks/tasks.md`. Команды: `/opsx:apply`,
`/opsx:archive`.
