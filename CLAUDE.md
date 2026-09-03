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
# Every machine (.shell_common is the shared shell config — link it first)
ln -sf ~/dot_files/.shell_common ~/.shell_common
ln -sf ~/dot_files/.emacs ~/.emacs
ln -sf ~/dot_files/.gitconfig ~/.gitconfig

# macOS (zsh)
ln -sf ~/dot_files/.zshrc ~/.zshrc

# Linux / WSL (bash)
ln -sf ~/dot_files/.bashrc ~/.bashrc
ln -sf ~/dot_files/.bash_aliases ~/.bash_aliases
ln -sf ~/dot_files/.bash_profile ~/.bash_profile
ln -sf ~/dot_files/.vimrc ~/.vimrc

# Linux desktop only (not WSL)
ln -sf ~/dot_files/.Xresources ~/.Xresources
mkdir -p ~/.i3 && ln -sf ~/dot_files/.i3/config ~/.i3/config
```

**One config, every machine.** `.shell_common` holds all shared shell setup —
aliases, `EDITOR`, PATH, kubectl helpers — and is sourced by both `.zshrc` and
`.bashrc`, so macOS/zsh and Linux/WSL/bash behave identically. Do not add
portable config to `.zshrc` or `.bashrc`; it belongs in `.shell_common`.

Anything that exists on only one machine (SDK paths, nvm, cargo, credentials)
goes in untracked per-machine files, which `.shell_common` and the rc files
source if present:

| File | Sourced by | Purpose |
|------|-----------|---------|
| `~/.shell_local` | `.shell_common` (both shells) | Machine-specific, shell-agnostic |
| `~/.bashrc.local` | `.bashrc` | Machine-specific bash only |
| `~/.zshrc.local` | `.zshrc` | Machine-specific zsh only |

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

### 5. Connect to the other computers
C2 is the Ubuntu XPS 13 used to run the Tribu app. C3 is WSL2 on an ASUS Windows laptop. Connection details:

| Machine | Role | IP | User | SSH key comment |
|---------|------|----|------|-----------------|
| C1 (Mac) | Editing, git, Claude Code | 192.168.1.78 | alfonsoa | mac2 |
| C2 (Ubuntu XPS 13) | Running Tribu app, dev server | 192.168.1.88 | user | alfonso |
| C3 (`LAPTOP-MCEGUI5B`) | WSL2 Ubuntu-20.04 under Windows Terminal; local editing | 192.168.1.80 (also .81 — mirrored, shared with Windows host) | user | alfonso@tinkerware.io |

C3 is WSL2 (Ubuntu 20.04.6, kernel `*-microsoft-standard-WSL2`) on an ASUS
Windows laptop, running in **mirrored networking** mode. The WSL2 guest shares
the Windows host's LAN addresses instead of sitting behind its own NAT — it
answers on both `192.168.1.80` and `192.168.1.81`.

**Both directions work with keys** (verified 2026-09-02 with a full
C1 → C3 → C1 round trip, no password prompts):

```bash
ssh user@192.168.1.80          # C1 → C3   (C3 authorizes C1's `mac2` key)
ssh alfonsoa@192.168.1.78      # C3 → C1   (C1 authorizes C3's `alfonso@tinkerware.io` key)
```

Getting the inbound direction (C1 → C3) working took three separate layers on
C3, and all three are required — enabling mirrored networking alone is not
enough, since it opens *outbound* only:

1. sshd inside WSL — `sudo apt install -y openssh-server && sudo service ssh start`
2. A Windows Firewall rule — `New-NetFirewallRule -DisplayName "WSL SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow`
3. The Hyper-V firewall, which mirrored mode adds on top — `Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultInboundAction Allow`

**Debugging tip:** while any layer is still closed, `192.168.1.80` answers ARP
but drops every SYN — the host looks alive at layer 2 while every port reads as
filtered. A packet capture on C1 (`sudo tcpdump -i en0 -n 'tcp port 22'`) tells
the two cases apart: SYNs with no SYN-ACK means filtered, not down.

C3 runs **bash**, not zsh — zsh is not installed there.

Both directions between C1 and C2 have key-based SSH auth configured. IPs may change if DHCP reassigns — check with `hostname -I` (Linux) or `ipconfig getifaddr en0` (macOS).

**From C1 (Mac) → C2:**
```bash
ssh-keyscan -t ed25519 192.168.1.88 >> ~/.ssh/known_hosts 2>/dev/null
ssh user@192.168.1.88 'hostname && uname -a'
# If auth fails: ssh-copy-id -i ~/.ssh/id_ed25519.pub user@192.168.1.88
```

