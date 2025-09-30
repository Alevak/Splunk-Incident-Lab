Ось готовий Markdown-файл який можна зберегти як instructions/06_check_forwarder_and_simulate_bruteforce.md в репозиторії. Скопіюй весь вміст та збережи файл.

⸻


# ✅ Перевірка логів від Forwarder & Симуляція SSH brute-force

Цей документ показує як:
- перевірити, що Splunk Universal Forwarder (UF) читає і форвардить логи,
- діагностувати типові проблеми та способи їх вирішення,
- симулювати SSH brute-force на `test-linux` і перевірити події в Splunk,
- написати SPL для виявлення та створити Alert.

> Передумови: стенд піднятий через `docker compose up -d` і в `docker-compose.yml` сервіс `test-linux` має UF, rsyslog і sshd.

---

## 1) Швидка перевірка — чи є логи у контейнері (локально)

1. Зайдіть у контейнер `test-linux`:
```bash
docker exec -it test-linux /bin/bash

	2.	Перевірте наявність системних логів:

# auth.log (SSH-related)
ls -l /var/log/auth.log
tail -n 100 /var/log/auth.log

# syslog (якщо використовується)
ls -l /var/log/syslog
tail -n 100 /var/log/syslog

	3.	Якщо /var/log/auth.log відсутній — впевніться, що в образі встановлено rsyslog та що він запущений:

# всередині контейнера
ps aux | grep rsyslog
# або
pgrep -a rsyslogd

# запустити rsyslog (якщо потрібно)
service rsyslog start
# або
/usr/sbin/rsyslogd -n &


⸻

2) Перевірка налаштувань Universal Forwarder (в контейнері)

У контейнері test-linux перевірте UF:

# Список monitored paths
/opt/splunkforwarder/bin/splunk list monitor

# Перевірити configured forward servers
/opt/splunkforwarder/bin/splunk list forward-server

# Переглянути останні лог-рядки UF
tail -n 200 /opt/splunkforwarder/var/log/splunk/splunkd.log

Очікувані результати
	•	list monitor має показати /var/log/auth.log та/або /var/log/syslog.
	•	list forward-server має містити splunk:9997 або інший приймач з active forwards.
	•	У splunkd.log немає критичних помилок підключення (connection refused, DNS failure тощо).

⸻

3) Перевірка на стороні Splunk (indexer)
	1.	Відкрийте Splunk Web: http://localhost:8000 (admin / changeme123).
	2.	Переконайтеся, що порт для forwarder-ів увімкнений:
Settings → Forwarding and receiving → Receive data — має бути порт 9997 (Enabled).
	3.	Швидкий пошук в UI (Search & Reporting) — показати останні події з UF:

index=_internal sourcetype=splunkd component=TcpOutputProc OR component=TcpInputProc | tail 20

або просто знайти свіжі події з тестової машини:

index=main host=test-linux | sort -_time | head 20

Якщо бачите події — UF працює. Якщо ні — див. розділ «Траблшутинг».

⸻

4) Типові проблеми та як їх діагностувати/виправити

Проблема A — /var/log/auth.log порожній або відсутній

Можливі причини: rsyslog не встановлений/не запущений; sshd логує в інше місце; syslog-конфіг відрізняється у дистрибутиву.
Виправлення:
	•	Встановіть/запустіть rsyslog:

apt-get update && apt-get install -y rsyslog
service rsyslog start


	•	Перевірте sshd_config (параметри PasswordAuthentication, SyslogFacility) і що sshd логінить у auth facility.
	•	Тест: logger -p auth.info "test auth log" і перегляньте /var/log/auth.log.

Проблема B — UF не моніторить файл

Можливі причини: monitor не додано або конфіг зник після рестарту.
Виправлення:

/opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index main -sourcetype linux_auth -auth admin:changeme123
/opt/splunkforwarder/bin/splunk restart

Перевірте list monitor.

Проблема C — UF не підключається до Splunk (forward-server inactive)

Перевірки:
	•	З контейнера test-linux:

ping -c 1 splunk
nc -vz splunk 9997   # або curl на HEC порт, якщо HEC використовується


	•	Перегляньте /opt/splunkforwarder/var/log/splunk/splunkd.log на помилки (connection refused, DNS failure).

Проблема D — події приходять, але не видно в Search

Можливі причини: невірний index, неправильний time range, некоректний sourcetype.
Дії:
	•	Виконайте index=* | head 20 або index=main | head 20 щоб знайти останні події.
	•	Перевірте _time у подіях (можливо timestamp некоректний).

⸻

5) Симуляція SSH brute-force (генерація подій)

Для тестування ми робимо невдалі спроби входу до test-linux. Переконайтесь, що порт контейнера змеплений на хост (наприклад 2222:22 в docker-compose.yml).

Вручну

ssh -p 2222 root@localhost
# Вводьте неправильний пароль кілька разів

Автоматично (рекомендується для демонстрації)
	1.	Встановіть sshpass на ваш хост:

	•	macOS (brew):

brew install hudochenkov/sshpass/sshpass

	•	Ubuntu:

sudo apt install sshpass -y

	2.	Скрипт bruteforce.sh (запуск на хості):

#!/bin/bash
TARGET_PORT=2222
TARGET_HOST=localhost
TRIES=10
for i in $(seq 1 $TRIES); do
  sshpass -p wrongpass ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no -p $TARGET_PORT root@$TARGET_HOST true || true
  sleep 0.3
done

Запуск:

bash bruteforce.sh

Перевірка появи рядків у контейнері

docker exec -it test-linux tail -n 200 /var/log/auth.log

Шукайте рядки типу:

Failed password for root from 172.17.0.1 port 22 ssh2
Invalid user ...


⸻

6) SPL для виявлення brute-force (приклад)

Простий пошук (усі Failed):

index=main sourcetype=linux_auth ("Failed password" OR "Invalid user" OR "authentication failure")
| sort - _time

Агрегація по IP за 5 хв (threshold >=5):

index=main sourcetype=linux_auth ("Failed password" OR "Invalid user" OR "authentication failure")
| rex field=_raw "(?i)Failed password for (?:invalid user )?(?<user>\S+) from (?<src>\d{1,3}(?:\.\d{1,3}){3})"
| bin _time span=5m
| stats count AS failed_attempts values(user) AS users by src, host, _time
| where failed_attempts >= 5
| sort - failed_attempts

Пояснення:
	•	rex витягує user та src (IP) з _raw.
	•	bin _time агрегує події по вікну часу.
	•	where failed_attempts >= 5 — поріг (підлаштовується під середовище).

⸻

7) Створення Alert (коротко)
	1.	У Search вставте потрібний SPL і виконайте (щоб переконатись, що запит повертає очікувані рядки).
	2.	Натисніть Save As → Alert.
	3.	Налаштування:
	•	Name: SSH brute-force (>=5/5m)
	•	Schedule: Run every 5 minutes
	•	Condition: If number of results > 0
	•	Throttle: 10 minutes per src (щоб уникнути спаму)
	•	Action: Triggered Alerts (лог/опціонально email/webhook)
	4.	Save і перевірте Activity → Triggered Alerts після симуляції.

⸻

8) Додаткова діагностика (коли нічого не приходить)
	•	Переконайтеся, що UF читає потрібний файл (/opt/splunkforwarder/bin/splunk list monitor).
	•	Перевірте права доступу до файлу логів (UF запускається як root в контейнері за замовчуванням).
	•	Переконайтеся, що forward-server активний (splunk list forward-server).
	•	Перевірте індекс у Splunk (можна пробіжитись index=* | head 50).
	•	Перевірте UF лог: /opt/splunkforwarder/var/log/splunk/splunkd.log.
	•	Перевірте indexer лог: index=_internal пошук або Settings → Server controls → View splunkd logs.

⸻

9) Корисні команди (зведено)

# Локально: які контейнери запущені
docker compose ps

# Логи тестового контейнера
docker compose logs -f test-linux

# Зайти в контейнер
docker exec -it test-linux /bin/bash

# В контейнері: перевірка monitor
