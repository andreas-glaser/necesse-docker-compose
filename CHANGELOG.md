# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Deduplicated README Quickstart instructions covering release downloads and cloning.

## [0.1.0] - 2025-10-19
### Added
- Debian-based Docker image that installs Necesse via SteamCMD and exposes configurable server flags.
- Compose file with health check, persistent data volume, and environment-driven configuration.
- Hardened entrypoint with optional auto-update, UID/GID remapping, and safe argument construction.
- Documentation and sample `.env` covering setup, updates, and troubleshooting.
- GitHub Actions CI workflow running shellcheck and docker build.
