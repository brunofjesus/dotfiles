#!/bin/sh
# qutebrowser reads the active theme itself (via gsettings) inside config.py.
# Re-source the config in the running instance so the colors update live.
# Note: colors.webpage.preferred_color_scheme is only read by QtWebEngine at
# startup, so it takes effect on the next launch.
if pgrep -x qutebrowser >/dev/null; then
    qutebrowser ":config-source" >/dev/null 2>&1
fi
