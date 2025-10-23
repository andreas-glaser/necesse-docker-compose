# Release Guide

A concise checklist for preparing and publishing a new Necesse Docker Server release.

---

## 1. Pre-release Review

1. **Update documentation**
   - [`CHANGELOG.md`](../CHANGELOG.md) – add `## [X.Y.Z] - YYYY-MM-DD` with highlights.
   - [`README.md`](../README.md) – ensure quickstart snippets reference the correct image tag.
   - `.env.example` – adjust defaults if behaviour changed.
   - Any other docs touched by the release (e.g. `docs/` guides).

2. **Verify working tree**
   ```bash
   git checkout main
   git pull --rebase origin main
   git status
   ```

3. **Smoke test (optional but recommended)**
   ```bash
   docker compose build necesse
  docker compose up -d
   docker compose logs -f necesse
   docker compose down
   ```

---

## 2. Commit the Release Prep

4. Stage and commit:
   ```bash
   git add -A
   git commit -m "chore: prepare release vX.Y.Z"
   git push origin main
   ```

5. Confirm CI is green (`Actions` tab or `gh run list --limit 5`).

---

## 3. Tag & Publish

6. Create an annotated tag from `main`:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

7. GitHub Actions (`.github/workflows/release.yml`) will:
   - Generate `.zip` and `.tar.gz` archives.
   - Publish the GitHub Release with notes from the changelog.
   - Build and push Docker images to Docker Hub (`andreasgl4ser/necesse-server:latest` and `:X.Y.Z`).

8. Monitor the workflow to completion:
   ```bash
   gh run list --workflow Release --limit 3
   ```

If the run fails, address the issue on `main`, delete the tag (`git tag -d vX.Y.Z` + `git push origin :refs/tags/vX.Y.Z`), fix the problem, and retag.

---

## 4. Post-release

9. Announce or document as needed (update Docker Hub overview, Discord post, etc.).
10. Start the next development iteration—`main` remains the primary branch; no forward merges required.

---

## Helpful Commands

```bash
# Last published tag
git describe --tags --abbrev=0

# View changes since last release
git log --oneline "$(git describe --tags --abbrev=0)..HEAD"
```

Need a refresher on commit conventions or branching? See the [Git Guide](GIT_GUIDE.md) and [Commit Guide](GIT_COMMIT_GUIDE.md).
