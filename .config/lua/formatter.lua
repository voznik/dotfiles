-- Shared formatter module for mise and micro
local M = {}

-- Formatter configurations - ALL in one place
M.formatters = {
	json = "biome format --write",
	html = "biome format --write",
	htm = "biome format --write",
	css = "biome format --write",
	js = "biome format --write",
	mjs = "biome format --write",
	cjs = "biome format --write",
	ts = "biome format --write",
	mts = "biome format --write",
	cts = "biome format --write",
	jsx = "biome format --write",
	tsx = "biome format --write",
	vue = "biome format --write",
	yaml = "yq -i -y '.'",
	yml = "yq -i -y '.'",
	toml = "taplo format",
	go = "gofmt -w",
	rs = "rustfmt -v -l --backup --edition=2021",
	py = "ruff format",
	lua = "stylua",
	sh = "shfmt -w",
	fish = "fish_indent -w",
}

-- Format a file
function M.format(filepath)
	local ext = filepath:match("%.([^%.]+)$")
	if not ext then
		return false, "No extension"
	end

	local cmd = M.formatters[ext]
	if not cmd then
		return false, "Unsupported: ." .. ext
	end

	local result = os.execute(cmd .. " " .. filepath)
	return result == true or result == 0
end

return M
