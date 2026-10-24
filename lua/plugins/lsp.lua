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

			local ensure_installed = { "pyright", "bashls", "lua_ls" }
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

			vim.lsp.config("bashls", {})
			vim.lsp.enable("bashls")

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
			vim.lsp.enable("lua_ls")

			local asm_lsp = vim.fn.exepath("asm-lsp")
			if asm_lsp ~= "" then
				vim.lsp.config("asm_lsp", {
					cmd = { asm_lsp },
					root_dir = function(bufnr, on_dir)
						local filename = vim.api.nvim_buf_get_name(bufnr)
						local root = vim.fs.root(filename, { ".asm-lsp.toml", ".git" })
						on_dir(root or vim.fs.dirname(filename))
					end,
				})
				vim.lsp.enable("asm_lsp")
			end
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

			local luasnip = require("luasnip")
			luasnip.config.setup({ history = true, update_events = "TextChanged,TextChangedI" })
			luasnip.add_snippets("asm", require("snippets.asm"))
			luasnip.add_snippets("python", require("snippets.python"))
			luasnip.add_snippets("c", require("snippets.c"))

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
					["<Tab>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						elseif cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
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
