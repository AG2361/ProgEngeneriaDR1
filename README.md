# Мониторинг инфраструктуры

Учебный проект: скрипты проверки API и анализа логов, Docker Compose с nginx-прокси, CI на GitHub Actions и анализ HTTP-трафика в Wireshark.

## Структура репозитория

```
.
├── .github/workflows/ci.yml   # CI: проверка скриптов и compose-файла
├── nginx/default.conf         # конфигурация nginx-прокси
├── docs/capture.pcapng        # дамп трафика Wireshark
├── check_api.sh               # проверка доступности API
├── analyze_logs.sh            # генерация и анализ access.log
├── docker-compose.yml         # сервисы api и proxy
├── .gitignore
└── README.md
```

## Запуск

### Скрипты

```bash
chmod +x check_api.sh analyze_logs.sh

./check_api.sh https://httpbin.org/status/200; echo "exit: $?"
./check_api.sh https://httpbin.org/status/500; echo "exit: $?"

./analyze_logs.sh
```

`check_api.sh` принимает один аргумент (URL) и возвращает код 0, если API ответил 200, иначе 1.
`analyze_logs.sh` генерирует `access.log` (300 строк) и выводит число запросов, топ-3 IP, количество ошибок 4xx и 5xx.

### Docker Compose

```bash
docker compose config
docker compose up -d
docker compose ps
curl http://localhost:80   # Monitoring Service Active
docker compose down
```

Сервис `api` наружу не открыт, доступ только через прокси `proxy` по внутренней сети `monitoring-net`.

## Деплой на удалённый сервер

```bash
# 1. Генерация ключа
ssh-keygen -t ed25519 -C "devops@startup"

# 2. Копирование публичного ключа на сервер
ssh-copy-id user@server_ip

# 3. Передача проекта
tar czf project.tar.gz --exclude='.git' --exclude='*.log' .
scp project.tar.gz user@server_ip:/opt/monitoring/
# или без промежуточного файла:
tar czf - . | ssh user@server_ip "mkdir -p /opt/monitoring && tar xzf - -C /opt/monitoring"

# 4. Запуск на сервере
ssh user@server_ip "cd /opt/monitoring && docker compose up -d"
```

## Безопасность

- Отключить парольный вход по SSH: в `/etc/ssh/sshd_config` указать `PasswordAuthentication no` и перезапустить `sshd`.
- Не работать под root: использовать обычного пользователя с правами на docker.
- Приватный ключ (`id_ed25519`) нигде не публиковать, на сервер копируется только публичный (`.pub`).
- Наружу открывать только необходимые порты (здесь только 80).
