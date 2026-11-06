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

# Unset CLAUDE_CODE_CHILD_SESSION so interactive `claude` sessions save transcripts.
# Claude Code sets this var when spawning subagents; if a new terminal inherits it,
# Claude treats the session as a child and skips writing transcripts to ~/.claude/sessions/.
alias claude='env -u CLAUDE_CODE_CHILD_SESSION claude'

# Machine-specific zsh settings, untracked.
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
export PATH="$HOME/.local/bin:$PATH"

# k9s shells out to the first `kubectl` in PATH for shell/attach/port-forward.
# The dockerbox kubectl (added by ~/.dev_environment/bash_functions) breaks on --context/-it, so force the system one.
alias k9s='PATH=/usr/local/bin:$PATH k9s'
