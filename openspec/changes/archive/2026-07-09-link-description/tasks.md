## 1. Модель и ядро (ShortlinksCore)

- [x] 1.1 Добавлено `public var note: String?` в `Link` (после `tags`); включено в `init` параметром `note: String? = nil`.
- [x] 1.2 В `Link.make` добавлен параметр `note: String? = nil`, нормализуется (`trimmingCharacters(in: .whitespacesAndNewlines)`, пустое → `nil`).
- [x] 1.3 `Codable` синтезируется корректно (round-trip тест); `ConflictMerge` не менялся — `note` едет с победившей записью по `id`.

## 2. Локализация (строки)

- [x] 2.1 В реестр `Strings` добавлены ключи с русским `defaultValue`: `create.noteLabel`, `create.notePlaceholder`, `detail.note`, `cli.add.note`.
- [x] 2.2 Правки `Localizable.xcstrings` не нужны: каталог хранит только plural-вариации, singular-строки резолвятся из `defaultValue` (как все прочие). Литералов во вью/CLI нет.

## 3. Приложение (ShortlinksApp)

- [x] 3.1 `CreateForm`: добавлено `note = ""`; `openCreate()` сбрасывает форму (note → "").
- [x] 3.2 `AppModel.submitCreate()`: передаёт `form.note` в `Link.make(note:)`.
- [x] 3.3 `AppModel.filteredLinks`: `note` включён в предикат поиска (регистронезависимо).
- [x] 3.4 `CreateSheet`: многострочное поле «Описание» (`TextField(axis: .vertical)`) после «Короткий адрес», перед Тип/Срок, через `LabeledField`/`fieldBox()`.
- [x] 3.5 `LinkDetailView`: строка «Описание» первой в инфо-карточке, когда `note` задано.
- [x] 3.6 `LinkRow` (LinkListView): когда `note` задано — показывает его **вместо** строки цели/маски (`text-primary`, `lineLimit(1)`), иначе цель; без иконки. Для защищённой ссылки описание не маскируется.
- [x] 3.7 `RedirectOverlay`: описание в блоке подтверждения, когда задано (в т.ч. для защищённой ссылки).

## 4. CLI (shortlinks-cli)

- [x] 4.1 `Add`: опция `@Option --note`, проброшена в `Link.make(note:)`.
- [x] 4.2 `ListCmd`: описание выводится второй строкой с отступом, когда `note` задано (формат существующих строк не изменён).

## 5. Дизайн-файл (design/shortlinks.pen) — согласовано и внесено

- [x] 5.1 Поле «Описание» на экране создания (после «Короткий адрес», перед Тип/Срок), из существующих токенов.
- [x] 5.2 Строка «Описание» первой в инфо-карточке деталей (InfoRow, значение переносится).
- [x] 5.3 В LinkRow описание заменяет строку цели, когда задано (иначе — цель); без иконки.
- [x] 5.4 Описание в оверлее подтверждения перехода (видно и для защищённой ссылки).
- [x] 5.5 `python3 design/validate_pen.py` — инварианты `.pen` целы.

## 6. Тесты (ShortlinksCoreTests)

- [x] 6.1 `testNoteRoundTrip`: `Link` c `note` кодируется/декодируется, значение сохраняется.
- [x] 6.2 `testDecodesLegacyJSONWithoutNote`: запись без ключа `note` → `note == nil`.
- [x] 6.3 `testMakeTrimsAndNilsEmptyNote`: пустое/пробельное описание → `nil`, непустое — тримится.
- [x] 6.4 `testResolvePreservesNoteOfWinner`: `ConflictMerge` сохраняет `note` победившей записи.
- [x] 6.5 Тесты добавлены в существующие файлы (LinkTests/ConflictMergeTests) — новых файлов нет, `project.yml`/`xcodegen` правок не требуют.

## 7. Сборка и проверка

- [x] 7.1 `xcodegen generate`; `ShortlinksCoreTests` — 74 теста зелёные (`CODE_SIGNING_ALLOWED=NO`); `ShortlinksApp` и `shortlinks-cli` собираются без ошибок.
- [x] 7.2 Ядро `note` покрыто юнит-тестами (создание/персист/обратная совместимость/merge), app+CLI компилируются, дизайн сверён в Pencil. Живой прогон CLI против реального `links.json` и GUI-смоук намеренно не запускались (CLI пишет в реальное хранилище — не засоряю данные; app — фоновый агент).
