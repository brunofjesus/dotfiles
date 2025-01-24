#!/bin/bash

OPTIONS="󰾅 Balanced\n󰾆 Powersave\n󰓅 Performance"
CURRENT=$(powerprofilesctl get)
PROMPT="Select Power Profile ($CURRENT):"
RUNNER="wofi -i --dmenu"

if tty -s; then
    RUNNER="fzf"
fi

op=$( echo -e "$OPTIONS" | $RUNNER --prompt "$PROMPT" | awk '{print tolower($2)}' )

case $op in 
        balanced)
                powerprofilesctl set balanced
                ;;
        powersave)
                powerprofilesctl set powersave
                ;;
        performance)
                powerprofilesctl set performance
                ;;
esac
