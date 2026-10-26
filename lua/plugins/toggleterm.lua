return {
	"akinsho/toggleterm.nvim",
	enabled = require("mivn.settings").plugin_enabled("toggleterm"),
	priority = 50,
	config = function()
		local options = require("mivn.settings").plugin_options("toggleterm")
		vim.opt.termguicolors = true

		local setup = {
			open_mapping = options.open_mapping or [[<leader>ot]],
			insert_mappings = options.insert_mappings == true,
			direction = options.direction or "float",
			shade_terminals = options.shade_terminals == true,
			shell = options.shell or vim.o.shell,
			float_opts = {
				border = options.border or "rounded",
				winblend = options.winblend or 32,
			},
			on_open = function(term)
				vim.api.nvim_set_option_value(
					"winhighlight",
					"FloatBorder:ToggleTermFloatBorder",
					{ win = term.window }
				)
			end,
		}
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		require("toggleterm").setup(setup)
		if type(setup.open_mapping) == "string" then
			vim.keymap.set("n", setup.open_mapping, "<cmd>ToggleTerm<cr>", {
				desc = "Toggle terminal",
				silent = true,
			})
		end

		-- Terminal ANSI palette (Catppuccin Mocha).
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
		require("mivn.theme").apply()
	end,
}
