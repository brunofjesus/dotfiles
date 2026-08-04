# Swift scripts

## dark-mode-actions.swift

A LaunchAgent runs `dark-mode-actions.swift`, which listens for macOS
appearance changes and re-themes nvim, k9s, and tmux (light = latte,
dark = frappe). It also runs once at load.

The script runs **in place** from this repo; the plist's `ProgramArguments`
points at its absolute path here.

### Install

From the repo root, stow the package to symlink the LaunchAgent into
`~/Library/LaunchAgents/`:

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
