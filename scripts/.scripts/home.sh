#!/bin/bash

# Home Assistant control via wofi (or fzf in a tty).
# Requires HA_URL and HA_TOKEN, sourced from ~/.env (like cctv.sh):
#   HA_URL="https://homeassistant.brunojesus.pt"
#   HA_TOKEN=<long-lived access token>

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
else
    source ~/.env
fi

QUIT="🚪 Quit"

die() {
    if tty -s; then
        echo "$1" >&2
    else
        notify-send "Home Assistant" "$1"
    fi
    exit 1
}

[ -z "$HA_URL" ] && die "HA_URL is not set (add it to ~/.env)."
[ -z "$HA_TOKEN" ] && die "HA_TOKEN is not set (add it to ~/.env)."

api_get() {
    # $1 = path (e.g. /api/states)
    curl -s -m 15 -H "Authorization: Bearer $HA_TOKEN" \
        "$HA_URL$1"
}

api_post() {
    # $1 = domain/service path (e.g. climate/set_temperature), $2 = JSON body.
    # Prints "<body>\n<http_status>"; caller checks the status for 2xx.
    curl -s -m 15 -X POST \
        -w '\n%{http_code}' \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$2" \
        "$HA_URL/api/services/$1"
}

# Runs a service call and notifies on success/failure.
# $1 = domain/service, $2 = JSON body, $3 = success message
call_service() {
    local out code body
    out=$(api_post "$1" "$2")
    code=$(printf '%s' "$out" | tail -n1)
    body=$(printf '%s' "$out" | sed '$d')

    if [[ "$code" =~ ^2 ]]; then
        notify-send "Home Assistant" "$3"
    else
        notify-send "Home Assistant" "Failed (HTTP ${code:-?}): ${body:-no response}"
    fi
    # Give HA a moment to reflect the change before the caller re-fetches state.
    sleep 0.4
}

menu() {
    # $1 = prompt, reads options from stdin, prints selection
    $RUNNER --prompt "$1"
}

# Renders a Jinja template server-side via the HA template API.
# $1 = template string; prints the rendered body.
api_template() {
    curl -s -m 15 -X POST \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$(jq -nc --arg t "$1" '{template: $t}')" \
        "$HA_URL/api/template"
}

# Fetches /api/states into the named variable. Returns non-zero (and notifies)
# when Home Assistant is unreachable or the response is not a JSON array.
# $1 = name of the variable to populate.
fetch_states() {
    local __out
    __out=$(api_get "/api/states")
    if [ -z "$__out" ] || ! echo "$__out" | jq -e 'type == "array"' >/dev/null 2>&1; then
        notify-send "Home Assistant" "Could not reach Home Assistant at $HA_URL."
        return 1
    fi
    printf -v "$1" '%s' "$__out"
}

# Format a numeric temperature: drop a trailing ".0" (23.0 -> 23)
fmt_temp() {
    printf '%s' "$1" | sed 's/\.0$//'
}

# ── HVAC ────────────────────────────────────────────────────────────────────

hvac_menu() {
    while true; do
        local states
        fetch_states states || return

        # Build "entity_id<TAB>label" for every climate.* entity.
        local list
        list=$(echo "$states" | jq -r '
            [ .[] | select(.entity_id | startswith("climate.")) ]
            | .[]
            | .entity_id as $id
            | (.attributes.friendly_name // $id) as $name
            | .state as $mode
            | (if .attributes.current_temperature == null then "?"
               else (.attributes.current_temperature | tostring) end) as $cur
            | (if .attributes.temperature == null then "?"
               else (.attributes.temperature | tostring) end) as $target
            | "\($id)\t❄️ \($name) — \($mode) · \($cur)° → \($target)°"
        ')

        if [ -z "$list" ]; then
            notify-send "Home Assistant" "No HVAC (climate) units found."
            return
        fi

        local choice
        choice=$( { echo "$list" | cut -f2-; echo "$QUIT"; } | menu "HVAC unit:")
        case "$choice" in
            "")     return ;;   # Esc -> up to type menu
            "$QUIT") exit 0 ;;
        esac

        local entity_id
        entity_id=$(echo "$list" | awk -F'\t' -v c="$choice" '$2 == c {print $1; exit}')
        [ -z "$entity_id" ] && continue

        hvac_unit_menu "$entity_id"
    done
}

