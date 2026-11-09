#!/bin/bash
# Генерация access.log и анализ логов
set -euo pipefail

LOG_FILE="access.log"
LINES=300

generate_log() {
  local ips=("192.168.1.10" "192.168.1.11" "192.168.1.12" "10.0.0.5" "10.0.0.8" "172.16.0.3")
  local methods=("GET" "POST" "PUT" "DELETE")
  local paths=("/api/users" "/api/orders" "/api/products" "/login" "/health" "/api/items")
  local codes=(200 200 200 201 301 400 401 403 404 404 500 502 503)

  : > "$LOG_FILE"
  for ((i = 1; i <= LINES; i++)); do
    local ip="${ips[RANDOM % ${#ips[@]}]}"
    local method="${methods[RANDOM % ${#methods[@]}]}"
    local path="${paths[RANDOM % ${#paths[@]}]}"
    local code="${codes[RANDOM % ${#codes[@]}]}"
    local sec=$((RANDOM % 60))
    printf '%s - - [15/Aug/2026:10:15:%02d] "%s %s HTTP/1.1" %s\n' \
      "$ip" "$sec" "$method" "$path" "$code" >> "$LOG_FILE"
  done
}

analyze_log() {
  echo "=== Анализ $LOG_FILE ==="
  echo "Всего запросов: $(wc -l < "$LOG_FILE")"
  echo "Топ-3 IP:"
  grep -oE '^([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -3
  echo "Ошибок 4xx: $(awk '$NF ~ /^4[0-9][0-9]$/' "$LOG_FILE" | wc -l)"
  echo "Ошибок 5xx: $(awk '$NF ~ /^5[0-9][0-9]$/' "$LOG_FILE" | wc -l)"
}

generate_log
analyze_log
