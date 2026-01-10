local formatter = dofile(os.getenv("XDG_CONFIG_DIR") .. "/lua/formatter.lua")

local selected_or_hovered = ya.sync(function()
	local tab, urls = cx.active, {}
	for _, u in pairs(tab.selected) do
		urls[#urls + 1] = u
	end
	if #urls == 0 and tab.current.hovered then
		urls[1] = tab.current.hovered.url
	end
	return urls
end)

local function fail(s, ...)
	ya.notify({
		title = "Format",
		content = string.format(s, ...),
		level = "error",
		timeout = 5,
	})
end

return {
	entry = function()
		ya.emit("escape", { visual = true })

		local urls = selected_or_hovered()
		if #urls == 0 then
			return ya.notify({ title = "Format", content = "No file selected", level = "warn", timeout = 5 })
		end

		local confirm = ya.confirm({
			pos = { "center", w = 40, h = 10 },
			title = "Format",
			body = "Format selected file(s)?",
		})
		if not confirm then
			return
		end

		for _, u in ipairs(urls) do
			local ext = u.ext
			if ext and formatter.formatters[ext] then
				local success = formatter.format(tostring(u))
				if not success then
					fail("Failed to format: %s", tostring(u))
				end
			end
		end

		ya.notify({
			title = "Format",
			content = string.format("Formatted %d file(s)", #urls),
			level = "info",
			timeout = 2,
		})
	end,
}
