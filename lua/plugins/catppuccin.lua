return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		local settings = require("mivn.settings").get()
		require("catppuccin").setup({
			transparent_background = true,
			integrations = {
				which_key = false,
			},
			term_colors = true,
			flavour = settings.flavour,

			-- Override global colors.
			color_overrides = {
				mocha = {
					text = "#FFFFFF",
					base = "#1E1E2E",
				},
			},

			-- Override specific highlight groups.
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
				functions = { "italic", "bold" },
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
		require("mivn.theme").apply()
	end,
}
