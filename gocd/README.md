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
