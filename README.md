🔍 Лабораторна робота: Виявлення підозрілої активності у Splunk

🎯 Мета
Навчитися виявляти потенційно шкідливу активність на основі логів, використовуючи засоби Splunk. Ознайомитися з основами SPL-запитів, створенням use-case-детекторів та налаштуванням лог-форвардингу зі сторонніх систем (Linux).

---


🛠️ Використані інструменти

| Інструмент               | Призначення                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| Splunk (в Docker)        | Аналіз логів, пошук загроз, виконання SPL-запитів, створення алертів та дашбордів |
| Universal Forwarder      | Форвардинг логів з Linux/Windows машин у Splunk (inputs.conf / outputs.conf), моніторинг файлів/путь |
| Тестові JSON-логи        | Набір згенерованих подій (валидні + аномальні) для тренування use-case’ів і тестування правил |
| Cursor (IDE / Assistant) | Інтерактивний помічник / IDE для розробки лабораторних, швидкого клонування репозиторію, запуску терміналу та тестування команд — допомагає студентам виконувати завдання й дебажити середовище |
---

🗂️ Структура репозиторію
Нижче — короткий огляд файлової структури репозиторію та призначення кожного каталогу/файлу. Це допоможе студентам швидко зорієнтуватися та знайти потрібні матеріали.

instructions/
├── 1_environment_setup_and_troubleshooting.md   # Гайд: підготовка середовища (Windows/macOS/Linux) + Troubleshooting
├── 2_upload_logs.md                              # Як завантажувати лог-файли в Splunk через UI (Upload)
├── 3_use_cases_eng.md                            # Опис use-case’ів англійською (SPL + логіка)
├── 3_use_cases_ua.md                             # Опис use-case’ів українською (SPL + логіка)
├── 4_alert_config.md                             # Інструкція: як зберегти пошук як Alert у Splunk
└── 5_universal_forwarder.md                      # Як налаштувати Splunk Universal Forwarder (без HEC)
log_samples/
├── linux_sudo_nopasswd.json                      # Приклад: зміни sudoers / NOPASSWD (Linux)
├── linux_tmp_exec.json                           # Приклад: виконання файлів із /tmp (Linux)
├── network_dns_duckdns.json                      # Приклад: DNS-запити до *.duckdns.org
├── sysmon_bruteforce.json                        # Приклад: Windows failed-logon (EventID 4625)
├── sysmon_powershell_base64.json                 # Приклад: PowerShell із base64 / обфускація
spl_queries/
├── linux_sudo_nopasswd.spl                       # SPL для виявлення sudo NOPASSWD
├── linux_tmp_exec.spl                            # SPL для виконання з /tmp
├── network_dns_duckdns.spl                       # SPL для DNS-запитів до duckdns
├── suspicious_powershell.spl                     # SPL для підозрілих PowerShell-команд
└── sysmon_bruteforce.spl                         # SPL для пошуку brute-force (EventID 4625)

Dockerfile.uf-test                                 # Dockerfile для тестового Linux з UF
docker-compose.yml                                 # Compose для підняття Splunk + тестового Linux
entrypoint.sh                                      # Шаблон entrypoint для UF-контейнера (старт rsyslog/sshd/UF)
README.md                                          # Головна інструкція (цей файл)

---
Основні кроки практичної роботи%
1.	🔧 Розгорнути Splunk за допомогою docker-compose.yml
2.	📤 Завантажити тестові логи з log_samples/ у Splunk або (альтернатива) запустити симуляцію — наприклад SSH brute-force проти test-linux (порт, наприклад 2222:22) з хоста або скриптом; після симуляції події повинні з’явитися в /var/log/auth.log у контейнері і бути підхоплені UF.
3.	🛰️ Universal Forwarder встановлюється та запускається автоматично у контейнері test-linux (перевірка і додаткові опції в instructions/5_universal_forwarder.md) — переконатися, що UF моніторить /var/log/auth.log і форвардить на splunk:9997.
4.	🔍 Виконати SPL-запити з папки spl_queries/ через Splunk Search (підставити index/sourcetype при потребі); для brute-force використовувати відповідний SPL (агрегація по часу + поріг).
5.	📑 Відкрити відповідні описи юз-кейсів у instructions/2_use_cases_ua.md або use_cases_eng.md і зіставити знайдені події з описами.
6.	📸 Зробити скриншоти для звіту (стан контейнерів, підтвердження UF моніторингу, рядки у /var/log/auth.log, результати пошуку в Splunk, спрацювання Alert).
---

📄 Вимоги до звіту (PDF)

Звіт повинен містити такі розділи:

1. Титульна сторінка
- Така як і в лабораторних

2. Скріншоти
- Виконання SPL-запитів у Splunk
- Виявлені події (event details) 
- Наявність логів з тестового лінукс хоста за допомогою Universal Forwarder на Splunk

3. Висновки
- Які кейси спрацювали
- Які труднощі виникли
- Що можна покращити


