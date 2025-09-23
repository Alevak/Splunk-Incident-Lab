#!/bin/bash

SPLUNK_HOME=/opt/splunkforwarder
SPLUNK_BIN=$SPLUNK_HOME/bin/splunk
SPLUNK_USER=admin
SPLUNK_PASS=changeme123

# Якщо ще не створено користувача — додаємо пароль
if [ ! -f "$SPLUNK_HOME/etc/passwd" ]; then
    echo "[i] First-time setup: using seed-passwd..."
    $SPLUNK_BIN start --accept-license --answer-yes --no-prompt --seed-passwd "$SPLUNK_PASS"
    $SPLUNK_BIN stop
fi

# Старт Splunk UF
$SPLUNK_BIN start --accept-license --answer-yes --no-prompt

# Логін за дефолтними кредами
$SPLUNK_BIN login -auth "$SPLUNK_USER:$SPLUNK_PASS"

# Додаємо forward-сервер (заміни hostname при потребі)
$SPLUNK_BIN add forward-server splunk:9997 -auth "$SPLUNK_USER:$SPLUNK_PASS"

# Додаємо моніторинг системних логів
$SPLUNK_BIN add monitor /var/log/syslog -auth "$SPLUNK_USER:$SPLUNK_PASS"
$SPLUNK_BIN add monitor /var/log/auth.log -auth "$SPLUNK_USER:$SPLUNK_PASS"

# Показуємо статус
$SPLUNK_BIN list forward-server -auth "$SPLUNK_USER:$SPLUNK_PASS"

# Запускаємо Bash-сесію
exec /bin/bash
