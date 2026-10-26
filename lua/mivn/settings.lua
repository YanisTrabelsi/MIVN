local M = {}

local defaults = {
	flavour = "mocha",
	accent = "purple_green",
	dashboard_layout = "centered",
	dashboard_language = "en",
	dashboard_animation = true,
	autosave_delay_ms = 200,
	languages = {
		assembly = true,
		c = true,
		python = true,
		bash = true,
		lua = true,
	},
}

local flavours = { mocha = true, macchiato = true, frappe = true, latte = true }
local accents = {
	purple_green = { label = "Purple / green", primary = "#CBA6F7", secondary = "#A6F7B2" },
	blue_cyan = { label = "Blue / cyan", primary = "#89B4FA", secondary = "#74D7F0" },
	rose_peach = { label = "Rose / peach", primary = "#F38BA8", secondary = "#FAB387" },
}
local layouts = { centered = true, compact = true, top = true }
local languages = {
	assembly = { label = "Assembly", server = "asm_lsp", executable = "asm-lsp" },
	c = { label = "C / C++", server = "clangd", executable = "clangd" },
	python = { label = "Python", server = "pyright", executable = "pyright-langserver" },
	bash = { label = "Shell", server = "bashls", executable = "bash-language-server" },
	lua = { label = "Lua", server = "lua_ls", executable = "lua-language-server" },
}

local settings = vim.deepcopy(defaults)
local settings_path = vim.fn.stdpath("state") .. "/mivn-settings.json"

local function normalize(raw)
	if type(raw) ~= "table" then return vim.deepcopy(defaults) end
	local result = vim.deepcopy(defaults)
	if flavours[raw.flavour] then result.flavour = raw.flavour end
	if accents[raw.accent] then result.accent = raw.accent end
	if layouts[raw.dashboard_layout] then result.dashboard_layout = raw.dashboard_layout end
	if raw.dashboard_language == "en" or raw.dashboard_language == "fr" then
		result.dashboard_language = raw.dashboard_language
	end
	if type(raw.dashboard_animation) == "boolean" then result.dashboard_animation = raw.dashboard_animation end
	if raw.autosave_delay_ms == 100 or raw.autosave_delay_ms == 200 or raw.autosave_delay_ms == 400 then
		result.autosave_delay_ms = raw.autosave_delay_ms
	end
	if type(raw.languages) == "table" then
		for name in pairs(languages) do
			if type(raw.languages[name]) == "boolean" then result.languages[name] = raw.languages[name] end
		end
	end
	return result
end

local function load()
	if vim.fn.filereadable(settings_path) ~= 1 then return end
	local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(settings_path), "\n"))
	if ok then settings = normalize(decoded) end
end

local function save()
	local directory = vim.fn.fnamemodify(settings_path, ":h")
	vim.fn.mkdir(directory, "p")
	local ok, encoded = pcall(vim.json.encode, settings)
	if not ok then
		vim.notify("Could not encode MIVN settings: " .. tostring(encoded), vim.log.levels.ERROR)
		return false
	end
	local result = vim.fn.writefile({ encoded }, settings_path)
	if result ~= 0 then
		vim.notify("Could not save MIVN settings to " .. settings_path, vim.log.levels.ERROR)
		return false
	end
	return true
end

load()

function M.get()
	return vim.deepcopy(settings)
end

function M.palette()
	return vim.deepcopy(accents[settings.accent] or accents.purple_green)
end

local function apply_language(name, enabled)
	if not vim.g.mivn_lsp_ready then return end
	local info = languages[name]
	if not info then return end
	if enabled and vim.fn.executable(info.executable) ~= 1 then
		vim.notify(info.executable .. " is not on PATH. Install it, then restart Neovim to enable " .. info.label .. " support.", vim.log.levels.WARN)
		return
	end
	local ok, err = pcall(vim.lsp.enable, info.server, enabled)
	if not ok then
		vim.notify("Could not update " .. info.label .. " language support: " .. tostring(err), vim.log.levels.ERROR)
		return
	end
	if not enabled then
		for _, client in ipairs(vim.lsp.get_clients({ name = info.server })) do
			vim.lsp.stop_client(client.id)
		end
	end
end

