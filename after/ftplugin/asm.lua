vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.autoindent = true
vim.opt_local.smartindent = false
vim.opt_local.indentexpr = "v:lua.require'asm_indent'.get_indent()"

vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = true, desc = "Show ASM instruction documentation" })
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = true, desc = "Show ASM operand help" })
