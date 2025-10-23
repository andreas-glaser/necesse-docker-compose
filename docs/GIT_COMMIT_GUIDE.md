# Commit Guide

Follow this checklist before pushing code or opening a pull request.

## Pre-Commit Checks

1. **Review changes**
   ```bash
   git status
   git diff
   git diff --staged
   ```

2. **Run formatting / linting**  
   (Only if you touched these files)
   ```bash
   # Shell scripts
   shellcheck entrypoint.sh

   # Dockerfile sanity (optional)
   hadolint Dockerfile
   ```

3. **Optional smoke test**  
   Ensure the image builds and the server starts:
   ```bash
   docker compose build necesse
   docker compose up -d
   docker compose logs -f necesse
   docker compose down
   ```

## Commit Process

4. **Stage files**
   ```bash
   git add <specific_files>
   # or interactive:
   git add -p
   ```

5. **Create commit**
   ```bash
   git commit -m "<type>: <description>"
   ```

6. **Verify CI**
   ```bash
   gh run list --limit 5
   ```
   - Or visit: https://github.com/andreas-glaser/necesse-docker-server/actions
   - Do not push release tags while CI is failing.

## Commit Message Format

**Types:**
- `feat`: New behaviour or capability
- `fix`: Bug fix or regression prevention
- `docs`: Documentation-only change
- `refactor`: Internal refactoring without behaviour change
- `chore`: Build, config, dependency, or release prep
- `style`: Formatting-only changes (rare; use tools sparingly)
- `test`: Add/update tests

**Examples:**
- `feat: add auto update interval logging`
- `fix: copy steamcmd manifest inside app dir`
- `docs: expand docker hub quickstart`
- `chore: prepare release v1.1.0`

Rules:
- Use the imperative mood (“add”, “fix”, “update”).
- Keep the subject ≤72 characters.
- No trailing period.
- No AI references or emojis.

## Multi-line Messages

Use body lines for more context or issue references:
```bash
git commit -m "fix: ensure compose uses published image" -m "
- default to andreasgl4ser/necesse-server:latest
- allow overrides via IMAGE_TAG
- fixes #42"
```
