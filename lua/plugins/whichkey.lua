return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")

		wk.setup({
			triggers = {
				{ "<leader>", mode = { "n", "v" } },
			},
			win = {
				border = "rounded",
				padding = { 1, 2 },
			},
			layout = {
				spacing = 3,
			},
			icons = {
				mappings = true,
			},
		})

		require("mivn.theme").apply()
		wk.add({
			-- Files
			{ "<leader>f", group = "find" },
			{ "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },

			-- Buffers
			{ "<leader>b", group = "buffer" },
			{ "<leader>bd", "<cmd>bd<cr>", desc = "Delete buffer" },
			{ "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
			{ "<leader>bp", "<cmd>bprev<cr>", desc = "Prev buffer" },

			-- Windows
			{ "<leader>w", group = "window" },
			{ "<leader>wv", "<cmd>vsplit<cr><C-w>l", desc = "Split vertical" },
			{ "<leader>ws", "<cmd>split<cr><C-w>j", desc = "Split horizontal" },
			{ "<leader>wq", "<cmd>q<cr>", desc = "Close window" },
			{ "<leader>ww", "<cmd>w<cr>", desc = "Save" },
			{ "<leader>we", "<C-w>=", desc = "Equalize windows" },
			{ "<leader>w+", "<cmd>resize +5<cr>", desc = "Increase height" },
			{ "<leader>w-", "<cmd>resize -5<cr>", desc = "Decrease height" },
			{ "<leader>w>", "<cmd>vertical resize +5<cr>", desc = "Increase width" },
			{ "<leader>w<", "<cmd>vertical resize -5<cr>", desc = "Decrease width" },
			{ "<leader>wj", "<C-w>j", desc = "Go down" },
			{ "<leader>wk", "<C-w>k", desc = "Go up" },
			{ "<leader>wl", "<C-w>l", desc = "Go right" },
			{ "<leader>wh", "<C-w>h", desc = "Go left" },
			{ "<leader>wH", "<C-w><S-h>", desc = "Move left" },
			{ "<leader>wJ", "<C-w><S-j>", desc = "Move down" },
			{ "<leader>wK", "<C-w><S-k>", desc = "Move up" },
			{ "<leader>wL", "<C-w><S-l>", desc = "Move right" },

			-- Git
			{ "<leader>g", group = "git" },
			{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
			{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },

			-- Miscellaneous
			{ "<leader>q", "<cmd>qa<cr>", desc = "Quit all" },
			{ "<leader>=", "<cmd>normal mzgg=G`z<cr>", desc = "Format file" },
			{ "<leader>u", desc = "Undotree" },

			-- Snippets: expand directly from WhichKey without typing the trigger.
			{ "<leader>n", group = "snippets" },
			{ "<leader>na", group = "assembly" },
			{ "<leader>nam", function() require("snippets").expand("asm", "main") end, desc = "Main" },
			{ "<leader>naf", function() require("snippets").expand("asm", "func") end, desc = "Function" },
			{ "<leader>nar", function() require("snippets").expand("asm", "rodata") end, desc = "Read-only data" },
			{ "<leader>np", group = "python" },
			{ "<leader>npm", function() require("snippets").expand("python", "main") end, desc = "Main" },
			{ "<leader>npd", function() require("snippets").expand("python", "def") end, desc = "Function" },
			{ "<leader>npc", function() require("snippets").expand("python", "class") end, desc = "Class" },
			{ "<leader>npf", function() require("snippets").expand("python", "for") end, desc = "For loop" },
			{ "<leader>nc", group = "C" },
			{ "<leader>ncm", function() require("snippets").expand("c", "main") end, desc = "Main" },
			{ "<leader>ncf", function() require("snippets").expand("c", "func") end, desc = "Function" },
			{ "<leader>ncl", function() require("snippets").expand("c", "for") end, desc = "For loop" },

			-- Open
			{ "<leader>o", group = "open" },
			{ "<leader>ot", desc = "Terminal" },
			{ "<leader>oe", "<cmd>Oil<cr>", desc = "File explorer (Oil)" },
			{
				"<leader>of",
				function()
					require("oil").toggle_float()
				end,
				desc = "Floating file explorer (Oil)",
			},
			{ "<leader>ol", "<cmd>Lazy<cr>", desc = "Lazy" },
			{
				"<leader>oc",
				function()
					vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.stdpath("config")))
				end,
				desc = "Config Neovim",
			},
			{ "<leader>os", function() require("mivn.settings").open() end, desc = "Personalize MIVN" },

			-- Tabs
			{ "<leader>t", group = "tab" },
			{ "<leader>to", "<cmd>tabnew<cr>", desc = "New tab" },
			{ "<leader>tc", "<cmd>tabclose<cr>", desc = "Close tab" },
			{ "<leader>tn", "<cmd>tabnext<cr>", desc = "Next tab" },
			{ "<leader>tp", "<cmd>tabprevious<cr>", desc = "Prev tab" },
			{ "<leader>tf", "<cmd>tabfirst<cr>", desc = "First tab" },
			{ "<leader>tl", "<cmd>tablast<cr>", desc = "Last tab" },
			{ "<leader>tm", "<cmd>tabmove<cr>", desc = "Move tab" },

			-- Session
			{ "<leader>s", group = "session" },
			{ "<leader>ss", "<cmd>AutoSession save<cr>", desc = "Save session" },
			{ "<leader>sr", "<cmd>AutoSession restore<cr>", desc = "Restore session" },
			{ "<leader>se", "<cmd>AutoSession enable<cr>", desc = "Enable auto-session" },
			{ "<leader>sd", "<cmd>AutoSession disable<cr>", desc = "Disable auto-session" },
			{ "<leader>sD", "<cmd>AutoSession delete<cr>", desc = "Delete session" },
			{ "<leader>st", "<cmd>AutoSession toggle<cr>", desc = "Toggle auto-session" },
		})
	end,
}
