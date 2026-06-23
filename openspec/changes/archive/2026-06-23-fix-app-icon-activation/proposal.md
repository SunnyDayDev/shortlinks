## Why

После перевода приложения в фоновый агент (`LSUIElement`, change
`deeplink-silent-open`) пропала возможность открыть главное окно кликом по иконке
приложения (Finder / Spotlight / Launchpad). Раньше окно показывала сцена SwiftUI
`Window` при запуске; её убрали ради тихого `sl://`, но обработку «обычного» запуска и
повторной активации (reopen) не добавили. Итог: клик по иконке поднимает агента в
меню-бар без окна — пользователь думает, что приложение не запускается. Переходы по
`sl://` при этом работают (идут через `application(_:open:)`).

## What Changes

- Запуск приложения **не через `sl://`** (двойной клик по иконке, Spotlight) SHALL
  показывать главное окно.
- Повторная активация уже запущенного агента (`applicationShouldHandleReopen`, клик по
  иконке) SHALL показывать/поднимать главное окно.
- Тихий фоновый сценарий `sl://` сохраняется: запуск ради открытия ссылки **не**
  показывает окно (отличаем launch-with-URL от обычного запуска).

## Capabilities

### New Capabilities

(нет)

### Modified Capabilities

- `link-redirection`: к поведению агента (тихое фоновое открытие, временное повышение
  политики) добавляется требование показывать окно при пользовательской активации
  приложения — обычный запуск и reopen, в отличие от фонового открытия `sl://`.

## Impact

- `Sources/ShortlinksApp/ShortlinksApp.swift` — `AppDelegate`:
  `applicationDidFinishLaunching` (показ окна при запуске без URL),
  `applicationShouldHandleReopen(_:hasVisibleWindows:)`, флаг «запущен ради URL».
- Спека `openspec/specs/link-redirection` — обновляется через `/opsx:sync`.
- Регрессия из change `deeplink-silent-open` (уже заархивирован).
