# Necesse Dedicated Server (Docker)

Containerised Necesse dedicated server ready for GitHub distribution. It builds the official SteamCMD release, supports one-command upgrades, and keeps world data on the host.

## Features
- SteamCMD install during build with optional `UPDATE_ON_START=true` refresh on each container boot.
- Safe entrypoint argument handling (no `eval`) with full CLI flag coverage.
- `.env`-driven configuration including optional `-port`, `-datadir`, `-logs`, and latency controls.
- Health check to make orchestration aware of server crashes.
- Persistent saves/logs under `./data` by default.
- Optional `PUID`/`PGID` remap for rootless Docker hosts and custom volume ownership.

## Quickstart
1. Download the latest release archive (`.zip` or `.tar.gz`) from the [Releases page](https://github.com/andreas-glaser/necesse-docker-compose/releases) and extract it:
   ```bash
   unzip necesse-docker-compose-vX.Y.Z.zip
   cd necesse-docker-compose
   ```
   _Prefer Git instead? Clone with `git clone git@github.com:andreas-glaser/necesse-docker-compose.git`._
2. Copy `.env.example` to `.env` and adjust values (`WORLD_NAME`, `SERVER_PASSWORD`, etc.).
3. Forward UDP port `14159` on your router/firewall to the host running this container.
4. Build and start the stack:
   ```bash
   docker compose up --build -d
   ```
5. Tail logs to confirm launch:
   ```bash
   docker compose logs -f necesse
   ```

## Downloading Without Git

Download the latest release `.tar.gz` or `.zip` from the [GitHub Releases](https://github.com/andreas-glaser/necesse-docker-compose/releases) page. Extract it and continue with the Quickstart from step 2. If you need an older version, choose the appropriate tag from the releases list.

## Environment Variables

All variables live in `.env`; unset values fall back to the defaults in the `Dockerfile`.

| Variable | Description |
| --- | --- |
| `SERVER_PORT` | UDP port Necesse binds to (default `14159`). |
| `WORLD_NAME` | World name to load or create. |
| `SERVER_PASSWORD` | Optional join password (blank disables). |
| `SERVER_SLOTS` | Max players (1-250). |
| `SERVER_OWNER` | Player name granted owner permissions. |
| `SERVER_MOTD` | Message of the day (`\n` for newline). |
| `PAUSE_WHEN_EMPTY` | `1` pauses when empty, `0` keeps running. |
| `GIVE_CLIENTS_POWER` | `1` smooth client experience, `0` strict validation. |
| `ENABLE_LOGGING` | `1` writes session logs, `0` disables. |
| `ZIP_SAVES` | `1` compress saves, `0` stores plain folders. |
| `SERVER_LANGUAGE` | Language code for server messages (e.g. `en`). |
| `SETTINGS_FILE` | Path to a custom `server.cfg` inside the container. |
| `BIND_IP` | Specific interface/IP to bind. |
| `MAX_CLIENT_LATENCY` | Max seconds before timeout (`-maxlatency`). |
| `LOCAL_DIR` | Set to `1` to append `-localdir`. |
| `DATA_DIR` | Directory for saves/configs; created if provided. |
| `LOGS_DIR` | Directory for logs; created if provided. |
| `UPDATE_ON_START` | `true` forces SteamCMD update before launch. |
| `JAVA_OPTS` | Extra JVM flags (e.g. `-Xms512m -Xmx2g`). |
| `PUID` / `PGID` | Override runtime UID/GID for the `necesse` user (useful on rootless hosts). |

## Data Persistence

`docker-compose.yml` mounts `./data` to `/home/necesse/.config/Necesse`. This folder contains:
- `cfg/server.cfg`
- `logs/` (if logging enabled)
- `saves/<world>.zip`

Back up this directory regularly before upgrades or major changes.

To store data elsewhere, change the bind mount and/or set `DATA_DIR` and `LOGS_DIR`.

## Running as an Unprivileged Host User

Set `PUID`/`PGID` in `.env` to match the UID/GID of the host account that owns the bind-mounted data directory. The entrypoint remaps the internal `necesse` user and fixes permissions before dropping privileges with `gosu`, keeping the server non-root even under rootless Docker and Kubernetes.

## Updating the Server

- For repeatable builds, rebuild the image when the game updates:
  ```bash
  docker compose build necesse && docker compose up -d
  ```
- For automatic patching, set `UPDATE_ON_START=true` in `.env`. Each container start runs SteamCMD.

## Health & Monitoring

The compose file includes a `pgrep` health check. Deployments can use it to detect crashes. To manually verify the process:
```bash
docker compose exec necesse pgrep -f 'Server.jar'
```

Logs remain under `./data/logs`. Tail them with `docker compose logs -f necesse` or externally via the bind mount.

## Troubleshooting

- **Players cannot join:** confirm UDP port forwarding (`SERVER_PORT`) and public IP. Port testers may report false negatives; validating in-game is more reliable.
- **Configuration changes not applying:** stop the container, edit `.env`, and restart with `docker compose up -d`.
- **Server stuck out-of-date:** ensure `UPDATE_ON_START=true` or rebuild the image to pull the latest Steam release.

## Continuous Integration

GitHub Actions (`.github/workflows/ci.yml`) runs shellcheck on `entrypoint.sh` and builds the Docker image for every push and pull request.

## Release Process

1. Update [`CHANGELOG.md`](CHANGELOG.md) with the upcoming version and date.
2. Commit the changes to `main` (or merge from your working branch).
3. Tag the commit (e.g. `git tag -a v0.1.0 -m "v0.1.0"`).
4. Push the tag (`git push origin v0.1.0`). The release workflow attaches `.tar.gz` and `.zip` archives to the GitHub release automatically.

## Reference

- [Necesse Dedicated Server wiki (Feb 2025)](https://wiki.necesse.net/wiki/Dedicated_server)  
- [Necesse Multiplayer Linux guide (Nov 2024)](https://wiki.necesse.net/wiki/Multiplayer-Linux)

## License

Released under the [MIT License](LICENSE).
