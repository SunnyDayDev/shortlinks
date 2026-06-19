## 1. Сверка формата плагина/навыка

- [x] 1.1 Уточнить актуальный формат Claude-плагина (`.claude-plugin/plugin.json`),
  авто-дискавери `skills/`, фронтматтер `SKILL.md` и способ установки плагина в агент
  (локальный путь / marketplace) — через claude-code-guide или актуальную документацию

## 2. Каркас плагина

- [x] 2.1 Создать `plugins/shortlinks/.claude-plugin/plugin.json` с `name`, `description`,
  `version`, `author`
- [x] 2.2 Создать `plugins/shortlinks/skills/shortlinks/SKILL.md` с фронтматтером
  `name` и срабатывающим `description`

## 3. Содержание навыка (SKILL.md)

- [x] 3.1 Раздел «Что это»: `sl://link/<slug>`, локальное хранилище, одноразовые vs
  многоразовые
- [x] 3.2 Раздел «Доступность CLI»: проверка `command -v shortlinks`, fallback на
  `…/Shortlinks.app/Contents/Helpers/shortlinks`, как установить из приложения (без
  упоминания устаревшего `Contents/MacOS`)
- [x] 3.3 Команды с примерами и опциями: `add`, `list`, `rm`, `resolve`, `open`
  (включая `--once/--reuse`, `--ttl`, `--password`, `--tag/-g`, `--filter`,
  `--delete-on-consume`)
- [x] 3.4 Парсинг вывода (`sl://link/<slug>`, цель, строки list) и семантика:
  `open` потребляет одноразовую, `resolve` — нет
- [x] 3.5 Обработка ошибок: не найдено / недоступно / требуется пароль; когда выбирать
  `resolve` против `open`

## 4. Распространение и документация

- [x] 4.1 Добавить в `README.md` раздел «Использование навыка в других агентах» с
  командой установки плагина

## 5. Проверка

- [x] 5.1 Проверить примеры команд из навыка на реальном CLI (`add` → `sl://link/...`,
  `resolve` печатает цель, `list` формат, поведение ошибок) — вывод совпадает с навыком
- [x] 5.2 По возможности установить/активировать плагин и убедиться, что навык виден
  агенту
- [x] 5.3 `openspec validate add-shortlinks-skill --strict` — без ошибок
