local M = {}

local defaults = {
	theme = {
		flavour = "mocha",
		transparent_background = true,
		transparent_floats = true,
		colors = {
			primary = "#CBA6F7", secondary = "#A6F7B2", background = "#1E1E2E",
			text = "#CDD6F4", muted = "#6C7086", surface = "#313244",
			error = "#F38BA8", warning = "#F9E2AF", success = "#A6E3A1", info = "#89B4FA", visual = "#FAB387",
		},
	},
	dashboard = {
		language = "en",
		layout = "centered",
		show_logo = true,
		title = "MIVN your editor",
		animation = { enabled = true, effect = "glow", period_ms = 9000, width = 3 },
	},
	autosave = { enabled = true, delay_ms = 200 },
	languages = { assembly = true, c = true, cpp = true, python = true, bash = true, lua = true },
	plugins = {
		catppuccin = true, dashboard = true, which_key = true, noice = true,
		telescope = true, oil = true, toggleterm = true, treesitter = true,
		autopairs = true, conform = true, lint = true, lsp = true,
		completion = true, luasnip = true, friendly_snippets = true,
		asm_debug = true, auto_session = true,
		undotree = true, hlchunk = true, render_markdown = true,
	},
	plugin_options = {},
}

local config_path = vim.fn.stdpath("config") .. "/lua/mivn/user_config.lua"
local config = vim.deepcopy(defaults)

local function is_list(value)
	if vim.islist then
		return vim.islist(value)
	end
	for key in pairs(value) do
		if type(key) ~= "number" then
			return false
		end
	end
	return true
end

local function merge(base, override)
	if type(override) ~= "table" then
		return base
	end
	for key, value in pairs(override) do
		if type(value) == "table" and not is_list(value) then
			base[key] = merge(type(base[key]) == "table" and base[key] or {}, value)
		else
			base[key] = vim.deepcopy(value)
		end
	end
	return base
end

local function clamp_number(value, fallback, minimum, maximum)
	if type(value) ~= "number" then
		return fallback
	end
	return math.floor(math.max(minimum, math.min(maximum, value)))
end

local function valid_color(value)
	return type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil
end

