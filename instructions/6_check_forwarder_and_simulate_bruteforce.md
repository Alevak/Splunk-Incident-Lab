
Переконайтеся, що Universal Forwarder читає логи з тестової машинки, згенеруйте серію невдалих SSH-логінів (brute-force sample), перевірити, що події індексуються в Splunk, і створити Report де будуть події


1 — Заходимо в контейнер і перевіряємо UF

1.1. Перевірити списки моніторів UF (чи є folder/file який ми хочемо моніторити)

docker exec -it test-linux /bin/bash -c '/opt/splunkforwarder/bin/splunk list monitor -auth admin:changeme123 || true'

У виводі має бути /var/log/syslog 

1.2. Перевірити forward-server (UF -> Splunk)

docker exec -it test-linux /bin/bash -c '/opt/splunkforwarder/bin/splunk list forward-server -auth admin:changeme123 || true'

Потрібно бачити splunk:9997 і бажано Active (або Configured).


2 — Генерація brute-force подій (два варіанти) — реальні SSH підключення (ручні помилкові логіни)

З хоста робимо кілька невдалих ssh (якщо порт прокинуто)

Наприклад, якщо в docker-compose.yml прокинутий порт 2222 → test-linux:

# з хоста (повторити кілька разів, вводити неправильний пароль)
ssh -p 2222 root@localhost

Примітка: команда буде питати пароль — вводь неправильний більше трьох раз

⸻

3 — Перевірка у Splunk: чи взагалі є події

Відкрий Splunk UI: http://localhost:8000 → Search & Reporting

3.1. Базова перевірка — всі останні події

В полі пошуку:

index=* | head 50

Якщо бачиш події — forwarder працює.

3.2. Перевірити syslog / sshd події

index=main sourcetype=syslog sshd
| sort -_time
| head 50


⸻

4 — Специфічний пошук brute-force (SPL)

Простіший — виявити >=3 failed за 15 хв

index=main sourcetype=syslog "Failed password"
| rex "from (?<src_ip>\d{1,3}(?:\.\d{1,3}){3})"
| bin _time span=15m
| stats count AS failed_attempts by src_ip, host, _time
| where failed_attempts >= 3
| sort - failed_attempts

Детальніший — username, останній час

index=main sourcetype=syslog ("Failed password" OR "authentication failure")
| rex "from (?<src_ip>\d{1,3}(?:\.\d{1,3}){3})"
| rex "for (invalid user )?(?<username>\S+)"
| bin _time span=15m
| stats count AS failed_attempts values(username) as users latest(_time) as last_time by src_ip, host
| where failed_attempts >= 3
| eval last_time=strftime(last_time,"%Y-%m-%d %H:%M:%S")
| sort - failed_attempts

Виконай ці запити в Search — перевір, що вони повертають рядки з src_ip та failed_attempts.

Збережіть Search як Report (Save As → Report) це можна додати у Звіт по виконанні практичної роботи

Також налаштуйте Alert (Сам Alert не буде працювати у безплатній версії)

	1.	Натисніть Save As → Alert
	2.	Вкажіть:
	•	Title: Brute force detection
	•	Description: Detect multiple failed SSH login attempts
	•	Permissions: Shared in App
	•	Alert type: ✅ Scheduled (не Real-time)
	•	Schedule: Run every 1 minute
	•	Time range: Last 1 minute
	•	Trigger alert when: Number of Results > 0
	3.	(Опціонально) Додайте email-сповіщення:
	•	Тип дії: Send Email
	•	Укажіть адресу (наприклад, test@example.com)
	•	Увімкніть Include search results
