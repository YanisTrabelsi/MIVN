return {
	"shellRaining/hlchunk.nvim",
	event = "BufReadPre",
	config = function()
		require("hlchunk").setup({
			chunk = {
				enable = true,
				style = {
					{ fg = "#CBA6F7" }, -- chunk actif
					{ fg = "#F38BA8" }, -- erreur
				},
				chars = {
					horizontal_line = "─",
					vertical_line = "│",
					left_top = "╭",
					left_bottom = "╰",
					right_arrow = "─",
				},
				textobject = "",
				max_file_size = 1024 * 1024,
				error_sign = false,
			},
			indent = {
				enable = true,
				style = {
					{ fg = "#313244" },
					{ fg = "#3b3a52" },
					{ fg = "#45455a" },
				},
				chars = { "│" },
			},
			line_num = {
				enable = true,
				style = "#CBA6F7",
			},
			blank = {
				enable = false,
			},
		})

		-- Exclure certains filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"dashboard",
				"alpha",
				"snacks_dashboard",
				"help",
				"lazy",
				"mason",
				"terminal",
			},
			callback = function()
				vim.b.hlchunk_chunk_disable = true
				vim.b.hlchunk_indent_disable = true
				vim.b.hlchunk_line_num_disable = true
			end,
		})
	end,
}
