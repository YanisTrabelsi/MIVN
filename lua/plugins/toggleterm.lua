return {
	"akinsho/toggleterm.nvim",
	priority = 50,
	config = function()
		vim.opt.termguicolors = true

		require("toggleterm").setup({
			open_mapping = [[<leader>ot]],
			insert_mappings = false,
			direction = "float",
			shade_terminals = false,
			shell = vim.o.shell,
			float_opts = {
				border = "rounded",
				winblend = 0,
			},
			on_open = function(term)
				vim.api.nvim_set_option_value(
					"winhighlight",
					"FloatBorder:ToggleTermFloatBorder",
					{ win = term.window }
				)
			end,
		})

		-- Palette ANSI du terminal (Catppuccin Mocha)
		vim.g.terminal_color_0 = "#45475A"
		vim.g.terminal_color_1 = "#F38BA8"
		vim.g.terminal_color_2 = "#A6E3A1"
		vim.g.terminal_color_3 = "#F9E2AF"
		vim.g.terminal_color_4 = "#89B4FA"
		vim.g.terminal_color_5 = "#CBA6F7"
		vim.g.terminal_color_6 = "#94E2D5"
		vim.g.terminal_color_7 = "#BAC2DE"
		vim.g.terminal_color_8 = "#585B70"
		vim.g.terminal_color_9 = "#F38BA8"
		vim.g.terminal_color_10 = "#A6E3A1"
		vim.g.terminal_color_11 = "#F9E2AF"
		vim.g.terminal_color_12 = "#89B4FA"
		vim.g.terminal_color_13 = "#CBA6F7"
		vim.g.terminal_color_14 = "#94E2D5"
		vim.g.terminal_color_15 = "#A6ADC8"

		vim.api.nvim_set_hl(0, "ToggleTermFloatBorder", { fg = "#CBA6F7", bold = true })
		vim.api.nvim_set_hl(0, "ToggleTermNormalFloat", { bg = "NONE" })
	end,
}
