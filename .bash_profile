## Login shells read this file and NOT ~/.bashrc, so pull it in explicitly.
## Everything else — PATH, aliases, .shell_common — hangs off .bashrc, so
## without this line a login shell comes up with none of it.
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

## Ask to startx, but only where X can actually start.
## Guarded because this file is shared with WSL, where startx does not exist:
## `exec startx` there fails and takes the login shell down with it, so the
## terminal comes up with no PATH, no aliases and no colors.
if [[ -z $DISPLAY && ${XDG_VTNR:-0} -le 12 ]] \
   && command -v startx >/dev/null 2>&1 \
   && [[ -z $WSL_DISTRO_NAME ]] \
   && ! grep -qi microsoft /proc/version 2>/dev/null
then
    echo "Start X? (y/n)[Default y]"
    while true; do
        read REPLY
        case $REPLY in
            [Yy]|"") exec startx ;;
            [Nn]) break ;;
            *) printf '%s\n' 'Please answer y or n.' ;;
        esac
    done
fi
