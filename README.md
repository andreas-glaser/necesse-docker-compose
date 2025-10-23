# Necesse Dedicated Server (Docker)

[![CI](https://github.com/andreas-glaser/necesse-docker-server/actions/workflows/ci.yml/badge.svg)](https://github.com/andreas-glaser/necesse-docker-server/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/andreas-glaser/necesse-docker-server?sort=semver)](https://github.com/andreas-glaser/necesse-docker-server/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/andreasgl4ser/necesse-server)](https://hub.docker.com/r/andreasgl4ser/necesse-server)
[![Image Size](https://img.shields.io/docker/image-size/andreasgl4ser/necesse-server/latest?label=image%20size)](https://hub.docker.com/r/andreasgl4ser/necesse-server)

<video class="bb_img" autoplay muted loop playsinline poster="https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1169040/extras/6b1743004767ed52c5376274f701f8bd.poster.avif?t=1760982320" width="612" height="200">
  <source src="https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1169040/extras/6b1743004767ed52c5376274f701f8bd.webm?t=1760982320" type="video/webm; codecs=vp9" />
  <source src="https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1169040/extras/6b1743004767ed52c5376274f701f8bd.mp4?t=1760982320" type="video/mp4" />
  <a href="https://store.steampowered.com/app/1169040/Necesse/">Watch the Necesse trailer</a>
</video>

Dockerised Necesse dedicated server that always pulls the latest Steam release, keeps saves on the host, and exposes every server flag through environment variables. Published on Docker Hub as [`andreasgl4ser/necesse-server`](https://hub.docker.com/r/andreasgl4ser/necesse-server).

---

## Run With `docker run`

```bash
docker run -d \
  --name necesse \
  -p 14159:14159/udp \
  -v $PWD/data:/home/necesse/.config/Necesse \
  -e WORLD_NAME=MyWorld \
  -e SERVER_PASSWORD=changeme \
  -e SERVER_SLOTS=10 \
  -e UPDATE_ON_START=true \
  -e AUTO_UPDATE_INTERVAL_MINUTES=60 \
  andreasgl4ser/necesse-server:1.2.0
```

- Replace `changeme` with the password you want (leave blank to disable).
- The bind mount stores saves, logs, and `cfg/server.cfg` under `./data`.
- Forward UDP port `14159` from your router/firewall to this host.

To follow the latest image automatically, change the tag to `:latest`.

---

## Run With Docker Compose

`docker-compose.yml`:

```yaml
services:
  necesse:
    image: andreasgl4ser/necesse-server:${IMAGE_TAG:-latest}
    container_name: necesse
    restart: unless-stopped
    ports:
      - "14159:14159/udp"
    env_file: .env
    volumes:
      - ./data:/home/necesse/.config/Necesse
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f 'Server.jar' >/dev/null"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 30s
```

`.env` (copy from `.env.example` and adjust):

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
IMAGE_TAG=1.2.0
```

Start / update:

```bash
docker compose pull necesse   # grab latest published image (optional if IMAGE_TAG pinned)
docker compose up -d          # launch or restart the server
docker compose logs -f necesse
```

Set `IMAGE_TAG` (env or `.env`) to pin a specific release; leave it blank for `latest`. To build a custom image instead, run `docker compose build necesse` and Compose will reuse it.

---

## Environment Variables

| Variable | Purpose |
| --- | --- |
| `WORLD_NAME` | World to load or create. |
| `SERVER_PASSWORD` | Join password; blank disables. |
| `SERVER_SLOTS` | Maximum concurrent players (1–250). |
| `SERVER_OWNER` | Owner player name (grants admin on join). |
| `SERVER_MOTD` | Message shown on join (`\n` for newline). |
| `SERVER_PORT` | UDP port inside the container (default 14159). |
| `PAUSE_WHEN_EMPTY` | `1` pauses when empty, `0` keeps running. |
| `GIVE_CLIENTS_POWER` | `1` smoother clients, `0` strict validation. |
| `ENABLE_LOGGING` | `1` writes log files, `0` disables. |
| `ZIP_SAVES` | `1` compresses saves, `0` stores plain folders. |
| `SERVER_LANGUAGE` | Language code for server messages (`en`, `de`, …). |
| `MAX_CLIENT_LATENCY` | Max seconds before kick (`-maxlatency`). |
| `SETTINGS_FILE` | Path to a custom `server.cfg` inside the container. |
| `BIND_IP` | Specific IP/interface for the server to bind. |
| `LOCAL_DIR` | `1` appends `-localdir` flag for local storage. |
| `DATA_DIR`, `LOGS_DIR` | Override in-container paths (folders auto-created). |
| `UPDATE_ON_START` | `true` runs SteamCMD on every boot. |
| `AUTO_UPDATE_INTERVAL_MINUTES` | Background poll interval; container restarts when a new Steam build is detected (`0` disables). |
| `JAVA_OPTS` | Extra JVM flags (e.g. `-Xmx2G`). |
| `PUID` / `PGID` | Host UID/GID to chown bind mounts (useful on rootless hosts). |
| `IMAGE_TAG` | Override image tag in Compose (default `latest`). |

---

## Data, Permissions & Monitoring

- Saves live under `/home/necesse/.config/Necesse` (mapped to `./data`). Back it up regularly before upgrades or migrations.
- Set `PUID`/`PGID` to match the owner of the bind-mounted folder if your Docker daemon runs rootless or you need host-level permissions preserved. The entrypoint remaps the `necesse` user before launching the JVM.
- Health check: `pgrep -f 'Server.jar'`. Use `docker compose ps` or `docker inspect --format '{{.State.Health.Status}}' necesse` to verify.
- Tail logs with `docker compose logs -f necesse` or from `data/logs/`.

---

## Updates & Troubleshooting

- **Auto updates:** `UPDATE_ON_START=true` runs SteamCMD each start. Setting `AUTO_UPDATE_INTERVAL_MINUTES` (e.g. `60`) enables continuous polling; the container stops, updates, and restarts itself when Steam publishes a new build.
- **Players cannot join:** confirm UDP port forwarding and public IP. Some port testers give false negatives—validate in-game if unsure.
- **Config changes ignored:** edit `.env`, then `docker compose up -d` to recreate with new flags.
- **Version mismatch errors:** ensure both `UPDATE_ON_START` and the interval watcher are enabled, or manually pull the latest image and restart.

---

## Clone, Develop, Contribute

Prefer to work from source, tweak the image, or contribute?

```bash
git clone git@github.com:andreas-glaser/necesse-docker-server.git
cd necesse-docker-server
cp .env.example .env
docker compose build necesse
docker compose up -d
```

- Lint: `./.github/workflows/ci.yml` runs on PRs (shellcheck + docker build).
- Release process:
  1. Update [`CHANGELOG.md`](CHANGELOG.md) and documentation.
  2. `git tag -a vX.Y.Z -m "vX.Y.Z"` and push with `--follow-tags`.
  3. GitHub Actions publishes release archives and pushes Docker Hub tags (`latest`, `X.Y.Z`).

Issues and pull requests welcome!

---

## Reference

- [Necesse Dedicated Server wiki](https://wiki.necesse.net/wiki/Dedicated_server)
- [Necesse Multiplayer Linux guide](https://wiki.necesse.net/wiki/Multiplayer-Linux)

---

## License

Released under the [MIT License](LICENSE).