hvac_unit_menu() {
    local entity_id="$1"
    while true; do
        local states entity
        fetch_states states || return
        entity=$(echo "$states" | jq -c --arg id "$entity_id" '.[] | select(.entity_id == $id)')
        [ -z "$entity" ] && return   # entity vanished -> up to unit list

        local name mode cur target
        name=$(echo "$entity" | jq -r '.attributes.friendly_name // .entity_id')
        mode=$(echo "$entity" | jq -r '.state')
        cur=$(echo "$entity" | jq -r '.attributes.current_temperature // "?"')
        target=$(echo "$entity" | jq -r '.attributes.temperature // "?"')

        local action
        action=$(printf '🌡️ Set Temperature\n⚙️ Set Mode\n%s' "$QUIT" \
            | menu "$name ($mode · $(fmt_temp "$cur")° → $(fmt_temp "$target")°):")

        case "$action" in
            *Temperature) set_temperature "$entity_id" "$name" ;;
            *Mode)        set_mode "$entity_id" "$name" "$entity" ;;
            "$QUIT")      exit 0 ;;
            *)            return ;;   # Esc -> up to unit list
        esac
    done
}

set_temperature() {
    local entity_id="$1" name="$2"

    # Stepped list 18.0 -> 32.0 in 0.5 increments, with 22 pinned on top
    # as the default (wofi highlights the first row, so Enter selects it).
    # LC_ALL=C forces a '.' decimal separator (valid JSON numbers).
    local temps
    temps=$(printf '22\n'; LC_ALL=C seq 18.0 0.5 32.0 | sed 's/\.0$//')

    local choice
    choice=$( { echo "$temps"; echo "$QUIT"; } | menu "Temperature for $name:")
    case "$choice" in
        "")      return ;;   # Esc -> up to unit action menu
        "$QUIT") exit 0 ;;
    esac

    call_service "climate/set_temperature" \
        "$(jq -nc --arg id "$entity_id" --argjson t "$choice" \
            '{entity_id: $id, temperature: $t}')" \
        "$name set to ${choice}°"
}

set_mode() {
    local entity_id="$1" name="$2" entity="$3"

    local modes
    modes=$(echo "$entity" | jq -r '.attributes.hvac_modes[]? // empty')
    if [ -z "$modes" ]; then
        notify-send "Home Assistant" "No selectable modes for $name."
        return
    fi

    local choice
    choice=$( { echo "$modes"; echo "$QUIT"; } | menu "Mode for $name:")
    case "$choice" in
        "")      return ;;   # Esc -> up to unit action menu
        "$QUIT") exit 0 ;;
    esac

    call_service "climate/set_hvac_mode" \
        "$(jq -nc --arg id "$entity_id" --arg m "$choice" \
            '{entity_id: $id, hvac_mode: $m}')" \
        "$name mode set to $choice"
}

# ── Lights ──────────────────────────────────────────────────────────────────

