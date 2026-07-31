# Shortlinks

Локальный сервис коротких ссылок для macOS: создание одноразовых и многоразовых
ссылок вида `sl://link/<slug>` и их обработка, с опциональной синхронизацией между
устройствами через iCloud Drive.

- **Нативное приложение** (меню-бар + окно) на SwiftUI.
- **CLI** `shortlinks` для работы из терминала.
- **Без сервера:** короткий адрес — это кастомная URL-схема `sl://`, которую
  приложение регистрирует обработчиком в macOS.
- **Приватно:** данные хранятся локально (или в вашем личном iCloud Drive), без
  аккаунтов и сторонних серверов.

## Требования

- macOS 14+ и Xcode (проверено на Xcode 26).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`.
- Бесплатного Apple ID достаточно (платный Apple Developer Program не нужен).

## Сборка

```bash
xcodegen generate          # сгенерировать Shortlinks.xcodeproj из project.yml
open Shortlinks.xcodeproj  # собрать и запустить из Xcode (схема ShortlinksApp)
```

Тесты доменной логики:

```bash
xcodebuild test -project Shortlinks.xcodeproj -scheme ShortlinksCoreTests \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
```

## Установка CLI

Отдельно собирать и устанавливать CLI не нужно: `shortlinks` вкладывается внутрь
`Shortlinks.app` (`Contents/Helpers/shortlinks`) при сборке приложения. Доступность из
терминала включается в самом приложении — Настройки → «Командная строка» (или на шаге
онбординга при первом запуске): создаётся симлинк в `~/.local/bin`, который должен быть
в `PATH`.

Сборка CLI отдельным таргетом нужна только для разработки:

```bash
xcodebuild -project Shortlinks.xcodeproj -scheme shortlinks-cli -configuration Release build
```

## Использование CLI

```bash
shortlinks add https://example.com --once --ttl 24h   # → sl://link/<slug>
shortlinks add ~/Documents/report.pdf --slug report --tag work --note "Отчёт за квартал"
shortlinks list --filter active            # all | active | once | expired
shortlinks resolve <slug>
shortlinks open <slug>
shortlinks rm <slug>
```

Срок жизни (`--ttl`): `1h`, `24h`, `7d`, `never` (по умолчанию). Ссылку можно закрыть
паролем (`--password`), пометить тегами (`--tag`, можно несколько) и снабдить описанием
(`--note`). Язык вывода — системный, переопределяется `--lang`.

## Навык Claude (использование в других агентах)

В `plugins/shortlinks/` лежит Claude-плагин с навыком, который учит любого
Claude-агента пользоваться CLI `shortlinks`. Установить его в другой агент:

```bash
# Локально (разработка): подключить плагин из каталога
claude --plugin-dir ./plugins/shortlinks

# По Git: добавить этот репозиторий как marketplace и установить плагин
/plugin marketplace add SunnyDayDev/shortlinks
/plugin install shortlinks@shortlinks
```

Репозиторий публичный, установка по Git доступна без дополнительных прав; локальная
копия с `--plugin-dir` — запасной вариант.

После установки навык подхватывается автоматически, когда агенту нужно создать,
найти, резолвить или открыть короткую ссылку. Сам CLI `shortlinks` должен быть
доступен на машине (см. «Установка CLI» выше).

## Структура

```
project.yml              # XcodeGen-спека (источник истины по проекту)
Sources/
  ShortlinksCore/        # доменная модель, хранилище, логика (общая)
  ShortlinksApp/         # SwiftUI-приложение (меню-бар + окно) + дизайн-система
  shortlinks-cli/        # CLI
Tests/                   # юнит-тесты ShortlinksCore
design/                  # дизайн-макет shortlinks.pen (Pen) + validate_pen.py
plugins/shortlinks/      # Claude-плагин с навыком работы с CLI
Scripts/                 # ds-lint.sh — линт дизайн-системы
tools/                   # make_icon.swift — генератор иконки приложения
openspec/                # спецификации и план изменений (OpenSpec)
```

## Дизайн

Источник правды по UI — файл [design/shortlinks.pen](design/shortlinks.pen), макет
редактора Pen (прежнее название — Pencil). Внутри — страница «Design System» (токены и
мастера компонентов) и экраны приложения, собранные из их инстансов; токены зеркалят
слой `DesignSystem` в коде. Правки вносятся через Pen (MCP), проверка целостности
файла — `python3 design/validate_pen.py`.

## Хранилище

Все ссылки — в одном файле `links.json`:

- с синхронизацией: `~/Library/Mobile Documents/com~apple~CloudDocs/Shortlinks/links.json`
- локально: `~/Library/Application Support/Shortlinks/links.json`

## Подпись

Приложение подписывается самоподписанным сертификатом (manual signing, без
provisioning profile). См. `CLAUDE.md` и `project.yml`.

## Участие

Проект разрабатывается по Spec-Driven Development на базе
[OpenSpec](https://openspec.dev): спеки в `openspec/specs/` — источник правды,
изменения логики проходят через процесс OpenSpec и обновляют их. Процесс, git-правила
и проверки перед PR — в [CONTRIBUTING.md](CONTRIBUTING.md).
