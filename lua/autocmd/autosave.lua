vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"},
{
	command = "silent! write"
})
