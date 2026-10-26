return {
	"shellRaining/hlchunk.nvim",
	enabled = require("mivn.settings").plugin_enabled("hlchunk"),
	event = "BufReadPre",
	config = function()
		local options = require("mivn.settings").plugin_options("hlchunk")
		local colors = require("mivn.settings").get().theme.colors
		local setup = {
			chunk = {
				enable = options.chunk ~= false,
				style = {
					{ fg = colors.primary }, -- Active chunk.
					{ fg = options.error_color or colors.error }, -- Error.
				},
				chars = {
					horizontal_line = "─",
					vertical_line = "│",
					left_top = "╭",
					left_bottom = "╰",
					right_arrow = "─",
				},
				textobject = "",
				max_file_size = options.max_file_size or 1024 * 1024,
				error_sign = false,
			},
			indent = {
				enable = options.indent ~= false,
				style = {
					{ fg = options.indent_colors and options.indent_colors[1] or "#313244" },
					{ fg = options.indent_colors and options.indent_colors[2] or "#3b3a52" },
					{ fg = options.indent_colors and options.indent_colors[3] or "#45455a" },
				},
				chars = { "│" },
			},
			line_num = {
				enable = options.line_num ~= false,
				style = colors.primary,
			},
			blank = {
				enable = options.blank == true,
			},
		}
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		require("hlchunk").setup(setup)

		-- Exclude selected filetypes.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("MivnHlchunkFiletypes", { clear = true }),
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
