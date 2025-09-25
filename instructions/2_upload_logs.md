
📂 Інструкція – Завантаження логів до Splunk

📌 Кроки завантаження
	1.	Увійди до Splunk:
Відкрий браузер і перейдіть за посиланням: http://localhost:8000
Логін: admin, Пароль: changeme123
	2.	У верхньому меню:
Перейди до Settings → Add Data
	3.	Обери варіант завантаження:
	•	Тип: Upload
	•	Натисни Select File і обери один із логів з папки log_samples

⸻

🖥️ Windows Sysmon логи

Приклади:
	•	sysmon_powershell_base64.json
	•	sysmon_bruteforce.json

Налаштування при імпорті:
	•	Source type: json
	•	Sourcetype: sysmon
	•	Index: main або створити windows_logs
	•	Host: (залиши за замовчуванням)

✅ Пояснення: Sysmon — компонент Sysinternals Suite, який логує детальні події в Windows. У прикладах моделюється запуск PowerShell з Base64-командою (ознака атаки), та brute-force атаки.

⸻

🐧 Linux логи

Приклади:
	•	linux_tmp_exec.json
	•	linux_sudo_nopasswd.json
	

Налаштування при імпорті:
	•	Source type: json
	•	Sourcetype: linux
	•	Index: main або створити linux_logs
	•	Host: (залиш за замовчування)

✅ Пояснення:
	•	tmp_exec — виконання скриптів із тимчасових директорій (/tmp)
	•	sudo_nopasswd — використання sudo без пароля (потенційно небезпечно)
	

⸻

🌐 Мережеві події

Приклади:
	•	network_dns_duckdns.json


Налаштування при імпорті:
	•	Source type: json
	•	Sourcetype: network
	•	Index: main або створити network_logs
	•	Host: (наприклад gateway01)

✅ Пояснення:
	•	dns_duckdns — запити до динамічних DNS-сервісів (використовуються в бекдорах)
	•	web_access_logs — HTTP-запити, в яких можна шукати сканування, спроби SQLi/XSS

⸻

🔄 Завершення імпорту

Після того як вкажеш параметри:
	1.	Натисни Next
	2.	Потім Review
	3.	Нарешті Submit

⏳ Зачекай кілька секунд — логи з’являться у пошуку.

⸻

🔍 Для тестування запитів — переходь у Search & Reporting, і використовуй відповідний .spl з папки spl_queries.

