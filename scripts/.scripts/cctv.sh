#!/bin/bash

RUNNER="wofi -i --dmenu"
if tty -s; then
    RUNNER="fzf"
else
  source ~/.env
fi

declare -A camera_map
camera_map["sala"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.90/Streaming/Channels/101";
camera_map["cozinha"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.91/Streaming/Channels/101";
camera_map["garagem"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.92/Streaming/Channels/101";
camera_map["entrada"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.93/Streaming/Channels/101";
camera_map["rampa"]="rtsp://admin:${CCTV_PASSWORD}@172.30.1.94/Streaming/Channels/101";

OPTIONS="🛋️ Sala\n🧑‍🍳 Cozinha\n🚘 Garagem\n🚪 Entrada\n⛰️ Rampa\n🔳 Grid\n"

CHOICE=$(echo -e "$OPTIONS" | $RUNNER --prompt "Camera: " | awk '{print tolower($2)}' )


case "$CHOICE" in
    "sala"|"cozinha"|"garagem"|"entrada"|"rampa")
      mpv ${camera_map[$CHOICE]}
      ;;
    "grid")
      swaymsg workspace number 9

      TEMPFILE_SALA=$(mktemp /tmp/cctv.sala.XXXXXX)
      TEMPFILE_COZINHA=$(mktemp /tmp/cctv.cozinha.XXXXXX)
      TEMPFILE_GARAGEM=$(mktemp /tmp/cctv.garagem.XXXXXX)
      TEMPFILE_ENTRADA=$(mktemp /tmp/cctv.entrada.XXXXXX)
      TEMPFILE_RAMPA=$(mktemp /tmp/cctv.rampa.XXXXXX)

      swaymsg "exec mpv --force-window --idle=yes --input-ipc-server=${TEMPFILE_ENTRADA}"
      sleep 0.5

      swaymsg split v
      swaymsg "exec mpv --force-window --idle=yes --input-ipc-server=${TEMPFILE_COZINHA}"
      sleep 0.5

      swaymsg focus left
      swaymsg split h
      swaymsg "exec mpv --force-window --idle=yes --input-ipc-server=${TEMPFILE_SALA}"
      sleep 0.5

      swaymsg "exec mpv --force-window --idle=yes --input-ipc-server=${TEMPFILE_GARAGEM}"
      sleep 0.5

      swaymsg focus up
      swaymsg focus right
      swaymsg split h
      swaymsg "exec mpv --force-window --idle=yes --input-ipc-server=${TEMPFILE_RAMPA}"
      sleep 0.5


      printf '{ "command": ["loadfile", "%s"] }\n' "${camera_map["sala"]}" | nc -U "$TEMPFILE_SALA" &
      PID_SALA=$!
      printf '{ "command": ["loadfile", "%s"] }\n' "${camera_map["cozinha"]}" | nc -U "$TEMPFILE_COZINHA" &
      PID_COZINHA=$!
      printf '{ "command": ["loadfile", "%s"] }\n' "${camera_map["garagem"]}" | nc -U "$TEMPFILE_GARAGEM" &
      PID_GARAGEM=$!
      printf '{ "command": ["loadfile", "%s"] }\n' "${camera_map["entrada"]}" | nc -U "$TEMPFILE_ENTRADA" &
      PID_ENTRADA=$!
      printf '{ "command": ["loadfile", "%s"] }\n' "${camera_map["rampa"]}" | nc -U "$TEMPFILE_RAMPA" &
      PID_RAMPA=$!

      # Wait for all mpv processes to exit
      wait $PID_SALA
      wait $PID_COZINHA
      wait $PID_GARAGEM
      wait $PID_ENTRADA
      wait $PID_RAMPA
      
      # Now remove the temp files
      rm -f "$TEMPFILE_SALA" "$TEMPFILE_COZINHA" "$TEMPFILE_GARAGEM" "$TEMPFILE_ENTRADA" "$TEMPFILE_RAMPA"
      ;;
esac
