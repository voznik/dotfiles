-- INFO: can't use require in yazi lua
formatter = dofile(os.getenv("XDG_CONFIG_DIR") .. "/lua/formatter.lua")

-- require("folder-rules"):setup()

-- DuckDB plugin configuration -- https://github.com/wylie102/duckdb.yazi/tree/main#configurationcustomisation
require("duckdb"):setup({
	mode = "summarized", -- "standart"|"summarized"
	cache_size = 1000,
})

require("sshfs"):setup({
	sshfs_options = {
		"reconnect",
		"ServerAliveInterval=15",
		"ServerAliveCountMax=3",
	},
})

--- ===== https://github.com/boydaihungst/gvfs.yazi?tab=readme-ov-file#installation

require("gvfs"):setup({
	-- (Optional) Allowed keys to select device.
	-- which_keys = "1234567890qwertyuiopasdfghjklzxcvbnm-=[]\\;',./!@#$%^&*()_+{}|:\"<>?",

	-- (Optional) Table of blacklisted devices. These devices will be ignored in any actions
	-- List of device properties to match, or a string to match the device name:
	-- https://github.com/boydaihungst/gvfs.yazi/blob/master/main.lua#L144
	blacklist_devices = { { name = "Wireless Device", scheme = "mtp" }, { scheme = "file" }, "Device Name" },

	-- (Optional) Save file.
	-- Default: ~/.config/yazi/gvfs.private
	save_path = os.getenv("HOME") .. "/.config/yazi/gvfs.private",

	-- (Optional) Save file for automount devices. Use with `automount-when-cd` action.
	-- Default: ~/.config/yazi/gvfs_automounts.private
	save_path_automounts = os.getenv("HOME") .. "/.config/yazi/gvfs_automounts.private",

	-- (Optional) Input box position.
	-- Default: { "top-center", y = 3, w = 60 },
	-- Position, which is a table:
	-- 	`1`: Origin position, available values: "top-left", "top-center", "top-right",
	-- 	     "bottom-left", "bottom-center", "bottom-right", "center", and "hovered".
	--         "hovered" is the position of hovered file/folder
	-- 	`x`: X offset from the origin position.
	-- 	`y`: Y offset from the origin position.
	-- 	`w`: Width of the input.
	-- 	`h`: Height of the input.
	input_position = { "center", y = 0, w = 60 },

	-- (Optional) Select where to save passwords.
	-- Default: nil
	-- Available options: "keyring", "pass", or nil
	password_vault = "keyring",

	-- (Optional) Auto-save password after mount.
	-- Default: false
	save_password_autoconfirm = false,

	-- (Optional) mountpoint of gvfs. Default: /run/user/USER_ID/gvfs
	-- On some system it could be ~/.gvfs
	-- You can't decide this path, it will be created automatically. Only changed if you know where gvfs mountpoint is.
	-- Use command `ps aux | grep gvfs` to search for gvfs process and get the mountpoint path.
	root_mountpoint = (os.getenv("XDG_RUNTIME_DIR") or ("/run/user/" .. ya.uid())) .. "/gvfs",
})

-- -- Git plugin setup
-- require("git"):setup()
-- th.git = th.git or {}
-- th.git.added_sign = ""
-- th.git.modified_sign = ""
-- th.git.deleted_sign = ""

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

-- Status:children_add(function(self)
-- 	local h = self._current.hovered
-- 	if h and h.link_to then
-- 		return ui.span(" -> " .. tostring(h.link_to)):fg("green")
-- 	else
-- 		return ""
-- 	end
-- end, 3300, Status.LEFT)

Status:children_add(function()
	local h = cx.active.current.hovered
	if not h then
		return ""
	end
	return ui.Line({
		ui.Span(os.date("%d/%m/%y %H:%M", math.floor(h.cha.mtime))):fg("blue"),
		ui.Span(" "),
	})
end, 500, Status.RIGHT)
