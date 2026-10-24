local M = {}

local modes = {
	["n"] = "N",
	["i"] = "I",
	["v"] = "V",
	["V"] = "VL",
	["\22"] = "VB",
	["c"] = "C",
	["R"] = "R",
}

local mode_colors = {
	["n"] = "%#StatusNormal#",
	["i"] = "%#StatusInsert#",
	["v"] = "%#StatusVisual#",
	["V"] = "%#StatusVisual#",
	["c"] = "%#StatusCommand#",
	["R"] = "%#StatusReplace#",
}

local function set_highlights()
	vim.api.nvim_set_hl(0, "StatusNormal",  { fg = "#1E1E2E", bg = "#CBA6F7", bold = true })
	vim.api.nvim_set_hl(0, "StatusInsert",  { fg = "#1E1E2E", bg = "#A6E3A1", bold = true })
	vim.api.nvim_set_hl(0, "StatusVisual",  { fg = "#1E1E2E", bg = "#FAB387", bold = true })
	vim.api.nvim_set_hl(0, "StatusCommand", { fg = "#1E1E2E", bg = "#F38BA8", bold = true })
	vim.api.nvim_set_hl(0, "StatusReplace", { fg = "#1E1E2E", bg = "#F38BA8", bold = true })
	vim.api.nvim_set_hl(0, "StatusLine",    { fg = "#CDD6F4", bg = "" })
end

set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("MivnStatuslineHighlights", { clear = true }),
	callback = set_highlights,
})

M.render = function()

	local mode       = vim.fn.mode()
	local mode_label = modes[mode] or "?"
	local mode_hl    = mode_colors[mode] or "%#StatusLine#"

	local file_name  = vim.fn.expand("%:t")
	if file_name == "" then file_name = "[No Name]" end
	local modified   = vim.bo.modified and " [+]" or ""

	local line     = vim.fn.line(".")
	local col      = vim.fn.col(".")
	local line_str = tostring(line)
	local col_str  = tostring(col)

	local mode_part  = " " .. mode_label .. " "
	local file_part  = " " .. file_name:gsub("%%", "%%%%") .. modified .. " "
	local right_part = " " .. line_str .. ":" .. col_str .. " "

	local filler = vim.o.columns
		- vim.fn.strdisplaywidth(mode_part)
		- vim.fn.strdisplaywidth(" " .. file_name .. modified .. " ")
		- vim.fn.strdisplaywidth(right_part)

	return mode_hl .. mode_part
		.. "%#StatusLine#" .. file_part
		.. string.rep(" ", math.max(filler, 0))
		.. right_part
end

return M
