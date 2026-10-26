return {
	"stevearc/oil.nvim",
	enabled = require("mivn.settings").plugin_enabled("oil"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- Load at startup so Neovim can open directly into a directory.
	lazy = false,
	config = function()
		local options = require("mivn.settings").plugin_options("oil")
		local float_options = type(options.float) == "table" and options.float or {}
		local setup = {
			-- Use Oil instead of netrw as the default file explorer.
			default_file_explorer = true,

			view_options = {
				show_hidden = options.show_hidden ~= false,
				natural_order = options.natural_order ~= false,
			},

			columns = {
				"icon",
				-- "permissions",
				-- "size",
				-- "mtime",
			},

			delete_to_trash = options.delete_to_trash ~= false,
			skip_confirm_for_simple_edits = options.skip_confirm_for_simple_edits ~= false,

			win_options = {
				wrap = true,
				winblend = 0,
			},

			-- Floating window (used by <leader>of), styled like toggleterm and
			-- noice with a rounded border and transparent background.
			float = {
				padding = float_options.padding or 2,
				max_width = float_options.max_width or 90,
				max_height = float_options.max_height or 30,
				border = float_options.border or "rounded",
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
		}
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		require("oil").setup(setup)

		-- Filetype colors remain semantic; accent colors come from mivn.theme.
		local function set_oil_highlights()
			local theme = require("mivn.settings").get().theme
			local colors = theme.colors
			local float_background = theme.transparent_floats and "NONE" or colors.surface
			vim.api.nvim_set_hl(0, "OilFloatBorder", { fg = colors.primary, bold = true })
			vim.api.nvim_set_hl(0, "OilFloatTitle", { fg = colors.primary, bold = true })
			vim.api.nvim_set_hl(0, "OilNormalFloat", { bg = float_background })
			vim.api.nvim_set_hl(0, "OilTitle", { fg = colors.primary, bold = true })
			vim.api.nvim_set_hl(0, "OilDir", { fg = colors.info, bold = true })
			vim.api.nvim_set_hl(0, "OilDirIcon", { fg = colors.info })
			vim.api.nvim_set_hl(0, "OilLink", { fg = colors.success })
			vim.api.nvim_set_hl(0, "OilLinkTarget", { fg = colors.muted, italic = true })
			vim.api.nvim_set_hl(0, "OilCopy", { fg = colors.warning, bold = true })
			vim.api.nvim_set_hl(0, "OilMove", { fg = colors.warning, bold = true })
			vim.api.nvim_set_hl(0, "OilChange", { fg = colors.secondary, bold = true })
			vim.api.nvim_set_hl(0, "OilCreate", { fg = colors.success, bold = true })
			vim.api.nvim_set_hl(0, "OilDelete", { fg = colors.error, bold = true })
			vim.api.nvim_set_hl(0, "OilPermissionNone", { fg = colors.muted })
			vim.api.nvim_set_hl(0, "OilPermissionRead", { fg = colors.warning })
			vim.api.nvim_set_hl(0, "OilPermissionWrite", { fg = colors.error })
			vim.api.nvim_set_hl(0, "OilPermissionExecute", { fg = colors.success })
		end

		set_oil_highlights()
		local highlight_group = vim.api.nvim_create_augroup("MivnOilHighlights", { clear = true })
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = highlight_group,
			callback = set_oil_highlights,
		})
		vim.api.nvim_create_autocmd("User", {
			group = highlight_group,
			pattern = "MivnSettingsReloaded",
			callback = set_oil_highlights,
		})
	end,
}
