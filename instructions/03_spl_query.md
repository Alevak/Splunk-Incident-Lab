# 03 - Writing SPL Queries

## Goal: Detect encoded PowerShell

```spl
index=main sourcetype=sysmon Image=*powershell.exe* CommandLine="*-enc*"
```

This identifies base64-encoded PowerShell execution.
