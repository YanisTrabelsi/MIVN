return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("mason").setup()

			local uname = vim.loop.os_uname()
			local is_linux_aarch64 = uname.sysname == "Linux" and uname.machine == "aarch64"

			local ensure_installed = { "pyright" }
			if not is_linux_aarch64 then
				table.insert(ensure_installed, "clangd")
			end

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
			})

			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			vim.lsp.config("clangd", {})
			vim.lsp.enable("clangd")

			vim.lsp.config("pyright", {})
			vim.lsp.enable("pyright")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#CBA6F7" })
			vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#CBA6F7" })

			require("luasnip.loaders.from_vscode").lazy_load()

			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = {
						border = "rounded",
						winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
					},
					documentation = {
						border = "rounded",
						winhighlight = "Normal:CmpNormal,FloatBorder:CmpDocBorder",
					},
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "cmdline" },
				},
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
}
