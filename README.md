# Necesse Dedicated Server (Docker)

Self-host the Necesse dedicated server with Docker Compose. The image installs the official Steam release via SteamCMD, keeps your world data on the host, and exposes every server flag through a simple `.env` file.

## Highlights
- One `docker compose up` builds the image and launches the server with the latest Steam files.
- World saves, configs, and logs stay under `./data` for easy backup and migration.
- Optional `UPDATE_ON_START=true` keeps the container patched automatically on each start.
- Map container permissions to your host user with `PUID`/`PGID` so binds remain writable on rootless setups.
- Health check and structured logging help detect crashes and keep an eye on the process.

## Prerequisites
- Docker Engine 20.10+ and Docker Compose Plugin v2 (`docker compose` CLI).
- At least 1 GB of free RAM (2 GB recommended for larger worlds).
- Ability to forward UDP port `14159` (or your chosen port) from the internet to this host.

## Quickstart
1. Download the latest release archive (`.zip` or `.tar.gz`) from the [releases page](https://github.com/andreas-glaser/necesse-docker-compose/releases) and extract it, or clone the repository:
   ```bash
   git clone git@github.com:andreas-glaser/necesse-docker-compose.git
   cd necesse-docker-compose
   ```
   If you used the release archive, `cd` into the extracted folder instead.
2. Copy `.env.example` to `.env`.
3. Edit `.env` to set at least `WORLD_NAME`, `SERVER_PASSWORD` (optional), and any other preferences.
4. (Optional) Set `PUID`/`PGID` to match the host account that owns the `data/` directory.
5. Build and start the stack:
   ```bash
   docker compose up --build -d
   ```
6. Tail logs until you see the server announce it is ready:
   ```bash
   docker compose logs -f necesse
   ```

> The first start uses SteamCMD to download the Necesse server files and can take a few minutes.

## Managing the server
- Restart after config changes: `docker compose up -d`
- Stop the server: `docker compose down`
- Update to the newest game build:
  - Set `UPDATE_ON_START=true` and restart, **or**
  - Run `docker compose build necesse && docker compose up -d`
- Check if the JVM process is healthy: `docker compose exec necesse pgrep -f 'Server.jar'`

## Configuration reference
All settings live in `.env`. Fields left blank fall back to the defaults baked into the image.

### Core settings
| Variable | Description |
| --- | --- |
| `SERVER_PORT` | UDP port to expose (default `14159`). |
| `WORLD_NAME` | World to load or create. |
| `SERVER_PASSWORD` | Optional join password; leave blank to disable. |
| `SERVER_SLOTS` | Maximum player slots (1-250). |
| `SERVER_OWNER` | Player given owner permissions. |
| `SERVER_MOTD` | Message shown on join; use `\n` for newline. |

### Gameplay & session behaviour
| Variable | Description |
| --- | --- |
| `PAUSE_WHEN_EMPTY` | `1` pauses when empty, `0` keeps running. |
| `GIVE_CLIENTS_POWER` | `1` favours smoother clients, `0` enforces strict validation. |
| `SERVER_LANGUAGE` | Language code for server messages (e.g. `en`). |
| `MAX_CLIENT_LATENCY` | Max seconds before timeout (`-maxlatency`). |
| `ENABLE_LOGGING` | `1` writes log files, `0` disables. |
| `ZIP_SAVES` | `1` compresses saves, `0` stores plain folders. |

### Paths, advanced flags, and host integration
| Variable | Description |
| --- | --- |
| `LOCAL_DIR` | `1` appends `-localdir` for local data storage. |
| `DATA_DIR` | Override save/config directory inside the container. |
| `LOGS_DIR` | Override log directory inside the container. |
| `SETTINGS_FILE` | Path to a custom `server.cfg` within the container. |
| `BIND_IP` | Specific interface/IP for the server to bind. |
| `UPDATE_ON_START` | `true` forces a SteamCMD update every start. |
| `JAVA_OPTS` | Additional JVM flags (e.g. `-Xmx2G`). |
| `PUID` / `PGID` | Host UID/GID to chown data before starting. |

## Data & backups
The compose file binds `./data` to `/home/necesse/.config/Necesse`, which holds:
- `cfg/server.cfg`
- `logs/` (if logging enabled)
- `saves/<world>.zip`

Back up this directory before upgrading, migrating hosts, or testing mods. To relocate storage, change the `volumes` entry in `docker-compose.yml` and adjust `DATA_DIR` and `LOGS_DIR` as needed.

## Running as a non-root host user
If your Docker engine runs rootless or you need specific ownership, set `PUID` and `PGID` in `.env` to the IDs of the host account that owns the data directory. The entrypoint remaps the internal `necesse` user, fixes permissions, and then drops privileges using `gosu`.

## Health & monitoring
A built-in Docker health check uses `pgrep` to ensure the Java process stays alive. Container orchestrators can rely on this status to restart the service automatically. Combine it with your preferred log shipper by tailing `data/logs` or `docker compose logs`.

## Troubleshooting
- **Players cannot join:** ensure UDP port forwarding matches `SERVER_PORT` and that your public IP is correct. Online port testers often report false negatives; testing in-game is most reliable.
- **Config changes not applying:** stop the container, edit `.env`, and run `docker compose up -d` again so the entrypoint rebuilds the command.
- **Server reports old version:** set `UPDATE_ON_START=true` temporarily or rebuild the image to pull the latest Steam release.

## Reference
- [Necesse Dedicated Server wiki (Feb 2025)](https://wiki.necesse.net/wiki/Dedicated_server)
- [Necesse Multiplayer Linux guide (Nov 2024)](https://wiki.necesse.net/wiki/Multiplayer-Linux)

## License
Released under the [MIT License](LICENSE).
