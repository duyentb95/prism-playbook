Upgrade PRISM to latest version. Pulls prism-playbook from git + updates all registered projects.

$ARGUMENTS

Run these steps in order:

1. **Find prism-playbook source:**
   ```bash
   PRISM_SOURCE=$(cat ~/.prism/source-path 2>/dev/null)
   echo "Source path: ${PRISM_SOURCE:-NOT SET}"
   [ -n "$PRISM_SOURCE" ] && [ -d "$PRISM_SOURCE/.git" ] && echo "STATUS: LOCAL_REPO" || echo "STATUS: NEED_CLONE"
   ```

2. **If LOCAL_REPO** — pull latest:
   ```bash
   cd "$PRISM_SOURCE" && git pull origin main && git submodule update --init --recursive
   ```

3. **If NEED_CLONE** — clone from GitHub as fallback:
   ```bash
   mkdir -p ~/.prism/source
   git clone --depth 1 https://github.com/duyentb95/prism-playbook.git ~/.prism/source
   echo "$HOME/.prism/source" > ~/.prism/source-path
   PRISM_SOURCE="$HOME/.prism/source"
   ```

4. **Review before running setup:** Show the user what changed since last update:
   ```bash
   cd "$PRISM_SOURCE" && git log --oneline -10
   ```
   Then **ask the user for confirmation** before proceeding: "These commits will be applied. Run `./setup --update` now?"

5. **Only after user confirms** — run update:
   ```bash
   cd "$PRISM_SOURCE" && ./setup --update
   ```

6. **Report what changed:** Show the git log of new commits pulled, count of commands now available, and number of projects relinked.
