return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")

		telescope.setup({
			defaults = {
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "bottom",
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
		require("mivn.theme").apply()
	end,
}
