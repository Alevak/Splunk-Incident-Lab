#!/bin/bash
set -e

SPLUNK_HOME=/opt/splunkforwarder
SPLUNK_BIN=$SPLUNK_HOME/bin/splunk
SPLUNK_USER=admin
SPLUNK_PASS=changeme123
SPLUNK_INDEX=main
SPLUNK_FORWARDER_TARGET=splunk:9997   # ім'я/хост Splunk у docker-compose

# -------------------------
# 0) Ensure runtime dirs
# -------------------------
mkdir -p /run/sshd /var/log

# -------------------------
# 1) Create SSH host keys if missing
# -------------------------
if command -v ssh-keygen >/dev/null 2>&1; then
  ssh-keygen -A 2>/dev/null || true
fi

# -------------------------
# 2) Start rsyslog (so /var/log/auth.log and /var/log/syslog are produced)
# -------------------------
if command -v rsyslogd >/dev/null 2>&1; then
  echo "[i] Starting rsyslog..."
  /usr/sbin/rsyslogd -n -i /var/run/rsyslogd.pid &>/dev/null &
else
  echo "[w] rsyslogd not found — syslog files will not be created."
fi

# -------------------------
# 3) Start sshd (no systemd)
# -------------------------
if command -v /usr/sbin/sshd >/dev/null 2>&1; then
  echo "[i] Starting sshd..."
  /usr/sbin/sshd -D &>/dev/null &
else
  echo "[w] sshd not found — cannot accept SSH connections."
fi

# small pause to let services initialize
sleep 1

# -------------------------
# 4) First-time UF seed (if not configured)
# -------------------------
if [ ! -f "$SPLUNK_HOME/etc/passwd" ]; then
    echo "[i] First-time UF setup: using seed-passwd..."
    $SPLUNK_BIN start --accept-license --answer-yes --no-prompt --seed-passwd "$SPLUNK_PASS"
    $SPLUNK_BIN stop
fi

# -------------------------
# 5) Start Splunk UF
# -------------------------
echo "[i] Starting Splunk Universal Forwarder..."
$SPLUNK_BIN start --accept-license --answer-yes --no-prompt

# try to login for CLI operations (may fail if not ready yet)
$SPLUNK_BIN login -auth "$SPLUNK_USER:$SPLUNK_PASS" || true

# -------------------------
# 6) Configure forwarding and monitoring
# -------------------------
echo "[i] Configuring forward-server and monitors..."

# add forward-server (UF -> Splunk indexer). If outputs.conf already exists this is harmless.
$SPLUNK_BIN add forward-server ${SPLUNK_FORWARDER_TARGET} -auth "$SPLUNK_USER:$SPLUNK_PASS" || true

# add monitors for auth.log and syslog (idempotent; -auth used)
$SPLUNK_BIN add monitor /var/log/auth.log -index $SPLUNK_INDEX -sourcetype linux_auth -auth "$SPLUNK_USER:$SPLUNK_PASS" || true
$SPLUNK_BIN add monitor /var/log/syslog   -index $SPLUNK_INDEX -sourcetype syslog     -auth "$SPLUNK_USER:$SPLUNK_PASS" || true

# -------------------------
# 7) Show status (helpful for debug)
# -------------------------
echo "[i] Forward servers:"
$SPLUNK_BIN list forward-server -auth "$SPLUNK_USER:$SPLUNK_PASS" || true

echo "[i] Monitors:"
$SPLUNK_BIN list monitor -auth "$SPLUNK_USER:$SPLUNK_PASS" || true

# -------------------------
# 8) Keep container interactive (same behavior as before)
# -------------------------
exec /bin/bash
