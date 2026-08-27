#!/bin/zsh
# .zshrc — zsh entry point (macOS primarily).
# Everything portable lives in .shell_common, shared with .bashrc.
# Only zsh-specific setup belongs below.

[ -f "$HOME/.shell_common" ] && . "$HOME/.shell_common"

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
