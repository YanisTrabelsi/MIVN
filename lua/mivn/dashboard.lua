local M = {}

local animation_group = vim.api.nvim_create_augroup("MivnDashboard", { clear = true })
local animation_namespace = vim.api.nvim_create_namespace("MivnDashboardTitleGlow")
local animation_timer
local animation_buffer
local refreshing_dashboards = false

local logo = {
	"    ███╗   ███╗ ██╗ ██╗   ██╗ ███╗  ██╗ ",
	"    ████╗ ████║ ██║ ██║   ██║ ████╗ ██║ ",
	"    ██╔████╔██║ ██║ ██║   ██║ ██╔██╗██║ ",
	"    ██║╚██╔╝██║ ██║ ╚██╗ ██╔╝ ██║╚████║ ",
	"    ██║ ╚═╝ ██║ ██║  ╚████╔╝  ██║ ╚███║ ",
	"    ╚═╝     ╚═╝ ╚═╝   ╚═══╝   ╚═╝  ╚══╝ ",
}

local function config()
	return require("mivn.settings").get()
end

local function stop_animation()
	if animation_timer then
		animation_timer:stop()
		animation_timer:close()
		animation_timer = nil
	end
	if animation_buffer and vim.api.nvim_buf_is_valid(animation_buffer) then
		vim.api.nvim_buf_clear_namespace(animation_buffer, animation_namespace, 0, -1)
	end
	animation_buffer = nil
end

local function title_line(buffer, title)
	for row, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) do
		local start_at, end_at = line:find(title, 1, true)
		if start_at then
			return row - 1, start_at - 1, end_at
		end
	end
end

local function draw_glow(buffer, title, width, period_ms, timer)
	if animation_timer ~= timer or not vim.api.nvim_buf_is_valid(buffer) then
		return
	end
	if vim.api.nvim_get_current_buf() ~= buffer or vim.bo[buffer].filetype ~= "dashboard" then
		stop_animation()
		return
	end

	local row, start_at = title_line(buffer, title)
	if not row then
		return
	end
	local length = vim.fn.strchars(title)
	if length < 1 then
		return
	end

	local period = math.max(period_ms, 4000) / 1000
	local phase = (vim.uv.hrtime() / 1e9 % period) / period
	local travel = phase < 0.5 and phase * 2 or (1 - phase) * 2
	local center = math.floor(travel * (length - 1) + 0.5)
	vim.api.nvim_buf_clear_namespace(buffer, animation_namespace, row, row + 1)

	for offset = -width, width do
		local index = center + offset
		if index >= 0 and index < length then
			local first_byte = vim.fn.byteidx(title, index)
			local last_byte = vim.fn.byteidx(title, index + 1)
			local group = math.abs(offset) == 0 and "DashboardTitleGlowCore"
				or math.abs(offset) == 1 and "DashboardTitleGlowSoft"
				or "DashboardTitleGlowWide"
			vim.api.nvim_buf_add_highlight(buffer, animation_namespace, group, row, start_at + first_byte, start_at + last_byte)
		end
	end
end

function M.refresh_animation()
	stop_animation()
	local current = vim.api.nvim_get_current_buf()
	local values = config()
	local animation = values.dashboard.animation
	if not animation.enabled or animation.effect ~= "glow" or vim.bo[current].filetype ~= "dashboard" then
		return
	end

	animation_buffer = current
	animation_timer = vim.uv.new_timer()
	local timer = animation_timer
	local title = values.dashboard.title
	local width = animation.width
	local period_ms = animation.period_ms
	timer:start(110, 110, vim.schedule_wrap(function()
		draw_glow(current, title, width, period_ms, timer)
	end))
end

function M.refresh_open_dashboards()
	if refreshing_dashboards then
		return
	end
	refreshing_dashboards = true
	for _, window in ipairs(vim.api.nvim_list_wins()) do
		local buffer = vim.api.nvim_win_get_buf(window)
		if vim.bo[buffer].filetype == "dashboard" then
			vim.api.nvim_win_call(window, function()
				pcall(vim.cmd, "Dashboard")
			end)
		end
	end
	refreshing_dashboards = false
	M.refresh_animation()
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave", "FileType" }, {
	group = animation_group,
	callback = function(event)
		local buffer = event.buf
		if (event.event == "BufEnter" or event.event == "FileType") and vim.bo[buffer].filetype == "dashboard" then
			vim.schedule(M.refresh_animation)
		elseif event.event == "BufLeave" and buffer == animation_buffer then
			stop_animation()
		end
	end,
})

local function translate(language, english, french)
	return language == "fr" and french or english
end

function M.setup()
	local values = config()
	local dashboard = values.dashboard
	local plugin_options = require("mivn.settings").plugin_options("dashboard")
	local header = {}
	if dashboard.show_logo then
		vim.list_extend(header, logo)
		header[#header + 1] = ""
	end
	header[#header + 1] = "      " .. dashboard.title .. "      "
	header[#header + 1] = ""

	local entries = {}
	if require("mivn.settings").plugin_enabled("telescope") then
		vim.list_extend(entries, {
			{ key = "f", desc = translate(dashboard.language, "Find file", "Chercher un fichier"), action = "Telescope find_files" },
			{ key = "r", desc = translate(dashboard.language, "Recent files", "Fichiers récents"), action = "Telescope oldfiles" },
			{ key = "g", desc = translate(dashboard.language, "Live grep", "Recherche dans les fichiers"), action = "Telescope live_grep" },
		})
	end
	vim.list_extend(entries, {
		{ key = "c", desc = translate(dashboard.language, "Config", "Configuration"), action = function()
			vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua"))
		end },
		{ key = "s", desc = translate(dashboard.language, "Edit MIVN settings", "Modifier les réglages MIVN"), action = function()
			require("mivn.settings").open()
		end },
		{ key = "q", desc = translate(dashboard.language, "Quit", "Quitter"), action = "qa" },
	})
	local center = {}
	for _, entry in ipairs(entries) do
		center[#center + 1] = {
			icon = "  ", icon_hl = "DashboardIcon", desc = entry.desc,
			desc_hl = "DashboardDesc", key = entry.key, key_hl = "DashboardKey", action = entry.action,
		}
	end

	if dashboard.layout == "compact" then
		header = { dashboard.title }
	end

	local setup = {
		theme = "doom",
		config = {
			header = header,
			center = center,
			vertical_center = dashboard.layout == "centered",
			footer = {
				"",
				"     " .. require("lazy").stats().loaded .. "/" .. require("lazy").stats().count .. " plugins loaded  ",
			},
		},
	}
	setup = vim.tbl_deep_extend("force", setup, plugin_options.setup or {})
	require("dashboard").setup(setup)
	require("mivn.theme").apply()
	M.refresh_animation()
end

return M
