return {
	"catppuccin/nvim",
	name = "catppuccin",
	enabled = require("mivn.settings").plugin_enabled("catppuccin"),
	config = function()
		require("mivn.theme").setup_colorscheme()
	end,
}
