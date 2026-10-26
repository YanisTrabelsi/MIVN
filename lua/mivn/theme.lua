local M = {}

local function palette()
	local ok, settings = pcall(require, "mivn.settings")
	if ok then
		return settings.palette()
	end
	return { primary = "#CBA6F7", secondary = "#A6F7B2" }
end

function M.apply()
	local colors = palette()
	local primary, secondary = colors.primary, colors.secondary
	local function set(name, value)
		vim.api.nvim_set_hl(0, name, value)
	end

	set("CursorLine", { underline = true, sp = secondary })
	set("StatusNormal", { fg = "#1E1E2E", bg = primary, bold = true })
	set("StatusInsert", { fg = "#1E1E2E", bg = secondary, bold = true })
	set("StatusVisual", { fg = "#1E1E2E", bg = "#FAB387", bold = true })
	set("StatusCommand", { fg = "#1E1E2E", bg = "#F38BA8", bold = true })
	set("StatusReplace", { fg = "#1E1E2E", bg = "#F38BA8", bold = true })
	set("StatusColumnPrimary", { fg = primary })
	set("StatusColumnSecondary", { fg = secondary })
	set("MIVNTabActive", { fg = secondary, bg = "NONE", bold = true })
	set("MIVNTabCorner", { fg = primary, bg = "NONE", bold = true })
	set("MIVNTabInactive", { fg = secondary, bg = "NONE" })
	set("MIVNTabModified", { fg = secondary, bg = "NONE" })
	set("WhichKeyBorder", { fg = primary })
	set("WhichKeyTitle", { fg = primary, bold = true })
	set("WhichKeyNormal", { bg = "NONE" })
	set("WhichKey", { fg = secondary, bold = true })
	set("WhichKeyDesc", { fg = "#CDD6F4" })
	set("WhichKeyGroup", { fg = "#FAB387", bold = true })
	set("WhichKeySeparator", { fg = "#6C7086" })
	set("WhichKeyFloat", { bg = "NONE" })
	set("TelescopeBorder", { fg = primary })
	set("TelescopePromptBorder", { fg = primary })
	set("TelescopeResultsBorder", { fg = primary })
	set("TelescopePreviewBorder", { fg = primary })
	set("TelescopePromptTitle", { fg = primary, bold = true })
	set("CmpBorder", { fg = primary })
	set("CmpDocBorder", { fg = primary })
	set("CmpItemAbbrMatch", { fg = secondary, bold = true })
	set("CmpItemKind", { fg = primary })
	set("CmpItemMenu", { fg = primary })
	set("NoiceCmdlinePopupBorder", { fg = primary })
	set("NoiceCmdlinePopupTitle", { fg = primary })
	set("NoiceCmdlineIcon", { fg = secondary })
	set("NoiceCmdlinePopup", { fg = secondary })
	set("NoicePopup", { fg = secondary })
	set("ToggleTermFloatBorder", { fg = primary, bold = true })
	set("OilFloatBorder", { fg = primary, bold = true })
	set("OilFloatTitle", { fg = primary, bold = true })
	set("OilTitle", { fg = primary, bold = true })
	set("OilChange", { fg = secondary, bold = true })
	set("DashboardHeader", { fg = primary, bold = true })
	set("DashboardKey", { fg = secondary, bold = true })
	set("MivnSettingsTitle", { fg = primary, bold = true })
	set("MivnSettingsHeading", { fg = secondary, bold = true })
	set("MivnSettingsEnabled", { fg = secondary })
	set("DashboardSettingsTitle", { fg = primary, bold = true })
	set("DashboardSettingsHeading", { fg = secondary, bold = true })
	set("DashboardSettingsEnabled", { fg = secondary })
	set("AsmDebugTitle", { fg = primary, bold = true })
	set("AsmDebugAccent", { fg = secondary, bold = true })
	set("AsmDebugCurrent", { fg = "#1E1E2E", bg = secondary, bold = true })
	set("AsmDebugBorder", { fg = primary })
	set("AsmDebugStatus", { fg = secondary, bold = true })
	set("AsmDebugRegister", { fg = primary, bold = true })

	vim.g.terminal_color_5 = primary
	vim.g.terminal_color_13 = primary
	vim.g.terminal_color_2 = secondary
	vim.g.terminal_color_10 = secondary
end

function M.set_flavour(flavour)
	vim.g.catppuccin_flavour = flavour
	local ok = pcall(vim.cmd.colorscheme, "catppuccin-" .. flavour)
	if not ok then
		pcall(vim.cmd.colorscheme, "catppuccin")
	end
	M.apply()
end

vim.api.nvim_create_augroup("MivnTheme", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = "MivnTheme",
	callback = function()
		vim.schedule(M.apply)
	end,
})
vim.api.nvim_create_autocmd("User", {
	group = "MivnTheme",
	pattern = "VeryLazy",
	callback = function()
		vim.schedule(M.apply)
	end,
})

return M
