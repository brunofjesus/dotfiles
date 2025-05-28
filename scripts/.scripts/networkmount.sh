#!/bin/bash

# Config file for storing history
CONFIG_DIR="$HOME/.config/networkmount"
IP_HISTORY="$CONFIG_DIR/ip_history"
USERNAME_HISTORY="$CONFIG_DIR/username_history"

# Create config directory and history files if they don't exist
mkdir -p "$CONFIG_DIR"
touch "$IP_HISTORY" "$USERNAME_HISTORY"

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

# Get username
USERNAME=$(prompt_user "Username" "$USERNAME_HISTORY" "true")
[[ -z "$USERNAME" ]] && exit 1
MOUNT_PATH="$HOME/network"

# Get password (GUI or terminal)
if tty -s; then
    read -s -p "Enter password for $USERNAME: " PASSWD
    echo  # Add newline after password input
else
    PASSWD=$(echo "" | wofi --dmenu --password --prompt="Enter network share password for $USERNAME" -L 1 --hide-scroll)
fi

SHARES=$(smbclient -L $IP_ADDRESS --password=$PASSWD | awk '{ print $1 }' | tail -n +5)

# Choose between fzf and wofi
if tty -s; then
    SHARE_NAME=$(echo -e "$SHARES" | fzf --reverse --prompt="Share Name > ")
else
    SHARE_NAME=$(echo -e "$SHARES" | wofi -i --dmenu --prompt="Share Name > ")
fi
[[ -z "$SHARE_NAME" ]] && exit 1

# Create mount directory if it doesn't exist
mkdir -p "$MOUNT_PATH/$SHARE_NAME"

# Create a temporary credentials file
CREDS_FILE=$(mktemp)
chmod 600 "$CREDS_FILE"
echo "username=$USERNAME" > "$CREDS_FILE"
echo "password=$PASSWD" >> "$CREDS_FILE"

# Mount using credentials file
pkexec mount -t cifs //$IP_ADDRESS/$SHARE_NAME \
  "$MOUNT_PATH/$SHARE_NAME" \
  -o rw,uid=$UID,file_mode=0777,dir_mode=0777,credentials="$CREDS_FILE"

# Clean up credentials file
shred -u "$CREDS_FILE"
