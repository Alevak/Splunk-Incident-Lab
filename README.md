🧪 Лабораторна робота: Виявлення інцидентів безпеки у Splunk

 🎯 Мета
Навчитися:
- Розгортати SIEM-систему Splunk у Docker-контейнері
- Завантажувати приклади логів у Splunk
- Виконувати базовий аналіз журналів подій
- Шукати підозрілу активність (наприклад, використання PowerShell для атак та інші)
- Створювати алерти на основі виявлених шаблонів
- Перевіряти спрацювання алертів на основі нових подій
- Забезпечувати сталий потік логів із іншої машини (тестовий Linux)

---

📘 Методичка для студентів

Ця лабораторна робота розрахована на студентів, які **не мають попереднього досвіду з Docker, Git або Splunk**. Усі команди та інструкції супроводжуються поясненнями.

---

🧱 Частина 1. Налаштування середовища

🔧 Встановлення необхідних інструментів
 1. 💻 Встановлення Cursor IDE

Cursor — це інтелектуальна IDE і чат асистент, який допоможе зрозуміти код, формувати запити до терміналу, тощо.

1.1. Windows:

1.1.1. Завантажи за посиланням: [https://www.cursor.so/](https://www.cursor.so/)
1.1.2. Вибери Windows Installer (.exe) та встанови

1.2. macOS:

1.2.1. Завантажи .dmg з офіційного сайту
1.2.2. Відкрий .dmg та перетягни Cursor в Application

1.3. Linux (Ubuntu):

```bash
wget https://github.com/getcursor/cursor/releases/latest/download/cursor.deb
sudo dpkg -i cursor.deb
```

Після цього запусти Cursor як повноцінну IDE з чатом, що розуміє термінал і скрипти.


2. Встановлення решти інструментів:
2.1. 🪟 Windows:
2.1.1 Встанови **Docker Desktop**: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
   - Під час встановлення увімкни підтримку WSL2 (Windows Subsystem for Linux)
   - Перезавантаж комп’ютер після встановлення

2.1.2 Встанови **Git for Windows**: [https://git-scm.com/download/win](https://git-scm.com/download/win)


2.2. 🍎 macOS:
2.2.1. Встанови **Docker Desktop for Mac**: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
   - Потрібно мати macOS 11+ і чип M1/M2 або Intel

2.2.2. Встанови **Git** через Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git
```

2.3.🐧 Linux (Ubuntu/Debian):
```bash
sudo apt update && sudo apt install -y docker.io git
sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker $USER
```
Після цього перезавантаж систему або вийди й зайди знову, щоб застосувались зміни.

---

📦 Частина 2. Клонування лабораторної

```bash
git clone https://github.com/AleVak/splunk-incident-lab.git
cd splunk-incident-lab
```

*Якщо у вас немає GitHub-акаунта — просто завантажте `.zip` з GitHub та розпакуйте.*

---

🐳 Частина 3. Запуск Splunk у Docker

```bash
docker-compose up -d
```

⏳ Зачекай 1–2 хвилини, поки Splunk повністю запуститься.

Потім відкрий браузер і перейдіть за посиланням: [http://localhost:8000](http://localhost:8000)

- Ім’я користувача: `admin`
- Пароль: `changeme`

> Якщо не відкривається — перевір, чи Docker працює, і повтори `docker-compose up -d`

---

📂 Частина 4. Завантаження логів та ознаймлення з use cases

Як завантажити однроразово логи - instructions/02_upload_logs.md
Ознаймлення з use cases - instructions/2_use_cases.md

---

🔎 Частина 5. Написання запиту SPL (Search Processing Language)

В Splunk зайди в `Search & Reporting` → створити новий пошук:

```spl
index=main sourcetype=sysmon Image=*powershell.exe* CommandLine="*-enc*"
```


🔍 Цей запит шукатиме всі події, де запускався PowerShell із закодованою командою (частий індикатор шкідливої активності).

!!! Решта spl запитів знаходиться тут - spl_queries/ !!!

✅ Можна переглянути деталі події, натиснувши на запис у результатах.

---

🚨 Частина 6. Створення алерту

1. У вікні пошуку натисни **Save As** → **Alert**
2. Введи назву: `Suspicious PowerShell Alert` решта алертів називаємо по імені атаки
3. Умова спрацювання: `If number of results > 0`
4. Час виконання: `Every 5 minutes`
5. Alert Type: **Scheduled Alert**
6. Action: можеш поки залишити без email — лише збереження у журналі
7. Натисни Save

Як налаштувати алертінг - instructions/04_alert_config.md
---

🧪 Частина 7. Тестування алерту

1. Імпортуй ще раз лог з подібною подією, або змінений лог, де є закодована команда
2. Зачекай 5 хвилин (або натисни "Run Alert Now")
3. Перевір, чи алерт з’явився в `Activity → Triggered Alerts`

---

📤 Частина 8. Звітність

🔖 Потрібно підготувати:
- `.spl` файл або текст пошукового запиту
- Скриншоти:
  - результату пошуку
  - налаштування алерту
  - моменту спрацювання (Triggered Alert)
- Звіт у форматі PDF 

---

💡 Поради
- Не забудь вимкнути Splunk після роботи:
```bash
docker-compose down
```
- Якщо Docker видає помилки — переконайся, що він працює, та перезапусти систему
- Якщо Splunk довго вантажиться — зачекай, це нормально для першого запуску

---

!!! Це опційно, не обов'язково виконувати

⚡️ Advanced: Налаштування сталого стрімінгу логів із тестової Linux-машини

1. Скопіюй та позапускай `Dockerfile.uf-test` (для створення контейнера Linux з Splunk Universal Forwarder):

```bash
docker build -f Dockerfile.uf-test -t uf-linux .
docker run -it uf-linux
```

2. Увесь злив відбувається через HEC (HTTP Event Collector) або завдяки Universal Forwarder
3. Упевнись, що токен HEC вставлено в скрипт або вконфігуровано forwarder на порт 9997

> Це дозволить використовувати Splunk як реальну SIEM систему, що збирає логи з інших хостів.


