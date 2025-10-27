## Necesse Dedicated Server

Hardened dedicated server image for **Necesse**, installing the latest Steam build via SteamCMD and keeping saves/configs on the host. Every server flag is exposed through environment variables. Published as `andreasgl4ser/necesse-server`.

---

### Quick Start — Docker CLI

```bash
docker run -d \
  --name necesse \
  -p 14159:14159/udp \
  -v $PWD/data:/home/necesse/.config/Necesse \
  -e WORLD_NAME=MyWorld \
  -e SERVER_PASSWORD=secret \
  -e SERVER_SLOTS=10 \
  -e UPDATE_ON_START=true \
  -e AUTO_UPDATE_INTERVAL_MINUTES=60 \
  andreasgl4ser/necesse-server:latest
```

**Volumes**

* `/home/necesse/.config/Necesse` — saves (`saves/<world>.zip`), logs, and `cfg/server.cfg`

Ensure UDP port **14159** is forwarded to the container host.

---

### Quick Start — Docker Compose

```yaml
services:
  necesse:
    image: andreasgl4ser/necesse-server:${IMAGE_TAG:-latest}
    container_name: necesse
    restart: unless-stopped
    ports:
      - "14159:14159/udp"
    environment:
      - SERVER_PORT=${SERVER_PORT:-14159}
      - WORLD_NAME=${WORLD_NAME:-MyWorld}
      - SERVER_PASSWORD=${SERVER_PASSWORD}
      - SERVER_SLOTS=${SERVER_SLOTS}
      - SERVER_OWNER=${SERVER_OWNER}
      - SERVER_MOTD=${SERVER_MOTD}
      - PAUSE_WHEN_EMPTY=${PAUSE_WHEN_EMPTY}
      - GIVE_CLIENTS_POWER=${GIVE_CLIENTS_POWER}
      - ENABLE_LOGGING=${ENABLE_LOGGING}
      - ZIP_SAVES=${ZIP_SAVES}
      - SERVER_LANGUAGE=${SERVER_LANGUAGE}
      - SETTINGS_FILE=${SETTINGS_FILE}
      - BIND_IP=${BIND_IP}
      - MAX_CLIENT_LATENCY=${MAX_CLIENT_LATENCY}
      - LOCAL_DIR=${LOCAL_DIR:-0}
      - DATA_DIR=${DATA_DIR}
      - LOGS_DIR=${LOGS_DIR}
      - UPDATE_ON_START=${UPDATE_ON_START}
      - AUTO_UPDATE_INTERVAL_MINUTES=${AUTO_UPDATE_INTERVAL_MINUTES:-0}
      - JAVA_OPTS=${JAVA_OPTS}
      - PUID=${PUID}
      - PGID=${PGID}
    volumes:
      - ./data:/home/necesse/.config/Necesse
    mem_limit: 2g
    mem_reservation: 512m
```

**.env Example**

```
WORLD_NAME=MyWorld
SERVER_PASSWORD=changeme
SERVER_SLOTS=10
SERVER_OWNER=AdminPlayer
SERVER_MOTD=Welcome to Necesse!
SERVER_PORT=14159
PUID=1000
PGID=1000
UPDATE_ON_START=true
AUTO_UPDATE_INTERVAL_MINUTES=60
IMAGE_TAG=latest
```

**Start / Update**

```bash
docker compose pull necesse
docker compose up -d
docker compose logs -f necesse
```

---

### Environment Variables

| Variable                                         | Description                                 |
| ------------------------------------------------ | ------------------------------------------- |
| `WORLD_NAME`                                     | World to load or create                     |
| `SERVER_PASSWORD`                                | Join password (blank disables)              |
| `SERVER_SLOTS`                                   | Max players (1–250)                         |
| `SERVER_OWNER`                                   | Owner player name                           |
| `SERVER_MOTD`                                    | Message of the day (`\n` for newline)       |
| `SERVER_PORT`                                    | UDP port inside container (default `14159`) |
| `PAUSE_WHEN_EMPTY`                               | `1` pauses when empty, `0` keeps running    |
| `GIVE_CLIENTS_POWER`                             | `1` client-friendly, `0` strict validation  |
| `ENABLE_LOGGING`, `ZIP_SAVES`, `SERVER_LANGUAGE` | Logging, save format, language              |
| `MAX_CLIENT_LATENCY`, `SETTINGS_FILE`, `BIND_IP` | Advanced server flags                       |
| `LOCAL_DIR`, `DATA_DIR`, `LOGS_DIR`              | Custom in-container paths (auto-created)    |
| `UPDATE_ON_START`                                | Run SteamCMD before every start             |
| `AUTO_UPDATE_INTERVAL_MINUTES`                   | Background update interval (0 disables)     |
| `JAVA_OPTS`                                      | Extra JVM options (e.g. `-Xmx2G`)           |
| `PUID` / `PGID`                                  | Host UID/GID for bind mounts                |
| `IMAGE_TAG`                                      | Image tag for Compose (default `latest`)    |

---

### Data and Backups

* Saves and configs stored under `./data` (or custom mount).
* Back up before upgrades or migrations.
* Change paths via Compose volume or `DATA_DIR` / `LOGS_DIR`.

---

### Auto Updates

* `UPDATE_ON_START=true` runs SteamCMD at every boot.
* `AUTO_UPDATE_INTERVAL_MINUTES` runs a background watcher that restarts the container when new builds appear.
* The watcher touches `/tmp/necesse-auto-update` to trigger an update cycle after the JVM exits.

---

### Health and Troubleshooting

* Built-in health check runs `pgrep -f 'Server.jar'` every 30s.
* View logs:

  ```bash
  docker compose logs -f necesse
  ```

**Common issues**

| Problem        | Fix                                                 |
| -------------- | --------------------------------------------------- |
| Can't join     | Confirm UDP port forwarding                         |
| Config ignored | Edit `.env`, then `docker compose up -d`            |
| Old version    | Set `UPDATE_ON_START=true` or pull the latest image |
