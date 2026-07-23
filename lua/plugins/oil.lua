return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- charge dès le démarrage pour pouvoir ouvrir nvim directement sur un dossier
	lazy = false,
	config = function()
		require("oil").setup({
			-- Oil remplace netrw comme explorateur par défaut
			default_file_explorer = true,

			view_options = {
				show_hidden = true,
				natural_order = true,
			},

			columns = {
				"icon",
				-- "permissions",
				-- "size",
				-- "mtime",
			},

			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,

			win_options = {
				wrap = true,
				winblend = 0,
			},

			-- Fenêtre flottante (utilisée par <leader>of), même style que
			-- toggleterm / noice : bordure arrondie, fond transparent
			float = {
				padding = 2,
				max_width = 90,
				max_height = 30,
				border = "rounded",
				win_options = {
					winblend = 0,
					winhighlight = "Normal:OilNormalFloat,FloatBorder:OilFloatBorder,FloatTitle:OilFloatTitle",
				},
			},

			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = { "actions.select", opts = { vertical = true } },
				["<C-h>"] = { "actions.select", opts = { horizontal = true } },
				["<C-t>"] = { "actions.select", opts = { tab = true } },
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["q"] = "<CMD>x<CR>",
				["<C-r>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = { "actions.cd", opts = { scope = "tab" } },
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
		})

		-- Palette Catppuccin Mocha, alignée sur le reste de la config
		local function set_oil_highlights()
			vim.api.nvim_set_hl(0, "OilFloatBorder", { fg = "#CBA6F7", bold = true })
			vim.api.nvim_set_hl(0, "OilFloatTitle", { fg = "#CBA6F7", bold = true })
			vim.api.nvim_set_hl(0, "OilNormalFloat", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "OilTitle", { fg = "#CBA6F7", bold = true })
			vim.api.nvim_set_hl(0, "OilDir", { fg = "#89B4FA", bold = true })
			vim.api.nvim_set_hl(0, "OilDirIcon", { fg = "#89B4FA" })
			vim.api.nvim_set_hl(0, "OilLink", { fg = "#94E2D5" })
			vim.api.nvim_set_hl(0, "OilLinkTarget", { fg = "#6C7086", italic = true })
			vim.api.nvim_set_hl(0, "OilCopy", { fg = "#F9E2AF", bold = true })
			vim.api.nvim_set_hl(0, "OilMove", { fg = "#F9E2AF", bold = true })
			vim.api.nvim_set_hl(0, "OilChange", { fg = "#A6F7B2", bold = true })
			vim.api.nvim_set_hl(0, "OilCreate", { fg = "#A6E3A1", bold = true })
			vim.api.nvim_set_hl(0, "OilDelete", { fg = "#F38BA8", bold = true })
			vim.api.nvim_set_hl(0, "OilPermissionNone", { fg = "#6C7086" })
			vim.api.nvim_set_hl(0, "OilPermissionRead", { fg = "#F9E2AF" })
			vim.api.nvim_set_hl(0, "OilPermissionWrite", { fg = "#F38BA8" })
			vim.api.nvim_set_hl(0, "OilPermissionExecute", { fg = "#A6E3A1" })
		end

		set_oil_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_oil_highlights,
		})
	end,
}
