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

CLI:

```bash
xcodebuild -project Shortlinks.xcodeproj -scheme shortlinks-cli -configuration Release build
# бинарь окажется в DerivedData; для удобства можно слинковать в ~/bin
```

## Использование CLI

```bash
shortlinks add https://example.com --once --ttl 24h   # → sl://link/<slug>
shortlinks list --filter active
shortlinks resolve <slug>
shortlinks open <slug>
shortlinks rm <slug>
```

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

После установки навык подхватывается автоматически, когда агенту нужно создать,
найти, резолвить или открыть короткую ссылку. Сам CLI `shortlinks` должен быть
доступен на машине (см. «Использование CLI» выше).

## Структура

```
project.yml              # XcodeGen-спека (источник истины по проекту)
Sources/
  ShortlinksCore/        # доменная модель, хранилище, логика (общая)
  ShortlinksApp/         # SwiftUI-приложение (меню-бар + окно)
  shortlinks-cli/        # CLI
plugins/shortlinks/      # Claude-плагин с навыком работы с CLI
_design/                 # исходный макет из Claude Design (референс)
openspec/                # спецификации и план изменений (OpenSpec)
```

## Хранилище

Все ссылки — в одном файле `links.json`:

- с синхронизацией: `~/Library/Mobile Documents/com~apple~CloudDocs/Shortlinks/links.json`
- локально: `~/Library/Application Support/Shortlinks/links.json`

## Подпись

Приложение подписывается самоподписанным сертификатом (manual signing, без
provisioning profile). См. `CLAUDE.md` и `project.yml`.
