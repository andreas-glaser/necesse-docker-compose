# Git, Branching, and Tagging Guide

This project keeps the workflow intentionally simple so server admins and contributors can ship fixes quickly. Use this guide alongside the README and CHANGELOG when preparing updates.

## Branch Model

Branches in use:
- `main` – production-ready; every commit on `main` should be releasable. Protected.
- `feature/*` – optional short-lived branches for enhancements (e.g. `feature/auto-update-logging`).
- `fix/*` – optional short-lived branches for bug fixes (e.g. `fix/compose-env-defaults`).
- `chore/*` or `docs/*` – optional for maintenance/documentation work.
- `hotfix/*` – urgent fixes cut from `main`, merged back into `main` immediately.

Pull request targets:
- All contributions target `main`.
- After merging a hotfix branch, delete it. No forward merge step is needed because `main` is the only long-lived branch.

## Local Git Setup

Recommended global configuration:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true
# Optional signing
# git config --global commit.gpgsign true
# git config --global tag.gpgSign true
```

Clone the repository:
```bash
git clone git@github.com:andreas-glaser/necesse-docker-server.git
cd necesse-docker-server
```

Keeping a fork updated:
```bash
# Add upstream once
git remote add upstream git@github.com:andreas-glaser/necesse-docker-server.git

# Sync main
git fetch upstream
git checkout main
git rebase upstream/main
git push origin main
```

## Working on Changes

Create a feature branch:
```bash
git checkout main
git pull --rebase origin main
git checkout -b feature/your-feature
# ...implement changes...
git push -u origin feature/your-feature
# Open a PR against main
```

Apply a bug fix or documentation update:
```bash
git checkout main
git pull --rebase origin main
git checkout -b fix/short-description
# ...work, commit...
git push -u origin fix/short-description
# Open a PR against main
```

Urgent hotfix directly on `main`:
```bash
git checkout main
git pull --rebase origin main
git checkout -b hotfix/outage-fix
# ...work, commit...
git push -u origin hotfix/outage-fix
# Open PR → base: main
```

## Version Bumping & Release Prep

Before tagging a release:
1. Update [`CHANGELOG.md`](../CHANGELOG.md) with the new version and date.
2. Review and adjust documentation:
   - [`README.md`](../README.md) (Docker Hub instructions, version tags in examples).
   - `.env.example` defaults if behaviour changed.
   - Any files referenced by Quickstart snippets or guides.
3. Ensure `main` is clean and tested (compose build if necessary).

Commit your changes to `main` (via PR). Once merged, tag the release.

## Tagging and Publishing

Release tags follow SemVer with a `v` prefix (`vX.Y.Z`). To cut a release:

```bash
git checkout main
git pull --rebase origin main

# Annotated tag
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin v1.1.0
```

What happens after pushing the tag:
- GitHub Actions workflow `.github/workflows/release.yml` runs.
- Archives (`.zip`, `.tar.gz`) are generated and attached to the GitHub Release.
- Docker images are built and pushed to Docker Hub (`andreasgl4ser/necesse-server:latest` and `:1.1.0`).

If the workflow fails, inspect the run logs (`Actions → Release → latest run`). Fix the issue on `main`, retag (delete and recreate `vX.Y.Z`), and push again.

## Handy Commands

```bash
# Branch graph overview
git log --oneline --graph --decorate --all --date-order

# Clean up merged local branches (except main)
git fetch -p
git branch --merged | grep -vE '\*|main' | xargs -r git branch -d

# Abort a problematic rebase
git rebase --abort

# Continue a rebase after resolving conflicts
git add -A && git rebase --continue
```

Need more detail? Open an issue or start a discussion on GitHub.
