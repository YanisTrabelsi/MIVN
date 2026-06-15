vim.g.mapleader = " "
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

--load every files in /lua/autocmd
local autocmd_path = vim.fn.stdpath("config") .. "/lua/autocmd"
for _, file in ipairs(vim.fn.readdir(autocmd_path)) do
	dofile(autocmd_path .. "/" .. file)
end

-- Initialisation
require("lazy").setup("plugins") -- loads every files in ./lua/plugins

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local ok, _ = pcall(vim.treesitter.start)
		if not ok then
		end
	end,
})

vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.o.statuscolumn = "%!v:lua.require('statuscolumn').render()"
vim.o.statusline = "%!v:lua.require('statusline').render()"
vim.opt.tabstop = 4 -- un tab = 4 espaces visuellement
vim.opt.shiftwidth = 4 -- indentation avec = aussi sur 4
vim.opt.cursorline = true
vim.api.nvim_set_hl(0, "CursorLine", { underline = true, sp = "#A6F7B2" })
vim.opt.laststatus = 3

vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.keymap.del("i", "<leader>t")
vim.opt.guicursor = "n-v-c:block,i:ver25,r:hor20"
--#CBA6F7 (primary)
--#A6F7B2 (secondary)
