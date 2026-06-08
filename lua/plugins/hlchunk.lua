return {
	"shellRaining/hlchunk.nvim",
	event = "BufReadPre",
	config = function()
		require("hlchunk").setup({
			chunk = {
				enable = true,
				style = "#CBA6F7",
			},
			indent = {
				enable = true,
				style = "#313244",
			},
			line_num = {
				enable = false,
			},
			blank = {
				enable = false,
			},
		})
	end,
}
