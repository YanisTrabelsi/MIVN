-- lua/statuscolumn.lua
local M = {}

local function set_highlights()
	vim.api.nvim_set_hl(0, "StatusColumnPrimary", { fg = "#CBA6F7" })
	vim.api.nvim_set_hl(0, "StatusColumnSecondary", { fg = "#A6F7B2" })
end

set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("MivnStatusColumnHighlights", { clear = true }),
	callback = set_highlights,
})

M.render = function()
	local lnum = vim.v.lnum

	local color = lnum % 5 == 0 and "%#StatusColumnSecondary#" or "%#StatusColumnPrimary#"

	return color .. "%l" .. "  "
end

return M
