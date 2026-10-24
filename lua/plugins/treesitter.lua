return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,

	config = function()
		local ts = require("nvim-treesitter")
		local parsers = {
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
			"asm",
		}
		local supported = {}
		for _, parser in ipairs(parsers) do
			supported[parser] = true
		end
		supported.help = true -- Neovim's help buffers use the vimdoc parser.

		ts.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = vim.tbl_keys(supported),
			callback = function(event)
				if vim.api.nvim_buf_is_loaded(event.buf) then
					local ok = pcall(vim.treesitter.start, event.buf)
					if ok and vim.bo[event.buf].filetype ~= "asm" then
						vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end
			end,
		})

		ts.install(parsers):await(function()
			-- FileType may have fired before the asynchronous parser install finished.
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) and supported[vim.bo[buf].filetype] then
					local ok = pcall(vim.treesitter.start, buf)
					if ok and vim.bo[buf].filetype ~= "asm" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end
			end
		end)
	end,
}
