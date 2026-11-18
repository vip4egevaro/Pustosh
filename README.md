# Пустошь V7.5 — Godot GUI tests

Приватный репозиторий для исходной игры «Пустошь». Исходный архив: `Pustosh_V7_5_CLAY_MENU_FULL.zip` (85.2 MiB, 320 файлов).

## Первая загрузка полного проекта

Для передачи больших бинарных PNG через ограниченный коннектор архив разрезан на 5 частей:

- `pustosh_v7_5.part00.bin`
- `pustosh_v7_5.part01.bin`
- `pustosh_v7_5.part02.bin`
- `pustosh_v7_5.part03.bin`
- `pustosh_v7_5.part04.bin`

Загрузи **пять файлов в корень этого репозитория** через страницу [Upload files](https://github.com/vip4egevaro/Pustosh/upload/main) и нажми Commit changes. Не распаковывай части вручную.

Workflow [Import Pustosh V7.5 archive](../../actions/workflows/import-v75.yml) объединит части, сверит SHA-256 исходного ZIP, распакует `Pustosh_V7_5_ClayUI/` в корень репозитория и сохранит исходники без пяти временных файлов.

SHA-256 исходного ZIP: `0eb90b9f2a223402283b9d0ed49211df5015219fa349dcaaf5d7d65a19564361`

После успешного импорта запусти [Pustosh V7.5 - graphical playtest](../../actions/workflows/pustosh-visual.yml) кнопкой **Run workflow**.

## Проверки

- Запуск настоящей сцены `main_world.tscn` с программным OpenGL и Xvfb
- Движение героя через игровой контроллер
- Открытие вкладки крафта
- Крафт дубины и безрукавки с тестовыми ресурсами
- Сохранение 5 скриншотов и JSON-отчёта в артефакте `pustosh-v75-visual-results`

Это **сценарный графический тест**, а не интерактивное управление героем человеком. До успешного запуска workflow результат не подтверждён.
