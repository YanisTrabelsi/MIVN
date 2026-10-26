return {
	"windwp/nvim-autopairs",
	enabled = require("mivn.settings").plugin_enabled("autopairs"),
	event = "InsertEnter",
	config = function()
		local options = require("mivn.settings").plugin_options("autopairs")
		local setup = {
			check_ts = options.check_treesitter ~= false,
		}
		setup = vim.tbl_deep_extend("force", setup, options.setup or {})
		require("nvim-autopairs").setup(setup)
		if require("mivn.settings").plugin_enabled("completion") then
			local ok, cmp = pcall(require, "cmp")
			if ok then
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end
		end
	end,
}
