# continuous-integration Specification

## Purpose

Автоматический прогон сборки и юнит-тестов `ShortlinksCore` на GitHub Actions при
изменениях, чтобы регрессии обнаруживались до мержа.

## Requirements

### Requirement: Автоматический прогон тестов на CI

Проект SHALL содержать конфигурацию GitHub Actions, которая на macOS-раннере
генерирует проект через XcodeGen и прогоняет юнит-тесты `ShortlinksCoreTests`. Сборка
тестов на CI SHALL выполняться с отключённой подписью кода
(`CODE_SIGNING_ALLOWED=NO`), т.к. самоподписанный сертификат на раннере недоступен.

#### Scenario: Прогон тестов на чистом раннере

- **WHEN** workflow запускается на macOS-раннере GitHub Actions
- **THEN** он ставит XcodeGen, выполняет `xcodegen generate` и прогоняет
  `ShortlinksCoreTests` без ошибок подписи

### Requirement: Триггеры CI на PR и push в main

Workflow SHALL запускаться при открытии/обновлении Pull Request в `main` и при push в
`main`.

#### Scenario: Запуск на Pull Request

- **WHEN** открывается или обновляется PR с веткой в `main`
- **THEN** workflow тестов запускается автоматически

#### Scenario: Запуск на push в main

- **WHEN** в `main` попадает новый коммит (например, после мержа PR)
- **THEN** workflow тестов запускается автоматически

### Requirement: Падение тестов делает проверку красной

Если хотя бы один тест падает или сборка тестов не проходит, workflow SHALL завершаться
с ненулевым кодом, помечая проверку PR красной.

#### Scenario: Красный чек при падении теста

- **WHEN** один из юнит-тестов падает в ходе CI
- **THEN** workflow завершается с ошибкой, и связанный с PR чек становится красным
