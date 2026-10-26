return {
	"mfussenegger/nvim-lint",
	enabled = require("mivn.settings").plugin_enabled("lint"),
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local options = require("mivn.settings").plugin_options("lint")

		lint.linters_by_ft = options.linters_by_ft or { python = { "flake8" } }

		vim.api.nvim_create_autocmd(options.events or { "BufEnter", "BufWritePost" }, {
			group = vim.api.nvim_create_augroup("MivnLint", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
