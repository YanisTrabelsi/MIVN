local statusline = "%!v:lua.require('statusline').render()"
local statuscolumn = "%!v:lua.require('statuscolumn').render()"
local group = vim.api.nvim_create_augroup("MivnStatusDisplay", { clear = true })

local function restore_status(window, buffer)
	if not vim.api.nvim_win_is_valid(window) or not vim.api.nvim_buf_is_valid(buffer) then
		return
	end
	if vim.api.nvim_win_get_buf(window) ~= buffer or vim.bo[buffer].filetype == "dashboard" then
		return
	end
	local is_terminal = vim.bo[buffer].buftype == "terminal"

	vim.wo[window].number = not is_terminal
	vim.wo[window].relativenumber = not is_terminal
	vim.wo[window].statuscolumn = is_terminal and "" or statuscolumn
	if is_terminal then
		vim.wo[window].signcolumn = "no"
	end
	vim.wo[window].statusline = statusline
	vim.o.laststatus = 3
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	group = group,
	callback = function(event)
		local window = vim.api.nvim_get_current_win()
		vim.schedule(function()
			restore_status(window, event.buf)
		end)
	end,
})
