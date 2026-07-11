return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		local ts = require("nvim-treesitter")
		ts.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		ts.install({
			"lua",
			"vim",
			"vimdoc",
			"bash",
			"python",
			"javascript",
			"typescript",
			"html",
			"css",
			"json",
			"markdown",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"lua",
				"vim",
				"vimdoc",
				"bash",
				"python",
				"javascript",
				"typescript",
				"html",
				"css",
				"json",
				"markdown",
			},
			callback = function()
				pcall(vim.treesitter.start)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
