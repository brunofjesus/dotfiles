#!/bin/sh
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/foot/foot.ini"

case "$1" in
  "frappe")
    THEME="1"
    ;;
  "latte")
    THEME="2"
    ;;
  *)
    THEME="1"
    ;;
esac

echo $THEME
sed -i "s/initial-color-theme=[0-9]*/initial-color-theme=$THEME/" "$CONFIG"
pkill -u "$USER" --signal=SIGUSR$THEME ^foot$
