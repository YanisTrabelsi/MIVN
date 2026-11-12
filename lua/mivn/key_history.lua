local M = {}

local keys = {}
local namespace
local redraw_pending = false

local function key_limit()
	local ok, settings = pcall(require, "mivn.settings")
	if not ok then
		return 16, false
	end
	local config = settings.get().key_history or {}
	return config.size or 16, config.enabled == true
end

local function redraw()
	if redraw_pending then
		return
	end
	redraw_pending = true
	vim.schedule(function()
		redraw_pending = false
		vim.cmd.redrawstatus()
	end)
end

function M.setup()
	if namespace then
		return
	end
	namespace = vim.api.nvim_create_namespace("MivnKeyHistory")
	vim.on_key(function(_, typed)
		local limit, enabled = key_limit()
		if not enabled or typed == "" then
			return
		end
		keys[#keys + 1] = vim.fn.keytrans(typed)
		while #keys > limit do
			table.remove(keys, 1)
		end
		redraw()
	end, namespace)
	vim.api.nvim_create_autocmd("User", {
		pattern = "MivnSettingsReloaded",
		callback = redraw,
	})
end

function M.render(max_width)
	local _, enabled = key_limit()
	if not enabled or #keys == 0 then
		return "", 0
	end

	local visible = {}
	local width = 0
	for index = #keys, 1, -1 do
		local token = keys[index]
		local token_width = vim.fn.strdisplaywidth(token) + (#visible > 0 and 1 or 0)
		if width + token_width > max_width then
			break
		end
		table.insert(visible, 1, token)
		width = width + token_width
	end
	if #visible == 0 then
		return "", 0
	end

	local parts = {}
	for index, token in ipairs(visible) do
		if index > 1 then
			parts[#parts + 1] = "%#StatusKeyHistorySeparator# "
		end
		local highlight = index == #visible and "StatusKeyHistoryRecent" or "StatusKeyHistory"
		parts[#parts + 1] = "%#" .. highlight .. "#" .. token:gsub("%%", "%%%%")
	end
	return table.concat(parts), width
end

return M
