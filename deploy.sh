#!/bin/bash
# Публикация карты Эрмитажа на GitHub Pages одной командой.
#
# Как настроить (один раз):
#   1. Склонировать репозиторий:
#        git clone https://github.com/zhannanedark/hermitage.git
#        cd hermitage
#   2. Разрешить запуск скрипта:
#        chmod +x deploy.sh
#   3. Включить GitHub Pages: Settings → Pages → Deploy from a branch → main → /(root)
#
# Как пользоваться:
#   Правишь файлы прямо в папке репозитория — index.html, styles.css, любые другие —
#   и выполняешь:
#        ./deploy.sh
#   Скрипт закоммитит всё изменившееся и запушит.
#   Через минуту страница обновится: https://zhannanedark.github.io/hermitage/
#
#   Если хочется задать своё сообщение коммита вместо даты:
#        ./deploy.sh "Поправила цвета залов"

set -euo pipefail

PAGES_URL="https://zhannanedark.github.io/hermitage/"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

# 0. Убеждаемся, что это репозиторий и мы на ветке
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Папка $REPO_DIR — не git-репозиторий. Деплоить нечего."
  exit 1
fi

BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
if [ -z "$BRANCH" ]; then
  echo "Сейчас вы не на ветке (detached HEAD)."
  echo "Вернитесь на основную ветку и повторите:  git checkout main"
  exit 1
fi

# 1. Забираем всё: правки, новые файлы, удаления
git add -A

# 2. Если менять нечего — выходим молча
if git diff --cached --quiet; then
  echo "Ничего не изменилось. Ничего не коммичу."
  exit 0
fi

# 3. Показываем, что именно уедет на сайт
echo "В коммит войдёт:"
git diff --cached --name-status | sed 's/^/   /'
echo

# 4. Коммитим
MSG="${1:-Карта Эрмитажа: обновление $(date '+%d.%m.%Y %H:%M')}"
git commit -m "$MSG"

# 5. Пушим; в первый раз заодно привязываем ветку к origin
echo
if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
  git push
else
  git push -u origin "$BRANCH"
fi

echo
echo "Готово. Через минуту обновится:"
echo "   $PAGES_URL"
echo
echo "Подсказка: если страница показывает старую версию — обнови её"
echo "с очисткой кэша или открой в режиме инкогнито."
