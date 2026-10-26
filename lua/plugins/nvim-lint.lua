return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			python = { "flake8" },
		}

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
			group = vim.api.nvim_create_augroup("MivnLint", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
