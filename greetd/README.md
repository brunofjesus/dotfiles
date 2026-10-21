# greetd

`greetd` is a minimal, agnostic login manager daemon. Here it's configured to
use `agreety` (the bundled terminal greeter) to log in and launch `sway`
(Wayland compositor) directly, without a graphical greeter.

## Files

- `/etc/greetd/config.toml` — greetd configuration (greeter + session).
- `/usr/local/bin/start-sway` — wrapper script that sets up the Wayland
  environment and execs `sway`.

## `/usr/local/bin/start-sway`

```sh
#!/bin/sh
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway

# Wayland stuff
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

exec sway "$@"
```

## `/etc/greetd/config.toml`

```toml
[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 1

# The default session, also known as the greeter.
[default_session]

# `agreety` is the bundled agetty/login-lookalike. You can replace `/bin/sh`
# with whatever you want started, such as `sway`.
#command = "agreety --cmd /bin/sh"
command = "agreety --cmd /usr/local/bin/start-sway"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the `video` group.
user = "greeter"

[initial_session]
command = "sh -c 'exec sway < /dev/null'"
user = "bruno"
```

## Setup steps

1. **Install greetd and sway** (package names vary by distro, e.g. on Arch:
   `pacman -S greetd sway`).

2. **Create the launch script** at `/usr/local/bin/start-sway` with the
   contents above, then make it executable:

   ```sh
   sudo install -m 755 start-sway /usr/local/bin/start-sway
   ```

3. **Write the config** to `/etc/greetd/config.toml` with the contents above.

   - `[default_session]` is what greetd starts on the greeter VT: `agreety`
     prompts for a username/password, then execs `/usr/local/bin/start-sway`
     as that user.
   - `[initial_session]` is optional — it's an auto-login session greetd will
     start immediately without showing the greeter at all (here, user
     `bruno` is auto-logged into `sway` directly). Remove this section if you
     want to always be prompted by `agreety`.

## Enabling the greetd systemd service

greetd ships a systemd unit (commonly at `/usr/lib/systemd/system/greetd.service`):

```ini
[Unit]
Description=Greeter daemon
After=systemd-user-sessions.service plymouth-quit-wait.service
After=getty@tty1.service
Conflicts=getty@tty1.service

[Service]
Type=simple
ExecStart=greetd
IgnoreSIGPIPE=no
SendSIGHUP=yes
TimeoutStopSec=30s
KeyringMode=shared
Restart=always
RestartSec=1
StartLimitBurst=5
StartLimitInterval=30

[Install]
Alias=display-manager.service
```

Enable it so it starts on boot and becomes the system's display manager:

```sh
sudo systemctl enable greetd.service
```

Because the unit declares `Alias=display-manager.service`, enabling it also
creates the `display-manager.service` symlink that systemd uses to decide
which login manager to start — so you don't need to set it manually.

Start it right away (or just reboot):

```sh
sudo systemctl start greetd.service
```

Check status/logs if something goes wrong:

```sh
systemctl status greetd.service
journalctl -u greetd.service -b
```

To disable it later (e.g. switching back to another display manager):

```sh
sudo systemctl disable --now greetd.service
```
