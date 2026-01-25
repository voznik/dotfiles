-- https://github.com/stevearc/oil.nvim?tab=readme-ov-file#options
return {
  'stevearc/oil.nvim',
  enabled = false,
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if prefer nvim-web-devicons
  config = function()
    require('oil').setup {
      default_file_explorer = true,
      keymaps = {
        -- Mappings can be a string
        -- ['~'] = '<cmd>edit $HOME<CR>',
        -- Mappings can be a function
        ['gz'] = function()
          require('oil').set_columns { 'icon', 'permissions', 'size', 'mtime' }
        end,
        -- You can pass additional opts to vim.keymap.set by using
        -- a table with the mapping as the first element.
        ['<leader>sp'] = {
          function()
            require('telescope.builtin').find_files {
              cwd = require('oil').get_current_dir(),
            }
          end,
          mode = 'n',
          nowait = true,
          desc = 'Find files in the current directory',
        },
        -- Mappings that are a string starting with "actions." will be
        -- one of the built-in actions, documented below.
        ['`'] = 'actions.tcd',
        -- Some actions have parameters. These are passed in via the `opts` key.
        ['<leader>:'] = {
          'actions.open_cmdline',
          opts = {
            shorten_path = true,
            modify = ':h',
          },
          desc = 'Open the command line with the current directory as an argument',
        },
      },
    }
  end,
}
