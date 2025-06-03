#!/bin/bash

IP="172.30.1.99"
USER="admin"
PASS=$CCTV_PASSWORD

# Camera options
declare -A camera_map
camera_map["sala"]=101
camera_map["cozinha"]=201
camera_map["garagem"]=301
camera_map["entrada"]=401

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
else
  source ~/.env
fi

choose_camera() {
    CAMERA_OPTIONS="🛋️ Sala\n🧑‍🍳 Cozinha\n🚘 Garagem\n🚪 Entrada"
    CHOICE=$(echo -e "$CAMERA_OPTIONS" | $RUNNER --prompt "Camera: " | awk '{print tolower($2)}' )
    echo ${camera_map[$CHOICE]}
}


# Convert local date + time to UTC ISAPI format
to_utc_format() {
    date -u -d "$1 $2" +%Y%m%dT%H%M%SZ
}

# Ask for datetime input via terminal or zenity
get_datetime_input() {
    local label="$1"
    local default_date="$2"
    local default_time="$3"

    if tty -s; then
        read -p "$label date [$default_date]: " date_input
        read -p "$label time (HH:MM) [$default_time]: " time_input
        echo "$(to_utc_format "${date_input:-$default_date}" "${time_input:-$default_time}")"
    else
        # Extract year, month, and day from default_date
        default_year=$(date -d "$default_date" +%Y)
        default_month=$(date -d "$default_date" +%m)
        default_day=$(date -d "$default_date" +%d)

        date_input=$(zenity --calendar --title="$label Date" --text="Choose a date" \
          --year="$default_year" --month="$default_month" --day="$default_day" \
          --date-format="%Y-%m-%d")
        [ $? -ne 0 ] && exit 1
        time_input=$(zenity --entry --title="$label Time" --text="Enter time (HH:MM)" --entry-text="$default_time")
        [ $? -ne 0 ] && exit 1
        echo "$(to_utc_format "$date_input" "$time_input")"
#    fi
}

CAMERA_ID=$(choose_camera)
# Calculate default time range: 5 min ago → now
NOW_LOCAL=$(date "+%Y-%m-%d %H:%M")
FIVE_MIN_AGO_LOCAL=$(date -d '-5 minutes' "+%Y-%m-%d %H:%M")
TEN_SEC_AGO_LOCAL=$(date -d '-10 seconds' "+%Y-%m-%d %H:%M")

START=$(get_datetime_input "Start Time" "${FIVE_MIN_AGO_LOCAL%% *}" "${FIVE_MIN_AGO_LOCAL##* }")
END=$(get_datetime_input "End Time" "${TEN_SEC_AGO_LOCAL%% *}" "${TEN_SEC_AGO_LOCAL##* }")


# Final URL and output
RTSP_URL="rtsp://$USER:$PASS@$IP:554/Streaming/tracks/$CAMERA_ID?starttime=$START&endtime=$END"
FILE_NAME="camera1_${START}_to_${END}.mkv"
OUTPUT_PATH="$VIDEOS_DIR/$FILE_NAME"

mpv "$RTSP_URL"
