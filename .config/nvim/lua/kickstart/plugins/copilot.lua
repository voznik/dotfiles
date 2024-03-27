return {
  'zbirenbaum/copilot.lua',
  config = function()
    require('copilot').setup {
      suggestion = {
        auto_trigger = true,
        debounce = 150,
      },
      filetypes = {
        markdown = true,
        python = true,
        javascript = true,   -- allow specific filetype
        typescript = true,   -- allow specific filetype
        ['*'] = false,       -- disable for all other filetypes and ignore default `filetypes`
      },
    }
  end,
}
