# dot_files

Alfonso's dotfiles repo. Shared across multiple computers (macOS and Linux).

## Repository structure

- `.emacs` — Main Emacs config (symlinked from `~/.emacs`)
- `.zshrc` — Zsh config for macOS (symlinked from `~/.zshrc`)
- `.emacs.d/lisp/` — Manual elisp packages (popon, subr-x, swap-windows, etc.)
- `.emacs.d/elpa/` — Auto-installed packages (not manually managed)
- `.i3/` — i3 window manager config (Linux)
- `.bashrc`, `.bash_aliases`, `.bash_profile` — Bash configs (Linux)
- `.gitconfig` — Git configuration
- `.Xresources` — X11 terminal settings (Linux)

## Setup on a new machine

1. Clone the repo: `git clone git@github.com:AAlvz/dot_files.git ~/dot_files`
2. Symlink `.emacs`: `ln -s ~/dot_files/.emacs ~/.emacs`
3. Symlink `.zshrc` (macOS): `ln -s ~/dot_files/.zshrc ~/.zshrc`
4. Ensure `~/.emacs.d/lisp/` has required files (popon.el, subr-x.el, swap-windows.el) — copy from `dot_files/.emacs.d/lisp/` or symlink the directory
5. Start Emacs — packages auto-install on first run

## Emacs server & emacsclient

- `.emacs` runs `(server-start)` automatically
- `alias e='emacsclient -c -a emacs'` — opens a new frame in the running Emacs, falls back to launching Emacs if no server
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
