return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			integrations = {
				which_key = false,
			},
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
					}
				end,
			},
		})

		vim.cmd("colorscheme catppuccin")
	end,
}
