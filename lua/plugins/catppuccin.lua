return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			integrations = {
				which_key = false,
			},
			term_colors = true,
			flavour = "mocha", -- latte, frappe, macchiato, mocha

			-- Modifier les couleurs globales
			color_overrides = {
				mocha = {
					text = "#FFFFFF",
					base = "#1E1E2E",
				},
			},

			-- Modifier des highlight groups spécifiques
			highlight_overrides = {
				mocha = function(colors)
					return {
						Comment = { fg = colors.lavender, style = { "italic" } },
						IblIndent = { fg = "#313244" },
						IblScope = { fg = "#CBA6F7" },
					}
				end,
			},
			styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
				comments = { "italic" }, -- Change the style of comments
				conditionals = { "italic" },
				loops = {},
				functions = { "italic", "underline" },
				keywords = {},
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
				-- miscs = {}, -- Uncomment to turn off hard-coded styles
			},
			lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
				virtual_text = {
					errors = { "italic" },
					hints = { "italic" },
					warnings = { "italic" },
					information = { "italic" },
					ok = { "italic" },
				},
				underlines = {
					errors = { "underline" },
					hints = { "underline" },
					warnings = { "underline" },
					information = { "underline" },
					ok = { "underline" },
				},
				inlay_hints = {
					background = true,
				},
			},
		})

		vim.cmd("colorscheme catppuccin")
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#A6F7B2" })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = "#A6F7B2" })
		vim.api.nvim_set_hl(0, "NoicePopup", { fg = "#A6F7B2" })
		vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = "#FFFFFF" })
		vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#A6F7B2", bold = true })
		vim.api.nvim_set_hl(0, "CmpItemKind", { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#CBA6F7" })
	end,
}
