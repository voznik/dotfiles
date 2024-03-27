return {
  -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'Mofiqul/dracula.nvim',
  lazy = false,
  priority = 1000,   -- Make sure to load this before all the other start plugins.
  config = function()
    local dracula = require 'dracula'
    dracula.setup {
      colors = dracula.colors(),
      transparent_bg = true,
      show_end_of_buffer = false,
      italic_comment = true,
      overrides = {},
    }
  end,
  init = function()
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    vim.cmd.colorscheme 'dracula'

    -- You can configure highlights by doing something like:
    vim.cmd.hi 'Comment gui=none'
  end

}
