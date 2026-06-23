## 1. Слой токенов (Tokens)

- [x] 1.1 Создать каталог `Sources/ShortlinksApp/DesignSystem/Tokens/`; перенести в
  него `Color(hex:)`/`Color.dyn` и foundation-палитру (приватные hex-константы из
  макета `_design/`) как единственное место сырых литералов
- [x] 1.2 Цветовые токены (semantic): accent/accentHover, surface, surfaceSubtle,
  content, sidebar, separator, textPrimary, textSecondary, code, iconTileBg/iconTileFg,
  onceAccent/onceText, activeAccent, destructive/destructiveBg, `status(_:)` — поверх
  foundation и системных `NSColor`; свести дубликаты серого (`0x9AA0AC`/`0x9AA0AA`) к
  одному токену
- [x] 1.3 Типографические токены: именованная шкала (`title`/`headline`/`body`/
  `caption`/… + mono-варианты), отображающая текущие кегли с визуальным паритетом
- [x] 1.4 Токены отступов (spacing-шкала) и радиусов (`sm`/`md`/`lg` + пилюля/плитка),
  покрывающие текущие значения
- [x] 1.5 Обновить `project.yml`, прогнать `xcodegen generate`, убедиться, что app
  собирается с новым слоем токенов

## 2. Компоненты и стили

- [x] 2.1 Кнопки: `PrimaryButtonStyle`, `SecondaryButtonStyle`, `DestructiveButtonStyle`
  (единые цвет/радиус/отступы, опц. иконка)
- [x] 2.2 `.card()` модификатор (surface + рамка + радиус) и `SectionLabel`
  (объединяет `groupLabel`/`sectionLabel`)
- [x] 2.3 `FieldBox`/input-стиль, `CodeBox` (моно-блок), `IconTile` (SF Symbol на
  цветном фоне)
- [x] 2.4 Перевести существующие `StatusPill`, `TargetIcon`, `TagChip` на токены
  (убрать hardcoded `0x3F6BB5`/`0x2A6FDB` в `TagChip`)
- [x] 2.5 Регенерировать проект и собрать app с компонентами

## 3. Миграция экранов (поэкранно, с визуальной сверкой)

- [x] 3.1 `SidebarView` — на токены/`IconTile`/`SectionLabel`
- [x] 3.2 `MainView` (тулбар, bulkBar, toast) — на токены/`PrimaryButtonStyle`
- [x] 3.3 `LinkListView` (`LinkRow`, `EmptyState`) — на `.card()`/токены/primary-кнопку
- [x] 3.4 `LinkDetailView` (`infoCard`, кнопки open/delete) — на `.card()`/стили кнопок
- [x] 3.5 `CreateSheet` (поля, slug-инпут) — на `FieldBox`/токены
- [x] 3.6 `SettingsView` (`card`/`row`/`groupLabel`, CLI-блок) — на компоненты/токены
- [x] 3.7 `RedirectOverlay` (ready/blocked/consumed, code-box) — на `CodeBox`/токены/кнопки
- [x] 3.8 `HowItWorksView` (шаги, пример) — на `.card()`/`IconTile`/токены

## 4. Чистка и инвариант

- [x] 4.1 Удалить устаревшие inline-хелперы (`boxBg`, локальные `card`/`groupLabel`/
  `sectionLabel` и т.п.), осиротевшие константы
- [x] 4.2 Добавить grep-линт (скрипт/проверка): во `Views/` и `MainView.swift` нет
  `Color(hex:`, прямых `*.BackgroundColor`, `.font(.system(size:`
- [x] 4.3 Прогнать линт — добиться нуля совпадений (сырые значения только в слое токенов)

## 5. Верификация

- [x] 5.1 Финальный `xcodegen generate` + сборка `ShortlinksApp`
- [x] 5.2 Прогнать `ShortlinksCoreTests` (CODE_SIGNING_ALLOWED=NO) — зелёные
- [x] 5.3 Визуальная проверка всех экранов в светлой и тёмной теме на соответствие
  домиграционному виду и макету `_design/`
- [x] 5.4 Проверить смену темы «в одном месте»: правка одного цветового токена меняет
  акцент по всему приложению без правок во `Views/`

## 6. Шкалы spacing/size (убрать магические числа)

- [x] 6.1 `Spacing` — шкала под ритм макета (2/4/6/8/12/14/18/22/26/32),
  пиксель-сохраняющая для доминирующих значений; хвост (3/5/7/9/13) снап ≤2px
- [x] 6.2 `Size` — именованные токены фиксированных размеров (ширины окна/листа/оверлея,
  высоты контролов/полей, ширины колонок-меток, max-ширины контента, размеры плиток,
  точки-индикаторы)
- [x] 6.3 Перевести все отступы/спейсинги/`frame`-размеры во `Views/` на `Spacing`/`Size`
  (ноль голых чисел в layout)

## 7. Atoms / Molecules (структура поверх токенов)

- [x] 7.1 Разнести дизайн-систему на `Tokens/` · `Atoms/` · `Molecules/`
  (atoms = примитивы и стили; molecules = составные компоненты)
- [x] 7.2 `ScreenContainer` (molecule) — общий контейнер экрана (max-ширина + единые
  отступы), заменяет повтор в Detail/Settings/HowItWorks/CreateSheet
- [x] 7.3 Промоут повторяющихся составных паттернов в molecules, впитывающие размеры:
  `LabeledField` (CreateSheet), `InfoRow` (LinkDetail), `SidebarItem` (Sidebar),
  `SettingsRow`/`SettingsCard` (Settings)
- [x] 7.4 Удалить локальные хелперы экранов, заменённые molecules

## 8. Линт и финальная верификация (расширенный объём)

- [x] 8.1 Расширить `Scripts/ds-lint.sh`: во `Views/` нет голых чисел в
  `.padding(`/`spacing:`/`frame(width|height|maxWidth:` (только `Spacing`/`Size`)
- [x] 8.2 `xcodegen generate` + сборка `ShortlinksApp`; `ShortlinksCoreTests` зелёные;
  линт (цвет/шрифт/spacing/size) проходит
- [x] 8.3 Финальная визуальная сверка всех экранов в светлой и тёмной теме (закрывает 5.3)
