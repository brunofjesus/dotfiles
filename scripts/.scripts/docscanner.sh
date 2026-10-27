#!/usr/bin/env bash
#
# docscanner.sh - scan documents with scanimage.
#
# Lists available scanners, lets you pick one (fuzzel on GUI, fzf on TTY),
# asks for format and filename, then scans one or more pages and combines
# them into a single PDF/TIFF when needed.
#
# Scanners can be manually added to:
# /etc/sane.d/airscan.conf
#
# Overridable environment variables:
#   SCAN_DIR   destination directory (default: ~/Documents/scans)

set -uo pipefail

SCAN_DIR="${SCAN_DIR:-$HOME/Documents/scans}"
FORMATS=(png jpeg pdf tiff)
DEFAULT_NAME="scan_$(date +%Y%m%d-%H%M%S)"

die() {
    printf 'docscanner: %s\n' "$*" >&2
    exit 1
}

command -v scanimage >/dev/null 2>&1 || die "scanimage not found (install sane-utils)"

# fuzzel for graphical sessions, fzf (or a numbered prompt) otherwise
if [[ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]] && command -v fuzzel >/dev/null 2>&1; then
    GUI=1
else
    GUI=0
fi

notify() {
    local title=$1 body=${2:-}
    if ((GUI)) && command -v notify-send >/dev/null 2>&1; then
        notify-send -a docscanner "$title" "$body"
    elif [[ -n $body ]]; then
        printf '%s: %s\n' "$title" "$body" >&2
    else
        printf '%s\n' "$title" >&2
    fi
}

