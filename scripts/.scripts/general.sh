#!/bin/bash

script_dir=$HOME/.scripts/
echo "Script directory: $script_dir"

# List all scripts in the script's directory, excluding general.sh
options=$(find "$script_dir" -maxdepth 1 -type f -name "*.sh" ! -name "general.sh" -printf "%f\n" | \
    sed 's/\.sh$//' | \
    sed 's/-/ /g')

runner="wofi -i --dmenu"
if tty -s; then
    runner="fzf"
fi


# Get the selected option and convert spaces back to hyphens
selected=$( printf '%s\n' "$options" | $runner )
if [ -n "$selected" ]; then
    # Convert spaces back to hyphens and add .sh extension
    script_name=$(echo "$selected" | sed 's/ /-/g').sh
    script_path="$script_dir/$script_name"
    
    # Check if script exists and execute it
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Script not found: $script_path"
        exit 1
    fi
fi
