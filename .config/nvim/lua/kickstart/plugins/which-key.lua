return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup()
    require('which-key').add {
      { '<leader>a', proxy = '<c-w>', group = '[W]indows [A]ctions' }, -- proxy to window mappings
      -- }
      -- Document existing key chains
      { '<leader>c', group = '[C]ode' },
      { '<leader>c_', hidden = true },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>d_', hidden = true },
      { '<leader>f', group = '[F]ile Actions' },
      { '<leader>f_', hidden = true },
      { '<leader>h', group = '[Git]signs' },
      { '<leader>h_', hidden = true },
      { '<leader>r', group = '[R]ename' },
      { '<leader>r_', hidden = true },
      { '<leader>s', group = '[S]earch' },
      { '<leader>s_', hidden = true },
      { '<leader>w', group = '[W]orkspace Symbols' },
      { '<leader>w_', hidden = true },
    }
  end,
}
