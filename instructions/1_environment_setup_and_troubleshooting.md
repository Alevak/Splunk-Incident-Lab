
# 🧪 Splunk Lab Environment Setup Guide

Цей документ описує процес підготовки середовища для виконання лабораторної роботи зі Splunk.

---

## 🎯 Мета лабораторної роботи

Навчитись налаштовувати середовище для збору та аналізу логів із Linux-систем у Splunk, використовуючи Docker, Universal Forwarder та власні SPL-запити.

---

## 🛠️ Інструменти, що використовуються

| Інструмент | Призначення |
|-----------|-------------|
| **Docker** | Контейнеризація компонентів |
| **Docker Compose** | Оркестрація запуску контейнерів |
| **Splunk Enterprise** | Збір, аналіз логів, візуалізація |
| **Splunk Universal Forwarder** | Передача логів із Linux до Splunk |
| **Linux container** | Генерація логів для аналізу |
| **SPL (Search Processing Language)** | Запити для виявлення інцидентів |

---

## 📁 Структура репозиторію

```
splunk-incident-lab/
├── docker-compose.yml         # Сервіси: Splunk, Linux, UF
├── linux-uf/
│   ├── Dockerfile             # Linux + Splunk UF
│   └── entrypoint.sh          # Налаштування логів і паролів
├── splunk-lab/
│   ├── usecases/              # SPL-запити
│   └── logs/                  # JSON з подіями
└── README.md                  # Інструкції
```

---

## 🧭 Основні кроки роботи

1. Клонувати репозиторій або завантажити `.zip`
2. Підняти середовище: `docker compose up`
3. Переконатись, що логін у Splunk працює (`localhost:8000`)
4. Перевірити наявність логів із Universal Forwarder
5. Виконати SPL-запити зі сценаріями з `usecases/`
6. Згенерувати PDF-звіт зі скріншотами результатів

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

---

# 🛠️ Common Troubleshooting Guide

Цей розділ містить типові проблеми та їх вирішення.

## Docker не встановлено або не запускається
**Рішення:** перевірити встановлення та активність `docker info`

## `docker-compose` не знайдено
**Рішення:** використовуйте `docker compose` без дефіса

## Порт 8000 вже зайнятий
**Рішення:** змінити порт у `docker-compose.yml`

## Splunk UI не відкривається
**Рішення:** почекати кілька хвилин після запуску. Перевірити `docker compose logs splunk`

## Пароль Splunk невідомий
**Рішення:** перевір `SPLUNK_PASSWORD` у `docker-compose.yml`

## Universal Forwarder не передає логи
**Рішення:**
- перевірити правильність `forward-server` в `entrypoint.sh`
- перевірити наявність `inputs.conf` або команд `add monitor`
- перевірити `splunkd.log`

## Очистити середовище
```bash
docker compose down -v
```

---

📌 **Після завершення лабораторної:**

🔖 Студент має надати **PDF-звіт**, що містить:
- Скріни запущеного Splunk UI
- Скріни пошуку подій у Splunk
- Скріни логів із Linux Forwarder
- Коментарі до виявлених подій
