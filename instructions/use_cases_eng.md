SPL Use Case Descriptions

1. linux_sudo_nopasswd.spl

Use Case: Detection of sudo configuration allowing passwordless root command execution.

Why It's Dangerous:
Allowing `NOPASSWD` in the `/etc/sudoers` configuration file enables users to escalate privileges without entering a password. This configuration is often abused by attackers after gaining low-privilege access to elevate rights silently.

SPL Query:
```spl
source="linux_sudo_nopasswd.json" index="main" sourcetype="_json" auth="NOPASSWD"
```

Detection Logic:
We search logs for occurrences of the keyword `NOPASSWD` in relation to `sudoers` edits or sudo configuration files. These events indicate misconfigurations or privilege escalation vectors.

---

2. linux_tmp_exec.spl

Use Case**: Execution of binaries/scripts from the `/tmp` directory.

Why It's Dangerous:
The `/tmp` directory is world-writable and commonly used by attackers to stage and execute malware. Legitimate applications rarely run executables from `/tmp`, making it a red flag for malicious behavior.

SPL Query:
```spl
source="linux_tmp_exec.json" sourcetype="_json" exec="/tmp/malware.sh"
```

Detection Logic:
This query searches command-line execution logs for any scripts or binaries run from `/tmp`, which is often a TTP in Linux malware campaigns.

---

3. network_dns_duckdns.spl

Use Case: DNS queries to dynamic DNS provider `duckdns.org`.

Why It's Dangerous:
`duckdns.org` is frequently used by attackers for command and control (C2) domains due to its ease of dynamic registration and IP mapping. Frequent lookups to this domain could indicate malware beaconing behavior.

SPL Query:
```spl
source="network_dns_duckdns.json" index="main" sourcetype="_json" query="*.duckdns.org"
```

Detection Logic:
We look for outbound DNS queries that include `duckdns.org`. This helps identify C2-related activity or tunneling to attacker infrastructure.

---

4. suspicious_powershell.spl

Use Case: Detection of suspicious PowerShell commands.

Why It's Dangerous:
PowerShell is a powerful administrative tool that’s commonly used by attackers to execute scripts, download payloads, and evade detection (e.g., obfuscation or base64 encoding).

SPL Query:
```spl
source="sysmon_powershell_base64.json" index="main" sourcetype="_json" command_line="*-enc*"
```

Detection Logic:
This query identifies common signs of PowerShell abuse such as encoded payloads aligned with initial access and execution tactics in MITRE ATT&CK.

---

5. sysmon_bruteforce.spl

Use Case: Windows brute-force attack detection based on failed login events.

Why It's Dangerous:
Multiple failed logins (Event ID 4625) in a short timeframe may indicate brute-force attacks aimed at gaining unauthorized access.

SPL Query:
```spl
source="bruteforce_sample_mixed.json" sourcetype="_json" EventID="4625"
| bin _time span=1h
| stats count as failed_attempts by IpAddress, UserName, _time
| where failed_attempts >= 3
| sort - failed_attempts
```

Detection Logic:
We correlate multiple failed logins from the same IP address or username. The threshold `count > 3` filters out noise while capturing suspicious behavior suggestive of brute-force attempts.
