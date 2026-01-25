return {
	"DrKJeff16/project.nvim",
	version = false,
	main = "project",
	dependencies = {
		"ibhagwan/fzf-lua",
	},
	init = function()
		-- Create an autocommand group for the fix
		local project_fix_group = vim.api.nvim_create_augroup("ProjectYaziFix", { clear = true })

		-- This tells project.nvim to skip any buffer that is:
		-- 1. A terminal (like Yazi's internal window)
		-- 2. A file inside the Neovim config directory (to prevent errors while editing config)
		vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "FileType" }, {
			group = project_fix_group,
			pattern = { "yazi", "*/.config/nvim/*" },
			callback = function()
				vim.b.skip_project_nvim = true
			end,
		})
	end,
	opts = {
		silent_chdir = true,
		exclude_dirs = { "~/.cache/*", "/tmp/*", "/var/tmp/*", "~/.config/nvim/*" },
		detection_methods = { "lsp", "pattern" },
		patterns = { ".git", "mise.toml", "package.json" },
	},
}
