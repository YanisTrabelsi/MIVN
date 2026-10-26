local options = require("mivn.settings").plugin_options("auto_session")

return {
	"rmagatti/auto-session",
	enabled = require("mivn.settings").plugin_enabled("auto_session"),
	lazy = false,

	---enables autocomplete for opts
	---@module "auto-session"
	---@type AutoSession.Config
	opts = vim.tbl_deep_extend("force", {
		auto_save = options.auto_save ~= false,
		auto_restore = options.auto_restore == true,
		suppressed_dirs = options.suppressed_dirs or { "~/", "~/Projects", "~/Downloads", "/" },
	}, options.setup or {}),
}
