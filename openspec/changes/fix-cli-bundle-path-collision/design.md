## Context

CLI `shortlinks` вкладывается в `Shortlinks.app` через copy-фазу app-таргета с
`destination: executables` (= `Contents/MacOS`), `subpath: ""`. Главный исполняемый
файл приложения — `Contents/MacOS/Shortlinks` (`PRODUCT_NAME: Shortlinks`,
`CFBundleExecutable: Shortlinks`).

На стандартном для macOS регистронезависимом APFS имена `Shortlinks` и `shortlinks`
эквивалентны — это один и тот же путь. Подтверждено на практике: оба имени в собранном
бандле указывали на один inode, и собранный `.app` недетерминированно содержал то
бинарь приложения, то CLI под именем главного исполняемого файла. Когда «побеждал» CLI,
приложение не запускалось, а подпись бандла была невалидной.

Путь вложенного бинаря также зашит в `CLIInstaller` (ShortlinksCore) — `bundledBinaryURL`
в `standard()` и эвристика `isShortlinksBinary` — и в тестах `CLIInstallerTests`.

## Goals / Non-Goals

**Goals:**
- Устранить коллизию имён: вложенный CLI и главный исполняемый файл приложения не
  должны делить путь с учётом регистронезависимости ФС.
- Сохранить неизменным пользовательский интерфейс: команда `shortlinks`, симлинк
  `~/.local/bin/shortlinks`, действия установки/удаления/статуса.
- Детерминированно собирать запускаемый `.app` с валидной подписью.

**Non-Goals:**
- Переименование команды CLI или изменение каталога установки симлинка.
- Нотаризация / Developer ID подпись (вне рамок — самоподписанный серт остаётся).
- Изменение логики установки/удаления симлинка по существу.

## Decisions

### Решение: вложить CLI в `Contents/Helpers/shortlinks`

Переносим вложенный CLI в отдельный подкаталог бандла `Contents/Helpers/` — там имя
`shortlinks` ни с чем не конфликтует. `Contents/Helpers` — конвенциональное место для
вспомогательных исполняемых файлов в macOS-бандлах.

В `project.yml` это `destination: wrapper` (корень `.app`) + `subpath: Contents/Helpers`:

```yaml
- target: shortlinks-cli
  embed: true
  codeSign: true
  copy:
    destination: wrapper
    subpath: Contents/Helpers
```

**Альтернативы:**
- `Contents/MacOS/cli/shortlinks` (подпапка внутри MacOS) — тоже снимает коллизию, но
  складывать произвольные подпапки в `MacOS/` менее принято, чем использовать `Helpers/`.
- Переименовать команду (`sl`) или главный бинарь — ломает интерфейс/ожидания
  пользователя, отвергнуто.
- Положить CLI в `Contents/Resources/` — нестандартно для исполняемых файлов; `Helpers`
  семантически точнее.

### Решение: обновить путь в `CLIInstaller`

- `standard()`: `bundledBinaryURL` строится как
  `Bundle.main.bundleURL/Contents/Helpers/shortlinks`.
- `isShortlinksBinary`: эвристика проверяет вхождение
  `Shortlinks.app/Contents/Helpers` (вместо `Contents/MacOS`).
- Комментарии-докстринги с путём обновляются.

### Решение: обновить тесты `CLIInstallerTests`

Заменить в тестах `Shortlinks.app/Contents/MacOS` на `Shortlinks.app/Contents/Helpers`,
чтобы соответствовать новой эвристике (две точки: имитация вложенного бинаря и проверка
«чужого» бандла).

## Risks / Trade-offs

- [Старые установленные симлинки указывают на `…/Contents/MacOS/shortlinks`] → после
  обновления приложения пользователь переустанавливает CLI из Настроек/онбординга;
  «Установить CLI» идемпотентно перезапишет симлинк на новый путь. Для самоподписанной
  локальной сборки приемлемо; миграция симлинка автоматически не делается.
- [xcodegen `destination: wrapper` + subpath кладёт файл в произвольное место бандла] →
  путь зафиксирован в spec и тестах; регрессию ловит сценарий «CLI присутствует в
  собранном бандле».
- [Регистронезависимость — свойство тома, не гарантировано везде] → решение корректно и
  на регистрозависимых томах (там пути и так различались); вреда нет.

## Migration Plan

1. Поправить `project.yml`, `CLIInstaller.swift`, `CLIInstallerTests.swift`, `CLAUDE.md`.
2. `xcodegen generate` (явный список файлов/таргетов не меняется, но copy-фаза — да).
3. Прогнать `ShortlinksCoreTests`.
4. Собрать `ShortlinksApp` (Release) и проверить: `Contents/MacOS/Shortlinks` — это
   бинарь приложения, `Contents/Helpers/shortlinks` — CLI, `codesign --verify` валиден,
   приложение запускается.
5. Откат: вернуть прежнюю copy-фазу и путь в `CLIInstaller` (обратимо одним коммитом).

## Open Questions

(нет)
