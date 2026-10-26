local settings = require("mivn.settings")

return {
	{
		"stevearc/conform.nvim",
		enabled = settings.plugin_enabled("conform"),
		event = { "BufWritePre" },
		opts = function()
			local options = settings.plugin_options("conform")
			local format_on_save
			if options.format_on_save ~= false then
				format_on_save = {
					timeout_ms = options.timeout_ms or 500,
					lsp_format = options.lsp_format or "fallback",
				}
			end
			local setup = {
				formatters_by_ft = options.formatters_by_ft or { python = { "ruff_format" } },
				format_on_save = format_on_save,
			}
			return vim.tbl_deep_extend("force", setup, options.setup or {})
		end,
	},
}
