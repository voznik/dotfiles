require("git"):setup()
th.git = th.git or {}
th.git.added_sign = ""
th.git.modified_sign = ""
th.git.deleted_sign = ""

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