function M.set(key, value)
	local previous = vim.deepcopy(settings)
	local changed_language
	if key == "flavour" and flavours[value] then
		settings.flavour = value
	elseif key == "accent" and accents[value] then
		settings.accent = value
	elseif key == "dashboard_layout" and layouts[value] then
		settings.dashboard_layout = value
	elseif key == "dashboard_language" and (value == "en" or value == "fr") then
		settings.dashboard_language = value
	elseif key == "dashboard_animation" and type(value) == "boolean" then
		settings.dashboard_animation = value
	elseif key == "autosave_delay_ms" and (value == 100 or value == 200 or value == 400) then
		settings.autosave_delay_ms = value
	elseif key == "language" and languages[value] then
		settings.languages[value] = not settings.languages[value]
		changed_language = value
	else
		return false
	end
	if not save() then
		settings = previous
		return false
	end

	if key == "flavour" or key == "accent" then
		local ok, theme = pcall(require, "mivn.theme")
		if ok then
			if key == "flavour" then theme.set_flavour(settings.flavour) else theme.apply() end
		end
	elseif key == "dashboard_layout" or key == "dashboard_language" then
		local ok, dashboard = pcall(require, "mivn.dashboard")
		if ok then pcall(dashboard.setup) end
	elseif key == "dashboard_animation" then
		local ok, dashboard = pcall(require, "mivn.dashboard")
		if ok then dashboard.refresh_animation() end
	end
	if changed_language then
		apply_language(changed_language, settings.languages[changed_language])
	end
	if key == "flavour" or key == "accent" or key == "dashboard_language" or key == "dashboard_layout" then
		pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "MivnSettingsChanged" })
	end
	return true
end

local page = { buffer = nil, return_buffer = nil }

local function tr(english, french)
	return settings.dashboard_language == "fr" and french or english
end

local function render_page()
	local buf = page.buffer
	if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
	local palette = M.palette()
	local lines = {
		"MIVN SETTINGS",
		"",
		tr("Personalize your editor. Changes are saved automatically.", "Personnalisez votre éditeur. Les changements sont sauvegardés automatiquement."),
		"",
		"APPEARANCE",
		"  c  " .. tr("Colors", "Couleurs") .. ": Catppuccin " .. settings.flavour .. " / " .. palette.label,
		"  d  " .. tr("Dashboard layout", "Disposition du dashboard") .. ": " .. settings.dashboard_layout,
		"  a  " .. tr("Subtle dashboard animation", "Animation discrète du dashboard") .. ": " .. (settings.dashboard_animation and tr("On", "Activée") or tr("Off", "Désactivée")),
		"  l  " .. tr("Dashboard language", "Langue du dashboard") .. ": " .. (settings.dashboard_language == "en" and "English" or "Français"),
		"",
		"LANGUAGE SERVERS",
	}
	for _, name in ipairs({ "assembly", "c", "python", "bash", "lua" }) do
		local info = languages[name]
		local mark = settings.languages[name] and "[x]" or "[ ]"
		lines[#lines + 1] = string.format("  %s %s  (%s)", mark, info.label, info.server)
	end
	table.insert(lines, "  g  " .. tr("Toggle a language server", "Activer/désactiver un serveur de langue"))
	table.insert(lines, "")
	table.insert(lines, "EDITING")
	table.insert(lines, "  s  " .. tr("Autosave delay outside Insert mode", "Délai d'autosauvegarde hors mode Insert") .. ": " .. settings.autosave_delay_ms .. " ms")
	table.insert(lines, "")
	table.insert(lines, tr("Notifications: Neovim default display", "Notifications : affichage natif de Neovim"))
	table.insert(lines, "")
	table.insert(lines, "  r  " .. tr("Reset settings", "Réinitialiser les réglages") .. "    q  " .. tr("Close settings tab", "Fermer l'onglet des réglages"))
	table.insert(lines, "")
	table.insert(lines, tr("Press a key or use <Enter> on an item.", "Appuyez sur une touche ou <Entrée> sur une option."))
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	local ns = vim.api.nvim_create_namespace("MivnSettings")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "MivnSettingsTitle", 0, 0, -1)
	for row, line in ipairs(lines) do
		if line == "APPEARANCE" or line == "LANGUAGE SERVERS" or line == "EDITING" then
			vim.api.nvim_buf_add_highlight(buf, ns, "MivnSettingsHeading", row - 1, 0, -1)
		elseif line:match("^%s+%[x%]") then
			vim.api.nvim_buf_add_highlight(buf, ns, "MivnSettingsEnabled", row - 1, 0, -1)
		end
	end
end

local function choose_flavour()
	local choices = { "mocha", "macchiato", "frappe", "latte" }
	vim.ui.select(choices, { prompt = tr("Catppuccin flavor", "Thème Catppuccin") }, function(choice)
		if not choice then return end
		M.set("flavour", choice)
		vim.ui.select({ "purple_green", "blue_cyan", "rose_peach" }, { prompt = tr("Accent colors", "Couleurs d'accentuation"), format_item = function(item)
			return accents[item].label
		end }, function(accent)
			if accent then M.set("accent", accent) end
			render_page()
		end)
	end)
