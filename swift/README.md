# Swift scripts

## dark-mode-actions.swift

A LaunchAgent runs `dark-mode-actions.swift`, which listens for macOS
appearance changes and re-themes nvim, k9s, and tmux (light = latte,
dark = frappe). It also runs once at load.

The setup is user-agnostic: the script resolves paths from `$HOME`
(`NSHomeDirectory()`), and the plist invokes it through a `/bin/sh -c`
wrapper so `$HOME` expands at runtime (launchd won't expand `~` in
`ProgramArguments`).

### Install

From the repo root, stow the package. This symlinks the script into
`~/.local/bin/` and the LaunchAgent into `~/Library/LaunchAgents/`:

```sh
stow swift
```

Then load it (or log out/in):

```sh
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.darkmodeactions.plist
```

To reload after editing the plist or script:

```sh
launchctl bootout gui/$(id -u)/com.user.darkmodeactions
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.darkmodeactions.plist
```

> The plist sets `PATH` to include `/opt/homebrew/bin` so the theme scripts
> can find Homebrew binaries like `tmux`.
