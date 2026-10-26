local settings = require("mivn.settings")

return {
	{
		"neovim/nvim-lspconfig",
		enabled = settings.plugin_enabled("lsp"),
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local preferences = settings.get()
			local languages = preferences.languages
			local options = settings.plugin_options("lsp")
			local user_servers = type(options.servers) == "table" and options.servers or {}
			local mason_options = type(options.mason) == "table" and options.mason or {}
			require("mason").setup(mason_options)
			local uname = vim.uv.os_uname()
			local is_linux_arm = uname.sysname == "Linux" and uname.machine == "aarch64"
			local servers = {
				{ name = "clangd", languages = { "c", "cpp" } },
				{ name = "pyright", languages = { "python" } },
				{ name = "bashls", languages = { "bash" } },
				{ name = "lua_ls", languages = { "lua" } },
			}
			local known_servers = { asm_lsp = true }
			for _, server in ipairs(servers) do
				known_servers[server.name] = true
			end
			local ensure_installed = {}
			if type(options.ensure_installed) == "table" then
				ensure_installed = vim.deepcopy(options.ensure_installed)
			elseif options.ensure_installed ~= false then
				for _, server in ipairs(servers) do
					if server.name ~= "clangd" or not is_linux_arm then
						ensure_installed[#ensure_installed + 1] = server.name
					end
				end
			end
			for name, server_options in pairs(user_servers) do
				if not known_servers[name] and type(server_options) == "table" and server_options.ensure_installed == true then
					ensure_installed[#ensure_installed + 1] = name
				end
			end

			local mason_lspconfig_setup = {
				ensure_installed = ensure_installed,
				automatic_enable = false,
			}
			local custom_mason_lspconfig = type(options.mason_lspconfig) == "table" and options.mason_lspconfig or {}
			mason_lspconfig_setup = vim.tbl_deep_extend("force", mason_lspconfig_setup, custom_mason_lspconfig)
			require("mason-lspconfig").setup(mason_lspconfig_setup)
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local custom_capabilities = type(options.capabilities) == "table" and options.capabilities or {}
			capabilities = vim.tbl_deep_extend("force", capabilities, custom_capabilities)
			vim.lsp.config("*", { capabilities = capabilities })

			for _, server in ipairs(servers) do
				local raw_options = user_servers[server.name]
				local server_options = vim.deepcopy(type(raw_options) == "table" and raw_options or {})
				local configured_enabled = server_options.enabled
				server_options.enabled = nil
				server_options.ensure_installed = nil
				if server.name == "lua_ls" then
					local custom_settings = type(server_options.settings) == "table" and server_options.settings or {}
					server_options.settings = vim.tbl_deep_extend("force", {
						Lua = { diagnostics = { globals = { "vim" } } },
					}, custom_settings)
				end
				vim.lsp.config(server.name, server_options)
				local can_run = server.name ~= "clangd" or not is_linux_arm or vim.fn.executable("clangd") == 1
				local enabled = false
				for _, language in ipairs(server.languages) do
					enabled = enabled or languages[language] == true
				end
				if configured_enabled ~= nil then
					enabled = configured_enabled == true
				end
				if can_run then
					vim.lsp.enable(server.name, enabled)
				end
			end

			local asm_lsp = vim.fn.exepath("asm-lsp")
			if asm_lsp ~= "" then
				local asm_raw_options = user_servers.asm_lsp
				local asm_user_options = vim.deepcopy(type(asm_raw_options) == "table" and asm_raw_options or {})
				local asm_enabled = asm_user_options.enabled
				asm_user_options.enabled = nil
				asm_user_options.ensure_installed = nil
				local asm_options = vim.tbl_deep_extend("force", {
					cmd = { asm_lsp },
					root_dir = function(bufnr, on_dir)
						local filename = vim.api.nvim_buf_get_name(bufnr)
						local root = vim.fs.root(filename, { ".asm-lsp.toml", ".git" })
						on_dir(root or vim.fs.dirname(filename))
					end,
				}, asm_user_options)
				vim.lsp.config("asm_lsp", asm_options)
				local enable_asm = languages.assembly
				if asm_enabled == false then
					enable_asm = false
				elseif asm_enabled == true then
					enable_asm = true
				end
				vim.lsp.enable("asm_lsp", enable_asm)
			end

			for name, raw_options in pairs(user_servers) do
				if not known_servers[name] and type(raw_options) == "table" then
					local server_options = vim.deepcopy(raw_options)
					local enabled = server_options.enabled == true
					server_options.enabled = nil
					server_options.ensure_installed = nil
					vim.lsp.config(name, server_options)
					vim.lsp.enable(name, enabled)
				end
			end

			vim.g.mivn_lsp_ready = true
		end,
	},
}
