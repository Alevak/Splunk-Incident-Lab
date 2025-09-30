
# 🧪 Splunk Lab Environment Setup Guide

Цей документ описує процес підготовки середовища для виконання лабораторної роботи зі Splunk.


## 🧭 Основні кроки роботи підготовки середовища

1. Клонувати репозиторій або завантажити `.zip`
2. Підняти середовище: `docker compose up`
3. Переконатись, що логін у Splunk працює (`localhost:8000`)

---

## 🐧 Налаштування для ОС

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

