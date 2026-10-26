local M = {}

local animation_timer
local animation_group = vim.api.nvim_create_augroup("MivnDashboardAnimation", { clear = true })
local pulse = false

local function setting_values()
	local ok, settings = pcall(require, "mivn.settings")
	return ok and settings.get() or { dashboard_layout = "centered", dashboard_language = "en", dashboard_animation = false }
end

local function translate(language, english, french)
	return language == "fr" and french or english
end

local function set_footer_color()
	local ok, settings = pcall(require, "mivn.settings")
	local color = "#6C7086"
	if ok and settings.get().dashboard_animation and pulse then
		color = settings.palette().primary
	end
	vim.api.nvim_set_hl(0, "DashboardFooter", { fg = color, italic = true })
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave", "FileType" }, {
	group = animation_group,
	callback = function(event)
		local buf = event.buf
		if (event.event == "BufEnter" or event.event == "FileType") and vim.bo[buf].filetype == "dashboard" then
			M.refresh_animation()
		elseif event.event == "BufLeave" and vim.bo[buf].filetype == "dashboard" and animation_timer then
			animation_timer:stop()
			animation_timer:close()
			animation_timer = nil
		end
	end,
})

function M.refresh_animation()
	if animation_timer then
		animation_timer:stop()
		animation_timer:close()
		animation_timer = nil
	end
	pulse = false
	set_footer_color()
	local values = setting_values()
	local current = vim.api.nvim_get_current_buf()
	if not values.dashboard_animation or vim.bo[current].filetype ~= "dashboard" then
		return
	end

	animation_timer = vim.uv.new_timer()
	local timer = animation_timer
	timer:start(1200, 1200, vim.schedule_wrap(function()
		if animation_timer ~= timer then
			return
		end
		local current = vim.api.nvim_get_current_buf()
		if not vim.api.nvim_buf_is_valid(current) or vim.bo[current].filetype ~= "dashboard" then
			timer:stop()
			timer:close()
			animation_timer = nil
			pulse = false
			set_footer_color()
			return
		end
		pulse = not pulse
		set_footer_color()
	end))
end

local header = {
	"    ███╗   ███╗ ██╗ ██╗   ██╗ ███╗  ██╗ ",
	"    ████╗ ████║ ██║ ██║   ██║ ████╗ ██║ ",
	"    ██╔████╔██║ ██║ ██║   ██║ ██╔██╗██║ ",
	"    ██║╚██╔╝██║ ██║ ╚██╗ ██╔╝ ██║╚████║ ",
	"    ██║ ╚═╝ ██║ ██║  ╚████╔╝  ██║ ╚███║ ",
	"    ╚═╝     ╚═╝ ╚═╝   ╚═══╝   ╚═╝  ╚══╝ ",
	"",
	"     y o u r  e d i t o r  ",
	"",
}

function M.setup()
	local values = setting_values()
	local language = values.dashboard_language
	local entries = {
		{ key = "f", desc = translate(language, "Find file", "Chercher un fichier"), action = "Telescope find_files" },
		{ key = "r", desc = translate(language, "Recent files", "Fichiers récents"), action = "Telescope oldfiles" },
		{ key = "g", desc = translate(language, "Live grep", "Recherche dans les fichiers"), action = "Telescope live_grep" },
		{ key = "c", desc = translate(language, "Config", "Configuration"), action = function()
			vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua"))
		end },
		{ key = "s", desc = translate(language, "Personalize MIVN", "Personnaliser MIVN"), action = function()
			require("mivn.settings").open()
		end },
		{ key = "q", desc = translate(language, "Quit", "Quitter"), action = "qa" },
	}
	local center = {}
	for _, entry in ipairs(entries) do
		center[#center + 1] = {
			icon = "  ", icon_hl = "DashboardIcon", desc = entry.desc,
			desc_hl = "DashboardDesc", key = entry.key, key_hl = "DashboardKey", action = entry.action,
		}
	end

	local content_height = #header + #center * 2 + 3
	local padding = 0
	if values.dashboard_layout == "centered" then
		padding = math.max(0, math.floor((vim.o.lines - content_height) / 2))
	elseif values.dashboard_layout == "compact" then
		padding = 3
	end
	local padded_header = {}
	for _ = 1, padding do
		padded_header[#padded_header + 1] = ""
	end
	vim.list_extend(padded_header, header)

	require("dashboard").setup({
		theme = "doom",
		config = {
			header = padded_header,
			center = center,
			vertical_center = false,
			footer = {
				"",
				"     " .. require("lazy").stats().loaded .. "/" .. require("lazy").stats().count .. " plugins loaded  ",
			},
		},
	})

	vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#CDD6F4" })
	vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#89B4FA" })
	require("mivn.theme").apply()
	M.refresh_animation()
end

return M
