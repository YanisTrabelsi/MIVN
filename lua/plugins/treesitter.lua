return {
	"nvim-treesitter/nvim-treesitter",
	commit = "f197a15",
	lazy = false,
	dev = true,
	dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter",
	build = function()
		vim.cmd("TSUpdate")
		local patch = vim.fn.stdpath("config") .. "/lua/patches/query_predicates.lua"
		local target = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/lua/nvim-treesitter/query_predicates.lua"
		if vim.loop.fs_stat(patch) then
			vim.loop.fs_copyfile(patch, target)
		end
	end,
	config = function()
		-- Réappliquer le patch au démarrage (au cas où)
		local patch = vim.fn.stdpath("config") .. "/lua/patches/query_predicates.lua"
		local target = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/lua/nvim-treesitter/query_predicates.lua"
		if vim.loop.fs_stat(patch) then
			vim.loop.fs_copyfile(patch, target)
		end

		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"python",
				"javascript",
				"typescript",
				"html",
				"css",
				"json",
				"yaml",
				"toml",
				"c",
				"cpp",
				"rust",
				"go",
				"java",
				"kotlin",
				"bash",
				"fish",
				"markdown",
				"markdown_inline",
				"sql",
				"graphql",
				"dockerfile",
				"terraform",
				"regex",
				"comment",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
