local wezterm = require('wezterm')
local colors = require('colors.custom')
local fonts = require('config.fonts')

return {
   -- term = 'xterm-256color',
   animation_fps = 12,
   -- max_fps = 60,
   front_end = 'WebGpu',
   -- webgpu_power_preference = 'HighPerformance',

   -- color scheme
   -- colors = colors,
   color_scheme = 'Dracula (base16)',

   -- background
   macos_window_background_blur = 30,
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
         background = '#21222c',
         active_tab = {
            bg_color = '#282a36',
            fg_color = '#c0c0c0',
         },
         inactive_tab = {
            bg_color = '#191a21',
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
   window_decorations = 'INTEGRATED_BUTTONS|RESIZE',
   initial_cols = 120,
   initial_rows = 36,
   window_padding = {
      left = 8,
      right = 12,
      top = 12,
      bottom = 8,
   },
   window_close_confirmation = 'NeverPrompt',
   window_frame = {
      active_titlebar_bg = '#191a21',
      inactive_titlebar_bg = '#0F2536',
      active_titlebar_border_bottom = '#191a21',
      font = fonts.font,
      -- font_size = fonts.font_size,
      border_left_width = '0.5cell',
      border_right_width = '0.5cell',
      border_bottom_height = '0.25cell',
      border_top_height = '0.25cell',
      border_left_color = '#191a21',
      border_right_color = '#191a21',
      border_bottom_color = '#191a21',
      border_top_color = '#191a21',
   },
   inactive_pane_hsb = { saturation = 0.8, brightness = 1.0 },
}
