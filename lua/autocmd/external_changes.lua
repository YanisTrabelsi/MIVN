-- Reload files changed outside Neovim whenever the buffer has no local edits.
vim.opt.autoread = true
vim.opt.confirm = false

local group = vim.api.nvim_create_augroup("MivnExternalChanges", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "CursorHold", "CursorHoldI" }, {
	group = group,
	command = "silent! checktime",
})

-- External changes take precedence; don't show Neovim's save/reload question.
vim.api.nvim_create_autocmd("FileChangedShell", {
	group = group,
	callback = function()
		if vim.v.fcs_reason == "changed" then
			vim.v.fcs_choice = "reload"
		end
	end,
})
