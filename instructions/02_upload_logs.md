# 02 - Upload Logs to Splunk

1. Go to `Settings → Add Data`
2. Choose **Upload** and select `sysmon_powershell_base64.json`
3. Set:
   - Source type: `json`
   - Index: `main`
   - Sourcetype: `sysmon`
4. Confirm and finish.
