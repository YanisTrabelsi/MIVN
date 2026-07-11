return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local header = {
			"    ███╗   ███╗ ██╗ ██╗   ██╗ ███╗  ██╗ ",
			"    ████╗ ████║ ██║ ██║   ██║ ████╗ ██║ ",
			"    ██╔████╔██║ ██║ ██║   ██║ ██╔██╗██║ ",
			"    ██║╚██╔╝██║ ██║ ╚██╗ ██╔╝ ██║╚████║ ",
			"    ██║ ╚═╝ ██║ ██║  ╚████╔╝  ██║ ╚███║ ",
			"    ╚═╝     ╚═╝ ╚═╝   ╚═══╝   ╚═╝  ╚══╝ ",
			"",
			"     y o u r  e d i t o r  ",
			"",
		}

		-- Hauteur totale du contenu (header + center + footer)
		-- center : 5 items * 2 lignes chacun = 10, + separateurs ~ 13
		local content_height = #header + 13 + 3
		local padding = math.floor((vim.o.lines - content_height) / 2)
		padding = math.max(0, padding)

		local padded_header = {}
		for _ = 1, padding do
			table.insert(padded_header, "")
		end
		for _, line in ipairs(header) do
			table.insert(padded_header, line)
		end

		require("dashboard").setup({
			theme = "doom",
			config = {
				header = padded_header,
				center = {
					{
						icon = "  ",
						icon_hl = "DashboardIcon",
						desc = "Find file",
						desc_hl = "DashboardDesc",
						key = "f",
						key_hl = "DashboardKey",
						action = "Telescope find_files",
					},
					{
						icon = "  ",
						icon_hl = "DashboardIcon",
						desc = "Recent files",
						desc_hl = "DashboardDesc",
						key = "r",
						key_hl = "DashboardKey",
						action = "Telescope oldfiles",
					},
					{
						icon = "  ",
						icon_hl = "DashboardIcon",
						desc = "Live grep",
						desc_hl = "DashboardDesc",
						key = "g",
						key_hl = "DashboardKey",
						action = "Telescope live_grep",
					},
					{
						icon = "  ",
						icon_hl = "DashboardIcon",
						desc = "Config",
						desc_hl = "DashboardDesc",
						key = "c",
						key_hl = "DashboardKey",
						action = "edit " .. vim.fn.stdpath("config") .. "/init.lua",
					},
					{
						icon = "  ",
						icon_hl = "DashboardIcon",
						desc = "Quit",
						desc_hl = "DashboardDesc",
						key = "q",
						key_hl = "DashboardKey",
						action = "qa",
					},
				},
				footer = {
					"",
						"     "
						.. require("lazy").stats().loaded
						.. "/"
						.. require("lazy").stats().count
						.. " plugins loaded  ",
				},
			},
		})

		vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#CBA6F7", bold = true })
		vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#CDD6F4" })
		vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#89B4FA" })
		vim.api.nvim_set_hl(0, "DashboardKey", { fg = "#A6E3A1", bold = true })
		vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#6C7086", italic = true })
	end,
}
