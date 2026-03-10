#!/usr/bin/env bash

# Check if running in a terminal, if not launch Kitty
if [ ! -t 0 ]; then
    # Not in terminal - launch Kitty
    if command -v kitty >/dev/null 2>&1; then
        kitty --class "floating_kitty" --override remember_window_size=no --override initial_window_width=700 --override initial_window_height=300 -e bash -c "$0; echo; read -p 'Press Enter to exit...'"
        exit 0
    else
        # Kitty not found, show notification
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Error" "Kitty terminal not found. Please install kitty to run this script."
        fi
        exit 1
    fi
fi

RESET="\033[0m"
GREEN_BG="\033[42m"
ORANGE_BG="\033[48;5;208m"
RED_BG="\033[41m"
BLACK_TXT="\033[30m"
WHITE_TXT="\033[97m"

WIDTH=8
GAP="  "   # spacing between left and right groups

green()  { printf "${GREEN_BG}${BLACK_TXT} %-*s ${RESET}" "$WIDTH" "$1"; }
orange() { printf "${ORANGE_BG}${BLACK_TXT} %-*s ${RESET}" "$WIDTH" "$1"; }
red() { printf "${RED_BG}${BLACK_TXT} %-*s ${RESET}" "$WIDTH" "$1"; }

echo

# Row 1 padding
printf "   "
green "" ; green ""; orange ""
printf "$GAP"
orange "" ; green ""; green ""
printf "\n"

# Row 2 titles
printf "1  "
green "USB4" ; green "Display"; orange "USB-A"
printf "$GAP"
orange "USB-A"; green "Display" ; green "USB4"
printf "  3\n"

# Row 3 subtitles
printf "   "
green "Charging" ; green ""; orange "";
printf "$GAP"
orange ""; green "" ; green "Charging"
printf "\n"

# Row 4 padding
printf "   "
green "" ; green ""; orange ""
printf "$GAP"
orange ""; green "" ; green ""
printf "\n\n"


# Second row (ports 2–4)

# Row 1 padding
printf "   "
green "" ; red ""; green "";
printf "$GAP"
green "" ; green ""; green "";
printf "\n"

# Row 2 titles
printf "2  "
green "USB 3.2" ; red "Display"; green "USB-A"
printf "$GAP"
green "USB-A"; green "Display" ; green "USB 3.2"
printf "  4\n"

# Row 3 subtitles
printf "   "
green "Charging" ; red ""; green ""
printf "$GAP"
green ""; green "" ; green "Charging"
printf "\n"

# Row 4 padding
printf "   "
green "" ; red ""; green "";
printf "$GAP"
green ""; green "" ; green ""
printf "\n\n"


printf "                     ${ORANGE_BG}${BLACK_TXT}  Higher power consumption  ${RESET}\n\n"
