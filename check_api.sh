#!/bin/bash
# Проверка доступности API по URL

if [ $# -ne 1 ]; then
  echo "Использование: $0 <URL>"
  exit 1
fi

URL="$1"
CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL")

if [ "$CODE" -eq 200 ]; then
  echo "API доступен"
  exit 0
else
  echo "API недоступен, код ответа: $CODE"
  exit 1
fi
