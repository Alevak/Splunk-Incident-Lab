#!/bin/bash

SPLUNK_HOME=/opt/splunkforwarder
SPLUNK_BIN=$SPLUNK_HOME/bin/splunk

# Запускаємо Splunk UF з прийняттям ліцензії
$SPLUNK_BIN start --accept-license --answer-yes --no-prompt

# Додаємо forward-сервер (замінити на IP/hostname хосту Splunk)
$SPLUNK_BIN add forward-server splunk:9997

# Додаємо моніторинг логів у тестовій машині
$SPLUNK_BIN add monitor /var/log/syslog
$SPLUNK_BIN add monitor /var/log/auth.log

# Виводимо статус підключення
$SPLUNK_BIN list forward-server

# Залишаємо bash активним
exec /bin/bash
