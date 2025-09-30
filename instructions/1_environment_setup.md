
# 🧪 Splunk Lab Environment Setup Guide

Цей документ описує процес підготовки середовища для виконання лабораторної роботи зі Splunk.


## 🧭 Основні кроки роботи підготовки середовища
1. Встановлення Cursor IDE
2. Встановлення docker
3. Створення облікового запису на github якщо нема

---

 🐧 Налаштування для ОС

### Windows
- Встановіть [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Активуйте WSL2 або Hyper-V
- Запускайте термінал у режимі **Administrator**

### macOS
- Встановіть Docker Desktop (через brew або dmg)
- Перевірка: `docker info`

### Linux (Ubuntu)
```bash
sudo apt update && sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER
newgrp docker
```
💻 Використання Cursor IDE 

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

4) SSH ключі (для GitHub по SSH)
	•	Якщо ще нема ключа:

ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub


	•	Скопіюй публічний ключ і додай у GitHub → Settings → SSH and GPG keys.

5) Клонування репозиторію
	•	В терміналі:

git clone git@github.com:YourUser/splunk-incident-lab.git
cd splunk-incident-lab


	•	Або через вбудований Git GUI (Source Control).

6) Запуск Docker Compose з Cursor
	•	Відкрий термінал у папці репо і запусти:

docker compose up -d --build


	•	Перевір:

docker compose ps



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

3) Git і SSH
	•	Перевір:

git --version
ssh -V


	•	Якщо потрібно генерувати ключ:

ssh-keygen -t ed25519 -C "your_email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub   # скопіює ключ у буфер macOS


	•	Додай ключ у GitHub.

4) Docker
	•	Встанови Docker Desktop for Mac (M1/M2 є специфічні версії). Запусти Docker Desktop перед Cursor.
	•	Перевір у Cursor terminal:

docker info



5) Клонування репо та запуск
	•	Відкрий термінал у Cursor:

git clone git@github.com:YourUser/splunk-incident-lab.git
cd splunk-incident-lab
docker compose up -d --build



6) Troubleshooting
	•	Якщо Docker для Apple Silicon показує помилки platform/manifest — в docker-compose.yml можна вказати platform: linux/amd64 для сервісів, які не мають arm образу (але деякі образи не працюватимуть на M1).
	•	Якщо SSH-агент не працює: на macOS можеш додати ключ у Keychain:

ssh-add --apple-use-keychain ~/.ssh/id_ed25519



⸻

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


	•	SSH ключ:

ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub


	•	Додай ключ на GitHub.

4) Docker
	•	Встановлення Docker + Compose (Ubuntu):

sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER
newgrp docker


	•	Перевір:

docker --version
docker compose version



5) Клонування репо і запуск
	•	Відкрий Cursor → Terminal:

git clone git@github.com:YourUser/splunk-incident-lab.git
cd splunk-incident-lab
docker compose up -d --build





