#!/bin/bash

# Function to get current theme
get_current_theme() {
    current=$(gsettings get org.gnome.desktop.interface color-scheme)
    if [[ $current == "'prefer-dark'" ]]; then
        echo "Current:🌒 Dark Mode"
    else
        echo "Current:🔆 Light Mode"
    fi
}

# Set the theme
set_theme() {
    case $1 in
        "dark")
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
            ;;
        "light")
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
            ;;
    esac
}

# Show current theme
current_theme=$(get_current_theme)

# Create menu options
options="🌒 Dark Mode\n🔆 Light Mode"

# Check if running from terminal
if tty -s; then
    # Use fzf if in terminal
    choice=$(echo -e "$current_theme\n$options" | fzf --reverse | awk '{print tolower($2)}')
else
    # Use wofi if not in terminal
    choice=$(echo -e "$current_theme\n$options" | wofi -i --dmenu | awk '{print tolower($2)}')
fi

# Apply the selected theme
[[ -n "$choice" ]] && set_theme "$choice"
