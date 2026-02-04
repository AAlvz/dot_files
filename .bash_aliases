alias ll='ls -lah --color=auto'
alias l='ls -CF'
alias emacs='emacs -nw'
alias grep='grep --color=auto'
cdd() { cd "$@" && ls -la; pwd > ~/.pwd; }
alias battery='acpi'
alias playmusic='mpg123'

# Copy PRIMARY selection to CLIPBOARD (highlight in terminal → clip → Ctrl+V anywhere)
alias clip='xclip -o | xclip -sel clip && echo "Copied to clipboard"'
