-- lua/statuscolumn.lua
local M = {}

require("mivn.theme").apply()

M.render = function()
	local lnum = vim.v.lnum

	local color = lnum % 5 == 0 and "%#StatusColumnSecondary#" or "%#StatusColumnPrimary#"

	return color .. "%l" .. "  "
end

return M
