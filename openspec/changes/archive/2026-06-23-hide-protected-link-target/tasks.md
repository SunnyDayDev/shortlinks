## 1. Строки и иконки (реестры)

- [x] 1.1 В `Sources/ShortlinksCore/Strings.swift` добавить строки: `Redirect.protectedBody` («Эта ссылка защищена паролем. Введите пароль, чтобы открыть.»), `Detail.reveal` («Показать»), `Detail.hide` («Скрыть»), `Common.targetMask` («••••••••», общая — список и детали).
- [x] 1.2 ~~Добавить ключи в `Localizable.xcstrings`~~ → **не требуется**. Обнаружено при реализации: каталог содержит только plural-вариации (`expiry.*`), а все плоские строки (`redirect.confirmBody`, `common.password`, …) живут в коде через `L()`/`defaultValue` и в каталоге отсутствуют. Добавление плоских ключей нарушило бы этот установившийся паттерн. Новые строки резолвятся через `defaultValue` (ru — язык-источник), как и все прочие плоские строки; запись в каталог понадобится только при переводе на новый язык.
- [x] 1.3 В `Sources/ShortlinksApp/DesignSystem/Tokens/Icons.swift` добавить группу `Reveal` с `show = "eye"` и `hide = "eye.slash"`.

## 2. Оверлей перехода — скрыть цель защищённой ссылки

- [x] 2.1 В `Sources/ShortlinksApp/Views/RedirectOverlay.swift`, во `var ready`, разветвить по `link.isProtected`: для защищённой ссылки НЕ рендерить `Text(Strings.Redirect.confirmBody)` и `Text(link.target)`; показать иконку замка (`Icons.Status.privacy`) и `Strings.Redirect.protectedBody`.
- [x] 2.2 Для защищённой ветки сохранить `SecureField` (пароль), предупреждение `once` (если `kind == .once`) и кнопки «Отмена»/«Открыть»; убедиться, что адрес `sl://` остаётся в шапке оверлея, а цель не отображается нигде в фазе `ready`.
- [x] 2.3 Незащищённую ветку (включая режим подтверждения) оставить без изменений — цель показывается как прежде.

## 3. Карточка деталей — маска и раскрытие по паролю

- [x] 3.1 В `Sources/ShortlinksApp/Views/LinkDetailView.swift` добавить компонент `ProtectedTargetRow` (без нового файла; в слое Views, а не в DesignSystem — чтобы доменная проверка пароля и `Strings` не протекали в presentational-молекулы) с локальным состоянием `masked → prompting → revealed`: в `masked` — метка «Перенаправляет на», маска `Strings.Detail.targetMask` (невыделяемая) и кнопка `Icons.Reveal.show` + `Strings.Detail.reveal`; в `prompting` — `SecureField` (`Strings.Common.password`) с подтверждением/отменой; в `revealed` — настоящая цель (`mono`, выделяемая) и кнопка `Icons.Reveal.hide` + `Strings.Detail.hide`.
- [x] 3.2 В `ProtectedTargetRow` по подтверждению пароля вызвать `Password.verify(input, against: passwordHash)`: при совпадении — перейти в `revealed`; при несовпадении — оставить скрытой и показать встроенное сообщение `Strings.Toast.wrongPassword`.
- [x] 3.3 В `Sources/ShortlinksApp/Views/LinkDetailView.swift`, в `infoCard`, для `link.isProtected` подставить `ProtectedTargetRow` вместо `InfoRow(label: redirectsTo, …)`; для незащищённой ссылки оставить существующий `InfoRow`.
- [x] 3.4 Привязать `.id(link.id)` к `ProtectedTargetRow` (или к контейнеру деталей), чтобы раскрытие сбрасывалось при переходе к другой ссылке и повторном открытии карточки.

- [x] 3.5 В `Sources/ShortlinksApp/Views/LinkListView.swift` (`LinkRow`) для защищённой ссылки заменить `Text(link.target)` на маску `Strings.Common.targetMask`; раскрытия прямо из списка нет.
- [x] 3.6 В `Sources/ShortlinksApp/DesignSystem/Atoms/TargetIcon.swift` добавить флаг `masked` (замок `Icons.Status.privacy` вместо кода типа) и включать его для защищённой ссылки в списке (`LinkRow`) и в шапке деталей (`LinkDetailView`).

## 4. Сборка и проверка спеков

- [x] 4.1 `openspec validate hide-protected-link-target --strict` — спеки валидны.
- [x] 4.2 Собрать приложение: `xcodebuild -project Shortlinks.xcodeproj -scheme ShortlinksApp build` (новых файлов нет → `xcodegen generate` не требуется).
- [x] 4.3 Прогнать юнит-тесты ядра (логика не менялась, sanity): `xcodebuild test -project Shortlinks.xcodeproj -scheme ShortlinksCoreTests -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO`.

## 5. Ручная верификация сценариев

- [x] 5.1 Оверлей защищённой ссылки: открыть `sl://link/<slug>` защищённой ссылки → видны только адрес `sl://` и запрос пароля, цель не показана; верный пароль → переход; неверный → ошибка, перехода нет.
- [x] 5.2 Детали защищённой ссылки: строка «Перенаправляет на» показывает маску и «Показать»; верный пароль раскрывает цель и даёт «Скрыть»; «Скрыть» снова маскирует; неверный пароль → сообщение об ошибке, цель скрыта.
- [x] 5.3 Сброс раскрытия: раскрыть цель, перейти к другой ссылке и вернуться → цель снова замаскирована.
- [x] 5.4 Регрессия незащищённых ссылок: в оверлее (режим подтверждения) и в деталях цель показывается как раньше, без запроса пароля.
- [x] 5.5 Список: защищённая ссылка показывает маску вместо цели и замок вместо иконки типа; незащищённая ссылка — цель и обычную иконку (регрессия).
