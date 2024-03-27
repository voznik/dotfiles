-- nvim-scrollview is a Neovim plugin that displays interactive vertical scrollbars and signs. The plugin is customizable (see :help scrollview-configuration).
return {
  'dstein64/nvim-scrollview',
  config = function()
    require('scrollview').setup {
      marks_characters = {},
    }
  end,
}
