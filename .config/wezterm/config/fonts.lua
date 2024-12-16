local wezterm = require('wezterm')
local platform = require('utils.platform')

local font = 'MonaspiceKr Nerd Font Mono'
local font_size = platform().is_mac and 14 or 12

return {
   font = wezterm.font(font),
   font_size = font_size,
   -- harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
   harfbuzz_features = {
      'calt=1',
      'ss01=1',
      'ss02=1',
      'ss03=1',
      'ss04=1',
      'ss05=1',
      'ss06=1',
      'ss07=1',
      'ss08=1',
      'ss09=1',
      'liga=1',
   },

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   -- freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   -- freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
