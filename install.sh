#!/usr/bin/env bash
#
# install.sh — link this repo's dotfiles into $HOME on a fresh machine.
#
#   ./install.sh              link everything appropriate for this machine
#   ./install.sh --dry-run    show what would happen, touch nothing
#   ./install.sh --check      only verify an existing install
#
# Safe to re-run: an already-correct symlink is left alone, and anything real
# sitting in the way is moved to <name>.backup.<timestamp> rather than deleted.
#
# The repo location is derived from this script, not hardcoded, so it works
# wherever the repo is cloned.

set -euo pipefail

# Running this as `sh install.sh` would silently lose BASH_SOURCE and break the
# repo-path detection below, so fail loudly instead.
if [ -z "${BASH_VERSION:-}" ]; then
  echo "install.sh needs bash — run './install.sh' or 'bash install.sh'" >&2
  exit 1
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
CHECK_ONLY=0
LINKED=0 SKIPPED=0 BACKED_UP=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --check)   CHECK_ONLY=1 ;;
    -h|--help) sed -n '3,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

# ------------------------------------------------------------------ platform --
case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  if grep -qi microsoft /proc/version 2>/dev/null; then OS=wsl; else OS=linux; fi ;;
  *)      OS=unknown ;;
esac

# Colour only when writing to a terminal, so piping this into a log or a CI
# job produces clean text instead of escape codes.
if [ -t 1 ]; then
  C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_BAD=$'\033[31m'; C_OFF=$'\033[0m'
else
  C_OK=''; C_WARN=''; C_BAD=''; C_OFF=''
fi

say()  { printf '%s\n' "$*"; }
ok()   { printf '  %s✓%s %s\n' "$C_OK"   "$C_OFF" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_WARN" "$C_OFF" "$*"; }
bad()  { printf '  %s✗%s %s\n' "$C_BAD"  "$C_OFF" "$*"; }

# link <repo-relative-source> <name-in-home>
link() {
  local src="$REPO/$1" dest="$HOME/$2"

  if [ ! -e "$src" ]; then
    warn "$2 — not in repo, skipping"
    return 0
  fi

  # Already pointing where we want it: nothing to do.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    ok "$2 (already linked)"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [ $DRY_RUN -eq 1 ]; then
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      say "  would back up $2 -> $2.backup.$STAMP, then link"
    else
      say "  would link $2 -> $src"
    fi
    return 0
  fi

  # Something real is in the way — never clobber it, move it aside.
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.backup.$STAMP"
    warn "$2 — existing file saved as $2.backup.$STAMP"
    BACKED_UP=$((BACKED_UP + 1))
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  ok "$2"
  LINKED=$((LINKED + 1))
}

# -------------------------------------------------------------------- verify --
verify() {
  local fail=0
  say ""
  say "Verifying:"

  for f in .shell_common .emacs .gitconfig; do
    if [ -L "$HOME/$f" ]; then ok "$f linked"; else bad "$f MISSING"; fail=1; fi
  done

  # Only require the rc files this machine actually boots from. bash exists on
  # macOS too, so keying this off "is bash installed" would fail every Mac —
  # C1 drives everything from zsh and has no need of .bashrc at all.
  local required_rc=""
  case "$OS" in
    macos)      required_rc=".zshrc" ;;
    linux|wsl)  required_rc=".bashrc .bash_profile" ;;
  esac

  for f in $required_rc; do
    if [ -L "$HOME/$f" ]; then ok "$f linked"; else bad "$f MISSING"; fail=1; fi
  done

  # Anything linked beyond that is a bonus, not a requirement.
  for f in .zshrc .bashrc .bash_profile; do
    case " $required_rc " in *" $f "*) continue ;; esac
    [ -L "$HOME/$f" ] && ok "$f linked (optional here)"
  done

  # The real test: do the aliases actually resolve in a fresh interactive
  # shell? Every symlink can be correct while the shared config still fails to
  # load — that exact combination went unnoticed on C1 for two weeks.
  local probe="for a in e c k ll; do command -v \$a >/dev/null 2>&1 || echo \"MISSING:\$a\"; done"
  local missing=""
  if [ -n "${ZSH_VERSION:-}" ] || command -v zsh >/dev/null 2>&1; then
    missing="$(zsh -ic "$probe" 2>/dev/null </dev/null | grep '^MISSING:' || true)"
  else
    missing="$(bash -ic "$probe" 2>/dev/null </dev/null | grep '^MISSING:' || true)"
  fi

  if [ -z "$missing" ]; then
    ok "aliases resolve (e, c, k, ll)"
  else
    bad "aliases not resolving: $(echo "$missing" | sed 's/MISSING://' | tr '\n' ' ')"
    fail=1
  fi

  say ""
  if [ $fail -eq 0 ]; then
    say "All good. Open a new terminal to pick everything up."
  else
    say "Some checks failed — see above."
    return 1
  fi
}

# ---------------------------------------------------------------------- main --
say "dot_files installer"
say "  repo: $REPO"
say "  os:   $OS"
[ $DRY_RUN -eq 1 ] && say "  mode: dry run (nothing will change)"
say ""

if [ $CHECK_ONLY -eq 1 ]; then
  verify
  exit $?
fi

say "Shared (every machine):"
link .shell_common .shell_common
link .emacs        .emacs
link .gitconfig    .gitconfig

# Emacs' manual elisp. Only lisp/ is linked — .emacs.d/elpa is machine-local
# and gitignored, since each machine compiles its own .elc.
link .emacs.d/lisp .emacs.d/lisp

# Link the rc files for whichever shells exist, rather than guessing from the
# OS: a Linux box may run zsh, and a Mac may be driven from bash. Each rc only
# ever loads in its own shell, so linking both is harmless.
if command -v zsh >/dev/null 2>&1; then
  say ""
  say "zsh:"
  link .zshrc .zshrc
fi

if command -v bash >/dev/null 2>&1; then
  say ""
  say "bash:"
  # .bash_profile matters more than it looks: a login shell reads it *instead
  # of* .bashrc, so without it the shell starts with no aliases and no PATH.
  link .bashrc       .bashrc
  link .bash_profile .bash_profile
  link .bash_aliases .bash_aliases
fi

if [ "$OS" = linux ] || [ "$OS" = wsl ]; then
  say ""
  say "Linux:"
  link .vimrc .vimrc
fi

# X11 and i3 are desktop-only. WSL has no X server, and linking these there
# is what broke C3: .bash_profile's startx block killed the login shell.
if [ "$OS" = linux ]; then
  say ""
  say "Linux desktop (X11 + i3):"
  link .Xresources .Xresources
  link .i3/config  .i3/config
fi

say ""
say "Summary: $LINKED linked, $SKIPPED already correct, $BACKED_UP backed up"

if [ $DRY_RUN -eq 1 ]; then
  say ""
  say "Dry run — nothing changed. Re-run without --dry-run to apply."
  exit 0
fi

verify
