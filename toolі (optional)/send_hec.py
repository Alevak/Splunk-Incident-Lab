import requests
import json

url = 'http://localhost:8088/services/collector'
headers = {
    'Authorization': 'Splunk <your-token-here>'
}
payload = {
    "event": {
        "source": "lab-script",
        "command": "ping google.com",
        "status": "OK"
    }
}

requests.post(url, headers=headers, json=payload, verify=False)
