return {
	"mbbill/undotree",
	config = function()
		local undodir = vim.fn.stdpath("data") .. "/undodir"
		if vim.fn.isdirectory(undodir) == 0 then
			vim.fn.mkdir(undodir, "p")
		end

		vim.opt.undofile = true
		vim.opt.undodir = undodir
		vim.opt.undolevels = 1000000

		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })
	end,
}
