#!/bin/sh
# qutebrowser reads the active theme itself (via gsettings) inside config.py.
# colors.webpage.preferred_color_scheme requires a full restart to take
# effect (QtWebEngine reads it only at startup), so we restart instead of
# just reloading the config. :restart preserves open tabs via session
# auto-save (c.auto_save.session = True).
if pgrep -x qutebrowser >/dev/null; then
    qutebrowser ":restart" >/dev/null 2>&1 &
    disown
fi
