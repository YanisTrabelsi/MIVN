return {
	name = "mivn-asm-debug",
	dir = vim.fn.stdpath("config"),
	lazy = false,
	dependencies = { "nvim-telescope/telescope.nvim" },

	config = function()
		require("asm_debug").setup()
	end,
}
