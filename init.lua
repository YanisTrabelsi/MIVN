vim.g.mapleader = " "

vim.filetype.add({
	extension = { asm = "asm", s = "asm" },
	pattern = { [".*%.S"] = "asm" },
})

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

-- Load every file in /lua/autocmd.
local autocmd_path = vim.fn.stdpath("config") .. "/lua/autocmd"
for _, file in ipairs(vim.fn.readdir(autocmd_path)) do
	dofile(autocmd_path .. "/" .. file)
end

-- Initialization
require("lazy").setup("plugins") -- Load all files under ./lua/plugins.

vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
})

vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.o.statuscolumn = "%!v:lua.require('statuscolumn').render()"
vim.o.statusline = "%!v:lua.require('statusline').render()"
vim.opt.tabstop = 4 -- A tab displays as four spaces.
vim.opt.shiftwidth = 4 -- The = operator also indents by four spaces.
vim.opt.cursorline = true
vim.api.nvim_set_hl(0, "CursorLine", { underline = true, sp = "#A6F7B2" })
vim.opt.laststatus = 3

vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.opt.guicursor = "n-v-c:block,i:ver25,r:hor20"
vim.opt.fillchars = { eob = " " }
--#CBA6F7 (primary)
--#A6F7B2 (secondary)
