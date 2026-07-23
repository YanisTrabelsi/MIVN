return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("notify").setup({
			background_colour = "#000000",
			timeout = 2000,
		})

		vim.keymap.set("n", "<C-\\>", function()
			require("notify").dismiss({ silent = true, pending = true })
		end)

		require("noice").setup({
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
			},
			views = {
				cmdline_popup = {
					position = {
						row = "95%",
						col = "50%",
					},
					size = {
						width = 25,
						height = "auto",
					},
				},
				popupmenu = {
					relative = "editor",
					position = {
						row = 8,
						col = "50%",
					},
					size = {
						width = 60,
						height = 10,
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
					},
				},
			},
		})
	end,
}