**From C2 (Ubuntu) → C1:**
```bash
ssh-keyscan -t ed25519 192.168.1.78 >> ~/.ssh/known_hosts 2>/dev/null
ssh alfonsoa@192.168.1.78 'hostname && uname -a'
# If auth fails: ssh-copy-id -i ~/.ssh/id_ed25519.pub alfonsoa@192.168.1.78
# macOS must have Remote Login enabled (System Settings → General → Sharing → Remote Login)
```

**C1 (Mac) ↔ C3 (WSL2):** both directions are set up with keys.
```bash
ssh user@192.168.1.80 'hostname'        # from C1
ssh alfonsoa@192.168.1.78 'hostname'    # from C3
```

To redo it on a fresh WSL install (or after an IP change), run **on C3**:
```bash
test -f ~/.ssh/id_ed25519 || ssh-keygen -t ed25519 -C "c3" -N "" -f ~/.ssh/id_ed25519
ssh-copy-id -i ~/.ssh/id_ed25519.pub alfonsoa@192.168.1.78   # C3 → C1
```
and **on C1**, for the reverse:
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@192.168.1.80       # C1 → C3
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
- `.shell_common` — **Shared shell config for bash and zsh, all platforms.** Portable aliases/env go here
- `.zshrc` — Zsh entry point (macOS); sources `.shell_common`, plus zsh-only setup
- `.emacs.d/lisp/` — Manual elisp packages (popon, subr-x, swap-windows, etc.)
- `.emacs.d/elpa/` — Auto-installed packages. **Gitignored, not shared.** Each
  machine compiles its own `.elc` against its own Emacs version, so shipping one
  machine's `elpa` to another only causes version skew. Packages come from
  `package-selected-packages` in `.emacs`, which every machine installs itself.
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
- Only the first Emacs to start wins the server socket; other `emacs -nw` instances are unreachable by `emacsclient`

## vterm scrollback

Scrolling back through vterm history was broken by seven stacked faults and took
several rounds to fix. Before touching the vterm or mouse blocks in `.emacs`,
read [docs/vterm-scrollback.md](docs/vterm-scrollback.md) — it records the
causes, the dead ends already ruled out, and what is still open.

Two things from it that bite immediately:

- Claude Code's own conversation is scrollable only because `.shell_common` exports
  `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`. A `claude` started from a shell without it
  draws on the alternate screen and leaves no scrollback at all.
- `M-:` does not work inside a vterm (it types into the running program). Use `M-x`.
- Never plain-`setq` a permanently buffer-local variable in `.emacs` — reloading
  the file from inside a vterm then clobbers that buffer. Use `setq-default`.

## Cross-platform notes

- The `.emacs` file works on both macOS and Linux without OS-specific tweaks
- **Terminal keybindings:** text terminals cannot encode chords like `C-<return>` or `C-<` —
  they arrive as plain `RET`, or as nothing. `.emacs` decodes xterm `modifyOtherKeys`
  sequences (`ESC [ 27 ; mod ; code ~`) back into real key events via `my/tty-key-sequences`
  and `tty-setup-hook`. The block is inert on terminals that never send those sequences, so
  it stays cross-platform. The *emitting* side is configured in the terminal emulator, not in
  this repo — on Windows Terminal, `sendInput` actions in its `settings.json`
  (`User.sendInput.ctrlEnter`, `User.sendInput.ctrlShiftComma`). Every such chord also has a
  terminal-safe fallback (`C-c C-p`, `C-c TAB`) that works with no terminal config at all.
  Note `M-TAB` can never reach Emacs on Windows: the OS claims Alt+Tab first
- Clipboard: `select-enable-clipboard` handles macOS GUI and X11 natively; `xclip` package handles terminal mode on Linux (harmless on macOS)
- `exec-path-from-shell` ensures GUI Emacs inherits shell PATH on both OSes
- Codeium is commented out but kept as a ready-to-uncomment block (requires cloning the repo into `~/.emacs.d/codeium.el/`)
- LSP mode is commented out but kept as reference
- `grep-find-template` is kept as a template — update the search term as needed, already excludes node_modules, .terraform, .git

## Branches

- `master` — the only branch. One config for every machine: platform differences
  are handled by conditionals inside `.emacs` (`my/wsl-p`, `tty-setup-hook`,
  `xclip`), never by forking the file.
- `archive/win` (tag, not a branch) — the old Windows-only variant that used
  corfu instead of company and had no windmove. Deleted as a branch once master
  went cross-platform; `git show archive/win` still reaches it.
