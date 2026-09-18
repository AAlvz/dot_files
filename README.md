dot_files
===

Alfonso's dotfiles — Emacs, shell, git — shared across macOS, Linux and WSL.

One config, every machine: the portable shell setup lives in a single
`.shell_common` sourced by both `.zshrc` and `.bashrc`, and one `.emacs` runs
everywhere. Anything machine-specific stays in untracked local files.

Setup
===

```bash
git clone git@github.com:AAlvz/dot_files.git ~/dot_files
cd ~/dot_files && ./install.sh
```

Then open a new terminal.

`install.sh` detects the platform and links only what belongs there. It is safe
to re-run: correct symlinks are left alone, and anything real in the way is
moved to `<name>.backup.<timestamp>` rather than overwritten.

| Command | Does |
|---------|------|
| `./install.sh` | Link everything for this machine, then verify |
| `./install.sh --dry-run` | Show what would change, touch nothing |
| `./install.sh --check` | Verify an existing install, no changes |

The verify step checks that the aliases actually resolve in a fresh interactive
shell, not just that the symlinks exist — the two are not the same thing, and a
machine once ran for two weeks with every symlink but one in place and no
working aliases at all.

What gets linked
===

| | macOS | Linux desktop | WSL |
|---|:---:|:---:|:---:|
| `.shell_common`, `.emacs`, `.gitconfig`, `.emacs.d/lisp` | ✓ | ✓ | ✓ |
| `.zshrc` | ✓ | if zsh | if zsh |
| `.bashrc`, `.bash_profile`, `.bash_aliases` | if bash | ✓ | ✓ |
| `.vimrc` | — | ✓ | ✓ |
| `.Xresources`, `.i3/config` | — | ✓ | **no** |

X11 and i3 are deliberately withheld from WSL: there is no X server there, and
`.bash_profile`'s `startx` block would kill the login shell.

Layout
===

| Path | Purpose |
|------|---------|
| `install.sh` | Machine setup — start here |
| `.shell_common` | **Shared shell config, bash + zsh, all platforms.** Portable aliases and env go here |
| `.zshrc` | zsh entry point; sources `.shell_common` plus zsh-only setup |
| `.bashrc` | bash entry point; same idea |
| `.bash_profile` | Login-shell entry point — sources `.bashrc`, since a login shell reads this file *instead of* it |
| `.emacs` | Emacs config, identical on every machine |
| `.emacs.d/lisp/` | Manually vendored elisp |
| `.emacs.d/elpa/` | Auto-installed packages. Gitignored — each machine compiles its own `.elc` |
| `.gitconfig` | Git configuration |
| `.i3/`, `.Xresources` | i3 and X11, Linux desktop only |

Per-machine, untracked
===

Anything that exists on only one box — SDK paths, nvm, cargo, credentials —
goes in files that are sourced if present and never committed, so the tracked
config stays byte-identical everywhere:

| File | Sourced by |
|------|-----------|
| `~/.shell_local` | `.shell_common` (both shells) |
| `~/.bashrc.local` | `.bashrc` |
| `~/.zshrc.local` | `.zshrc` |

Adding config
===

Portable setup belongs in `.shell_common`, **not** in `.zshrc` or `.bashrc` —
those are only for genuinely shell-specific things (zsh's `bindkey`, bash
completion). Keep `.shell_common` POSIX-compatible: no bashisms, no zshisms.

See `CLAUDE.md` for the full environment notes, including the multi-machine SSH
setup and platform-specific gotchas.
