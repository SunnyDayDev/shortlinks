#!/usr/bin/env bash
#
# Линт дизайн-системы: вне слоя DesignSystem/ во вью не должно быть «сырых»
# UI-значений — цвета, кегли, отступы и размеры берутся только из токенов
# (`Theme`/`Typography`/`Spacing`/`Size`). Сырые литералы допустимы лишь внутри
# `Sources/ShortlinksApp/DesignSystem/`.
#
# Запуск:  bash Scripts/ds-lint.sh   (код возврата != 0 при нарушениях)

set -uo pipefail

cd "$(dirname "$0")/.." || exit 2

# Слой представления: всё в ShortlinksApp, кроме самой дизайн-системы.
FILES=$(find Sources/ShortlinksApp -name '*.swift' -not -path '*/DesignSystem/*')

# Запрещённые во вью паттерны → читаемое имя. Разделитель «@@» (в regex не встречается).
PATTERNS=(
  'Color\(hex:@@сырой цвет Color(hex:) — заведите токен в Theme'
  '\.controlBackgroundColor@@сырой NSColor — используйте Theme.surface'
  '\.textBackgroundColor@@сырой NSColor — используйте Theme.content'
  '\.windowBackgroundColor@@сырой NSColor — используйте Theme.overlay'
  '\.font\(\.system\(size:@@произвольный кегль — используйте токен Typography'
  '\.padding\([^)]*[^A-Za-z0-9_][1-9]@@голое число в padding — используйте Spacing'
  '(spacing|minLength): [1-9]@@голое число в spacing — используйте Spacing'
  '(width|height|maxWidth|minHeight): [1-9]@@голый размер во frame — используйте Size'
)

violations=0
for entry in "${PATTERNS[@]}"; do
  pattern="${entry%%@@*}"
  message="${entry##*@@}"
  hits=$(echo "$FILES" | tr '\n' '\0' | xargs -0 grep -nE "$pattern" 2>/dev/null)
  if [[ -n "$hits" ]]; then
    echo "✗ $message"
    echo "$hits" | sed 's/^/    /'
    violations=$((violations + 1))
  fi
done

if [[ "$violations" -gt 0 ]]; then
  echo ""
  echo "Дизайн-линт: найдено нарушений — $violations. Перенесите значения в слой токенов."
  exit 1
fi

echo "✓ Дизайн-линт пройден: во вью только токены (цвет/шрифт/spacing/size)."
