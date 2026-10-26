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
			local preferences = require("mivn.settings").get().languages

			local servers = {
				{ id = "clangd", setting = "c" },
				{ id = "pyright", setting = "python" },
				{ id = "bashls", setting = "bash" },
				{ id = "lua_ls", setting = "lua" },
			}
			local ensure_installed = {}
			for _, server in ipairs(servers) do
				if server.id ~= "clangd" or not is_linux_aarch64 then
					table.insert(ensure_installed, server.id)
				end
			end

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				automatic_enable = false,
			})

			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			vim.lsp.config("clangd", {})
			vim.lsp.config("pyright", {})
			vim.lsp.config("bashls", {})
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
			for _, server in ipairs(servers) do
				if server.id ~= "clangd" or not is_linux_aarch64 or vim.fn.executable("clangd") == 1 then
					vim.lsp.enable(server.id, preferences[server.setting])
				end
			end

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
				vim.lsp.enable("asm_lsp", preferences.assembly)
			end
			vim.g.mivn_lsp_ready = true
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
			require("mivn.theme").apply()

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
