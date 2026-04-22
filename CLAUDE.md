# dot_files

Alfonso's dotfiles and environment bootstrap repo. This is the entry point for setting up any new machine — it contains dotfiles, symlink instructions, and references to all project repos.

## Full Environment Bootstrap

When starting from scratch on a clean machine, Claude should follow these steps in order:

### 1. Clone this repo (if not already)
```bash
git clone git@github.com:AAlvz/dot_files.git ~/dot_files
```

### 2. Symlink dotfiles
```bash
# macOS
ln -sf ~/dot_files/.emacs ~/.emacs
ln -sf ~/dot_files/.zshrc ~/.zshrc
ln -sf ~/dot_files/.gitconfig ~/.gitconfig

# Linux (additional)
ln -sf ~/dot_files/.bashrc ~/.bashrc
ln -sf ~/dot_files/.bash_aliases ~/.bash_aliases
ln -sf ~/dot_files/.bash_profile ~/.bash_profile
ln -sf ~/dot_files/.Xresources ~/.Xresources
ln -sf ~/dot_files/.vimrc ~/.vimrc
mkdir -p ~/.i3 && ln -sf ~/dot_files/.i3/config ~/.i3/config
```

### 3. Emacs setup
```bash
mkdir -p ~/.emacs.d/lisp
cp ~/dot_files/.emacs.d/lisp/*.el ~/.emacs.d/lisp/ 2>/dev/null || ln -sf ~/dot_files/.emacs.d/lisp ~/.emacs.d/lisp
# Start Emacs once — packages auto-install on first run
```

### 4. Clone all project repos
```bash
mkdir -p ~/aalvz
cd ~/aalvz
git clone git@github.com:AAlvz/projects.git
git clone git@github.com:AAlvz/tribu.git
# dot_files is already at ~/dot_files (step 1)
```

### 5. Connect to C2 (the other computer)
C2 is the Ubuntu XPS 13 used to run the Tribu app. Connection details:

| Machine | Role | IP | User | SSH key comment |
|---------|------|----|------|-----------------|
| C1 (Mac) | Editing, git, Claude Code | 192.168.1.90 | alfonsoa | mac2 |
| C2 (Ubuntu XPS 13) | Running Tribu app, dev server | 192.168.1.88 | user | alfonso |

Both directions have key-based SSH auth configured. IPs may change if DHCP reassigns — check with `hostname -I` (Linux) or `ipconfig getifaddr en0` (macOS).

**From C1 (Mac) → C2:**
```bash
ssh-keyscan -t ed25519 192.168.1.88 >> ~/.ssh/known_hosts 2>/dev/null
ssh user@192.168.1.88 'hostname && uname -a'
# If auth fails: ssh-copy-id -i ~/.ssh/id_ed25519.pub user@192.168.1.88
```

**From C2 (Ubuntu) → C1:**
```bash
ssh-keyscan -t ed25519 192.168.1.90 >> ~/.ssh/known_hosts 2>/dev/null
ssh alfonsoa@192.168.1.90 'hostname && uname -a'
# If auth fails: ssh-copy-id -i ~/.ssh/id_ed25519.pub alfonsoa@192.168.1.90
# macOS must have Remote Login enabled (System Settings → General → Sharing → Remote Login)
```

Full C2 dev workflow (deploy, logs, app start/stop) is documented in `~/aalvz/tribu/CLAUDE.md` under "Two-Machine Dev Setup".

### Working from C2

When Claude is running on C2 and needs to work with C1:
- Repos on C1: `~/dot_files`, `~/aalvz/projects`, `~/aalvz/tribu`
- Pull from C1: `ssh alfonsoa@192.168.1.90 'cd ~/aalvz/tribu && git pull'`
- Read files on C1: `ssh alfonsoa@192.168.1.90 'cat ~/dot_files/CLAUDE.md'`
- Tribu repo on C2 is at `/home/user/Documents/tribu/` (symlinked as `/home/user/tribu`)

