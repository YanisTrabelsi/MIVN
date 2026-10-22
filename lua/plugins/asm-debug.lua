return {
	name = "mivn-asm-debug",
	dir = vim.fn.stdpath("config"),
	lazy = false,

	config = function()
		require("asm_debug").setup()
	end,
}
