# tmux config

A tmux setup based on [marceloborges.dev/posts/4](https://marceloborges.dev/posts/4/),
with a backtick leader, vim-style navigation, floating panes, and fuzzy session
switching via [`sesh`](https://github.com/joshmedeski/sesh).

Config lives at `.config/tmux/tmux.conf`. Plugins are managed with
[TPM](https://github.com/tmux-plugins/tpm).

> **Prefix / leader key is `` ` `` (backtick), not `C-b`.**
> Throughout this doc, `` ` `` means "press the prefix, then the key".
> Bindings marked **(root)** need no prefix — press them directly.

## New to tmux?

tmux is a **terminal multiplexer**: it lets one terminal window hold many shells,
split the screen, and — most importantly — keep everything running even after you
close the terminal or your SSH connection drops. You reconnect later and pick up
exactly where you left off.

### The three concepts

```
Session  ──▶  a workspace (e.g. one project). Survives terminal close.
  └─ Window ──▶  like a browser tab. Fills the screen; you switch between them.
       └─ Pane ──▶  a split within a window. Each pane is its own shell.
```

- **Session** — a named collection of windows. You *attach* to and *detach* from
  sessions. Detaching leaves everything running in the background.
- **Window** — a full-screen "tab" inside a session. The status bar at the bottom
  lists them.
- **Pane** — a rectangular split inside a window; each runs its own shell.

### How keybindings work

Almost every tmux command starts with the **prefix**. Here the prefix is `` ` ``
(backtick). You press and *release* the prefix, then press the command key. So
"`` ` `` `c`" means: tap `` ` ``, then tap `c` — it creates a new window.

A few keys are **root** bindings (marked **(root)** below) that skip the prefix
entirely, like `C-h`/`C-j`/`C-k`/`C-l` to move between panes.

### Getting started from the shell

| Command | What it does |
| --- | --- |
| `tmux` | Start a new unnamed session |
| `tmux new -s work` | Start a new session named `work` |
| `tmux ls` | List running sessions |
| `tmux attach -t work` | Re-attach to the `work` session |
| `tmux kill-session -t work` | Delete the `work` session |

Once you're inside, prefer the in-tmux bindings below. In this config the fastest
way to jump around is `` ` `` `T` (the `sesh` picker).

### The essentials to memorize first

| Do this | Press |
| --- | --- |
| Detach (leave tmux running) | `` ` `` `d` |
| New window | `` ` `` `c` |
| Next / previous window | `M-→` / `M-←` **(root)** |
| Split panes | `` ` `` `"` (vertical) · `` ` `` `%` (horizontal) |
| Move between panes | `C-h` / `C-j` / `C-k` / `C-l` **(root)** |
| Zoom a pane fullscreen (toggle) | `` ` `` `m` |
| Enter scroll / copy mode | `` ` `` `[` (then `q` to quit) |
| Command prompt | `` ` `` `:` |

> **Detach vs. quit:** `` ` `` `d` detaches — your programs keep running and you can
> re-attach later. To actually close things, exit each shell (`exit` / `C-d`) or
> kill the window/pane. Closing your terminal app also just detaches; nothing is lost.

## Requirements

- `tmux` (with `tmux-256color` terminal support)
- [`sesh`](https://github.com/joshmedeski/sesh) — session manager (`` ` `` `T` / `` ` `` `o`)
- [`fzf`](https://github.com/junegunn/fzf) — provides `fzf-tmux` for the session picker
- [`zoxide`](https://github.com/ajeetdsouza/zoxide) — smart directory jumping in the picker
- [`fd`](https://github.com/sharkdp/fd) — directory search in the picker (`^f`)
- [TPM](https://github.com/tmux-plugins/tpm) — plugin manager (installed under `plugins/tpm`)
- A **Nerd Font** — for the Catppuccin status bar icons

## General

| Key | Action |
| --- | --- |
| `` ` `` | Prefix (leader) |
| `` ` `` `` ` `` | Send a literal backtick |
| `` ` `` `r` | Reload `~/.config/tmux/tmux.conf` |
| `` ` `` `I` | (TPM) Install plugins |
| `` ` `` `U` | (TPM) Update plugins |

## Panes

| Key | Action |
| --- | --- |
| `` ` `` `"` | Split vertically (top/bottom), same dir |
| `` ` `` `-` | Split vertically (top/bottom), same dir |
| `` ` `` `%` | Split horizontally (left/right), same dir |
| `` ` `` `\|` | Split horizontally (left/right), same dir |
| `C-h` / `C-j` / `C-k` / `C-l` **(root)** | Move to left/down/up/right pane — also crosses into Neovim splits (vim-tmux-navigator) |
| `` ` `` `H` / `J` / `K` / `L` | Resize pane left/down/up/right by 5 (repeatable) |
| `` ` `` `←` / `↓` / `↑` / `→` | Resize pane by 5 (repeatable) |
| `` ` `` `m` | Toggle zoom (maximize) pane (repeatable) |
| `M-f` **(root)** | Toggle floating pane (see below) |

Panes and windows are numbered from **1**. Splits open in the current pane's directory.

## Windows

| Key | Action |
| --- | --- |
| `` ` `` `c` | New window in the current pane's directory |
| `M-←` / `M-→` **(root)** | Previous / next window |
| `M-i` / `M-o` **(root)** | Move current window left / right |

Windows renumber automatically when one closes, and are never auto-renamed.

## Sessions

| Key | Action |
| --- | --- |
| `` ` `` `T` | Session switcher — `sesh` list in an `fzf-tmux` popup |
| `` ` `` `o` | Jump to the last session (`sesh last`) |

Inside the `` ` `` `T` picker:

| Key | Filter |
| --- | --- |
| `^a` | All sources |
| `^t` | tmux sessions only |
| `^g` | Config sessions |
| `^x` | zoxide directories |
| `^f` | Find directories (`fd` under `~`) |
| `^d` | Kill the selected tmux session |
| `Tab` / `S-Tab` | Move down / up |

Closing a session does **not** detach you from tmux (`detach-on-destroy off`).

## Copy mode (vi)

Copy mode uses vi keys (`mode-keys vi`). Enter it with `` ` `` `[` (or scroll with the mouse).

| Key | Action |
| --- | --- |
| `v` | Begin selection |
| `C-v` | Toggle rectangle (block) selection |
| `y` | Yank selection to the system clipboard (tmux-yank) |
| `o` | Open the selected text in your browser (tmux-open) |
| `C-o` | Open the selected text in `$EDITOR` (tmux-open) |

Dragging with the mouse keeps you in copy mode instead of exiting on release.
The active pane is dimmed (`bg=#181818`) while in copy mode.

## Floating pane (floax)

| Key | Action |
| --- | --- |
| `M-f` **(root)** | Toggle the floating scratch pane |
| `` ` `` `P` | Open the floax options menu (resize, fullscreen, reset, …) |

## Plugins

- **[tpm](https://github.com/tmux-plugins/tpm)** — plugin manager
- **[tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)** — sane default settings
- **[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)** — `C-h/j/k/l` navigation across tmux panes and Neovim splits
- **[catppuccin/tmux](https://github.com/catppuccin/tmux)** — status bar theme (`latte` flavor)
- **[tmux-yank](https://github.com/tmux-plugins/tmux-yank)** — OS-agnostic clipboard copy
- **[tmux-floax](https://github.com/omerxx/tmux-floax)** — floating scratch pane
- **[tmux-open](https://github.com/tmux-plugins/tmux-open)** — open highlighted text/URLs

## Notes

- **Mouse** support is on (select panes, resize, scroll).
- **Clipboard** integration is on (`set-clipboard on`) — copies reach the system clipboard.
- **Extended keys** (`C-.`, `C-;`, `S-Enter`, …) are forwarded to apps like Neovim.
- **Image passthrough** is on (`allow-passthrough on`) for terminal image protocols.
- Status bar sits at the **bottom** and shows application, session, and date/time.
- If your terminal doesn't support kitty/ghostty features, uncomment the
  `terminal-overrides ",xterm*:Tc"` line in `tmux.conf`.
