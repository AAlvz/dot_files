#!/bin/zsh
# .zshrc — zsh entry point (macOS primarily).
# Everything portable lives in .shell_common, shared with .bashrc.
# Only zsh-specific setup belongs below.

# Load the shared config. This used to be a bare `[ -f ... ] && .` guard, which
# fails silently: C1 was missing the ~/.shell_common symlink for two weeks and
# just came up with no aliases, no e, no c, and nothing to explain why. Fall
# back to the repo so a skipped symlink step is survivable, and complain if
# neither path is there rather than starting a crippled shell in silence.
for _sc in "$HOME/.shell_common" "$HOME/dot_files/.shell_common"; do
  if [ -f "$_sc" ]; then . "$_sc"; _sc_loaded=1; break; fi
done
[ -n "$_sc_loaded" ] || print -u2 "dot_files: .shell_common not found — aliases and PATH are missing"
unset _sc _sc_loaded

# Emacs-style line editing (enables Alt+., Alt+b, Alt+f, etc.)
bindkey -e
bindkey '\e.' insert-last-word

# Autosuggestions — path differs by Homebrew prefix (Apple Silicon vs Intel)
# and by distro, so probe the known locations instead of hardcoding one.
for _zsh_autosuggest in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [ -f "$_zsh_autosuggest" ] && . "$_zsh_autosuggest" && break
done
unset _zsh_autosuggest

# Machine-specific zsh settings, untracked.
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
