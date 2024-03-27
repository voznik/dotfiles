local wezterm = require('wezterm')
local platform = require('utils.platform')()
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_linux then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'ALT|CTRL'
end

local keys = {
   { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(1) },
   { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
   { key = 'PageUp', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(-1) },
   { key = 'PageDown', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
   { key = 'h', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Left') },
   { key = 'l', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Right') },
   { key = 'k', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Up') },
   { key = 'j', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Down') },
   {
      key = 'LeftArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection('Left'),
   },
   {
      key = 'RightArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection('Right'),
   },
   { key = 'UpArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Up') },
   {
      key = 'DownArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivatePaneDirection('Down'),
   },
   { key = 'LeftArrow', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize({ 'Left', 5 }) },
   {
      key = 'RightArrow',
      mods = 'ALT|SHIFT',
      action = wezterm.action.AdjustPaneSize({ 'Right', 5 }),
   },
   { key = 'UpArrow', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize({ 'Up', 5 }) },
   { key = 'DownArrow', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize({ 'Down', 5 }) },
   {
      key = 'd',
      mods = 'CTRL|ALT',
      action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   {
      key = 'r',
      mods = 'CTRL|ALT',
      action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },
   { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentPane({ confirm = false }) },
   { key = 'q', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane({ confirm = true }) },
   { key = 'b', mods = 'LEADER|CTRL', action = wezterm.action.SendString('\x02') },
   --
   { key = 'l', mods = 'CTRL|ALT', action = wezterm.action.ShowLauncher },
   { key = 'n', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnWindow },
   { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
   { key = 'Enter', mods = 'SUPER', action = wezterm.action.ActivateCopyMode },
   { key = 'C', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo('Clipboard') },
   { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom('Clipboard') },
   {
      key = 'u',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.CharSelect({
         copy_on_select = true,
         copy_to = 'ClipboardAndPrimarySelection',
      }),
   },
   {
      key = 'K',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ClearScrollback('ScrollbackAndViewport'),
   },
   { key = 'PageUp', mods = 'SHIFT', action = wezterm.action.ScrollByPage(-1) },
   { key = 'PageDown', mods = 'SHIFT', action = wezterm.action.ScrollByPage(1) },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
   -- Move mouse will only select text and not copy text to clipboard
   {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.SelectTextAtMouseCursor 'Cell',
   },
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.ExtendSelectionToMouseCursor 'Cell',
   },
   {
      event = { Drag = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.ExtendSelectionToMouseCursor 'Cell',
   },
   -- Triple Left click will select a line
   {
      event = { Down = { streak = 3, button = 'Left' } },
      mods = 'NONE',
      action = act.SelectTextAtMouseCursor 'Line',
   },
   {
      event = { Up = { streak = 3, button = 'Left' } },
      mods = 'NONE',
      action = act.SelectTextAtMouseCursor 'Line',
   },
   -- Double Left click will select a word
   {
      event = { Down = { streak = 2, button = 'Left' } },
      mods = 'NONE',
      action = act.SelectTextAtMouseCursor 'Word',
   },
   {
      event = { Up = { streak = 2, button = 'Left' } },
      mods = 'NONE',
      action = act.SelectTextAtMouseCursor 'Word',
   },
   -- Turn on the mouse wheel to scroll the screen
   {
      event = { Down = { streak = 1, button = { WheelUp = 1 } } },
      mods = 'NONE',
      action = act.ScrollByCurrentEventWheelDelta,
   },
   {
      event = { Down = { streak = 1, button = { WheelDown = 1 } } },
      mods = 'NONE',
      action = act.ScrollByCurrentEventWheelDelta,
   },
}

return {
   disable_default_key_bindings = true,
   disable_default_mouse_bindings = true,
   leader = { key = 'Space', mods = 'CTRL|SHIFT' },
   keys = keys,
   mouse_bindings = mouse_bindings,
}
