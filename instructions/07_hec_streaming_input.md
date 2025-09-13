# 07 – Real-Time Logging with HEC

This lab shows how to send logs to Splunk in real-time using the HTTP Event Collector (HEC).

## 1. Enable HEC in Splunk

- Go to: Settings → Data Inputs → HTTP Event Collector
- Click "New Token"
  - Name: `lab-hec`
  - Source type: `json`
  - Index: `main`
  - Keep SSL disabled for localhost
- Save the token shown (e.g., `D1234567-...`)

## 2. Send data via curl

```bash
curl -k https://localhost:8088/services/collector   -H "Authorization: Splunk <token>"   -d '{"event": {"type":"heartbeat","source":"student"}}'
```

## 3. Or use Python

```python
import requests
requests.post(
    'http://localhost:8088/services/collector',
    headers={'Authorization': 'Splunk <token>'},
    json={"event": {"source": "lab-script", "message": "hi Splunk!"}},
    verify=False
)
```

## 4. Search in Splunk

```spl
index=main source="lab-script"
```