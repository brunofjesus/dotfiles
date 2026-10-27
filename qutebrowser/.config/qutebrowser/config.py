c = c  # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

import subprocess

# catppuccin palettes (kept in sync with ~/.config/sway/catppuccin-{latte,frappe})
PALETTES = {
    "latte": {
        "rosewater": "#dc8a78",
        "flamingo": "#dd7878",
        "pink": "#ea76cb",
        "mauve": "#8839ef",
        "red": "#d20f39",
        "maroon": "#e64553",
        "peach": "#fe640b",
        "yellow": "#df8e1d",
        "green": "#40a02b",
        "teal": "#179299",
        "sky": "#04a5e5",
        "sapphire": "#209fb5",
        "blue": "#1e66f5",
        "lavender": "#7287fd",
        "text": "#4c4f69",
        "subtext1": "#5c5f77",
        "subtext0": "#6c6f85",
        "overlay2": "#7c7f93",
        "overlay1": "#8c8fa1",
        "overlay0": "#9ca0b0",
        "surface2": "#acb0be",
        "surface1": "#bcc0cc",
        "surface0": "#ccd0da",
        "base": "#eff1f5",
        "mantle": "#e6e9ef",
        "crust": "#dce0e8",
    },
    "frappe": {
        "rosewater": "#f2d5cf",
        "flamingo": "#eebebe",
        "pink": "#f4b8e4",
        "mauve": "#ca9ee6",
        "red": "#e78284",
        "maroon": "#ea999c",
        "peach": "#ef9f76",
        "green": "#a6d189",
        "teal": "#81c8be",
        "sky": "#99d1db",
        "sapphire": "#85c1dc",
        "blue": "#8caaee",
        "lavender": "#babbf1",
        "text": "#c6d0f5",
        "subtext1": "#b5bfe2",
        "subtext0": "#a5adce",
        "overlay2": "#949cbb",
        "overlay1": "#838ba7",
        "overlay0": "#737994",
        "surface2": "#626880",
        "surface1": "#51576d",
        "surface0": "#414559",
        "base": "#303446",
        "mantle": "#292c3c",
        "crust": "#232634",
    },
}


def _is_dark_mode():
    try:
        out = subprocess.run(
            ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"],
            capture_output=True,
            text=True,
            timeout=2,
        ).stdout.strip()
        return True if "dark" in out else False
    except Exception:
        return False


def _current_theme():
    return "frappe" if _is_dark_mode() else "latte"


colors = PALETTES[_current_theme()]

c.colors.statusbar.normal.bg = colors["base"]
c.colors.statusbar.command.bg = colors["base"]
c.colors.statusbar.command.fg = colors["text"]
c.colors.statusbar.normal.fg = colors["text"]
c.colors.statusbar.passthrough.fg = colors["teal"]
c.colors.statusbar.url.fg = colors["pink"]
c.colors.statusbar.url.success.https.fg = colors["pink"]
c.colors.statusbar.url.hover.fg = colors["blue"]
# c.statusbar.show = "always"
c.colors.tabs.even.bg = colors["base"]
c.colors.tabs.odd.bg = colors["base"]
c.colors.tabs.bar.bg = colors["base"]
c.colors.tabs.even.fg = colors["subtext1"]
c.colors.tabs.odd.fg = colors["subtext1"]
c.colors.tabs.selected.even.bg = colors["crust"]
c.colors.tabs.selected.odd.bg = colors["crust"]
c.colors.tabs.selected.even.fg = colors["blue"]
c.colors.tabs.selected.odd.fg = colors["blue"]
c.colors.hints.bg = colors["base"]
c.colors.hints.fg = colors["text"]
c.tabs.show = "multiple"

c.colors.completion.item.selected.match.fg = colors["teal"]
c.colors.completion.match.fg = colors["teal"]

c.colors.tabs.indicator.start = colors["green"]
c.colors.tabs.indicator.stop = colors["overlay0"]
c.colors.completion.odd.bg = colors["base"]
c.colors.completion.even.bg = colors["base"]
c.colors.completion.fg = colors["text"]
c.colors.completion.category.bg = colors["base"]
c.colors.completion.category.fg = colors["text"]
c.colors.completion.item.selected.bg = colors["base"]
c.colors.completion.item.selected.fg = colors["text"]

