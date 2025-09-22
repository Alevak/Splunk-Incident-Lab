5 – Real-Time Logging with Splunk Universal Forwarder

This lab shows how to forward logs from a separate Linux container using Splunk Universal Forwarder.

 1. Start test Linux container

```bash
docker run -dit --name test-linux ubuntu:20.04 bash
docker exec -it test-linux bash
```

2. Install Splunk UF in container

```bash
apt update && apt install -y wget
wget -O splunkforwarder.tgz 'https://download.splunk.com/products/universalforwarder/releases/9.1.1/linux/splunkforwarder-9.1.1-64e843ea36b1-Linux-x86_64.tgz'
tar -xvzf splunkforwarder.tgz -C /opt
/opt/splunkforwarder/bin/splunk start --accept-license
```

3. Configure forwarding
```bash
/opt/splunkforwarder/bin/splunk add forward-server <host-ip>:9997 -auth admin:changeme
/opt/splunkforwarder/bin/splunk add monitor /var/log
```

4. In Splunk UI

Enable receiving port:

- Settings → Forwarding and receiving → Configure receiving
- Add port 9997

5. Search

```spl
index=main host="test-linux"
```
