return {
	name = "mivn-asm-debug",
	dir = vim.fn.stdpath("config"),
	enabled = require("mivn.settings").plugin_enabled("asm_debug"),
	lazy = false,
	dependencies = { "nvim-telescope/telescope.nvim" },

	config = function()
		require("asm_debug").setup()
	end,
}
