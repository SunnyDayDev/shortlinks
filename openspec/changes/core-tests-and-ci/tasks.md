## 1. Тест-seam в хранилище

- [x] 1.1 Добавить `LinkStore.init(fileURL:watch:)` и переиспользовать его в существующем `init(watch:)` (через `StorageLocation.current()`); поведение не меняется
- [x] 1.2 Собрать `ShortlinksApp` и `shortlinks-cli`, убедиться, что существующий код компилируется без изменений в местах вызова

## 2. Юнит-тесты доменной логики

- [x] 2.1 `SlugTests`: `clean`/`normalizeForSave` (регистр, недопустимые символы, схлопывание `//`, ведущие/хвостовые `/`, пустой → сгенерированный); `generate` (длина, алфавит без `l/o/0/1`)
- [x] 2.2 `SchemeTests`: `url(forSlug:)`, `slug(fromURL:)` (`sl://link/<slug>`, запасной `sl://<slug>`, чужая схема → `nil`), `detect` (web/file/app/text)
- [x] 2.3 `PasswordTests`: формат `salt:hex`, `verify` верный/неверный/битый хеш, разные соли → разный хеш
- [x] 2.4 `LinkTests`: `status(now:)` (active/expired/viewed), `make` (`expiresAt` из `Lifetime`, `passwordHash` только при непустом пароле), `Lifetime.seconds`
- [x] 2.5 `ConflictMergeTests`: слияние по `id`, правило `resolve` (viewed > active, ранний `consumedAt`, больше `opens`), порядок по `createdAt`
- [x] 2.6 `FormatTests`: `plural` (1/2/5/11/21…), `opensText`, `statusLabel`, `expiresText`/`subtitle` на фиксированных датах
- [x] 2.7 `LinkStoreTests`: `add`/`resolve`/`delete(id:)`/`delete(slug:)`; `consume` для once (потребление, повторный → `nil`) и reuse (инкремент `opens`); `consume` истёкшей → `nil` — всё во временном файле
- [x] 2.8 Локально прогнать `xcodebuild test -scheme ShortlinksCoreTests` — все тесты зелёные

## 3. CI на GitHub Actions

- [x] 3.1 Добавить `.github/workflows/ci.yml` (`macos-14`): checkout → `brew install xcodegen` → `xcodegen generate` → `xcodebuild test -scheme ShortlinksCoreTests -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO`
- [x] 3.2 Настроить триггеры: `pull_request` (branches: main) и `push` (branches: main)
- [x] 3.3 Проверить зелёный прогон workflow на PR этого изменения (по логам Actions)

## 4. Документация и проверка спек

- [x] 4.1 Обновить `CLAUDE.md`: раздел про тесты ShortlinksCore и CI (GitHub Actions)
- [x] 4.2 Прогнать `openspec validate core-tests-and-ci` и финальную сборку app
