#!/usr/bin/env bash

options=" Poweroff\n Reboot\n Suspend\n Lock\n Logout"
runner="wofi -i --dmenu"

if tty -s; then
    runner="fzf"
fi

op=$( echo -e "$options" | $runner | awk '{print tolower($2)}' )


case $op in 
        poweroff)
                ;&
        reboot)
                ;&
        suspend)
                systemctl $op
                ;;
        lock)
		            swaylock -f -c000000 
                ;;
        logout)
                swaymsg exit
                ;;
esac
