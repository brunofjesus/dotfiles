#!/usr/bin/env bash
# choose pinentry depending on PINENTRY_USER_DATA

case $PINENTRY_USER_DATA in
curses)
  exec pinentry-curses "$@"
  ;;
gnome3|*)
  exec pinentry-gnome3 "$@"
  ;;
esac
