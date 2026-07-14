#!/bin/bash

# Switch the Catppuccin flavor used by tmux and live-reload running sessions.
# Called by the dark-mode switcher (dark-mode.sh on Linux,
# dark-mode-actions.swift on macOS) with 'latte' (light) or 'frappe' (dark).
#
# The palette is applied with tmux's `-o` flag ("don't overwrite"), so a plain
# re-source can't change colors. The plugin's supported way to switch live is to
# set @catppuccin_reset, re-run the plugin (which unsets the palette first), then
# re-apply our customizations and run it once more. See the plugin's
# docs/tutorials/03-resetting-theme.md.

TMUX_DIR="$(cd "$(dirname "$0")" && pwd)"
FLAVOR_FILE="$TMUX_DIR/current-flavor.conf"
PLUGIN="$TMUX_DIR/plugins/tmux/catppuccin.tmux"

set_theme() {
    local theme="$1"
    case "$theme" in
        latte|frappe|macchiato|mocha) ;;
        *)
            echo "Unknown theme: $theme"
            echo "Available themes: latte, frappe, macchiato, mocha"
            return 1
            ;;
    esac

    # Persist the choice so freshly-started tmux servers pick it up on startup.
    echo "set -g @catppuccin_flavor '$theme'" >"$FLAVOR_FILE"

    # Live-reload any running server.
    tmux info &>/dev/null || return 0

    # The per-module status colors are set with -o ("don't overwrite") and -F
    # (expanded to a literal hex at source-time), so they're frozen to the first
    # flavor and @catppuccin_reset doesn't clear them. Unset them ourselves so the
    # status modules re-derive them from the new palette on the next run.
    for m in application session date_time; do
        tmux set -gu "@catppuccin_status_${m}_icon_fg"
        tmux set -gu "@catppuccin_status_${m}_text_fg"
        tmux set -gu "@catppuccin_${m}_color"
    done

    # 1. Reset: unset the sticky palette and re-run the plugin with the new flavor.
    tmux set -g @catppuccin_flavor "$theme"
    tmux set -g @catppuccin_reset "true"
    tmux run "$PLUGIN"

    # 2. Re-apply our customizations (the reset reverted them to plugin defaults)
    #    and run the plugin again so the status line rebuilds with them.
    tmux set -g @catppuccin_flavor "$theme"
    tmux source-file "$TMUX_DIR/catppuccin.conf"
    tmux run "$PLUGIN"
}

set_theme "$1"