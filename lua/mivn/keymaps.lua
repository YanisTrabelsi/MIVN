local M = {}

local arrow_keys = { "<Up>", "<Down>", "<Left>", "<Right>" }
local arrow_modes = { "n", "x", "s", "o" }
local arrow_map_description = "MIVN: use HJKL for navigation"

local function apply_key_group(keys, description, disabled)
	for _, mode in ipairs(arrow_modes) do
		for _, key in ipairs(keys) do
			local existing = vim.fn.maparg(key, mode, false, true)
			if disabled then
				vim.keymap.set(mode, key, "<Nop>", { desc = description, silent = true })
			elseif existing and existing.desc == description then
				vim.keymap.del(mode, key)
			end
		end
	end
end

function M.apply_navigation_settings()
	local navigation = require("mivn.settings").get().navigation
	apply_key_group(arrow_keys, arrow_map_description, navigation.disable_arrow_keys)
end

function M.setup()
	local settings = require("mivn.settings")
	local function map(lhs, rhs, description)
		vim.keymap.set("n", lhs, rhs, { desc = description, silent = true })
	end

	map("<leader>os", "<cmd>MivnSettings<cr>", "Edit MIVN settings")
	map("<leader>oc", function()
		vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua"))
	end, "Edit Neovim config")
	map("<leader>ww", "<cmd>update<cr>", "Save buffer")
	map("<leader>wh", "<cmd>wincmd h<cr>", "Focus left window")
	map("<leader>wj", "<cmd>wincmd j<cr>", "Focus lower window")
	map("<leader>wk", "<cmd>wincmd k<cr>", "Focus upper window")
	map("<leader>wl", "<cmd>wincmd l<cr>", "Focus right window")
	map("<leader>wH", "<cmd>wincmd H<cr>", "Move window to far left")
	map("<leader>wJ", "<cmd>wincmd J<cr>", "Move window to bottom")
	map("<leader>wK", "<cmd>wincmd K<cr>", "Move window to top")
	map("<leader>wL", "<cmd>wincmd L<cr>", "Move window to far right")
	map("<leader>w=", "<cmd>wincmd =<cr>", "Equalize window sizes")
	map("<leader>w+", "<cmd>resize +2<cr>", "Increase window height")
	map("<leader>w-", "<cmd>resize -2<cr>", "Decrease window height")
	map("<leader>w>", "<cmd>vertical resize +4<cr>", "Increase window width")
	map("<leader>w<", "<cmd>vertical resize -4<cr>", "Decrease window width")
	map("<leader>wv", "<cmd>vsplit<cr>", "Split vertically")
	map("<leader>ws", "<cmd>split<cr>", "Split horizontally")
	map("<leader>wq", "<cmd>close<cr>", "Close window")
	map("<leader>bd", "<cmd>bdelete<cr>", "Delete current buffer")
	map("<leader>bn", "<cmd>bnext<cr>", "Go to next buffer")
	map("<leader>bp", "<cmd>bprevious<cr>", "Go to previous buffer")
	map("<leader>to", "<cmd>tabnew<cr>", "Open new tab")
	map("<leader>tc", "<cmd>tabclose<cr>", "Close current tab")
	map("<leader>tn", "<cmd>tabnext<cr>", "Go to next tab")
	map("<leader>tp", "<cmd>tabprevious<cr>", "Go to previous tab")
	map("<leader>tf", "<cmd>tabfirst<cr>", "Go to first tab")
	map("<leader>tl", "<cmd>tablast<cr>", "Go to last tab")
	map("<leader>t>", "<cmd>tabmove +1<cr>", "Move tab right")
	map("<leader>t<", "<cmd>tabmove -1<cr>", "Move tab left")
	map("<leader>qq", "<cmd>qa<cr>", "Quit Neovim")

	M.apply_navigation_settings()
	local group = vim.api.nvim_create_augroup("MivnNavigationSettings", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MivnSettingsReloaded",
		callback = M.apply_navigation_settings,
	})

	if settings.plugin_enabled("dashboard") then
		map("<leader>od", "<cmd>Dashboard<cr>", "Open dashboard")
	end
	if settings.plugin_enabled("telescope") then
		map("<leader><leader>", "<cmd>Telescope find_files<cr>", "Find files")
		map("<leader>ff", "<cmd>Telescope find_files<cr>", "Find files")
		map("<leader>fr", "<cmd>Telescope oldfiles<cr>", "Recent files")
		map("<leader>fg", "<cmd>Telescope live_grep<cr>", "Search in files")
		map("<leader>fb", "<cmd>Telescope buffers<cr>", "Open buffers")
		map("<leader>bb", "<cmd>Telescope buffers<cr>", "Choose open buffer")
		map("<leader>fh", "<cmd>Telescope help_tags<cr>", "Help tags")
		map("<leader>gf", "<cmd>Telescope git_files<cr>", "Tracked files")
		map("<leader>gs", "<cmd>Telescope git_status<cr>", "Git status")
		map("<leader>gc", "<cmd>Telescope git_commits<cr>", "Git commits")
	else
		map("<leader>bb", "<cmd>buffers<cr>", "List open buffers")
	end
	if settings.plugin_enabled("oil") then
		map("<leader>of", "<cmd>Oil --float<cr>", "File explorer")
	end
	if settings.plugin_enabled("lsp") then
		map("<leader>lg", vim.lsp.buf.definition, "Go to definition")
		map("<leader>lR", vim.lsp.buf.references, "Find references")
		map("<leader>li", vim.lsp.buf.implementation, "Go to implementation")
		map("<leader>lt", vim.lsp.buf.type_definition, "Go to type definition")
		map("<leader>ld", vim.diagnostic.setloclist, "List diagnostics")
		map("<leader>ln", vim.diagnostic.goto_next, "Next diagnostic")
		map("<leader>lp", vim.diagnostic.goto_prev, "Previous diagnostic")
		map("<leader>lh", vim.lsp.buf.hover, "Hover documentation")
		map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
		map("<leader>la", vim.lsp.buf.code_action, "Code action")
		map("<leader>lf", function()
			if settings.plugin_enabled("conform") then
				require("conform").format({ async = true, lsp_format = "fallback" })
			else
				vim.lsp.buf.format({ async = true })
			end
		end, "Format buffer")
	end
	if settings.plugin_enabled("auto_session") then
		map("<leader>ss", "<cmd>AutoSession save<cr>", "Save session")
		map("<leader>sr", "<cmd>AutoSession restore<cr>", "Restore session")
		map("<leader>sf", "<cmd>AutoSession search<cr>", "Find session")
	end
end

return M
