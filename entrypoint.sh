#!/bin/bash
set -euo pipefail

SPLUNK_HOME=${SPLUNK_HOME:-/opt/splunkforwarder}
SPLUNK_BIN=${SPLUNK_HOME}/bin/splunk
SPLUNK_USER=${SPLUNK_USER:-admin}
SPLUNK_PASS=${SPLUNK_PASS:-changeme123}
SPLUNK_INDEX=${SPLUNK_INDEX:-main}
SPLUNK_FORWARDER_TARGET=${SPLUNK_FORWARDER_TARGET:-splunk:9997}

# Retry settings
RETRY_MAX=20
SLEEP_BETWEEN=3

log() { printf '%b\n' "[i] $*"; }
warn() { printf '%b\n' "[w] $*" >&2; }
err() { printf '%b\n' "[ERROR] $*" >&2; }

# ensure runtime dirs and log files exist
mkdir -p /run/sshd /var/log
touch /var/log/syslog /var/log/auth.log
chmod 644 /var/log/syslog /var/log/auth.log

# --- Start lightweight syslog (busybox) ---
if command -v syslogd >/dev/null 2>&1 || command -v /sbin/syslogd >/dev/null 2>&1 || command -v busybox >/dev/null 2>&1; then
  log "Starting lightweight syslog (busybox/syslogd)..."
  # prefer syslogd binary if available, else use busybox
  if command -v syslogd >/dev/null 2>&1; then
    /sbin/syslogd -O /var/log/syslog || warn "syslogd start returned non-zero"
  elif command -v /sbin/syslogd >/dev/null 2>&1; then
    /sbin/syslogd -O /var/log/syslog || warn "syslogd start returned non-zero"
  else
    # busybox syslogd
    busybox syslogd -O /var/log/syslog || warn "busybox syslogd start returned non-zero"
  fi
  # create auth.log symlink to syslog (so existing monitors can find it)
  if [ ! -f /var/log/auth.log ]; then
    ln -sf /var/log/syslog /var/log/auth.log || true
  else
    # if auth.log exists as file, keep it
    :
  fi
else
  warn "No lightweight syslog binary found; syslog will not be available."
fi

# Start sshd (if available)
if [ -x /usr/sbin/sshd ]; then
  log "Starting sshd..."
  /usr/sbin/sshd || warn "sshd failed to start"
else
  warn "sshd not found — SSH access unavailable."
fi

# small pause to let syslog/sshd initialize
sleep 1

# (rest is UF bootstrap — can keep your existing logic)
if [ ! -f "${SPLUNK_HOME}/etc/passwd" ]; then
  log "First-time UF setup: seeding admin password..."
  "${SPLUNK_BIN}" start --accept-license --answer-yes --no-prompt --seed-passwd "${SPLUNK_PASS}"
  "${SPLUNK_BIN}" stop
fi

log "Starting Splunk Universal Forwarder..."
"${SPLUNK_BIN}" start --accept-license --answer-yes --no-prompt

# Wait for Splunk management endpoint
attempt=0
while [ $attempt -lt $RETRY_MAX ]; do
  if curl -sS --insecure http://localhost:8089/services/server/info >/dev/null 2>&1; then
    log "Splunk management available"
    break
  fi
  attempt=$((attempt+1))
  log "Waiting for Splunk (${attempt}/${RETRY_MAX})..."
  sleep ${SLEEP_BETWEEN}
done

# Try login with retries
login_attempt=0
while [ $login_attempt -lt $RETRY_MAX ]; do
  if "${SPLUNK_BIN}" login -auth "${SPLUNK_USER}:${SPLUNK_PASS}" >/dev/null 2>&1; then
    log "Logged into Splunk CLI"
    break
  fi
  login_attempt=$((login_attempt+1))
  sleep ${SLEEP_BETWEEN}
done

# configure forward-server and monitors (idempotent)
"${SPLUNK_BIN}" add forward-server "${SPLUNK_FORWARDER_TARGET}" -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || warn "add forward-server returned non-zero"

# If syslog exists (or symlink), monitor it; otherwise fallback to dpkg.log, wtmp
if [ -f /var/log/syslog ] || [ -L /var/log/syslog ]; then
  "${SPLUNK_BIN}" list monitor | grep -q "/var/log/syslog" || "${SPLUNK_BIN}" add monitor /var/log/syslog -index "${SPLUNK_INDEX}" -sourcetype syslog -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || warn "add monitor syslog failed"
  "${SPLUNK_BIN}" list monitor | grep -q "/var/log/auth.log" || "${SPLUNK_BIN}" add monitor /var/log/auth.log -index "${SPLUNK_INDEX}" -sourcetype linux_auth -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || warn "add monitor auth.log failed"
else
  log "syslog not present — adding fallback monitors"
  "${SPLUNK_BIN}" list monitor | grep -q "/var/log/dpkg.log" || "${SPLUNK_BIN}" add monitor /var/log/dpkg.log -index "${SPLUNK_INDEX}" -sourcetype dpkg_log -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || true
  "${SPLUNK_BIN}" list monitor | grep -q "/var/log/wtmp"    || "${SPLUNK_BIN}" add monitor /var/log/wtmp -index "${SPLUNK_INDEX}" -sourcetype wtmp_log -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || true
fi

# show status
log "Forward servers:"
"${SPLUNK_BIN}" list forward-server -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || true
log "Monitors:"
"${SPLUNK_BIN}" list monitor -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || true

log "Tail last lines of splunkd log for quick debug:"
tail -n 40 "${SPLUNK_HOME}/var/log/splunk/splunkd.log" || true

# keep container alive
exec /bin/bash
