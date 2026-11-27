return {
	"mbbill/undotree",
	enabled = require("mivn.settings").plugin_enabled("undotree"),
	config = function()
		local undodir = vim.fn.stdpath("data") .. "/undodir"
		if vim.fn.isdirectory(undodir) == 0 then
			vim.fn.mkdir(undodir, "p")
		end

		vim.opt.undofile = true
		vim.opt.undodir = undodir
		vim.opt.undolevels = 1000000

		-- Open with the history focused and its diff visible. Navigating with j/k
		-- (or the arrow keys) immediately switches the buffer to the selected state.
		vim.g.undotree_WindowLayout = 2
		vim.g.undotree_SetFocusWhenToggle = 1
		vim.g.undotree_DiffAutoOpen = 1
		vim.g.undotree_DiffpanelHeight = 12
		vim.g.undotree_RelativeTimestamp = 1
		vim.g.undotree_ShortIndicators = 1
		vim.g.undotree_HelpLine = 1

		vim.cmd([[
			function! g:Undotree_CustomMap()
			  nmap <silent><buffer> j <Plug>UndotreeNextState<Plug>UndotreeEnter
			  nmap <silent><buffer> k <Plug>UndotreePreviousState<Plug>UndotreeEnter
			  nmap <silent><buffer> <Down> <Plug>UndotreeNextState<Plug>UndotreeEnter
			  nmap <silent><buffer> <Up> <Plug>UndotreePreviousState<Plug>UndotreeEnter
			  nmap <silent><buffer> <CR> <Plug>UndotreeEnter
			  nmap <silent><buffer> q <Plug>UndotreeClose
			endfunction
		]])

		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {
			desc = "Undo history (j/k previews states)",
		})
	end,
}
