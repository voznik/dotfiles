-- https://github.com/ahmedkhalf/project.nvim
return {
  'ahmedkhalf/project.nvim',
  event = 'VeryLazy',
  config = function()
    require('project_nvim').setup {
      manual_mode = false,
      silent_chdir = true,
      detection_methods = { 'pattern', 'lsp' },
      -- pattern_get_current_dir_fn = function()
      --   local status, oil = pcall(require, 'oil')
      --
      --   if status then
      --     local dir = oil.get_current_dir()
      --
      --     if dir ~= nil then
      --       return dir
      --     end
      --   end
      --   return vim.fn.expand('%:p:h', true)
      -- end,
      show_hidden = false,
      datapath = vim.fn.stdpath 'data',
    }

    -- vim.utils.on_load('telescope.nvim', function()
    --   require('telescope').load_extension 'projects'
    -- end)
  end,
}
