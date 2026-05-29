return {
	"akinsho/toggleterm.nvim",
	priority = 50,
	config = function()
		require("toggleterm").setup({
			open_mapping = [[<leader>t]],
			direction = "float",
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

		vim.api.nvim_set_hl(0, "ToggleTermFloatBorder", { fg = "#CBA6F7", bold = true })
		vim.api.nvim_set_hl(0, "ToggleTermNormalFloat", { bg = "NONE" })
	end,
}
