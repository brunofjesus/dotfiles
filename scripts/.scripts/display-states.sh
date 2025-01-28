#!/bin/bash

# Directory to store display states
STATE_DIR="$HOME/.config/display_states"
mkdir -p "$STATE_DIR"

# Get the display state filename
get_state_file() {
    echo "$STATE_DIR/$1.json"
}

# Store the current display state
store_state() {
    state_name=$(wofi --show dmenu --prompt "Enter a name for the display profile:")
    [ -z "$state_name" ] && exit 0
    state_file=$(get_state_file "$state_name")
    swaymsg -t get_outputs > "$state_file"
    notify-send "Display Profile Saved" "Display state saved as '$state_name'."
}

# Apply a saved display state
apply_state() {
    state_name=$(ls "$STATE_DIR" | sed 's/.json$//' | wofi --show dmenu --prompt "Select a display profile to apply:")
    [ -z "$state_name" ] && exit 0
    state_file=$(get_state_file "$state_name")
    jq -r '.[] | if .current_mode == null then "output \(.name) disable" else "output \(.name) mode \(.current_mode.width)x\(.current_mode.height) position \(.rect.x) \(.rect.y) enable" end' "$state_file" | while read cmd; do
        echo "Applying: $cmd"
        swaymsg "$cmd"
    done
    notify-send "Display Profile Applied" "Display state '$state_name' applied successfully."
}

# Delete a saved display state
delete_state() {
    state_name=$(ls "$STATE_DIR" | sed 's/.json$//' | wofi --show dmenu --prompt "Select a display profile to delete:")
    [ -z "$state_name" ] && exit 0
    state_file=$(get_state_file "$state_name")
    rm -f "$state_file"
    notify-send "Display Profile Deleted" "Display state '$state_name' deleted successfully."
}

mirror_display() {
    connected_outputs=$(wlr-randr --json | jq -r '.[] | select(.enabled) | .name')
    wofi --show dmenu --prompt "Select an output to mirror:" < <(echo "$connected_outputs") | while read output; do
      wl-mirror "$output"
    done
}

# Main menu
main_menu() {
    choice=$(printf "🪞 Mirror Display\n💾 Store Layout\n✅ Apply Layout\n🗑️ Delete Layout\n🚪 Exit" | wofi --show dmenu --prompt "Choose an action:" |  awk '{print tolower($2)}')
    case $choice in
        mirror) mirror_display ;;
        store) store_state ;;
        apply) apply_state ;;
        delete) delete_state ;;
        *) exit 0 ;;
    esac
}

# Run the main menu
main_menu
