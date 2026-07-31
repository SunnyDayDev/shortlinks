# Участие в разработке

Спасибо за интерес к проекту! Этот документ описывает, как устроен процесс
разработки Shortlinks и что ожидается от изменений. Технические детали сборки —
в [README.md](README.md), инструкции для AI-агентов — в [CLAUDE.md](CLAUDE.md).

## Spec-Driven Development (OpenSpec)

Проект разрабатывается по методологии **Spec-Driven Development** на базе
[OpenSpec](https://openspec.dev). Действующие спецификации в
`openspec/specs/` — источник правды о поведении системы: код реализует спеки,
а не наоборот.

**Любое изменение логики обязано идти через этот процесс и обновлять спеки:**

1. **Предложение** — изменение оформляется как change в `openspec/changes/<name>/`
   (proposal, design при необходимости, delta-спеки, tasks). Команда: `/opsx:propose`.
2. **Реализация** — код пишется по tasks.md изменения, прогресс отмечается
   чекбоксами. Команда: `/opsx:apply`.
3. **Синхронизация** — delta-спеки вливаются в основные `openspec/specs/`.
   Команда: `/opsx:sync`.
4. **Архивация** — завершённый change уезжает в `openspec/changes/archive/`.
   Команда: `/opsx:archive`.

Синхронизация и архивация выполняются **до открытия PR** — в `main` изменение
приходит уже с актуальными спеками. Валидность спеков проверяется командой
`openspec validate`.

Исключения — правки, не меняющие поведение системы: опечатки, документация,
рефакторинг без изменения контрактов, обслуживание CI. Им change не нужен.

## Git-процесс

`main` — стабильная ветка, защищена branch protection: прямые коммиты, force-push
и удаление запрещены, мерж — только через Pull Request с зелёным обязательным
чеком «ShortlinksCore tests».

- **Ветка под каждое изменение**, от свежего `main`. Именование:
  `feat/<kebab>` — функционал, `fix/<kebab>` — исправление,
  `chore/<kebab>` — обслуживание, `docs/<kebab>` — документация/спеки.
- **PR** с осмысленным заголовком и описанием: что сделано и зачем. Если изменение
  затрагивает логику — в PR входят обновлённые спеки (см. выше). Если PR меняет
  внешний вид приложения — в него входит обновление `design/shortlinks.pen`;
  если визуальных изменений нет, это отмечается в описании.
- **Слияние** — merge-commit (`gh pr merge <n> --merge --delete-branch`), ветка
  после мержа удаляется, локальный `main` подтягивается
  (`git checkout main && git pull --ff-only`).

## Правила кода

- **Доменная логика — в ShortlinksCore**, не дублируется в app/CLI.
- **Строки** — только через реестр `Strings` поверх `Localizable.xcstrings`
  (русский — язык-источник); пользовательские литералы не хардкодятся.
- **Иконки** — только через реестр `Icons`; имена SF Symbols не хардкодятся во вью.
- **Дизайн-система** — вью строятся из токенов и компонентов `DesignSystem`;
  сырые цвета/кегли/отступы запрещены (проверяется `Scripts/ds-lint.sh`). Новый
  токен/компонент добавляется парно: в код и в `design/shortlinks.pen`.
- **Дизайн-файл** `design/shortlinks.pen` редактируется через редактор
  [Pen](https://pen.new) (MCP-сервер `pencil`); ручная правка JSON — только при
  разрешении merge-конфликтов. Инварианты проверяет `python3 design/validate_pen.py`.
- **Проект генерируется**: `Shortlinks.xcodeproj` не коммитится — правьте
  `project.yml` и запускайте `xcodegen generate`.
- Новая доменная логика сопровождается юнит-тестами в `Tests/ShortlinksCoreTests`.

## Проверки перед PR

```bash
xcodegen generate
xcodebuild -project Shortlinks.xcodeproj -scheme ShortlinksApp build
xcodebuild test -project Shortlinks.xcodeproj -scheme ShortlinksCoreTests \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
bash Scripts/ds-lint.sh
python3 design/validate_pen.py   # если менялся дизайн-файл
openspec validate                # если менялись спеки
```

CI (GitHub Actions, `macos-15`) прогоняет `ShortlinksCoreTests` на каждый PR;
без зелёного чека мерж заблокирован.
