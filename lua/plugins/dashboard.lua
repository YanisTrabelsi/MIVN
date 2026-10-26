return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	enabled = require("mivn.settings").plugin_enabled("dashboard"),
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("mivn.dashboard").setup()
	end,
}
