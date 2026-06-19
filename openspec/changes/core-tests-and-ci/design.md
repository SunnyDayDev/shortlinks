## Context

`ShortlinksCore` содержит всю доменную логику (переиспользуется app и CLI), но тестами
покрыт только `CLIInstaller` (добавлен в change `bundle-cli-with-app`). Тест-таргет
`ShortlinksCoreTests` и схема уже существуют в `project.yml`. Проверки PR описаны в
спеке `dev-workflow`, но выполняются вручную — CI нет.

Ограничения проекта (см. `CLAUDE.md`):
- Проект генерируется из `project.yml` через `xcodegen generate`; `.xcodeproj` не
  коммитится — CI должен генерировать его сам.
- Подпись — самоподписанный сертификат `shortlinks-app` (`CODE_SIGN_STYLE: Manual`),
  которого на CI-раннере нет.
- Swift language mode 5, deployment target macOS 14.

## Goals / Non-Goals

**Goals:**
- Детерминированные юнит-тесты на всю доменную логику `ShortlinksCore`.
- Автоматический прогон тестов на GitHub Actions при PR и push в `main`.
- Красный прогон → красный чек PR (блокирует мерж по конвенции).

**Non-Goals:**
- Не собираем и не подписываем GUI-приложение на CI (нужен самоподписанный серт;
  достаточно прогона тестов ядра).
- Не вводим UI-тесты и не тестируем `ShortlinksApp` (SwiftUI).
- Не настраиваем required status checks в GitHub (branch protection недоступна на free
  private — остаётся конвенцией, как уже описано в `CLAUDE.md`).
- Не гоняем сетевые/iCloud-зависимые сценарии — только локальный временный файл.

## Decisions

### Решение 1: Тест-seam в `LinkStore`

`LinkStore.init` сейчас всегда берёт `StorageLocation.current()` (реальный путь
пользователя), поэтому изолированно тестировать CRUD нельзя. Добавляем
инициализатор с явным `fileURL`:

```swift
public init(fileURL: URL, watch: Bool = false) { … }
// существующий init(watch:) вызывает его с StorageLocation.current()
```

Тесты создают `LinkStore(fileURL: tmp.appendingPathComponent("links.json"), watch: false)`
во временном каталоге. Доменное поведение не меняется — добавляется только точка входа.

*Альтернатива:* подменять `StorageLocation.current()` глобально (через env/override) —
скрытая глобальная зависимость, хуже для параллельных тестов. Отвергнуто.

### Решение 2: Состав тестов

Покрываем наблюдаемое поведение, без привязки к приватным деталям:
- `Slug`: `clean`/`normalizeForSave` (регистр, недопустимые символы → `-`, схлопывание
  `//`, обрезка ведущих/хвостовых `/`, пустой → сгенерированный), `generate` (длина,
  алфавит без `l/o/0/1`).
- `Scheme`: `url(forSlug:)`, `slug(fromURL:)` (`sl://link/<slug>`, запасной `sl://<slug>`,
  чужая схема → `nil`), `detect` (web/file/app/text).
- `Password`: `hash` формат `salt:hex`, `verify` (верный/неверный/битый хеш),
  разные соли → разный хеш одного пароля.
- `Link`/`Lifetime`: `status(now:)` (active/expired/viewed), `make` (вычисление
  `expiresAt`, `passwordHash` только при непустом пароле), `Lifetime.seconds`.
- `ConflictMerge`: объединение по `id`, правило `resolve` (viewed > active; ранний
  `consumedAt`; при active больше `opens`), стабильный порядок по `createdAt`.
- `Format`: `plural` (1/2/5/11/21…), `opensText`, `statusLabel`, `expiresText`/`subtitle`
  на фиксированных датах.
- `LinkStore`: `add`/`resolve`/`delete(id:)`/`delete(slug:)`, `consume` для once и reuse,
  повторный `consume` → `nil`, `consume` истёкшей → `nil`.

Время фиксируем через параметры `now:` там, где они есть, чтобы тесты были стабильны.

### Решение 3: GitHub Actions workflow

`.github/workflows/ci.yml` на `macos-14`:
1. `actions/checkout`.
2. Установка XcodeGen (`brew install xcodegen`).
3. `xcodegen generate`.
4. `xcodebuild test -project Shortlinks.xcodeproj -scheme ShortlinksCoreTests
   -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO`.

Триггеры: `pull_request` (branches: main) и `push` (branches: main). `CODE_SIGNING_ALLOWED=NO`
снимает требование самоподписанного сертификата для тест-бандла. Раннеры GitHub несут
несколько версий Xcode; при необходимости фиксируем версию через `xcode-select` /
`maxim-lobanov/setup-xcode`, но по умолчанию полагаемся на образ `macos-14`.

*Альтернатива:* собирать всё приложение на CI — требует сертификата/секретов и не
добавляет ценности для проверки логики ядра. Отвергнуто (см. Non-Goals).

## Risks / Trade-offs

- **Версия Xcode/Swift на раннере** отличается от локальной → возможны различия сборки.
  *Mitigation:* при нестабильности зафиксировать версию Xcode в workflow.
- **`brew install xcodegen` медленный/флапает** → дольше прогон. *Mitigation:* при
  необходимости кешировать или ставить через Mint; пока достаточно brew.
- **Тест-seam расширяет публичный API `LinkStore`** → минимально; альтернативный init
  не меняет существующее поведение.
- **Required checks не enforce'ятся** (free private) → красный CI не блокирует мерж
  технически. *Mitigation:* остаётся конвенцией (уже зафиксировано в `dev-workflow`/
  `CLAUDE.md`); включить required checks при переходе на Pro/публичный репо.

## Migration Plan

1. Добавить `LinkStore(fileURL:watch:)`; убедиться, что существующий init работает как
   прежде.
2. Написать тест-файлы по компонентам; локально `xcodebuild test` зелёный.
3. Добавить `.github/workflows/ci.yml`; проверить прогон на PR этого изменения.
4. Обновить `CLAUDE.md` (тесты + CI) и спеку `dev-workflow`.

Откат: удалить workflow и тесты; `LinkStore` остаётся с дополнительным init без вреда.

## Open Questions

- Нет.
