local wezterm = require('wezterm')
local _config = require('config.appearance')

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(_config, {
   modules = {
      workspace = {
         enabled = false,
      },
   },
})

return _config
