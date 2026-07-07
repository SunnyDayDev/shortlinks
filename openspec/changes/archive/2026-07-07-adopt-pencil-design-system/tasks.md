# Tasks — Adopt Pencil Design System

## 1. Версионирование дизайн-файла и чистка

- [x] 1.1 Создать ветку `docs/adopt-pencil-design-system` от свежего `main`
- [x] 1.2 Добавить каталог `design/` (файл `design/shortlinks.pen`) в git; убедиться,
      что мусорные артефакты (например `.DS_Store`) не попадают в индекс
- [x] 1.3 Удалить каталог `_design/` из репозитория
- [x] 1.4 Проверить, что в дизайн-файле нет placeholder-фреймов и битых инстансов
      (snapshot_layout problemsOnly чистый по экранам)

## 2. Документация и конвенции

- [x] 2.1 Обновить `CLAUDE.md`: в «Конвенции» — `design/shortlinks.pen` как источник
      правды дизайна, правка только через Pencil MCP, правило «UI-изменение ⇒
      обновление дизайн-файла», парность токенов/компонентов код ↔ дизайн-файл
- [x] 2.2 Убрать из `CLAUDE.md` упоминания `_design/` (разделы ShortlinksApp и
      Конвенции) — экраны и цвета по дизайн-файлу
- [x] 2.3 Обновить project-контекст OpenSpec (`openspec/project.md` или аналог), если
      он описывает источник дизайна — нет `project.md`/design-упоминаний, правки не нужны

## 3. Спеки, sync и archive (до PR)

- [x] 3.1 `openspec validate adopt-pencil-design-system` — дельты валидны
- [x] 3.2 `/opsx:sync` — влить дельты в главные спеки (`design-file`, `design-system`,
      `dev-workflow`)
- [x] 3.3 `/opsx:archive` — заархивировать изменение

## 4. PR и завершение

- [ ] 4.1 Открыть PR (`docs/adopt-pencil-design-system`) со всем содержимым: дизайн-
      файл, удаление `_design/`, документация, синхронизированные спеки, архив
      изменения; дождаться зелёного CI
- [ ] 4.2 После аппрува: merge-commit (`gh pr merge --merge --delete-branch`),
      подтянуть локальный `main`