c.colors.messages.info.bg = colors["base"]
c.colors.messages.info.fg = colors["text"]
c.colors.messages.error.bg = colors["base"]
c.colors.messages.error.fg = colors["text"]
c.colors.downloads.error.bg = colors["base"]
c.colors.downloads.error.fg = colors["text"]

c.colors.downloads.bar.bg = colors["base"]
c.colors.downloads.start.bg = colors["green"]
c.colors.downloads.start.fg = colors["text"]
c.colors.downloads.stop.bg = colors["overlay0"]
c.colors.downloads.stop.fg = colors["text"]

c.colors.tooltip.bg = colors["base"]
c.colors.webpage.bg = colors["base"]
c.hints.border = colors["text"]

# c.url.start_pages = ""
# c.url.default_page = ""

c.tabs.title.format = "{audio}{current_title}"

c.url.searchengines = {
    # note - if you use duckduckgo, you can make use of its built in bangs, of which there are many! https://duckduckgo.com/bangs
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "!aw": "https://wiki.archlinux.org/?search={}",
    "!apkg": "https://archlinux.org/packages/?sort=&q={}&maintainer=&flagged=",
    "!gh": "https://github.com/search?o=desc&q={}&s=stars",
    "!yt": "https://www.youtube.com/results?search_query={}",
}

c.completion.open_categories = [
    "searchengines",
    "quickmarks",
    "bookmarks",
    "history",
    "filesystem",
]

config.load_autoconfig()  # load settings done via the gui

c.auto_save.session = True  # save tabs on quit/restart

# keybinding changes
# config.bind('=', 'cmd-set-text -s :open')
# config.bind('cc', 'hint images spawn sh -c "cliphist link {hint-url}"')
# config.bind('cs', 'cmd-set-text -s :config-source')
# config.bind('T', 'hint links tab')
# config.bind('pP', 'open -- {primary}')
# config.bind('pp', 'open -- {clipboard}')
# config.bind('pt', 'open -t -- {clipboard}')
# config.bind('qm', 'macro-record')
# config.bind('<ctrl-y>', 'spawn --userscript ytdl.sh')

# Custom commands
c.aliases["password"] = "mode-enter insert ;; spawn --detach rofi-rbw"

# keybinding
config.bind("gJ", "tab-move +")
config.bind("gK", "tab-move -")
config.bind("gm", "tab-move")
config.bind("ttb", "config-cycle tabs.show multiple never")
config.bind("tdt", "config-cycle colors.webpage.darkmode.enabled true false")

# dark mode setup
c.colors.webpage.darkmode.enabled = _is_dark_mode()
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "never"
c.colors.webpage.preferred_color_scheme = "dark" if _is_dark_mode() else "light"
no_darkmode_sites = [
    "*://brunojesus.pt/*",
]
for pattern in no_darkmode_sites:
    config.set("colors.webpage.darkmode.enabled", False, pattern)


# styles, cosmetics
# c.content.user_stylesheets = ["~/.config/qutebrowser/styles/youtube-tweaks.css"]
c.tabs.padding = {"top": 5, "bottom": 5, "left": 5, "right": 5}
c.tabs.indicator.width = 0  # no tab indicators
c.tabs.width = 200
c.tabs.position = "left"

# fonts
c.fonts.default_family = []
c.fonts.default_size = "12pt"
c.fonts.web.size.default = 18
c.fonts.web.family.fixed = "monospace"
c.fonts.web.family.sans_serif = ""
c.fonts.web.family.serif = ""
c.fonts.web.family.standard = ""

# privacy - adjust these settings based on your preference
# config.set("completion.cmd_history_max_items", 0)
# config.set("content.private_browsing", True)
config.set("content.webgl", False, "*")
config.set("content.canvas_reading", False)
config.set("content.geolocation", False)
config.set("content.webrtc_ip_handling_policy", "default-public-interface-only")
config.set("content.cookies.accept", "all")
config.set("content.cookies.store", True)
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36",
)
# config.set("content.javascript.enabled", False) # tsh keybind to toggle

c.content.blocking.enabled = True
c.content.blocking.method = 'adblock' # auto / adblock / both / hosts
# c.content.blocking.adblock.lists = [
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/legacy.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2021.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2022.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2023.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2024.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badware.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-cookies.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-others.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/quick-fixes.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt",
#         "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"]
