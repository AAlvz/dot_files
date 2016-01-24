##Ask to startx
if [[ -z $DISPLAY && $XDG_VTNR -le 12 ]];
then
    echo "Start X? (y/n)[Default y]"
    while true; do
        read REPLY
        case $REPLY in
            [Yy]|"") exec startx ;;
            [Nn]) break ;;
            *) printf '%s /n' 'Please answer y or n.' ;;
        esac
    done
fi
