#!/bin/bash

# Check if minimum required parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <ip_address> <share_name> [username]"
    echo "Example: $0 shared_folder 172.30.1.10"
    echo "Example with username: $0 shared_folder 172.30.1.10 john"
    exit 1
fi

IP_ADDRESS=$1
SHARE_NAME=$2
MOUNT_PATH="$HOME/network"
USERNAME=${4:-$USER}  # Use 4th parameter if provided, otherwise use system username

# Create mount directory if it doesn't exist
mkdir -p "$MOUNT_PATH/$SHARE_NAME"

sudo mount -t cifs //$IP_ADDRESS/$SHARE_NAME \
  "$MOUNT_PATH/$SHARE_NAME" \
  -o rw,username=$USERNAME,uid=$UID,file_mode=0777,dir_mode=0777,gid=$GROUPS
