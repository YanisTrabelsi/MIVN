-- lua/statuscolumn.lua
local M = {}

M.render = function()
	vim.api.nvim_set_hl(0, "StatusColumnRel", { fg = "#CBA6F7" })
	vim.api.nvim_set_hl(0, "StatusColumnRel2", { fg = "#A6F7B2" })

	local lnum = vim.v.lnum
	local relnum = vim.v.relnum
	local total = vim.fn.line("$") -- nombre total de lignes du fichier
	local width = #tostring(total) -- nombre de chiffres du plus grand numéro

	local abs = string.format("%" .. width .. "d", lnum)
	local rel = string.format("%" .. width .. "d", relnum)

	return "%#StatusColumnRel2#" .. abs .. " " .. "%#StatusColumnRel#" .. rel .. "  "
end

return M
