local M = {}

local function mix(first, second, amount)
	local output = { "#" }
	for index = 2, 7, 2 do
		local left = tonumber(first:sub(index, index + 1), 16)
		local right = tonumber(second:sub(index, index + 1), 16)
		output[#output + 1] = string.format("%02X", math.floor(left * (1 - amount) + right * amount + 0.5))
	end
	return table.concat(output)
end

local function settings()
	local ok, module = pcall(require, "mivn.settings")
	if ok then
		return module.get()
	end
	return {
		theme = {
			flavour = "mocha",
			transparent_background = true,
			transparent_floats = true,
			colors = {
				primary = "#CBA6F7", secondary = "#A6F7B2", background = "#1E1E2E",
				text = "#CDD6F4", muted = "#6C7086", surface = "#313244",
				error = "#F38BA8", warning = "#F9E2AF", success = "#A6E3A1", info = "#89B4FA", visual = "#FAB387",
			},
		},
	}
end

function M.apply()
	local config = settings()
	local palette = config.theme.colors
	local primary, secondary = palette.primary, palette.secondary
	local float_background = config.theme.transparent_floats and "NONE" or palette.surface
	local function set(name, value)
		vim.api.nvim_set_hl(0, name, value)
	end

	set("CursorLine", { underline = true, sp = secondary })
	set("NormalFloat", { bg = float_background })
	set("FloatBorder", { fg = primary, bg = float_background })
	set("StatusNormal", { fg = palette.background, bg = primary, bold = true })
	set("StatusInsert", { fg = palette.background, bg = secondary, bold = true })
	set("StatusVisual", { fg = palette.background, bg = palette.visual, bold = true })
	set("StatusCommand", { fg = palette.background, bg = palette.error, bold = true })
	set("StatusReplace", { fg = palette.background, bg = palette.error, bold = true })
	set("StatusColumnPrimary", { fg = primary })
	set("StatusColumnSecondary", { fg = secondary })
	set("MIVNTabActive", { fg = secondary, bg = "NONE", bold = true })
	set("MIVNTabCorner", { fg = primary, bg = "NONE", bold = true })
	set("MIVNTabInactive", { fg = secondary, bg = "NONE" })
	set("MIVNTabModified", { fg = secondary, bg = "NONE" })
	set("WhichKeyBorder", { fg = primary })
	set("WhichKeyTitle", { fg = primary, bold = true })
	set("WhichKeyNormal", { bg = float_background })
	set("WhichKey", { fg = secondary, bold = true })
	set("WhichKeyDesc", { fg = palette.text })
	set("WhichKeyGroup", { fg = palette.visual, bold = true })
	set("WhichKeySeparator", { fg = palette.muted })
	set("WhichKeyFloat", { bg = float_background })
	set("TelescopeBorder", { fg = primary, bg = float_background })
	set("TelescopePromptBorder", { fg = primary, bg = float_background })
	set("TelescopeResultsBorder", { fg = primary, bg = float_background })
	set("TelescopePreviewBorder", { fg = primary, bg = float_background })
	set("TelescopePromptTitle", { fg = primary, bold = true })
	set("CmpNormal", { bg = float_background })
	set("CmpBorder", { fg = primary, bg = float_background })
	set("CmpDocBorder", { fg = primary, bg = float_background })
	set("CmpItemAbbrMatch", { fg = secondary, bold = true })
	set("CmpItemKind", { fg = primary })
	set("CmpItemMenu", { fg = primary })
	set("NoiceCmdlinePopupBorder", { fg = primary, bg = float_background })
	set("NoiceCmdlinePopupTitle", { fg = primary })
	set("NoiceCmdlineIcon", { fg = secondary })
	set("NoiceCmdlinePopup", { fg = secondary, bg = float_background })
	set("NoicePopup", { fg = secondary, bg = float_background })
	set("ToggleTermFloatBorder", { fg = primary, bg = float_background, bold = true })
	set("ToggleTermNormalFloat", { bg = float_background })
	set("OilFloatBorder", { fg = primary, bg = float_background, bold = true })
	set("OilFloatTitle", { fg = primary, bg = float_background, bold = true })
	set("OilNormalFloat", { bg = float_background })
	set("OilTitle", { fg = primary, bold = true })
	set("OilChange", { fg = secondary, bold = true })
	set("DashboardHeader", { fg = primary, bold = true })
	set("DashboardKey", { fg = secondary, bold = true })
	set("DashboardTitle", { fg = primary, bold = true })
	set("DashboardTitleGlowWide", { fg = mix(primary, palette.background, 0.55), bold = true })
	set("DashboardTitleGlowSoft", { fg = mix(primary, "#FFFFFF", 0.08), bold = true })
	set("DashboardTitleGlowCore", { fg = mix(primary, "#FFFFFF", 0.22), bold = true })
	set("DashboardFooter", { fg = palette.muted, italic = true })
	set("AsmDebugTitle", { fg = primary, bold = true })
	set("AsmDebugAccent", { fg = secondary, bold = true })
	set("AsmDebugCurrent", { fg = palette.background, bg = secondary, bold = true })
	set("AsmDebugBorder", { fg = primary })
	set("AsmDebugStatus", { fg = secondary, bold = true })
	set("AsmDebugRegister", { fg = primary, bold = true })

	vim.g.terminal_color_5 = primary
	vim.g.terminal_color_13 = primary
	vim.g.terminal_color_2 = secondary
	vim.g.terminal_color_10 = secondary
end

function M.setup_colorscheme()
	local config = settings()
	local ok, catppuccin = pcall(require, "catppuccin")
	if not ok then
		M.apply()
		return false
	end

	local palette = config.theme.colors
	local options = {
		flavour = config.theme.flavour,
		transparent_background = config.theme.transparent_background,
		term_colors = true,
		integrations = { which_key = false },
		color_overrides = {
			mocha = { text = palette.text, base = palette.background },
			macchiato = { text = palette.text, base = palette.background },
			frappe = { text = palette.text, base = palette.background },
			latte = { text = palette.text, base = palette.background },
		},
		highlight_overrides = {
			mocha = function(colors)
				return {
					Comment = { fg = colors.lavender, style = { "italic" } },
					IblIndent = { fg = "#313244" },
					IblScope = { fg = palette.primary },
				}
			end,
		},
		styles = {
			comments = { "italic" },
			conditionals = { "italic" },
			loops = {},
			functions = { "italic", "bold" },
			keywords = {},
			strings = {},
			variables = {},
			numbers = {},
			booleans = {},
			properties = {},
			types = {},
			operators = {},
		},
		lsp_styles = {
			virtual_text = {
				errors = { "italic" }, hints = { "italic" }, warnings = { "italic" },
				information = { "italic" }, ok = { "italic" },
			},
			underlines = {
				errors = { "underline" }, hints = { "underline" }, warnings = { "underline" },
				information = { "underline" }, ok = { "underline" },
			},
			inlay_hints = { background = true },
		},
	}
	options = vim.tbl_deep_extend("force", options, config.plugin_options.catppuccin or {})
	options.flavour = config.theme.flavour
	options.transparent_background = config.theme.transparent_background
	catppuccin.setup(options)
	vim.cmd.colorscheme("catppuccin")
	M.apply()
	return true
end

local group = vim.api.nvim_create_augroup("MivnTheme", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = function()
		vim.schedule(M.apply)
	end,
})
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "VeryLazy",
	callback = function()
		vim.schedule(M.apply)
	end,
})

return M
