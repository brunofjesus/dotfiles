#!/bin/bash

declare -A timezones=(
    ["🇵🇹 Lisbon"]="Europe/Lisbon"
    ["🇺🇸 New York"]="America/New_York"
    ["🇯🇵 Tokyo"]="Asia/Tokyo"
)

declare -A colors=(
    ["🇵🇹 Lisbon"]="\033[1;32m"
    ["🇺🇸 New York"]="\033[1;33m"
    ["🇯🇵 Tokyo"]="\033[1;31m"
)

# Generate time strings
output=""
table_data=""

for location in "${!timezones[@]}"; do
    timezone="${timezones[$location]}"
    time_str=$(TZ="$timezone" date '+%Y-%m-%d %H:%M')
    
    # For wofi output
    output+="$location: $time_str\n"
    
    # For terminal table output (tab-separated for column command)
    table_data+="$location\t$time_str\n"
done

# Check if running in a terminal or desktop environment with wofi
if ! tty -s && [[ -n "$DISPLAY" ]] && command -v wofi &> /dev/null; then
    # Use wofi for desktop display (when not in terminal)
    printf "$output" | \
        wofi --dmenu --prompt "World Times" --width 400 --height 200 --cache-file /dev/null
else
    # Terminal display with table formatting and colors
    echo -e "\033[1;34m🌍 World Times\033[0m"
    
    # First create aligned table, then apply colors line by line
    aligned_output=$(printf "$table_data" | column -t -s $'\t')
    
    while IFS= read -r line; do
        for location in "${!colors[@]}"; do
            if [[ "$line" == "$location"* ]]; then
                color="${colors[$location]}"
                echo -e "${color}${line}\033[0m"
                break
            fi
        done
    done <<< "$aligned_output"
fi
