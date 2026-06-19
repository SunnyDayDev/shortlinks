## 1. Перенос вложенного CLI в project.yml

- [x] 1.1 В copy-фазе `shortlinks-cli` у таргета `ShortlinksApp` заменить
  `destination: executables` / `subpath: ""` на `destination: wrapper` /
  `subpath: Contents/Helpers` (с сохранением `embed: true`, `codeSign: true`)
- [x] 1.2 Обновить комментарий про путь вложенного CLI в `project.yml`
  (`Contents/MacOS/shortlinks` → `Contents/Helpers/shortlinks`)

## 2. Обновление CLIInstaller

- [x] 2.1 В `CLIInstaller.standard()` строить `bundledBinaryURL` как
  `Contents/Helpers/shortlinks` вместо `Contents/MacOS/shortlinks`
- [x] 2.2 В `isShortlinksBinary` заменить проверку пути
  `Shortlinks.app/Contents/MacOS` на `Shortlinks.app/Contents/Helpers`
- [x] 2.3 Обновить докстринги/комментарии с упоминанием пути вложенного бинаря

## 3. Тесты

- [x] 3.1 В `CLIInstallerTests` заменить `Shortlinks.app/Contents/MacOS` на
  `Shortlinks.app/Contents/Helpers` (имитация вложенного бинаря и проверка чужого бандла)

## 4. Документация и регенерация

- [x] 4.1 Обновить `CLAUDE.md`: расположение вложенного CLI —
  `Contents/Helpers/shortlinks`
- [x] 4.2 `xcodegen generate` — перегенерировать `Shortlinks.xcodeproj`

## 5. Проверка

- [x] 5.1 Прогнать `ShortlinksCoreTests` (`xcodebuild test … CODE_SIGNING_ALLOWED=NO`) — зелёные
- [x] 5.2 Собрать `ShortlinksApp` (Release); убедиться, что
  `Contents/MacOS/Shortlinks` — бинарь приложения, а `Contents/Helpers/shortlinks` — CLI
  (разные inode/размеры)
- [x] 5.3 `codesign --verify --deep --strict` по бандлу — валиден; приложение запускается
  (`open`), процесс живёт
- [x] 5.4 `openspec validate fix-cli-bundle-path-collision --strict` — без ошибок
