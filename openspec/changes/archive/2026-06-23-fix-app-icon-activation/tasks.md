## 1. Показ окна при пользовательской активации

- [x] 1.1 В `AppDelegate` добавить флаг `didOpenURLAtLaunch`; в `application(_:open:)`
  выставлять его перед обработкой URL.
- [x] 1.2 В `applicationDidFinishLaunching` после привязки замыканий запланировать
  `DispatchQueue.main.async`: если `didOpenURLAtLaunch == false` — показать окно через
  `surfaceForInteraction(forRedirect: false)`.
- [x] 1.3 Реализовать `applicationShouldHandleReopen(_:hasVisibleWindows:)`: показать
  окно (`surfaceForInteraction(forRedirect: false)`), вернуть `true`.
- [x] 1.4 Починить фокус окна на холодном старте `sl://`: в `surfaceForInteraction`
  отложить `activate` + показ окна на следующий тик рунлупа (иначе на запуске ради
  защищённой ссылки окно не выходит в фокус).

## 2. Проверка

- [x] 2.1 Холодный запуск кликом по иконке/Spotlight: открывается главное окно.
- [x] 2.2 Reopen: при запущенном агенте повторный клик по иконке поднимает окно.
- [x] 2.3 Регрессия: фоновый `sl://` (многоразовая без пароля) остаётся тихим — без
  окна и иконки в Dock.
- [x] 2.4 `sl://`, требующий UI (пароль/ненайдена/подтверждение), по-прежнему
  показывает оверлей и возвращается в фон.

## 3. Документация и спека

- [x] 3.1 Обновить `CLAUDE.md` (модуль ShortlinksApp): показ окна при обычном
  запуске/reopen наряду с тихим `sl://`.
- [x] 3.2 `/opsx:sync` — перенести дельту в `openspec/specs/link-redirection`.
