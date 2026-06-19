# cli-interface Specification

## Purpose

Командная строка `shortlinks` для создания, просмотра, удаления, открытия и резолва
ссылок поверх того же хранилища, что использует приложение.

## Requirements

### Requirement: Команда создания ссылки
CLI SHALL предоставлять команду `add <target>` с опциями `--slug`, `--once`/`--reuse`,
`--ttl 1h|24h|7d|never`, `--password`, `--tag` (повторяемая), создающую ссылку в том
же хранилище, что и приложение, и печатающую `sl://link/<slug>`.

#### Scenario: Создание из терминала
- **WHEN** выполняется `shortlinks add https://example.com --once --ttl 24h`
- **THEN** создаётся одноразовая ссылка со сроком 24ч и в stdout печатается `sl://link/<slug>`

### Requirement: Команда списка
CLI SHALL предоставлять `list` с опциями `--filter all|active|once|expired` и `--tag`,
выводящую ссылки в читаемом виде.

#### Scenario: Список активных
- **WHEN** выполняется `shortlinks list --filter active`
- **THEN** выводятся только активные ссылки

### Requirement: Команды удаления, открытия и резолва
CLI SHALL предоставлять `rm <slug>` (удалить), `open <slug>` (резолв и открытие цели с
учётом потребления одноразовой) и `resolve <slug>` (печать цели без открытия).

#### Scenario: Резолв цели
- **WHEN** выполняется `shortlinks resolve <slug>` для существующей ссылки
- **THEN** в stdout печатается её цель

#### Scenario: Открытие одноразовой через CLI
- **WHEN** выполняется `shortlinks open <slug>` для активной одноразовой ссылки
- **THEN** цель открывается и ссылка помечается потреблённой

#### Scenario: Удаление
- **WHEN** выполняется `shortlinks rm <slug>`
- **THEN** ссылка удаляется из хранилища
