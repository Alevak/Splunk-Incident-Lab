🧪 Splunk Lab Environment Setup Guide

Цей документ описує процес підготовки середовища для виконання практичної роботи зі Splunk.

 🧭 Основні кроки роботи підготовки середовища
1. Встановлення docker
2. Встановлення Cursor IDE
3. Створення облікового запису на github якщо нема (без інструкції)
⸻
Інструкція встановлення doccker desktop:

🐧 Windows (рекомендовано: Windows 10/11)
	1.	Завантажити Docker Desktop з офіційного сайту (або через winget).
	2.	Увімкнути WSL2 (рекомендовано) або Hyper-V:
	•	Відкрий PowerShell як Administrator і виконай:
wsl --install
wsl --set-default-version 2

Якщо wsl --install не працює — увімкни компонент Windows:
Turn Windows features on or off → поставити Virtual Machine Platform і Windows Subsystem for Linux, перезавантажити.

	•	Можливо потрібно встановити Linux kernel update package (Windows запропонує посилання).
	3.	Встановити Docker Desktop і в налаштуваннях обрати WSL2 backend (Settings → General → Use the WSL 2 based engine).
	4.	Запуск терміналу: використовуйте Windows Terminal або WSL shell (Ubuntu) — запуск від імені Administrator тільки при потребі.
	5.	Перевірка:

docker --version
docker compose version
docker run --rm hello-world

	6.	Типові проблеми/рішення:
	•	Якщо Docker не стартує — перезавантаж Windows або перезапустіть Docker Desktop.
	•	Якщо з’являються права доступу до файлів у WSL — працюйте з файлами в WSL fs (/home), а не у C:\ зі сторони WSL.

⸻

🍏 macOS (Intel / Apple Silicon)
	1.	Завантажити Docker Desktop for Mac (встановник .dmg) або brew install --cask docker.
	2.	Запустити Docker Desktop (іконка в меню).
	•	Для Apple Silicon (M1/M2) переконайтеся, що образи контейнерів підтримують arm, або в docker-compose.yml додайте platform: linux/amd64 для специфічних сервісів (але не всі x86 образи працюватимуть під емуляцією).
	3.	Перевірка:

docker --version
docker compose version
docker run --rm hello-world


	4.	Типові проблеми:
	•	Якщо образ не доступний для arm — помилка no matching manifest for linux/arm64 → вказати platform: linux/amd64 або використати інший образ.
	•	Якщо Docker не стартує — переконайтеся, що у Security & Privacy дозволено запуск (якщо повідомляв Gatekeeper).

⸻

🟢 Linux (Ubuntu / Debian)
	1.	Встановлення Docker (офіційний спосіб рекомендовано):

sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# вийдіть та зайдіть назад (або newgrp docker)
newgrp docker

(Краще встановлювати офіційні пакети з репозиторію Docker для останньої версії — але для лабораторії docker.io часто достатньо.)

	2.	Перевірка:

docker --version
docker compose version
docker run --rm hello-world


	3.	Типові проблеми:
	•	permission denied — додайте користувача в групу docker і перезайдіть.
	•	Якщо docker не стартує — sudo systemctl status docker і journalctl -u docker --no-pager -n 200.

⸻

🔁 Загальні перевірки після інсталяції (всі ОС)

docker --version
docker compose version
docker run --rm hello-world

⸻

🛠️ Короткий розділ Troubleshooting (швидко)
	•	Docker daemon не піднімається → перезапустіть Docker Desktop або sudo systemctl restart docker.
	•	Права/permission denied → додати користувача в групу docker і перезайти.
	•	Проблеми з WSL2 → оновити Linux kernel package і встановити WSL2 як default.
⸻

💻 Встановлення Cursor IDE 

Cursor може допомогти студентам працювати з кодом, докером та репозиторієм.

