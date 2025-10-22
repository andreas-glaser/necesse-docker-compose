# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-22
### Added
- Automatic update watcher controlled by `AUTO_UPDATE_INTERVAL_MINUTES` that checks Steam for new builds and restarts the server.
### Changed
- Reworked README for server admins with clearer quickstart, management guidance, and streamlined feature notes.
- Auto-update now logs when periodic checks are enabled so admins know the cadence.

## [0.1.0] - 2025-10-19
### Added
- Debian-based Docker image that installs Necesse via SteamCMD and exposes configurable server flags.
- Compose file with health check, persistent data volume, and environment-driven configuration.
- Hardened entrypoint with optional auto-update, UID/GID remapping, and safe argument construction.
- Documentation and sample `.env` covering setup, updates, and troubleshooting.
- GitHub Actions CI workflow running shellcheck and docker build.
