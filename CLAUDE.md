@AGENTS.md

# Специфика Claude Code

Общие правила проекта — в [AGENTS.md](AGENTS.md) (импортирован выше). Ниже только то,
что относится к Claude Code.

## Слэш-команды OpenSpec

Шаги цикла OpenSpec доступны и как слэш-команды (`.claude/commands/opsx/`), и как
скиллы (`.agents/skills/`, автотриггер). Соответствие:

| Команда | Скилл |
| --- | --- |
| `/opsx:propose` | `openspec-propose` |
| `/opsx:apply` | `openspec-apply-change` |
| `/opsx:sync` | `openspec-sync-specs` |
| `/opsx:archive` | `openspec-archive-change` |
| `/opsx:explore` | `openspec-explore` |

## Скиллы и настройки

- `.claude/skills/` — реальная директория с **симлинком на каждый скилл** в
  `.agents/skills/`. Директорию целиком не симлинкать: обнаружение скиллов через
  симлинкнутую директорию верхнего уровня ненадёжно. Новый скилл: создать в
  `.agents/skills/<name>/`, затем `ln -sfn ../../.agents/skills/<name> .claude/skills/<name>`.
- `.claude/settings.json` — проектные настройки, в git. `.claude/settings.local.json` —
  машинные, в `.gitignore`; в репозиторий не коммитятся.
- MCP-серверы (в т. ч. `pencil` для `design/shortlinks.pen`) настроены на уровне
  пользователя — `.mcp.json` в репозитории намеренно нет.