Установка Cursor
	•	Офіційний сайт Cursor
	•	Доступний для:
	•	Windows (Installer .exe)
	•	macOS (DMG або brew)
	•	Linux (AppImage або deb)
Налаштування для роботи з цим репозиторієм
	1.	Відкрити папку з репозиторієм у Cursor:
File → Open Folder → splunk-incident-lab

⸻
Встановлення Cursor (деталізовано)
🔧 Передумови (всі ОС)
	•	Має бути встановлений Docker Desktop (Windows/macOS) або Docker Engine + Compose (Linux).
	•	Має бути Git (в терміналі git --version має повертати версію).
	•	Якщо плануєш підключатися до GitHub по SSH — налаштований SSH-ключ у ~/.ssh і доданий у GitHub.

⸻

Windows (рекомендовано: Windows 10/11 + WSL2)

1) Завантажити та інсталювати Cursor
	1.	Відкрий сторінку завантаження Cursor (з офіційного джерела).
	2.	Завантаж Windows-інсталятор (.exe) і запусти його.
	3.	Дотримуйся інструкцій інсталятора (Next → Accept → Install).

Якщо у інсталятора є опції «Add to PATH» або «Install command line helpers» — увімкни.

2) Перше відкриття
	•	Запусти Cursor через меню Пуск.
	•	При першому запуску можуть попросити створити обліковий запис / увійти — зроби це (або skip якщо дозволяє).

3) Налаштування Git (якщо потрібно)
	•	Відкрий вбудований термінал (Terminal → New Terminal).
	•	Перевір git:

git --version


	•	Якщо не встановлено — постав Git for Windows (https://git-scm.com/download/win) і перезапусти Cursor.


5) Клонування репозиторію
	•	В терміналі:

git clone https://github.com/Alevak/Splunk-Incident-Lab
cd splunk-incident-lab

	•	Або через вбудований Git GUI (Source Control).




7) Проблеми / поради (Windows)
	•	Якщо Docker в WSL2, переконайся, що Cursor використовує правильний PATH і що термінал у Cursor має доступ до WSL.
	•	Якщо виникають права доступу до Docker socket — запусти Docker Desktop як Admin.
	•	Якщо Git по SSH питає пароль/фразу — запусти ssh-agent і додай ключ:

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519



⸻

macOS (Intel / Apple Silicon)

1) Встановити Cursor
	•	Завантаж .dmg або встанови через Homebrew (якщо Cursor має cask):

brew install --cask cursor

	•	Відкрий Cursor з Applications.

2) Налаштувати дозволи (Apple Silicon)
	•	Якщо з’являються попередження про те, що додаток від невідомого розробника — дозволи в System Preferences → Security & Privacy → Allow.


5) Клонування репо та запуск
	•	Відкрий термінал у Cursor:

Через інтерфейс при запуску Cursor AI вкажи посилання на репозиторій https://github.com/Alevak/Splunk-Incident-Lab

або через термінал (опційно)
git clone (https://github.com/Alevak/Splunk-Incident-Lab)
cd splunk-incident-lab


Linux (Ubuntu/Debian, Fedora та ін.)

1) Встановлення Cursor
	•	Cursor може постачатися як AppImage / deb / rpm. Для Ubuntu зазвичай:

# приклад (залежить від дистрибутиву і джерела)
wget https://cursor.sh/downloads/cursor-linux.AppImage
chmod +x cursor-linux.AppImage
./cursor-linux.AppImage


	•	Або встанови .deb:

sudo apt install ./cursor-x.y.z.deb


2) Права запуску
	•	Переконайся, що ти маєш права на запуск (chmod +x для AppImage) і що в системі встановлені залежності (glib, libfuse, тощо).

3) Git та SSH
	•	Git:

sudo apt update
sudo apt install git -y
git --version


4) Клонування репо і запуск
	•	Відкрий Cursor → Terminal:

git clone git@github.com:YourUser/splunk-incident-lab.git
cd splunk-incident-lab






