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
choose_state() {
    state_name=$(ls "$STATE_DIR" | sed 's/.json$//' | wofi --show dmenu --prompt "Select a display profile to apply:")
    [ -z "$state_name" ] && return 1
    apply_state "$state_name"
}

apply_state() {
    state_name="$1"
    [ -z "$state_name" ] && exit 0
    state_file=$(get_state_file "$state_name")

    # Get currently connected outputs for matching by make/model/serial
    current_outputs=$(swaymsg -t get_outputs)

    # Disconnect all currently enabled displays first
    echo "Disconnecting all current displays..."
    echo "$current_outputs" | jq -r '
        .[]
        | select(.active)
        | "output \(.name) disable"
    ' | while read cmd; do
        echo "Disabling: $cmd"
        swaymsg "$cmd"
    done

    # Apply the new display configuration, resolving port names by make/model/serial
    jq -r --argjson current "$current_outputs" '
        .[] | . as $saved |
        # Find the current port name matching this monitor by make/model/serial
        ($current[] | select(
            .make == $saved.make and
            .model == $saved.model and
            .serial == $saved.serial
        ) | .name) // $saved.name
        | . as $resolved_name |
        if $saved.current_mode == null then
            "output \($resolved_name) disable"
        else
            "output \($resolved_name) mode \($saved.current_mode.width)x\($saved.current_mode.height) position \($saved.rect.x) \($saved.rect.y) scale \($saved.scale // 1.0) enable"
        end
    ' "$state_file" | while read cmd; do
        echo "Applying: $cmd"
        swaymsg "$cmd"
    done
    makoctl reload
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
    choice=$(printf "🪞 Mirror Display\n💾 Store Layout\n✅ Choose Layout\n🗑️ Delete Layout\n🚪 Exit" | wofi --show dmenu --prompt "Choose an action:" |  awk '{print tolower($2)}')
    case $choice in
        mirror) mirror_display ;;
        store) store_state ;;
        choose) choose_state ;;
        delete) delete_state ;;
        *) exit 0 ;;
    esac
}

# Check for direct call to apply
if [ $# -gt 0 ] && [ "$1" = "apply" ]; then
    if [ -n "$2" ]; then
        apply_state "$2"
        exit 0
    else
        echo "Error: State name required for apply command"
        exit 1
    fi
fi

# Run the main menu
main_menu
