# 06 – Additional Use Cases

This section includes alternative detection scenarios using different datasets.

---

## 🐧 Linux: Suspicious Execution from /tmp

- **Goal**: Detect scripts or binaries launched from /tmp
- **SPL**:
```spl
index=main sourcetype=linux_logs command="/tmp/*"
```
- **Sample file**: `linux_tmp_exec.json`

---

## 🪟 Windows: Execution of Mimikatz

- **Goal**: Detect known credential dumping tool
- **SPL**:
```spl
index=main sourcetype=sysmon Image="*mimikatz.exe*"
```
- **Sample file**: `windows_mimikatz.json`

---

## 🐧 Linux: Sudo with NOPASSWD

- **Goal**: Find escalation or misconfigured sudo access
- **SPL**:
```spl
index=main sourcetype=auth_logs message="*NOPASSWD*"
```
- **Sample file**: `linux_sudo_nopasswd.json`

---

## 🌐 DNS: Dynamic DNS (duckdns)

- **Goal**: Detect use of dynamic DNS services
- **SPL**:
```spl
index=main sourcetype=dns_logs query="*.duckdns.org"
```
- **Sample file**: `network_dns_duckdns.json`