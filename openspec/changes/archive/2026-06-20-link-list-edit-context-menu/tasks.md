## 1. Домен: статус и хранение деактивации (ShortlinksCore)

- [x] 1.1 В `Link` добавить опциональное поле `disabledAt: Date?` (по умолчанию `nil` в `init`, не ломая `Link.make` и существующие вызовы)
- [x] 1.2 В `LinkStatus` добавить кейс `disabled`
- [x] 1.3 В `Link.status(now:)` реализовать приоритет: `consumedAt`→`viewed`, `disabledAt`→`disabled`, `expiresAt<=now`→`expired`, иначе `active`
- [x] 1.4 В `LinkStore` добавить `setDisabled(id:_ disabled:Bool, now:Date = Date())` через `mutate` и `delete(ids: Set<String>)` (массовое удаление одним `mutate`)

## 2. Модель приложения (AppModel)

- [x] 2.1 Добавить состояние режима редактирования: `editing: Bool`, `selection: Set<String>`
- [x] 2.2 Методы `toggleEditing()` (сброс `selection` при выходе), `toggleSelect(id:)`, `canDeleteSelected`, `deleteSelected()` (через `LinkStore.delete(ids:)` + `reload()`, сброс выбора)
- [x] 2.3 Методы `deactivate(id:)`/`activate(id:)` поверх `LinkStore.setDisabled` + `reload()`
- [x] 2.4 Проверить, что `route()`/`performOpen()` блокируют `disabled` (только `.active` проходит) — правка не требуется, подтвердить

## 3. UI: режим редактирования списка (LinkListView)

- [x] 3.1 Переключатель «Изменить / Готово» в тулбаре/шапке списка, привязанный к `model.editing`
- [x] 3.2 В режиме редактирования показывать в `LinkRow` элемент выбора (чекбокс), тап по строке переключает выбор вместо открытия карточки
- [x] 3.3 Нижняя панель массовых действий с кнопкой «Удалить выбранные (N)», неактивной при пустом выборе
- [x] 3.4 Подтверждение массового удаления (`.confirmationDialog`/`.alert` с числом выбранных) → `model.deleteSelected()`

## 4. UI: контекстное меню строки

- [x] 4.1 Добавить `.contextMenu` на `LinkRow`: «Открыть», «Скопировать адрес», «Деактивировать»/«Активировать» (по `link.status()`), «Удалить» (`.destructive`)
- [x] 4.2 Скрывать/блокировать пункт (де)активации для `viewed`-ссылки; не показывать контекстное меню в режиме редактирования

## 5. Отображение статуса

- [x] 5.1 В `StatusPill` добавить ветку `disabled` («Деактивирована», нейтральный цвет по макету `_design/`)
- [x] 5.2 В `Format.subtitle` (и любых `switch` по `LinkStatus`) обработать `disabled`
- [x] 5.3 В `shortlinks-cli` обработать новый статус в выводе `list` (и любых `switch` по статусу), чтобы CLI собирался и корректно печатал `disabled`

## 6. Тесты (ShortlinksCoreTests)

- [x] 6.1 Тест `Link.status`: деактивированная → `disabled`; приоритет `viewed`/`expired`/`disabled`
- [x] 6.2 Тест `LinkStore.setDisabled`: установка/снятие `disabledAt`, переход активна↔деактивирована
- [x] 6.3 Тест `LinkStore.delete(ids:)`: массовое удаление набора по `id`
- [x] 6.4 Тест совместимости: декодирование `links.json` без поля `disabledAt` (читается как не деактивированная)
- [x] 6.5 Зарегистрировать новые тест-файлы в `project.yml` при необходимости

## 7. Сборка и проверка

- [x] 7.1 `xcodegen generate` после изменений списка файлов/таргетов
- [x] 7.2 Прогнать `ShortlinksCoreTests` (`xcodebuild test … CODE_SIGNING_ALLOWED=NO`) — зелёные
- [x] 7.3 Собрать приложение и вручную проверить: режим редактирования + массовое удаление, контекстное меню, (де)активация блокирует переход
- [x] 7.4 `openspec validate link-list-edit-context-menu --strict`
