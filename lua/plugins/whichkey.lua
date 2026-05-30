return {
	"folke/which-key.nvim",
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

		local function set_wk_highlights()
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#CBA6F7" })
			vim.api.nvim_set_hl(0, "WhichKeyTitle", { fg = "#CBA6F7", bold = true })
			vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "WhichKey", { fg = "#A6F7B2", bold = true })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#CDD6F4" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#FAB387", bold = true })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#6C7086" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
		end

		set_wk_highlights()

		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_wk_highlights,
		})
		wk.add({
			-- Fichiers
			{ "<leader>f", group = "find" },
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

			-- Fenêtres
			{ "<leader>w", group = "window" },
			{ "<leader>wv", "<cmd>vsplit<cr>", desc = "Split vertical" },
			{ "<leader>ws", "<cmd>split<cr>", desc = "Split horizontal" },
			{ "<leader>wq", "<cmd>q<cr>", desc = "Close window" },
			{ "<leader>ww", "<cmd>w<cr>", desc = "Save" },

			-- Git
			{ "<leader>g", group = "git" },
			{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
			{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },

			-- Divers
			{ "<leader>q", "<cmd>q<cr>", desc = "Quit" },
			{ "<leader>Q", "<cmd>qa!<cr>", desc = "Quit all" },
			{ "<leader>e", "<cmd>Ex<cr>", desc = "Explorer" },
			{ "<leader>h", "<cmd>nohl<cr>", desc = "Clear highlights" },

			-- Navigation
			{ "<leader>wj", "<C-w>j", desc = "Move down" },
			{ "<leader>wk", "<C-w>k", desc = "Move up" },
			{ "<leader>wl", "<C-w>l", desc = "Move right" },
			{ "<leader>wh", "<C-w>h", desc = "Move left" },
		})
	end,
}