lights_menu() {
    while true; do
        local states
        fetch_states states || return

        # Fetch each light's area via the template API as {"light.x":"Area",...}.
        # Falls back to an empty map (no prefix) if the call fails.
        local areas
        areas=$(api_template '[{% for s in states.light %}{"id": {{ s.entity_id | tojson }}, "area": {{ area_name(s.entity_id) | tojson }}}{{ "," if not loop.last }}{% endfor %}]')
        if ! echo "$areas" | jq -e 'type == "array"' >/dev/null 2>&1; then
            areas="[]"
        fi
        areas=$(echo "$areas" | jq 'map({(.id): .area}) | add // {}')

        # Build "entity_id<TAB>type<TAB>pct<TAB>label" for every light.* entity.
        # type=dim when it has a color mode other than "onoff"; else toggle.
        local list
        list=$(echo "$states" | jq -r --argjson areas "$areas" '
            [ .[] | select(.entity_id | startswith("light.")) ]
            | .[]
            | .entity_id as $id
            | (.attributes.friendly_name // $id) as $fname
            | ($areas[$id]) as $area
            | (if $area != null and $area != "" then "\($area) · \($fname)" else $fname end) as $name
            | .state as $st
            | (if (((.attributes.supported_color_modes // []) - ["onoff"]) | length) > 0
               then "dim" else "toggle" end) as $type
            | (if .attributes.brightness == null then "?"
               else ((.attributes.brightness / 255 * 100) | round | tostring) end) as $pct
            | (if $type == "dim" and $st == "on"
               then "💡 \($name) — \($st) · \($pct)%"
               else "💡 \($name) — \($st)" end) as $label
            | "\($id)\t\($type)\t\($pct)\t\($label)"
        ' | sort)

        if [ -z "$list" ]; then
            notify-send "Home Assistant" "No lights found."
            return
        fi

        local choice
        choice=$( { echo "$list" | cut -f4-; echo "$QUIT"; } | menu "Light:")
        case "$choice" in
            "")      return ;;   # Esc -> up to type menu
            "$QUIT") exit 0 ;;
        esac

        local row entity_id type pct name
        row=$(echo "$list" | awk -F'\t' -v c="$choice" '$4 == c {print; exit}')
        [ -z "$row" ] && continue
        entity_id=$(printf '%s' "$row" | cut -f1)
        type=$(printf '%s' "$row" | cut -f2)
        pct=$(printf '%s' "$row" | cut -f3)
        name=$(echo "$states" | jq -r --arg id "$entity_id" --argjson areas "$areas" '
            .[] | select(.entity_id == $id)
            | (.attributes.friendly_name // .entity_id) as $fname
            | ($areas[$id]) as $area
            | if $area != null and $area != "" then "\($area) · \($fname)" else $fname end')

        if [ "$type" = "dim" ]; then
            set_brightness "$entity_id" "$name" "$pct"
        else
            toggle_light "$entity_id" "$name"
        fi
    done
}

toggle_light() {
    local entity_id="$1" name="$2"

    local action
    action=$(printf '🔆 Turn On\n🌙 Turn Off\n🔁 Toggle\n%s' "$QUIT" | menu "$name:")

    case "$action" in
        *"Turn On")  call_service "light/turn_on"  "$(jq -nc --arg id "$entity_id" '{entity_id: $id}')" "$name turned on" ;;
        *"Turn Off") call_service "light/turn_off" "$(jq -nc --arg id "$entity_id" '{entity_id: $id}')" "$name turned off" ;;
        *Toggle)     call_service "light/toggle"   "$(jq -nc --arg id "$entity_id" '{entity_id: $id}')" "$name toggled" ;;
        "$QUIT")     exit 0 ;;
        *)           return ;;   # Esc -> up to light list
    esac
}

set_brightness() {
    local entity_id="$1" name="$2" current="$3"

    # Default to current brightness (pinned on top); fall back to 100 when
    # the light is off or brightness is unknown.
    [ "$current" = "?" ] && current="100"

    local levels
    levels=$(printf '%s%%\n0%% (off)\n20%%\n40%%\n60%%\n80%%\n100%%' "$current")

    local choice
    choice=$( { echo "$levels"; echo "$QUIT"; } | menu "Brightness for $name:")
    case "$choice" in
        "")      return ;;   # Esc -> up to light list
        "$QUIT") exit 0 ;;
    esac

    # Extract the leading number from the selection.
    local pct
    pct=$(printf '%s' "$choice" | grep -oE '^[0-9]+')
    [ -z "$pct" ] && return

    if [ "$pct" -eq 0 ]; then
        call_service "light/turn_off" \
            "$(jq -nc --arg id "$entity_id" '{entity_id: $id}')" \
            "$name turned off"
    else
        call_service "light/turn_on" \
            "$(jq -nc --arg id "$entity_id" --argjson b "$pct" \
                '{entity_id: $id, brightness_pct: $b}')" \
            "$name set to ${pct}%"
    fi
}

# ── Entry point ─────────────────────────────────────────────────────────────

# Device-type menu (extend the case for more types).
main() {
    while true; do
        local choice
        choice=$(printf '🌡️ HVAC\n💡 Lights\n%s' "$QUIT" | menu "Control:")
        case "$choice" in
            *HVAC)   hvac_menu ;;
            *Lights) lights_menu ;;
            *)       exit 0 ;;   # Quit or Esc at the top level exits
        esac
    done
}

main
