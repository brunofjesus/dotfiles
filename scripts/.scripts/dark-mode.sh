#!/bin/bash

# Set the theme
set_theme() {
    case $1 in
        "dark")
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 
            gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue-dark' 
            $HOME/.config/waybar/set-theme.sh 'frappe'
            $HOME/.config/sway/set-theme.sh 'frappe'
            $HOME/.config/wofi/set-theme.sh 'frappe'
            $HOME/.config/zathura/set-theme.sh 'frappe'
            $HOME/.config/newsboat/set-theme.sh 'frappe'
            $HOME/.config/fzf/set-theme.sh 'frappe'
            $HOME/.config/lsd/set-theme.sh 'frappe'
            $HOME/.config/bat/set-theme.sh 'frappe'
            $HOME/.config/lazygit/set-theme.sh 'frappe'
            $HOME/.config/foot/set-theme.sh 'frappe'
            $HOME/.config/nvim/set-theme.sh 'dark'
            ;;
        "light")
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 
            gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue' 
            $HOME/.config/waybar/set-theme.sh 'latte'
            $HOME/.config/sway/set-theme.sh 'latte'
            $HOME/.config/wofi/set-theme.sh 'latte'
            $HOME/.config/zathura/set-theme.sh 'latte'
            $HOME/.config/newsboat/set-theme.sh 'latte'
            $HOME/.config/fzf/set-theme.sh 'latte'
            $HOME/.config/lsd/set-theme.sh 'latte'
            $HOME/.config/bat/set-theme.sh 'latte'
            $HOME/.config/lazygit/set-theme.sh 'latte'
            $HOME/.config/foot/set-theme.sh 'latte'
            $HOME/.config/nvim/set-theme.sh 'light'
            ;;
    esac
}

# Create menu options
options="🌒 Dark Mode\n🔆 Light Mode"

# Check if running from terminal
if tty -s; then
    # Use fzf if in terminal
    choice=$(echo -e "$options" | fzf --reverse | awk '{print tolower($2)}')
else
    # Use wofi if not in terminal
    choice=$(echo -e "$options" | wofi -i --dmenu | awk '{print tolower($2)}')
fi

# Apply the selected theme
[[ -n "$choice" ]] && set_theme "$choice"
