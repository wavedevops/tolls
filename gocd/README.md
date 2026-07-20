### Verify

```bash
systemctl status gocd-server
```

Open the GoCD web UI:

```
http://<SERVER_IP>:8153
```

The first-time admin password can be found in:

```bash
cat /home/gocd/go-server-23.5.0/config/go-server/password_file
```

This playbook is **idempotent** and works on **RHEL 9**.

```
dnf install java-17-openjdk.x86_64 -y

useradd gocd

curl -L -o /tmp/go-agent-23.5.0-18179.zip https://download.gocd.org/binaries/23.5.0-18179/generic/go-agent-23.5.0-18179.zip

su - gocd -c 'unzip /tmp/go-agent-23.5.0-18179.zip'


