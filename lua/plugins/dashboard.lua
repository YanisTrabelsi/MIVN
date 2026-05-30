return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("dashboard").setup({
			theme = "doom",
			config = {
				header = {
					"",
					"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
					"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
					"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
					"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
					"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
					"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
					"",
				},
				center = {
					{
						icon = "  ",
						desc = "Find file",
						key = "f",
						action = "Telescope find_files",
					},
					{
						icon = "  ",
						desc = "Recent files",
						key = "r",
						action = "Telescope oldfiles",
					},
					{
						icon = "  ",
						desc = "Live grep",
						key = "g",
						action = "Telescope live_grep",
					},
					{
						icon = "  ",
						desc = "Config",
						key = "c",
						action = "edit " .. vim.fn.stdpath("config") .. "/init.lua",
					},
					{
						icon = "  ",
						desc = "Quit",
						key = "q",
						action = "qa",
					},
				},
				footer = { "", "⚡ Neovim loaded fast." },
			},
		})

		-- Couleurs catppuccin
		vim.api.nvim_set_hl(0, "DashboardHeader",    { fg = "#CBA6F7" })
		vim.api.nvim_set_hl(0, "DashboardCenter",    { fg = "#CDD6F4" })
		vim.api.nvim_set_hl(0, "DashboardShortcut",  { fg = "#FAB387", bold = true })
		vim.api.nvim_set_hl(0, "DashboardFooter",    { fg = "#6C7086", italic = true })
	end,
}
