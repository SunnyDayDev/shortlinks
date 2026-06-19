## 1. Репозиторий и окружение агента

- [x] 1.1 `git init`, создать `.gitignore` (исключить `*.xcodeproj`, `DerivedData/`, `.build/`, `.DS_Store`, артефакты сборки)
- [x] 1.2 Создать `README.md` (описание, требования, команды сборки/запуска) и `CLAUDE.md` (карта модулей, команды, конвенции Swift/macOS)
- [x] 1.3 Настроить окружение агента: проектные навыки/инструкции под Swift/macOS-разработку в `.claude/` (CLAUDE.md + существующие OpenSpec-скиллы; права намеренно не расширял)
- [ ] 1.4 Первый коммит; создать GitHub-репозиторий через `gh repo create` (приватность и имя уточнить у пользователя) и запушить

## 2. Скаффолд проекта (XcodeGen)

- [ ] 2.1 Убедиться, что установлен XcodeGen (`brew install xcodegen` при отсутствии)
- [ ] 2.2 Написать `project.yml`: таргеты `ShortlinksCore` (framework), `ShortlinksApp` (app, macOS 14+, accessory), `shortlinks-cli` (executable); зависимость `swift-argument-parser`; deployment target; bundle id
- [ ] 2.3 Подпись: создать самоподписанный сертификат в Keychain Access; в `project.yml` для app-таргета `CODE_SIGN_STYLE: Manual` + `CODE_SIGN_IDENTITY` = этот сертификат, без provisioning profile, без энтайтлментов
- [ ] 2.4 `xcodegen generate` и проверка сборки пустых таргетов (`xcodebuild`/Xcode)

## 3. ShortlinksCore — модель и хранилище

- [ ] 3.1 `Link` (`Codable`/`Identifiable`): `id`, `slug`, `target`, `kind`, `opens`, `createdAt`, `expiresAt`, `consumedAt`, `passwordHash`, `tags`; перечисления `LinkKind`, вычисляемый `status`
- [ ] 3.2 `StorageLocation`: единый расчёт пути к `links.json` (iCloud Drive vs локальный fallback), выбор по настройке sync
- [ ] 3.3 `LinkStore`: CRUD над единым `links.json` через координированное read-modify-write (`NSFileCoordinator`) + атомарная запись (temp+rename); `resolve(slug:)`, `consume(slug:)`
- [ ] 3.4 Перенос хелперов из макета: `genSlug`, `cleanSlug`, `scheme(target)`, `statusView`, `subtitle`, `plural`, `expLabel/expWord`; маппинг ttl → `expiresAt`
- [ ] 3.5 Пароль: соль+SHA-256 (`CryptoKit`), `setPassword`/`verify`
- [ ] 3.6 Наблюдение за файлом `links.json` (FSEvents/`DispatchSource`) с уведомлением подписчиков
- [ ] 3.7 `mergeLinkConflicts` (разбор `NSFileVersion.unresolvedConflictVersions`: слияние по `id` — viewed важнее active, ранний `consumedAt`; непересекающиеся записи сохраняются)

## 4. CLI

- [ ] 4.1 `add <target>` с `--slug/--once/--reuse/--ttl/--password/--tag`, печать `sl://link/<slug>`
- [ ] 4.2 `list --filter --tag`
- [ ] 4.3 `rm <slug>`, `resolve <slug>`, `open <slug>` (резолв + `NSWorkspace`/`open`, потребление одноразовой)
- [ ] 4.4 Проверка CLI в терминале end-to-end (add → list → resolve → повторный open одноразовой → недоступна)

## 5. Приложение — каркас

- [ ] 5.1 `ShortlinksApp` (`MenuBarExtra` + `Window`, `ActivationPolicy.accessory`)
- [ ] 5.2 `Theme` (цвета `#2A6FDB`, статус-пилюли, радиусы) и `AppModel` (`@Observable`) поверх `LinkStore` (фильтры/поиск/счётчики как `renderVals`)
- [ ] 5.3 Меню-бар: быстрые действия (новая ссылка, открыть окно, недавние, тумблер обработчика)

## 6. Приложение — экраны (по макету)

- [ ] 6.1 Боковая панель (Все/Активные/Одноразовые/Истёкшие/Теги/Настройки/Как это работает) + тулбар с поиском и кнопкой «Новая ссылка»
- [ ] 6.2 Список (`LinkRow`) и пустое состояние
- [ ] 6.3 Карточка ссылки (детали, копировать, открыть, удалить)
- [ ] 6.4 Лист создания (цель, slug, тип, срок, теги, пароль)
- [ ] 6.5 Экраны «Настройки» (обработчик, дефолты, тумблер sync, «удалять одноразовую», приватность) и «Как это работает»; тосты

## 7. Обработка sl:// и переход

- [ ] 7.1 `Info.plist`: `CFBundleURLTypes` (схема `sl`), `LSUIElement`
- [ ] 7.2 `.onOpenURL` → резолв slug → оверлей перехода (ready/blocked/consumed)
- [ ] 7.3 Парольный гейт перед редиректом; открытие цели через `NSWorkspace.open`
- [ ] 7.4 Потребление одноразовой (`viewed`/`consumedAt`) или удаление по настройке
- [ ] 7.5 Тумблер «Обработчик по умолчанию» (`LSSetDefaultHandlerForURLScheme`)

## 8. Синхронизация iCloud Drive

- [ ] 8.1 Тумблер sync → переключение `StorageLocation`, перенос существующего `links.json`
- [ ] 8.2 Реакция app и CLI на внешние изменения `links.json`
- [ ] 8.3 Проверка появления `links.json` в iCloud Drive; обновить текст приватности под opt-in

## 9. Проверка end-to-end

- [ ] 9.1 CLI ↔ App: `shortlinks add` в терминале → запись появляется в открытом окне без перезапуска
- [ ] 9.2 Схема: `open 'sl://link/<slug>'` → оверлей → переход; повторный open одноразовой → «сгорела»
- [ ] 9.3 Пароль: защищённая ссылка требует ввод; неверный пароль не открывает цель
- [ ] 9.4 (Ручная) Синхронизация на втором Mac с тем же Apple ID
