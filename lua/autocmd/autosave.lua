local group = vim.api.nvim_create_augroup("MivnAutoSave", { clear = true })
local timers = {}

local function cleanup(buf)
	local timer = timers[buf]
	if timer then
		timer:stop()
		timer:close()
		timers[buf] = nil
	end
end

local function delay()
	local ok, settings = pcall(require, "mivn.settings")
	return ok and settings.get().autosave.delay_ms or 200
end

local function schedule_save(buf)
	local ok, settings = pcall(require, "mivn.settings")
	if ok and not settings.get().autosave.enabled then
		cleanup(buf)
		return
	end
	if not vim.api.nvim_buf_is_valid(buf) then
		cleanup(buf)
		return
	end
	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" or vim.bo[buf].buftype ~= "" or vim.bo[buf].readonly or not vim.bo[buf].modifiable then
		return
	end
	cleanup(buf)
	local timer = vim.uv.new_timer()
	timers[buf] = timer
	timer:start(delay(), 0, vim.schedule_wrap(function()
		if timers[buf] ~= timer then
			return
		end
		cleanup(buf)
		local settings_ok, current_settings = pcall(require, "mivn.settings")
		if settings_ok and not current_settings.get().autosave.enabled then
			return
		end
		if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then
			return
		end
		-- Never write while this buffer is in Insert mode: BufWritePre may format it.
		if vim.api.nvim_get_current_buf() == buf and vim.api.nvim_get_mode().mode:find("i", 1, true) then
			return
		end
		local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
			vim.cmd("silent update")
		end)
		if not ok then
			vim.notify("MIVN auto-save failed: " .. tostring(err), vim.log.levels.ERROR)
		end
	end))
end

vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufLeave" }, {
	group = group,
	callback = function(event)
		schedule_save(event.buf)
	end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(event)
		cleanup(event.buf)
	end,
})
