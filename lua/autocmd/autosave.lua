local group = vim.api.nvim_create_augroup("MivnAutoSave", { clear = true })
local timers = {}

local function schedule_save(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" or vim.bo[buf].buftype ~= "" or vim.bo[buf].readonly or not vim.bo[buf].modifiable then
		return
	end

	if timers[buf] then
		timers[buf]:stop()
	else
		timers[buf] = vim.loop.new_timer()
	end

	timers[buf]:start(800, 0, vim.schedule_wrap(function()
		if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then
			return
		end
		if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "n" then
			return
		end
		vim.api.nvim_buf_call(buf, function()
			vim.cmd("silent! update")
		end)
	end))
end

vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
	group = group,
	callback = function(event)
		schedule_save(event.buf)
	end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(event)
		local timer = timers[event.buf]
		if timer then
			timer:stop()
			timer:close()
			timers[event.buf] = nil
		end
	end,
})
