-- lua/statuscolumn.lua
local M = {}

M.render = function()
	vim.api.nvim_set_hl(0, "StatusColumnPrimary", { fg = "#CBA6F7" })
	vim.api.nvim_set_hl(0, "StatusColumnSecondary", { fg = "#A6F7B2" })

	local lnum = vim.v.lnum
	local relnum = vim.v.relnum
	local total = vim.fn.line("$")
	local width = #tostring(total)

	local rel = string.format("%" .. width .. "d", relnum)

	local color = lnum % 2 == 0 and "%#StatusColumnPrimary#" or "%#StatusColumnSecondary#"

	return color .. rel .. "  "
end

return M
