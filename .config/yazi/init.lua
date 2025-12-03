-- DuckDB plugin configuration -- https://github.com/wylie102/duckdb.yazi/tree/main#configurationcustomisation
require("duckdb"):setup({
	mode = "summarized", -- "standart"|"summarized"
	cache_size = 1000
})
-- Git plugin setup
require("git"):setup()
th.git = th.git or {}
th.git.added_sign = ""
th.git.modified_sign = ""
th.git.deleted_sign = ""

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return ui.span(" -> " .. tostring(h.link_to)):fg("green")
	else
		return ""
	end
end, 3300, Status.LEFT)

Status:children_add(function()
	local h = cx.active.current.hovered
	return ui.Line({
		ui.Span(os.date("%d/%m/%y %H:%M", math.floor(h.cha.mtime))):fg("blue"),
		ui.Span(" "),
	})
end, 500, Status.RIGHT)
