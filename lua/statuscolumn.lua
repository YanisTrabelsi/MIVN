-- lua/statuscolumn.lua
local M = {}

M.render = function()
	vim.api.nvim_set_hl(0, "StatusColumnPrimary", { fg = "#CBA6F7" })
	vim.api.nvim_set_hl(0, "StatusColumnSecondary", { fg = "#A6F7B2" })

	local lnum = vim.v.lnum

	local color = lnum % 5 == 0 and "%#StatusColumnSecondary#" or "%#StatusColumnPrimary#"

	return color .. "%l" .. "  "
end

return M
