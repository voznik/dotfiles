return {
  'DrKJeff16/project.nvim',
  version = false, -- Get the latest release
  dependencies = { -- OPTIONAL
    -- 'nvim-lua/plenary.nvim',
    -- 'nvim-telescope/telescope.nvim',
    'ibhagwan/fzf-lua',
  },
  ---@module 'project'

  ---@type Project.Config.Options
  opts = {},
}

-- vim.keymap.set('n', '<leader>p', '<cmd>ProjectTelescope<cr>', { desc = '[ ] Find [P]rojects' })
