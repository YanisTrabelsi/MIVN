return {
	"nvim-telescope/telescope.nvim",
	enabled = require("mivn.settings").plugin_enabled("telescope"),
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local telescope = require("telescope")
		local options = require("mivn.settings").plugin_options("telescope")

		local defaults = {
				sorting_strategy = options.sorting_strategy or "ascending",
				layout_strategy = options.layout_strategy or "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = options.prompt_position or "bottom",
						preview_width = options.preview_width or 0.55,
						results_width = options.results_width or 0.45,
					},
					width = options.width or 0.85,
					height = options.height or 0.85,
					preview_cutoff = options.preview_cutoff or 120,
				},
				borderchars = options.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				winblend = options.winblend or 0,
				color_devicons = options.color_devicons ~= false,
				path_display = options.path_display or { "truncate" },
		}
		defaults = vim.tbl_deep_extend("force", defaults, options.defaults or {})
		local setup = { defaults = defaults, extensions = options.extensions or {} }
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		telescope.setup(setup)
		require("mivn.theme").apply()
	end,
}