local function normalize(raw)
	local result = merge(vim.deepcopy(defaults), raw)
	for key, fallback in pairs(defaults) do
		if type(fallback) == "table" and type(result[key]) ~= "table" then
			result[key] = vim.deepcopy(fallback)
		end
	end
	for key, fallback in pairs(defaults.theme) do
		if type(fallback) == "table" and type(result.theme[key]) ~= "table" then
			result.theme[key] = vim.deepcopy(fallback)
		end
	end
	if type(result.dashboard.animation) ~= "table" then
		result.dashboard.animation = vim.deepcopy(defaults.dashboard.animation)
	end
	if type(result.plugin_options) ~= "table" then
		result.plugin_options = {}
	end
	local table_options = {
		dashboard = { "setup" },
		catppuccin = { "integrations", "styles", "color_overrides", "highlight_overrides" },
		asm_debug = {},
		render_markdown = {},
		which_key = { "setup", "padding", "layout_width" },
		telescope = { "setup", "defaults", "extensions", "path_display", "borderchars" },
		oil = { "setup", "float" },
		toggleterm = { "setup" },
		treesitter = { "setup", "parsers" },
		autopairs = { "setup" },
		completion = { "setup" },
		conform = { "setup", "formatters_by_ft" },
		lint = { "linters_by_ft", "events" },
		lsp = { "mason", "mason_lspconfig", "capabilities", "servers" },
		auto_session = { "setup", "suppressed_dirs" },
		hlchunk = { "setup", "indent_colors" },
		noice = { "setup", "cmdline_position", "cmdline_size", "popupmenu_position", "popupmenu_size" },
	}
	for name, keys in pairs(table_options) do
		if type(result.plugin_options[name]) ~= "table" then
			result.plugin_options[name] = {}
		end
		for _, key in ipairs(keys) do
			if result.plugin_options[name][key] ~= nil and type(result.plugin_options[name][key]) ~= "table" then
				result.plugin_options[name][key] = {}
			end
		end
	end
	if not ({ mocha = true, macchiato = true, frappe = true, latte = true })[result.theme.flavour] then
		result.theme.flavour = defaults.theme.flavour
	end
	result.theme.transparent_background = result.theme.transparent_background ~= false
	result.theme.transparent_floats = result.theme.transparent_floats ~= false
	for key, fallback in pairs(defaults.theme.colors) do
		if not valid_color(result.theme.colors[key]) then
			result.theme.colors[key] = fallback
		end
	end
	if result.dashboard.language ~= "en" and result.dashboard.language ~= "fr" then
		result.dashboard.language = defaults.dashboard.language
	end
	if not ({ centered = true, compact = true, top = true })[result.dashboard.layout] then
		result.dashboard.layout = defaults.dashboard.layout
	end
	if type(result.dashboard.title) ~= "string" or result.dashboard.title == "" then
		result.dashboard.title = defaults.dashboard.title
	end
	result.dashboard.animation.enabled = result.dashboard.animation.enabled == true
	if result.dashboard.animation.effect ~= "glow" and result.dashboard.animation.effect ~= "off" then
		result.dashboard.animation.effect = defaults.dashboard.animation.effect
	end
	result.dashboard.animation.period_ms = clamp_number(result.dashboard.animation.period_ms, 9000, 4000, 30000)
	result.dashboard.animation.width = clamp_number(result.dashboard.animation.width, 3, 1, 8)
	result.autosave.enabled = result.autosave.enabled ~= false
	result.dashboard.show_logo = result.dashboard.show_logo ~= false
	result.autosave.delay_ms = clamp_number(result.autosave.delay_ms, 200, 50, 2000)
	for key, fallback in pairs(defaults.languages) do
		if type(result.languages[key]) ~= "boolean" then
			result.languages[key] = fallback
		end
	end
	for key in pairs(defaults.plugins) do
		if type(result.plugins[key]) ~= "boolean" then
			result.plugins[key] = true
		end
	end
	return result
end

local function read_config(fallback)
	local chunk, compile_error = loadfile(config_path)
	if not chunk then
		if vim.fn.filereadable(config_path) == 1 then
			vim.notify("MIVN settings syntax error; keeping the last valid settings: " .. tostring(compile_error), vim.log.levels.ERROR)
		end
		return vim.deepcopy(fallback or defaults), false
	end
	local ok, loaded = pcall(chunk)
	if not ok or type(loaded) ~= "table" then
		vim.notify("MIVN settings must return a Lua table; keeping the last valid settings.", vim.log.levels.ERROR)
		return vim.deepcopy(fallback or defaults), false
	end
	return normalize(loaded), true
end

config = read_config()

function M.get()
	return vim.deepcopy(config)
end

function M.path()
	return config_path
end

function M.plugin_enabled(name)
	-- The assembly debugger opens its executable picker with Telescope.
	if name == "asm_debug" and not config.plugins.telescope then
		return false
	end
	return config.plugins[name] ~= false
end

function M.plugin_options(name)
	local options = config.plugin_options[name]
	return type(options) == "table" and vim.deepcopy(options) or {}
end

