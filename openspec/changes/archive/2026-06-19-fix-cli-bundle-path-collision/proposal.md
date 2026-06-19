## Why

Вложенный CLI кладётся в `Shortlinks.app/Contents/MacOS/shortlinks`, а главный
исполняемый файл приложения называется `Shortlinks`. На стандартном для macOS
регистронезависимом APFS `shortlinks` и `Shortlinks` — это **одно и то же имя файла**:
они указывают на один inode, и при сборке последний записанный бинарь затирает другой.
В результате собранный бандл недетерминированно содержит то приложение, то CLI под
именем `Shortlinks` — и приложение случайным образом перестаёт запускаться («not a real
app», невалидная подпись). Текущая раскладка вложенного CLI нежизнеспособна на дефолтном
диске и должна быть исправлена.

## What Changes

- Вложенный CLI переносится из `Contents/MacOS/shortlinks` в непересекающийся по имени
  путь внутри бандла — `Contents/Helpers/shortlinks` (отдельный подкаталог `Helpers`,
  где имя `shortlinks` не конфликтует с `Contents/MacOS/Shortlinks`).
- `project.yml`: copy-фаза app-таргета кладёт CLI в `Contents/Helpers` (с подписью).
- `CLIInstaller` (ShortlinksCore): путь к вложенному бинарю и эвристика опознания
  «свой бандл» обновляются на новый путь `Contents/Helpers/shortlinks`.
- Документация (`CLAUDE.md`, и при необходимости комментарии в `project.yml`)
  обновляется на новый путь.
- Поведение для пользователя не меняется: команда по-прежнему `shortlinks`, симлинк
  по-прежнему `~/.local/bin/shortlinks`. **Не BREAKING** для внешнего интерфейса.

## Capabilities

### New Capabilities

(нет)

### Modified Capabilities

- `cli-distribution`: уточняется требование «CLI вложен в бандл приложения» —
  фиксированный путь вложенного бинаря не должен совпадать (с учётом
  регистронезависимости файловой системы) с путём главного исполняемого файла
  приложения; задаётся как `Contents/Helpers/shortlinks`.

## Impact

- `project.yml` (copy-фаза `ShortlinksApp`, destination/subpath для `shortlinks-cli`).
- `Sources/ShortlinksCore/CLIInstaller.swift` (`bundledBinaryURL`, эвристика
  `isShortlinksBinary`).
- `Tests/ShortlinksCoreTests` (тесты `CLIInstaller`, если в них зашит старый путь).
- `CLAUDE.md` (описание расположения вложенного CLI).
- Регенерация `Shortlinks.xcodeproj` через `xcodegen generate`.
