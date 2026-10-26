return {
	"folke/noice.nvim",
	event = "VeryLazy",
	enabled = require("mivn.settings").plugin_enabled("noice"),
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local options = require("mivn.settings").plugin_options("noice")
		local cmdline_size = options.cmdline_size or { width = 25, height = "auto" }
		local popupmenu_size = options.popupmenu_size or { width = 60, height = 10 }
		local setup = {
			notify = {
				-- Keep vim.notify and Neovim's native message display untouched.
				enabled = options.native_notifications == false,
			},
			cmdline = {
				enabled = options.cmdline ~= false,
				view = "cmdline_popup",
			},
			popupmenu = {
				enabled = options.popupmenu ~= false,
			},
			views = {
				cmdline_popup = {
					position = options.cmdline_position or { row = "95%", col = "50%" },
					size = cmdline_size,
					border = { style = options.border or "rounded" },
				},
				popupmenu = {
					relative = "editor",
					position = options.popupmenu_position or { row = 8, col = "50%" },
					size = popupmenu_size,
					border = {
						style = options.border or "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
					},
				},
			},
		}
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		require("noice").setup(setup)
	end,
}
