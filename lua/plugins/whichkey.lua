local settings = require("mivn.settings")

return {
	"folke/which-key.nvim",
	enabled = settings.plugin_enabled("which_key"),
	event = "VeryLazy",
	config = function()
		local options = settings.plugin_options("which_key")
		local spec = {
			{ "<leader>o", group = "Open / settings" },
			{ "<leader>w", group = "Windows" },
			{ "<leader>q", group = "Quit" },
		}

		if settings.plugin_enabled("telescope") then
			table.insert(spec, { "<leader>f", group = "Find" })
			table.insert(spec, { "<leader>g", group = "Git" })
		end
		if settings.plugin_enabled("lsp") then
			table.insert(spec, { "<leader>l", group = "Language tools" })
		end
		if settings.plugin_enabled("auto_session") then
			table.insert(spec, { "<leader>s", group = "Sessions" })
		end
		if settings.plugin_enabled("asm_debug") then
			table.insert(spec, { "<leader>a", group = "Assembly debugger" })
		end

		local setup = {
			delay = options.delay or 300,
			preset = options.preset or "modern",
			icons = { mappings = options.icons ~= false },
			layout = { spacing = options.spacing or 3, width = options.layout_width or { min = 20, max = 50 } },
			win = {
				border = options.border or "rounded",
				padding = options.padding or { 1, 2 },
				wo = { winblend = options.winblend or 0, winhighlight = "Normal:WhichKeyFloat,FloatBorder:WhichKeyBorder,Title:WhichKeyTitle" },
			},
			spec = spec,
		}
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		require("which-key").setup(setup)
	end,
}
