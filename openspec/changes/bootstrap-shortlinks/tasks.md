## 1. Репозиторий и окружение агента

- [x] 1.1 `git init`, создать `.gitignore` (исключить `*.xcodeproj`, `DerivedData/`, `.build/`, `.DS_Store`, артефакты сборки)
- [x] 1.2 Создать `README.md` (описание, требования, команды сборки/запуска) и `CLAUDE.md` (карта модулей, команды, конвенции Swift/macOS)
- [x] 1.3 Настроить окружение агента: проектные навыки/инструкции под Swift/macOS-разработку в `.claude/` (CLAUDE.md + существующие OpenSpec-скиллы; права намеренно не расширял)
- [x] 1.4 Первый коммит; создать GitHub-репозиторий через `gh repo create` (приватность и имя уточнить у пользователя) и запушить → https://github.com/SunnyDayDev/shortlinks (private)

## 2. Скаффолд проекта (XcodeGen)

- [x] 2.1 Убедиться, что установлен XcodeGen (`brew install xcodegen` при отсутствии)
- [x] 2.2 Написать `project.yml`: таргеты `ShortlinksCore` (static library), `ShortlinksApp` (app, macOS 14+), `shortlinks-cli` (tool); зависимость `swift-argument-parser`; deployment target; bundle id `com.shortlinks.app`
- [x] 2.3 Подпись: `project.yml` настроен на `CODE_SIGN_STYLE: Manual` без provisioning/энтайтлментов; по умолчанию ad-hoc `CODE_SIGN_IDENTITY: "-"` (собирается без аккаунта). Создание самоподписанного сертификата в Keychain и замена identity на его имя — ручной шаг пользователя (строка с комментарием в project.yml)
- [x] 2.4 `xcodegen generate` и сборка таргетов (`xcodebuild`) — BUILD SUCCEEDED для app и CLI

## 3. ShortlinksCore — модель и хранилище

- [x] 3.1 `Link` (`Codable`/`Identifiable`): `id`, `slug`, `target`, `kind`, `opens`, `createdAt`, `expiresAt`, `consumedAt`, `passwordHash`, `tags`; перечисления `LinkKind`/`Lifetime`, вычисляемый `status`
- [x] 3.2 `StorageLocation`: единый расчёт пути к `links.json` (iCloud Drive vs локальный fallback), выбор по наличию файла в iCloud
- [x] 3.3 `LinkStore`: CRUD над единым `links.json` через координированное read-modify-write (`NSFileCoordinator`) + атомарная запись (temp+rename); `resolve(slug:)`, `consume(slug:)`
- [x] 3.4 Перенос хелперов из макета: `Slug.generate/clean`, `Scheme.detect`, `Format.statusLabel/subtitle/plural/expiresText`; маппинг ttl → `expiresAt`
- [x] 3.5 Пароль: соль+SHA-256 (`CryptoKit`), `Password.hash`/`verify`
- [x] 3.6 Наблюдение за каталогом `links.json` (`DispatchSource`) с уведомлением подписчиков (debounce)
- [x] 3.7 `ConflictMerge` (`NSFileVersion.unresolvedConflictVersionsOfItem`: слияние по `id` — viewed важнее active, ранний `consumedAt`; непересекающиеся записи сохраняются)

## 4. CLI

- [x] 4.1 `add <target>` с `--slug/--once/--reuse/--ttl/--password/--tag`, печать `sl://link/<slug>`
- [x] 4.2 `list --filter --tag`
- [x] 4.3 `rm <slug>`, `resolve <slug>`, `open <slug>` (резолв + `NSWorkspace`/`open`, потребление одноразовой)
- [x] 4.4 Проверка CLI в терминале end-to-end (add → list → resolve → open → повторный open одноразовой → недоступна) — пройдено

## 5. Приложение — каркас

- [x] 5.1 `ShortlinksApp` (`MenuBarExtra` + `Window`); LSUIElement=false (обычное приложение) для надёжной работы окна/sl:// — переключаемо на accessory
- [x] 5.2 `Theme` (цвета `#2A6FDB`, статус-пилюли, радиусы) и `AppModel` (`@Observable`) поверх `LinkStore` (фильтры/поиск/счётчики как `renderVals`)
- [x] 5.3 Меню-бар: быстрые действия (новая ссылка, открыть окно, недавние, выход)

## 6. Приложение — экраны (по макету)

- [x] 6.1 Боковая панель (Все/Активные/Одноразовые/Истёкшие/Теги/Настройки/Как это работает) + тулбар с поиском и кнопкой «Новая ссылка»
- [x] 6.2 Список (`LinkRow`) и пустое состояние
- [x] 6.3 Карточка ссылки (детали, копировать, открыть, удалить)
- [x] 6.4 Лист создания (цель, slug, тип, срок, теги, пароль)
- [x] 6.5 Экраны «Настройки» (обработчик, дефолты, тумблер sync, «удалять одноразовую», приватность) и «Как это работает»; тосты

## 7. Обработка sl:// и переход

- [x] 7.1 `Info.plist`: `CFBundleURLTypes` (схема `sl`), `LSUIElement`
- [x] 7.2 `.onOpenURL` → резолв slug → оверлей перехода (ready/blocked/consumed)
- [x] 7.3 Парольный гейт перед редиректом; открытие цели через `NSWorkspace.open`
- [x] 7.4 Потребление одноразовой (`viewed`/`consumedAt`) или удаление по настройке
- [x] 7.5 Тумблер «Обработчик по умолчанию» (`LSSetDefaultHandlerForURLScheme`)

## 8. Синхронизация iCloud Drive

- [x] 8.1 Тумблер sync → переключение `StorageLocation`, перенос существующего `links.json`
- [x] 8.2 Реакция app и CLI на внешние изменения `links.json` (наблюдатель каталога)
- [x] 8.3 Обновлён текст приватности под opt-in; путь iCloud `…/Shortlinks/links.json` (фактическое появление файла — при включении тумблера пользователем)

## 9. Проверка end-to-end

- [x] 9.1 CLI ↔ App: общий файл `links.json` (один путь у app и CLI), наблюдатель каталога обновляет окно (проверено на уровне данных; визуальное обновление — глазами в работающем приложении)
- [x] 9.2 Схема: зарегистрирован обработчик `com.shortlinks.app`; `open 'sl://link/<slug>'` маршрутизируется в приложение (rc=0). Визуальный оверлей/«сгорела» — глазами в приложении (от скриншота пользователь отказался)
- [x] 9.3 Пароль: защищённая ссылка хранит только соль+хеш; open без/с неверным паролем отклоняется, с верным — открывает (проверено через CLI)
- [ ] 9.4 (Ручная) Синхронизация на втором Mac с тем же Apple ID
