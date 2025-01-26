#!/bin/bash

# Config file for storing history
CONFIG_DIR="$HOME/.config/networkmount"
IP_HISTORY="$CONFIG_DIR/ip_history"
SHARE_HISTORY="$CONFIG_DIR/share_history"

# Create config directory and history files if they don't exist
mkdir -p "$CONFIG_DIR"
touch "$IP_HISTORY" "$SHARE_HISTORY"

# Function to prompt user with wofi/fzf
prompt_user() {
    local title="$1"
    local history_file="$2"
    local allow_new="$3"
    
    # Prepare menu items
    local menu_items=""
    if [[ -s "$history_file" ]]; then
        menu_items=$(cat "$history_file")
    fi
    
    if [[ "$allow_new" == "true" ]]; then
        menu_items=$(echo -e "[ New Entry ]\n$menu_items")
    fi
    
    # Choose between fzf and wofi
    if tty -s; then
        choice=$(echo -e "$menu_items" | fzf --reverse --prompt="$title > ")
    else
        choice=$(echo -e "$menu_items" | wofi -i --dmenu --prompt="$title")
    fi
    
    # Handle new entry
    if [[ "$choice" == "[ New Entry ]" ]]; then
        if tty -s; then
            read -p "Enter $title: " choice
        else
            choice=$(wofi -i --dmenu --prompt="Enter $title")
        fi
    fi
    
    # Add to history if it's a new entry
    if [[ -n "$choice" && "$choice" != "[ New Entry ]" ]]; then
        echo "$choice" | cat - "$history_file" | awk '!seen[$0]++' | head -n 10 > temp && mv temp "$history_file"
    fi
    
    echo "$choice"
}

# Get IP address
IP_ADDRESS=$(prompt_user "IP Address" "$IP_HISTORY" "true")
[[ -z "$IP_ADDRESS" ]] && exit 1

# Get share name
SHARE_NAME=$(prompt_user "Share Name" "$SHARE_HISTORY" "true")
[[ -z "$SHARE_NAME" ]] && exit 1
MOUNT_PATH="$HOME/network"
USERNAME=${4:-$USER}  # Use 4th parameter if provided, otherwise use system username

# Create mount directory if it doesn't exist
mkdir -p "$MOUNT_PATH/$SHARE_NAME"

sudo mount -t cifs //$IP_ADDRESS/$SHARE_NAME \
  "$MOUNT_PATH/$SHARE_NAME" \
  -o rw,username=$USERNAME,uid=$UID,file_mode=0777,dir_mode=0777,gid=$GROUPS