end

local function choose_language()
	local choices = {}
	local names = { "assembly", "c", "python", "bash", "lua" }
	for _, name in ipairs(names) do
		choices[#choices + 1] = string.format("%s  %s  [%s]", name, languages[name].label, settings.languages[name] and "on" or "off")
	end
	vim.ui.select(choices, { prompt = tr("Toggle language server", "Activer/désactiver un serveur de langue") }, function(choice, index)
		if not choice or not index then return end
		M.set("language", names[index])
		render_page()
	end)
end

local function choose_autosave_delay()
	local choices = { 100, 200, 400 }
	vim.ui.select(choices, { prompt = tr("Autosave delay in milliseconds", "Délai d'autosauvegarde en millisecondes"), format_item = function(value)
		return tostring(value) .. " ms"
	end }, function(value)
		if value then M.set("autosave_delay_ms", value) end
		render_page()
	end)
end

local function close_page()
	local return_buffer = page.return_buffer
	page.buffer, page.return_buffer = nil, nil
	if vim.fn.tabpagenr("$") > 1 then
		vim.cmd("tabclose")
	else
		pcall(vim.api.nvim_buf_delete, page.buffer or vim.api.nvim_get_current_buf(), { force = true })
		vim.cmd("enew")
	end
	if return_buffer and vim.api.nvim_buf_is_valid(return_buffer) and vim.bo[return_buffer].filetype == "dashboard" then
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(return_buffer) then
				vim.api.nvim_set_current_buf(return_buffer)
				pcall(vim.cmd, "Dashboard")
			end
		end)
	end
end

function M.open()
	if page.buffer and vim.api.nvim_buf_is_valid(page.buffer) then
		local windows = vim.fn.win_findbuf(page.buffer)
		if windows[1] then
			vim.api.nvim_set_current_win(windows[1])
			return
		end
	end
	page.return_buffer = vim.api.nvim_get_current_buf()
	vim.cmd("tabnew")
	local buf = vim.api.nvim_get_current_buf()
	page.buffer = buf
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "mivn-settings"
	vim.api.nvim_buf_set_name(buf, "MIVN Settings")
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.wrap = false
	vim.wo.cursorline = true
	local function map(key, callback, description)
		vim.keymap.set("n", key, callback, { buffer = buf, silent = true, nowait = true, desc = description })
	end
	map("q", close_page, "Close MIVN settings")
	map("<Esc>", close_page, "Close MIVN settings")
	map("c", choose_flavour, "Change colors")
	map("d", function()
		vim.ui.select({ "centered", "compact", "top" }, { prompt = tr("Dashboard layout", "Disposition du dashboard") }, function(value)
			if value then M.set("dashboard_layout", value) end
			render_page()
		end)
	end, "Change dashboard layout")
	map("a", function() M.set("dashboard_animation", not settings.dashboard_animation); render_page() end, "Toggle dashboard animation")
	map("l", function()
		vim.ui.select({ { label = "English", value = "en" }, { label = "Français", value = "fr" } }, { prompt = tr("Dashboard language", "Langue du dashboard"), format_item = function(item)
			return item.label
		end }, function(item)
			if item then M.set("dashboard_language", item.value) end
			render_page()
		end)
	end, "Change dashboard language")
	map("g", choose_language, "Toggle a language server")
	map("s", choose_autosave_delay, "Change autosave delay")
	map("r", function()
		local previous = settings
		settings = vim.deepcopy(defaults)
		if not save() then
			settings = previous
			render_page()
			return
		end
		for name in pairs(languages) do apply_language(name, settings.languages[name]) end
		local ok, theme = pcall(require, "mivn.theme"); if ok then theme.set_flavour(settings.flavour) end
		local ok_dashboard, dashboard = pcall(require, "mivn.dashboard"); if ok_dashboard then pcall(dashboard.setup); dashboard.refresh_animation() end
		pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "MivnSettingsChanged" })
		render_page()
	end, "Reset MIVN settings")
	map("<CR>", function()
		local line = vim.api.nvim_win_get_cursor(0)[1]
		local current = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] or ""
		local key = current:match("^%s+([cdalgsr])%s")
		if key then vim.api.nvim_feedkeys(key, "mt", false) end
	end, "Activate setting on current line")
	render_page()
end

vim.api.nvim_create_user_command("MivnSettings", M.open, { desc = "Open MIVN settings" })

return M
