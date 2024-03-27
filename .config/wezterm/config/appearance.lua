local wezterm = require('wezterm')
local colors = require('colors.custom')
-- local fonts = require('config.fonts')

return {
   -- term = 'xterm-256color',
   animation_fps = 60,
   max_fps = 60,
   front_end = 'WebGpu',
   webgpu_power_preference = 'HighPerformance',

   -- color scheme
   -- colors = colors,
   color_scheme = 'Dracula (base16)',

   -- background
   window_background_opacity = 0.95,
   win32_system_backdrop = 'Acrylic',
   -- window_background_gradient = {
   --    colors = { '#1A1B26', '#282A36' },
   --    -- Specifices a Linear gradient starting in the top left corner.
   --    orientation = { Linear = { angle = -45.0 } },
   -- },
   background = {
      {
         source = { File = wezterm.config_dir .. '/backdrops/bg.png' },
      },
      {
         source = { Color = '#282A36' },
         height = '100%',
         width = '100%',
         opacity = 0.95,
      },
   },
   enable_tab_bar = true,
   -- scrollbar
   enable_scroll_bar = true,
   min_scroll_bar_height = '3cell',
   colors = {
      scrollbar_thumb = '#2A2B3D',
      tab_bar = {
         background = '#2A2B3D',
         active_tab = {
            bg_color = '#2b2042',
            fg_color = '#c0c0c0',
         },
         inactive_tab = {
            bg_color = '#1A1B26',
            fg_color = '#c0c0c0',
         },
      },
   },
   -- cursor
   default_cursor_style = 'BlinkingBlock',
   -- cursor_blink_ease_in = 'Constant',
   -- cursor_blink_ease_out = 'Constant',
   cursor_blink_rate = 500,

   -- window
   adjust_window_size_when_changing_font_size = false,
   window_decorations = 'RESIZE',
   initial_cols = 120,
   initial_rows = 36,
   window_padding = {
      left = 4,
      right = 12,
      top = 12,
      bottom = 4,
   },
   window_close_confirmation = 'AlwaysPrompt',
   window_frame = {
      active_titlebar_bg = '#2A2B3D',
      inactive_titlebar_bg = '#0F2536',
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   },
   inactive_pane_hsb = { saturation = 0.8, brightness = 1.0 },
}
