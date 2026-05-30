return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")
		local themes = require("telescope.themes")

		telescope.setup({
			defaults = {
				prompt_prefix = "  ",
				selection_caret = " ",
				entry_prefix = "  ",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.45,
					},
					width = 0.85,
					height = 0.85,
					preview_cutoff = 120,
				},
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				winblend = 0,
				color_devicons = true,
				path_display = { "truncate" },
			},
		})
		vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = "#CBA6F7", bold = true })
	end,
}