local function apply_runtime(previous)
	local ok_theme, theme = pcall(require, "mivn.theme")
	if ok_theme then
		if config.plugins.catppuccin and package.loaded.catppuccin then
			pcall(theme.setup_colorscheme)
		else
			pcall(theme.apply)
		end
	end

	if config.plugins.dashboard and package.loaded.dashboard then
		local ok_dashboard, dashboard = pcall(require, "mivn.dashboard")
		if ok_dashboard then
			pcall(dashboard.setup)
			pcall(dashboard.refresh_open_dashboards)
		end
	end

	if vim.g.mivn_lsp_ready and config.plugins.lsp then
		local servers = {
			assembly = "asm_lsp", c = "clangd", cpp = "clangd", python = "pyright", bash = "bashls", lua = "lua_ls",
		}
		local enabled = {}
		local lsp_options = type(config.plugin_options.lsp) == "table" and config.plugin_options.lsp or {}
		local custom_servers = type(lsp_options.servers) == "table" and lsp_options.servers or {}
		for language, server in pairs(servers) do
			enabled[server] = enabled[server] or config.languages[language]
		end
		for server, value in pairs(enabled) do
			local server_options = custom_servers[server]
			if type(server_options) == "table" and server_options.enabled ~= nil then
				value = server_options.enabled == true
			end
			if server == "asm_lsp" and vim.fn.exepath("asm-lsp") == "" then
				value = false
			elseif server == "clangd" then
				local uname = vim.uv.os_uname()
				if uname.sysname == "Linux" and uname.machine == "aarch64" and vim.fn.executable("clangd") ~= 1 then
					value = false
				end
			end
			pcall(vim.lsp.enable, server, value)
		end
		local asm_options = custom_servers.asm_lsp
		if type(asm_options) == "table" and asm_options.enabled ~= nil then
			pcall(vim.lsp.enable, "asm_lsp", asm_options.enabled == true)
		end
		for server, options in pairs(custom_servers) do
			if not ({ asm_lsp = true, clangd = true, pyright = true, bashls = true, lua_ls = true })[server]
				and type(options) == "table" and options.enabled ~= nil then
				pcall(vim.lsp.enable, server, options.enabled == true)
			end
		end
	elseif vim.g.mivn_lsp_ready then
		for _, server in ipairs({ "asm_lsp", "clangd", "pyright", "bashls", "lua_ls" }) do
			pcall(vim.lsp.enable, server, false)
		end
		local lsp_options = type(config.plugin_options.lsp) == "table" and config.plugin_options.lsp or {}
		local custom_servers = type(lsp_options.servers) == "table" and lsp_options.servers or {}
		for server, options in pairs(custom_servers) do
			if not ({ asm_lsp = true, clangd = true, pyright = true, bashls = true, lua_ls = true })[server]
				and type(options) == "table" and options.enabled == true then
				pcall(vim.lsp.enable, server, false)
			end
		end
	end

	pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "MivnSettingsReloaded" })

	local changed = {}
	local restart_required = previous and not vim.deep_equal(previous.plugin_options, config.plugin_options)
	if previous then
		for name, enabled in pairs(config.plugins) do
			if previous.plugins[name] ~= enabled then
				changed[#changed + 1] = name
			end
		end
	end
	if #changed > 0 then
		table.sort(changed)
		vim.notify("Plugin switches saved (restart Neovim to apply): " .. table.concat(changed, ", "), vim.log.levels.INFO)
	elseif restart_required then
		vim.notify("Plugin options reloaded. Restart Neovim to apply all plugin changes.", vim.log.levels.INFO)
	else
		vim.notify("MIVN settings reloaded.", vim.log.levels.INFO)
	end
end

function M.reload()
	local previous = vim.deepcopy(config)
	local updated, valid = read_config(previous)
	if not valid then
		return false
	end
	config = updated
	apply_runtime(previous)
	return true
end

function M.open()
	vim.cmd("tabedit " .. vim.fn.fnameescape(config_path))
end

vim.api.nvim_create_user_command("MivnSettings", M.open, { desc = "Edit MIVN settings" })
vim.api.nvim_create_user_command("MivnSettingsReload", M.reload, { desc = "Reload MIVN settings" })

local group = vim.api.nvim_create_augroup("MivnSettings", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	pattern = "user_config.lua",
	callback = function(event)
		if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(event.buf), ":p") == vim.fn.fnamemodify(config_path, ":p") then
			M.reload()
		end
	end,
})

return M
