## MODIFIED Requirements

### Requirement: Команда создания ссылки
CLI SHALL предоставлять команду `add <target>` с опциями `--slug`, `--once`/`--reuse`,
`--ttl 1h|24h|7d|never`, `--password`, `--note` (описание) и `--tag` (повторяемая),
создающую ссылку в том же хранилище, что и приложение, и печатающую `sl://link/<slug>`.
Пустое значение `--note` (или его отсутствие) SHALL означать ссылку без описания.

#### Scenario: Создание из терминала
- **WHEN** выполняется `shortlinks add https://example.com --once --ttl 24h`
- **THEN** создаётся одноразовая ссылка со сроком 24ч и в stdout печатается `sl://link/<slug>`

#### Scenario: Создание с описанием
- **WHEN** выполняется `shortlinks add https://example.com --note "Гостевой Wi-Fi"`
- **THEN** создаётся ссылка, в записи которой поле `note` содержит «Гостевой Wi-Fi»

### Requirement: Команда списка
CLI SHALL предоставлять `list` с опциями `--filter all|active|once|expired` и `--tag`,
выводящую ссылки в читаемом виде. Для ссылки с заданным описанием (`note`) вывод SHALL
включать это описание.

#### Scenario: Список активных
- **WHEN** выполняется `shortlinks list --filter active`
- **THEN** выводятся только активные ссылки

#### Scenario: Описание в списке
- **WHEN** выполняется `shortlinks list` и у ссылки задано описание
- **THEN** в её строке вывода присутствует текст описания