### 6. Verify
```bash
# Dotfiles
test -L ~/.emacs && echo "emacs: ok" || echo "emacs: MISSING"
test -L ~/.zshrc && echo "zshrc: ok" || echo "zshrc: MISSING"

# Repos
test -d ~/aalvz/projects && echo "projects: ok" || echo "projects: MISSING"
test -d ~/aalvz/tribu && echo "tribu: ok" || echo "tribu: MISSING"
test -d ~/dot_files && echo "dot_files: ok" || echo "dot_files: MISSING"

# C2
ssh -o ConnectTimeout=3 -o BatchMode=yes user@192.168.1.88 'echo "c2: ok"' 2>/dev/null || echo "c2: NOT REACHABLE"
```

## Project Repos

| Repo | C1 (Mac) path | C2 (Ubuntu) path | Purpose |
|------|---------------|-------------------|---------|
| [dot_files](https://github.com/AAlvz/dot_files) | `~/dot_files` | `~/dot_files` | Dotfiles, env bootstrap (this repo) |
| [projects](https://github.com/AAlvz/projects) | `~/aalvz/projects` | `~/projects` | Tribu static sites (Firebase hosting), marketing sites |
| [tribu](https://github.com/AAlvz/tribu) | `~/aalvz/tribu` | `~/Documents/tribu` | Tribu Slack app (Python, Cloud Run, Firestore) |

## Sync Workflow (CRITICAL)

C1 and C2 must always stay in sync via git. **Every time Claude finishes a change on either machine, it must commit and push so the other machine can pull the latest.**

The workflow:
1. Make changes on the current machine
2. `git add`, `git commit`, `git push`
3. When switching to the other machine, `git pull` first

This applies to all three repos. Never leave uncommitted work behind — the other machine should always be able to `git pull` and have the full latest state.

When starting work on a machine, always pull first:
```bash
# On C1:
cd ~/dot_files && git pull
cd ~/aalvz/projects && git pull
cd ~/aalvz/tribu && git pull

# On C2:
cd ~/dot_files && git pull
cd ~/projects && git pull
cd ~/Documents/tribu && git pull
```

## Repository structure

- `.emacs` — Main Emacs config (symlinked from `~/.emacs`)
- `.zshrc` — Zsh config for macOS (symlinked from `~/.zshrc`)
- `.emacs.d/lisp/` — Manual elisp packages (popon, subr-x, swap-windows, etc.)
- `.emacs.d/elpa/` — Auto-installed packages (not manually managed)
- `.i3/` — i3 window manager config (Linux)
- `.bashrc`, `.bash_aliases`, `.bash_profile` — Bash configs (Linux)
- `.gitconfig` — Git configuration
- `.Xresources` — X11 terminal settings (Linux)

## Emacs server & emacsclient

- `.emacs` runs `(server-start)` automatically
- `alias e='emacsclient -nw -a ""'` — opens in the terminal; `-a ""` auto-starts a background daemon if none is running
- `EDITOR`, `VISUAL`, `KUBE_EDITOR` all set to `emacsclient -a emacs` in `.zshrc`
- Use `C-x #` (`server-edit`) to finish editing when a program is waiting (kubectl edit, git commit, crontab -e, etc.)
- For normal file editing (opened manually), use Emacs as usual — no need for `C-x #`

## Cross-platform notes

- The `.emacs` file works on both macOS and Linux without OS-specific tweaks
- Clipboard: `select-enable-clipboard` handles macOS GUI and X11 natively; `xclip` package handles terminal mode on Linux (harmless on macOS)
- `exec-path-from-shell` ensures GUI Emacs inherits shell PATH on both OSes
- Codeium is commented out but kept as a ready-to-uncomment block (requires cloning the repo into `~/.emacs.d/codeium.el/`)
- LSP mode is commented out but kept as reference
- `grep-find-template` is kept as a template — update the search term as needed, already excludes node_modules, .terraform, .git

## Branches

- `master` — main config, cross-platform
- `win` — older Windows-specific variant (uses corfu instead of company, no windmove)
