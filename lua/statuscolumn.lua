-- lua/statuscolumn.lua
local M = {}

M.render = function()
	local lnum = vim.v.lnum
	local relnum = vim.v.relnum
	local total = vim.fn.line("$") -- nombre total de lignes du fichier
	local width = #tostring(total) -- nombre de chiffres du plus grand numéro

	local abs = string.format("%" .. width .. "d", lnum)
	local rel = string.format("%" .. width .. "d", relnum)

	return "%#Comment#" .. abs .. " " .. "%#ErrorMsg#" .. rel .. "  "
end

return M
