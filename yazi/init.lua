require("bunny"):setup({
  hops = {
    { key = "/", path = "/",                      desc = "Root" },
    { key = "r", path = "/run/media/bruno/",      desc = "Mounted devices" },
    { key = "~", path = "~",                      desc = "Home" },
    { key = "c", path = "~/dotfiles/",            desc = "Dotfiles" },
    { key = "d", path = "~/nextcloud/Documents/", desc = "Nextcloud documents" },
    -- key and path attributes are required, desc is optional
  },
  desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
  ephemeral = true,       -- Enable ephemeral hops, default is true
  tabs = true,            -- Enable tab hops, default is true
  notify = true,          -- Notify after hopping, default is false
  fuzzy_cmd = "fzf",      -- Fuzzy searching command, default is "fzf"
})
