#!/bin/bash

CURRENT=$(powerprofilesctl get)
PROMPT="Select Power Profile. Current: $CURRENT"

op=$( echo -e "󰾅 Balanced\n󰾆 Powersave\n󰓅 Performance" | wofi -i --dmenu --prompt "$PROMPT" | awk '{print tolower($2)}' )

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
