#!/usr/bin/env python3
"""Проверка инвариантов дизайн-файла `.pen` (обычный JSON).

Основа пост-merge-проверки «безопасно ли смержено» (см. change `pen-merge-safety`
и capability `design-file`). Проверяет:

  1. файл парсится как JSON;
  2. все `id` узлов глобально уникальны;
  3. каждая ссылка `$variableName` присутствует в `variables`;
  4. каждый `ref`-инстанс указывает на существующий reusable-компонент.

Ссылочная целостность `descendants` осознанно не проверяется: ключи там могут быть
id, уникальным именем или путём — надёжно валидируется только в самом Pen.

Выход: 0 — инвариантов не нарушено; 1 — есть нарушения (печатаются); 2 — файл не JSON.

Usage: python3 design/validate_pen.py [path-to.pen]   # по умолчанию — соседний shortlinks.pen
"""
import json
import os
import re
import sys
from collections import Counter

VAR_REF = re.compile(r"^\$([A-Za-z0-9_-]+)$")


def walk(node, on_dict):
    """Обойти дерево узлов, вызывая on_dict для каждого dict."""
    if isinstance(node, dict):
        on_dict(node)
        for value in node.values():
            walk(value, on_dict)
    elif isinstance(node, list):
        for item in node:
            walk(item, on_dict)


def find_var_refs(node, out):
    """Собрать все строковые значения вида "$name" в свойствах узлов."""
    if isinstance(node, dict):
        for value in node.values():
            find_var_refs(value, out)
    elif isinstance(node, list):
        for item in node:
            find_var_refs(item, out)
    elif isinstance(node, str):
        m = VAR_REF.match(node)
        if m:
            out.add(m.group(1))


def main(argv):
    default = os.path.join(os.path.dirname(os.path.abspath(__file__)), "shortlinks.pen")
    path = argv[1] if len(argv) > 1 else default

    try:
        with open(path, encoding="utf-8") as f:
            doc = json.load(f)
    except FileNotFoundError:
        print(f"ОШИБКА: файл не найден: {path}")
        return 2
    except json.JSONDecodeError as e:
        print(f"ОШИБКА: не валидный JSON ({path}): {e}")
        return 2

    variables = doc.get("variables", {})
    children = doc.get("children", [])

    ids = []
    reusable_ids = set()
    ref_targets = []  # (ref_value, present_flag_filled_later)

    def collect(n):
        if "id" in n:
            ids.append(n["id"])
        if n.get("reusable"):
            reusable_ids.add(n.get("id"))
        if n.get("type") == "ref":
            ref_targets.append(n.get("ref"))

    walk(children, collect)

    id_set = set(ids)
    problems = []

    # 2. уникальность id
    dups = sorted(i for i, c in Counter(ids).items() if c > 1)
    if dups:
        problems.append(f"дубли id ({len(dups)}): {', '.join(dups[:15])}")

    # 3. разрешимость $var
    refs = set()
    find_var_refs(children, refs)
    missing_vars = sorted(r for r in refs if r not in variables)
    if missing_vars:
        problems.append(f"$var без определения ({len(missing_vars)}): {', '.join(missing_vars[:15])}")

    # 4. ref → существующий reusable-компонент
    dangling = sorted({r for r in ref_targets if r not in id_set})
    if dangling:
        problems.append(f"висячие ref ({len(dangling)}): {', '.join(dangling[:15])}")
    non_reusable = sorted({r for r in ref_targets if r in id_set and r not in reusable_ids})
    if non_reusable:
        problems.append(f"ref на не-reusable узел ({len(non_reusable)}): {', '.join(non_reusable[:15])}")

    summary = (
        f"{os.path.basename(path)}: "
        f"{len(ids)} узлов, {len(reusable_ids)} компонентов, "
        f"{len(ref_targets)} инстансов, {len(variables)} переменных, "
        f"{len(refs)} $var-ссылок"
    )
    print(summary)

    if problems:
        print("НАРУШЕНИЯ:")
        for p in problems:
            print(f"  - {p}")
        return 1

    print("OK — инвариантов не нарушено")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
