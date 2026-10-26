local function update_cursor_color()
	local term = vim.env.TERM or ""
	if vim.fn.has("gui_running") == 1 or vim.fn.has("ttyout") == 0 or term == "" or term == "dumb" then
		return
	end
	local ok, settings = pcall(require, "mivn.settings")
	local color = ok and settings.get().theme.colors.primary or "#CBA6F7"
	io.write("\27]12;" .. color .. "\7")
	io.flush()
end

local group = vim.api.nvim_create_augroup("MivnCursorColor", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", { group = group, callback = update_cursor_color })
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "MivnSettingsReloaded",
	callback = update_cursor_color,
})
