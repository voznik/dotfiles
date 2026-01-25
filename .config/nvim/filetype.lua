vim.filetype.add {
  extension = {
    foo = 'fooscript',
    bar = function(path, bufnr)
      if some_condition() then
        return 'barscript', function(bufnr)
          -- Set a buffer variable
          vim.b[bufnr].barscript_version = 2
        end
      end
      return 'bar'
    end,
  },
  filename = {
    ['.foorc'] = 'toml',
    ['$XDG_CONFIG_HOME/.config/waybar/config'] = 'json',
  },
  pattern = {
    -- Using an optional priority
    ['.*/etc/**/.*%.conf'] = { 'dosini', { priority = 10 } },
    -- A pattern containing an environment variable
    ['${XDG_CONFIG_HOME}/**/git'] = 'git',
    ['.*README.(%a+)'] = function(path, bufnr, ext)
      if ext == 'md' then
        return 'markdown'
      elseif ext == 'rst' then
        return 'rst'
      end
    end,
    -- -----
    ['**/requirements/*.txt'] = 'pip-requirements',
    ['*.resx'] = 'xml',
    ['*.yml.*'] = 'yaml',
    ['.prettierrc'] = 'json',
    ['*rc'] = 'shellscript',
    ['.*env*'] = 'dotenv',
    ['.*ignore'] = 'gitignore',
    ['.flake8*'] = 'ini',
    ['.stylelintrc'] = 'json',
    -- ['(jsonconfig|tsconfig|*-package).json'] = 'jsonc',
    ['Jenkinsfile*'] = 'jenkinsfile',
    ['config'] = 'shellscript',
    -- ['*-package.json', 'devcontainer.json', 'jsconfig.json', 'tsconfig.json'] = 'jsonc',
    ['*.tmpl'] = 'mustache',
  },
}
