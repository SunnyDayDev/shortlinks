## Why

Сейчас тестами покрыт только `CLIInstaller`, а остальная доменная логика
`ShortlinksCore` (slug, схема, пароли, статусы ссылок, хранилище, слияние конфликтов,
форматирование) — нет. Проверки PR (`dev-workflow`) выполняются вручную, без CI. Это
делает регрессии вероятными и полагается на дисциплину разработчика. Цель — покрыть
доменную логику юнит-тестами и автоматически прогонять их на GitHub Actions при каждом
PR/пуше, чтобы красный прогон блокировал мерж.

## What Changes

- **Юнит-тесты ShortlinksCore** на всю доменную логику: `Slug`, `Scheme`, `Password`,
  `Link`/`Lifetime` (статусы и фабрика), `ConflictMerge`, `Format`, `LinkStore`
  (CRUD/`consume`/`resolve`), `StorageLocation`.
- **Тестовый seam в `LinkStore`**: инициализатор с явным `fileURL`, чтобы тесты
  работали с временным файлом, а не с реальным хранилищем пользователя.
- **GitHub Actions workflow** (`.github/workflows/ci.yml`) на macOS-раннере: ставит
  XcodeGen, генерирует проект, собирает и прогоняет `ShortlinksCoreTests` с отключённой
  подписью (`CODE_SIGNING_ALLOWED=NO`). Триггеры — PR в `main` и push в `main`.
- **CI как проверка PR**: красный прогон тестов помечает PR-чек красным.

GitHub Actions **могут** это выполнять: на их macOS-раннерах доступны Xcode и
`xcodebuild`, XcodeGen ставится из Homebrew.

## Capabilities

### New Capabilities
- `core-tests`: доменная логика `ShortlinksCore` покрыта юнит-тестами, проверяющими её
  поведение (slug, схема, пароли, статусы, хранилище, слияние, форматирование).
- `continuous-integration`: автоматический прогон сборки и тестов на GitHub Actions при
  PR/пуше; падение тестов делает проверку PR красной.

### Modified Capabilities
- `dev-workflow`: требование к PR-проверкам уточняется — сборка и тесты выполняются
  автоматически через CI (GitHub Actions), а не только вручную/по договорённости.

## Impact

- `Tests/ShortlinksCoreTests/`: новые тест-файлы по компонентам.
- `Sources/ShortlinksCore/LinkStore.swift`: добавляется тест-ориентированный init с
  `fileURL` (доменное поведение не меняется).
- `.github/workflows/ci.yml`: новый workflow.
- `project.yml`: при необходимости — выделенная схема/настройки для CI-тестов (уже есть
  `ShortlinksCoreTests`).
- Документация: `CLAUDE.md` (раздел про тесты и CI), спека `dev-workflow`.