ui_menu() {
    local prompt=$1
    shift
    (( $# )) || return 1

    if ((GUI)); then
        printf '%s\n' "$@" | fuzzel --dmenu --prompt "$prompt: " 2>/dev/null
    elif command -v fzf >/dev/null 2>&1; then
        printf '%s\n' "$@" | fzf --prompt "$prompt: " --height 40% --reverse
    else
        local items=("$@") i choice
        printf '\n%s\n' "$prompt" >&2
        for i in "${!items[@]}"; do
            printf '  %d) %s\n' "$((i + 1))" "${items[i]}" >&2
        done
        read -r -p "> " choice || return 1
        [[ $choice =~ ^[0-9]+$ ]] || return 1
        ((choice >= 1 && choice <= ${#items[@]})) || return 1
        printf '%s\n' "${items[choice - 1]}"
    fi
}

ui_input() {
    local prompt=$1 placeholder=${2:-} reply
    if ((GUI)); then
        fuzzel --dmenu --prompt-only "$prompt: " --placeholder "$placeholder" </dev/null 2>/dev/null
    else
        read -r -p "$prompt${placeholder:+ [$placeholder]}: " reply || return 1
        printf '%s\n' "${reply:-$placeholder}"
    fi
}

# Print $1, or "$1-2", "$1-3"... if the file already exists.
unique_path() {
    local p=$1 n=2 dir base ext=""
    dir=$(dirname -- "$p")
    base=$(basename -- "$p")
    if [[ $base == *.* ]]; then
        ext=".${base##*.}"
        base=${base%.*}
    fi
    while [[ -e $p ]]; do
        p="$dir/$base-$n$ext"
        ((n++))
    done
    printf '%s\n' "$p"
}

supports() {
    local needle=$1 item
    shift
    for item in "$@"; do
        [[ $item == "$needle" ]] && return 0
    done
    return 1
}

# Largest available resolution <= target, else the smallest available.
closest_resolution() {
    local target=$1 r best=""
    for r in "${RES_CHOICES[@]}"; do
        if ((r <= target)) && { [[ -z $best ]] || ((r > best)); }; then
            best=$r
        fi
    done
    if [[ -z $best ]]; then
        for r in "${RES_CHOICES[@]}"; do
            if [[ -z $best ]] || ((r < best)); then
                best=$r
            fi
        done
    fi
    printf '%s\n' "$best"
}

# --------------------------------------------------------------------------
# 1. Pick a scanner
# --------------------------------------------------------------------------
mapfile -t DEVICE_LINES < <(scanimage -L 2>/dev/null | sed -n "s/^device [\`']\([^']*\)' is a \(.*\)$/\1\t\2/p")
(( ${#DEVICE_LINES[@]} )) || die "No scanner found (scanimage -L)"

LABELS=()
for line in "${DEVICE_LINES[@]}"; do
    LABELS+=("${line%%$'\t'*} — ${line#*$'\t'}")
done

if (( ${#LABELS[@]} == 1 )); then
    CHOICE=${LABELS[0]}
    notify "Scanner" "$CHOICE"
else
    CHOICE=$(ui_menu "Scanner" "${LABELS[@]}") || exit 0
    [[ -n $CHOICE ]] || exit 0
fi

DEVICE=""
for line in "${DEVICE_LINES[@]}"; do
    if [[ $CHOICE == "${line%%$'\t'*} — ${line#*$'\t'}" ]]; then
        DEVICE=${line%%$'\t'*}
        break
    fi
done
[[ -n $DEVICE ]] || DEVICE=${CHOICE%% — *}
[[ -n $DEVICE ]] || die "No scanner selected"

# --------------------------------------------------------------------------
# 2. Pick a format
# --------------------------------------------------------------------------
FORMAT=$(ui_menu "Format" "${FORMATS[@]}") || exit 0
[[ -n $FORMAT ]] || exit 0
supports "$FORMAT" "${FORMATS[@]}" || die "Unsupported format: $FORMAT"

# --------------------------------------------------------------------------
# 3. Pick resolution / color mode
# --------------------------------------------------------------------------
DEV_HELP=$(scanimage --help -d "$DEVICE" 2>/dev/null)
mapfile -t RES_CHOICES < <(printf '%s\n' "$DEV_HELP" |
    sed -n 's/.*--resolution[[:space:]]*\([^[:space:]]*\)dpi.*/\1/p' |
    tr '|' '\n' | grep -E '^[0-9]+$' | sort -n -u)
mapfile -t MODE_CHOICES < <(printf '%s\n' "$DEV_HELP" |
    sed -n 's/.*--mode[[:space:]]*\([^[:space:]]*\).*/\1/p' |
    tr '|' '\n' | awk 'NF && !seen[$0]++')

PRESET=$(ui_menu "Scan preset" \
    "Document — 300 dpi, Color" \
    "Text — 300 dpi, Gray" \
    "Photo — 600 dpi, Color" \
    "Custom…") || exit 0
[[ -n $PRESET ]] || exit 0

case $PRESET in
    Document*) DPI=300 MODE=Color ;;
    Text*)     DPI=300 MODE=Gray ;;
    Photo*)    DPI=600 MODE=Color ;;
    Custom*)
        if (( ${#RES_CHOICES[@]} )); then
            DPI=$(ui_menu "Resolution (dpi)" "${RES_CHOICES[@]}") || exit 0
            [[ -n $DPI ]] || exit 0
        fi
        if (( ${#MODE_CHOICES[@]} )); then
            MODE=$(ui_menu "Color mode" "${MODE_CHOICES[@]}") || exit 0
            [[ -n $MODE ]] || exit 0
        fi
        ;;
    *) die "Unknown preset: $PRESET" ;;
esac

if (( ${#RES_CHOICES[@]} )) && ! supports "$DPI" "${RES_CHOICES[@]}"; then
    DPI=$(closest_resolution "$DPI")
fi
if (( ${#MODE_CHOICES[@]} )) && ! supports "$MODE" "${MODE_CHOICES[@]}"; then
    MODE=${MODE_CHOICES[0]}
fi

# --------------------------------------------------------------------------
# 4. Destination file name
# --------------------------------------------------------------------------
RAW_NAME=$(ui_input "File name" "$DEFAULT_NAME") || exit 0
RAW_NAME=${RAW_NAME//[$'\n\r']/}
RAW_NAME=${RAW_NAME:-$DEFAULT_NAME}
[[ $RAW_NAME == "~"* ]] && RAW_NAME="$HOME${RAW_NAME:1}"

if [[ $RAW_NAME == */* ]]; then
    DEST_DIR=$(dirname -- "$RAW_NAME")
    BASE=$(basename -- "$RAW_NAME")
else
    DEST_DIR=$SCAN_DIR
    BASE=$RAW_NAME
fi

# Drop a known extension so it is replaced by the chosen format.
case ${BASE,,} in
    *.png | *.jpg | *.jpeg | *.pdf | *.tif | *.tiff) BASE=${BASE%.*} ;;
esac
[[ -n $BASE ]] || BASE=$DEFAULT_NAME
[[ -n $DEST_DIR ]] || DEST_DIR=$SCAN_DIR
mkdir -p -- "$DEST_DIR" || die "Cannot create directory: $DEST_DIR"

case $FORMAT in
    jpeg) EXT=jpg ;;
    *) EXT=$FORMAT ;;
esac
TARGET=$(unique_path "$DEST_DIR/$BASE.$EXT")

# --------------------------------------------------------------------------
# 5. Scan pages
# --------------------------------------------------------------------------
WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/docscanner.XXXXXX") || die "Cannot create temp directory"
trap 'rm -rf -- "$WORKDIR"' EXIT

SCAN_ARGS=(-d "$DEVICE" --format="$FORMAT")
(( ${#RES_CHOICES[@]} )) && SCAN_ARGS+=(--resolution="$DPI")
(( ${#MODE_CHOICES[@]} )) && SCAN_ARGS+=(--mode="$MODE")

PAGES=()

scan_page() {
    local out=$1 err="$WORKDIR/scanimage.log"

    if ((GUI)); then
        notify "Scanning…" "Page $((${#PAGES[@]} + 1)) on $DEVICE"
        scanimage "${SCAN_ARGS[@]}" >"$out" 2>"$err"
    else
        printf 'Scanning page %d...\n' "$((${#PAGES[@]} + 1))" >&2
        scanimage "${SCAN_ARGS[@]}" --progress >"$out"
    fi

    local status=$?
    if ((status != 0)) || [[ ! -s $out ]]; then
        local msg="scanimage exited with status $status"
        if [[ -s $err ]]; then
            msg=$(tail -n 3 -- "$err")
        fi
        [[ -n $msg ]] || msg="empty scan"
        notify "Scan failed" "$msg"
        rm -f -- "$out"
        return 1
    fi
    return 0
}

page_no=1
while :; do
    page=$(printf '%s/page-%03d.%s' "$WORKDIR" "$page_no" "$EXT")
    scan_page "$page" || exit 1
    PAGES+=("$page")

    if ! ANSWER=$(ui_menu "Page $page_no scanned" "Scan another page" "Finish and save"); then
        break
    fi
    [[ $ANSWER == "Scan another page" ]] || break
    ((page_no++))
done

# --------------------------------------------------------------------------
# 6. Assemble the result
# --------------------------------------------------------------------------
merge_pages() {
    local out=$1
    case $FORMAT in
        pdf)
            if command -v qpdf >/dev/null 2>&1 &&
                qpdf --empty --pages "${PAGES[@]}" -- "$out" 2>"$WORKDIR/merge.log"; then
                return 0
            fi
            if command -v magick >/dev/null 2>&1 &&
                magick "${PAGES[@]}" "$out" 2>>"$WORKDIR/merge.log"; then
                return 0
            fi
            ;;
        tiff)
            if command -v tiffcp >/dev/null 2>&1 &&
                tiffcp "${PAGES[@]}" "$out" 2>"$WORKDIR/merge.log"; then
                return 0
            fi
            if command -v magick >/dev/null 2>&1 &&
                magick "${PAGES[@]}" "$out" 2>>"$WORKDIR/merge.log"; then
                return 0
            fi
            ;;
    esac
    return 1
}

save_pages_individually() {
    local i out
    for i in "${!PAGES[@]}"; do
        out=$(unique_path "$DEST_DIR/$BASE-$(printf '%02d' "$((i + 1))").$EXT")
        if ! mv -f -- "${PAGES[i]}" "$out"; then
            notify "Save failed" "Could not write $out"
            return 1
        fi
        SAVED+=("$out")
    done
    return 0
}

SAVED=()

if (( ${#PAGES[@]} == 1 )); then
    if mv -f -- "${PAGES[0]}" "$TARGET"; then
        SAVED=("$TARGET")
    else
        notify "Save failed" "Could not write $TARGET"
        exit 1
    fi
elif [[ $FORMAT == png || $FORMAT == jpeg ]]; then
    # No single-file container for these formats; keep numbered pages.
    save_pages_individually || exit 1
elif merge_pages "$TARGET"; then
    SAVED=("$TARGET")
else
    # Never lose a scan because merging failed.
    save_pages_individually || exit 1
    notify "Merge failed" "Saved individual pages instead in $DEST_DIR"
fi

if (( ${#SAVED[@]} )); then
    notify "Scan saved" "$(printf '%s\n' "${SAVED[@]}")"
    printf '%s\n' "${SAVED[@]}"
    exit 0
fi

exit 1
