local M = {}

function M.expand(filetype, trigger)
	local luasnip = require("luasnip")
	local buf = vim.api.nvim_get_current_buf()
	for _, snippet in ipairs(luasnip.get_snippets(filetype) or {}) do
		if snippet.trigger == trigger then
			vim.cmd("startinsert")
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_current_buf() == buf then
					luasnip.snip_expand(snippet)
				end
			end)
			return
		end
	end
	vim.notify(string.format("Snippet %q not found for %s", trigger, filetype), vim.log.levels.WARN)
end

return M
