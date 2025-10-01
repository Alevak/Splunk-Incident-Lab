
⚡ Quick Start у Cursor: запуск Splunk

Цей гайд описує, як у Cursor AI запустити Docker Compose, перевірити роботу контейнерів і зайти в Splunk.

⸻

🐳 Крок 1. Запуск Docker Compose

У терміналі всередині Cursor:

docker compose up -d

	•	-d запускає контейнери у фоновому режимі.
	•	У проєкті піднімуться:
	•	splunk (інтерфейс SIEM на http://localhost:8000)
	•	test-linux (тестова Linux-машина з форвардером логів)

⸻

🔎 Крок 2. Перевірити, чи контейнери запущені

docker ps

Приклад результату:

CONTAINER ID   IMAGE                COMMAND                  STATUS         NAMES
abcd1234       splunk/splunk:9.1    "/sbin/entrypoint.sh"   Up 2 minutes   splunk
efgh5678       uf-linux:test        "/entrypoint.sh"        Up 2 minutes   test-linux

	•	STATUS має бути Up
	•	NAMES відповідають splunk і test-linux

⸻

🌐 Крок 4. Вхід у Splunk
	1.	Відкрити браузер і перейти:
👉 http://localhost:8000
	2.	Залогінитися:
	•	Username: admin
	•	Password: changeme123


Хочеш, я зберу цей гайд у .md файл для завантаження, щоб ти одразу додав у репозиторій у папку instructions/?
