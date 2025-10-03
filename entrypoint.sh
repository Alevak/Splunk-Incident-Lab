#!/bin/bash
set -euo pipefail

# -------------------------
# Config (можна перекривати через ENV)
# -------------------------
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

# -------------------------
# 0) Pre-check: splunk binary exists
# -------------------------
if [ ! -x "${SPLUNK_BIN}" ]; then
  err "Splunk UF binary not found at ${SPLUNK_BIN}. Build may have failed. Exiting."
  exit 2
fi

# -------------------------
# 0.5) Ensure runtime dirs & log files
# -------------------------
mkdir -p /run/sshd /var/log
# Ensure auth.log/syslog files exist (rsyslog will append)
touch /var/log/auth.log /var/log/syslog
chmod 644 /var/log/auth.log /var/log/syslog

# -------------------------
# 1) Create SSH host keys if missing
# -------------------------
if command -v ssh-keygen >/dev/null 2>&1; then
  log "Ensuring SSH host keys..."
  ssh-keygen -A 2>/dev/null || true
fi

# -------------------------
# 2) Start rsyslog (so /var/log/auth.log and /var/log/syslog are produced)
# -------------------------
if command -v rsyslogd >/dev/null 2>&1; then
  log "Starting rsyslog..."
  # run in background; keep logs to stdout/stderr via docker logs
  /usr/sbin/rsyslogd
  sleep 0.5
  if pgrep -x rsyslogd >/dev/null 2>&1; then
    log "rsyslogd is running"
  else
    warn "rsyslogd failed to start"
  fi
else
  warn "rsyslogd not found — syslog files may not be created."
fi

# -------------------------
# 3) Start sshd
# -------------------------
if [ -x /usr/sbin/sshd ]; then
  log "Starting sshd..."
  # start in background (daemonize)
  /usr/sbin/sshd || warn "sshd failed to start"
else
  warn "sshd not found — SSH access will be unavailable."
fi

# give syslog/sshd a moment
sleep 1

# -------------------------
# Helpers: wait for splunk to be ready
# -------------------------
wait_for_splunk() {
  local attempt=0
  while [ $attempt -lt $RETRY_MAX ]; do
    if "${SPLUNK_BIN}" status >/dev/null 2>&1; then
      # splunkd may be running but not ready for CLI; try a management endpoint
      if curl -sS --insecure http://localhost:8089/services/server/info >/dev/null 2>&1; then
        log "Splunk management endpoint reachable"
        return 0
      fi
    fi
    attempt=$((attempt+1))
    log "Waiting for Splunk to be ready... attempt ${attempt}/${RETRY_MAX}"
    sleep ${SLEEP_BETWEEN}
  done
  return 1
}

# -------------------------
# 4) First-time UF seed (if not configured)
# -------------------------
if [ ! -f "${SPLUNK_HOME}/etc/passwd" ]; then
  log "First-time UF setup: seeding admin password..."
  "${SPLUNK_BIN}" start --accept-license --answer-yes --no-prompt --seed-passwd "${SPLUNK_PASS}"
  log "Splunk started for initial setup; stopping to continue configuration..."
  "${SPLUNK_BIN}" stop
fi

# -------------------------
# 5) Start Splunk UF
# -------------------------
log "Starting Splunk Universal Forwarder..."
"${SPLUNK_BIN}" start --accept-license --answer-yes --no-prompt

# Wait for splunk to become responsive
if wait_for_splunk; then
  log "Splunk seems up"
else
  warn "Splunk did not become ready in time; continuing but CLI ops may fail"
fi

# -------------------------
# 6) Try to login (with retries) and perform config
# -------------------------
login_with_retry() {
  local attempt=0
  while [ $attempt -lt $RETRY_MAX ]; do
    if "${SPLUNK_BIN}" login -auth "${SPLUNK_USER}:${SPLUNK_PASS}" >/dev/null 2>&1; then
      log "Logged into Splunk CLI"
      return 0
    fi
    attempt=$((attempt+1))
    sleep ${SLEEP_BETWEEN}
    log "Retrying Splunk login ${attempt}/${RETRY_MAX}..."
  done
  return 1
}

if login_with_retry; then
  log "Configuring forward-server and monitors..."

  # add forward-server (idempotent)
  "${SPLUNK_BIN}" add forward-server "${SPLUNK_FORWARDER_TARGET}" -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || warn "add forward-server returned non-zero"

  # add monitors (idempotent checks)
  if ! "${SPLUNK_BIN}" list monitor | grep -q "/var/log/auth.log"; then
    "${SPLUNK_BIN}" add monitor /var/log/auth.log -index "${SPLUNK_INDEX}" -sourcetype linux_auth -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || warn "add monitor auth.log failed"
  else
    log "/var/log/auth.log already monitored"
  fi

  if ! "${SPLUNK_BIN}" list monitor | grep -q "/var/log/syslog"; then
    "${SPLUNK_BIN}" add monitor /var/log/syslog -index "${SPLUNK_INDEX}" -sourcetype syslog -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || warn "add monitor syslog failed"
  else
    log "/var/log/syslog already monitored"
  fi

else
  warn "Unable to login to Splunk CLI after retries — skipping add monitor/add forward-server (you can run these manually later)"
fi

# -------------------------
# 7) Show status (helpful for debug)
# -------------------------
log "Forward servers:"
"${SPLUNK_BIN}" list forward-server -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || true

log "Monitors:"
"${SPLUNK_BIN}" list monitor -auth "${SPLUNK_USER}:${SPLUNK_PASS}" || true

log "Tail last lines of splunkd log for quick debug:"
tail -n 40 "${SPLUNK_HOME}/var/log/splunk/splunkd.log" || true

# -------------------------
# 8) Keep container interactive (same behavior as before)
# -------------------------
exec /bin/bash
