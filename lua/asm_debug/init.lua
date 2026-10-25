local M = {}

local S = {
	job = nil,
	backend = nil,
	seq = 0,
	pending = {},
	mi_pending = {},
	mi_token = 0,
	mi_stdout_buffer = "",
	dap_buffer = "",
	dap_expected = nil,
	dap_launched = false,
	frame_id = nil,
	thread_id = 1,
	buffers = {},
	windows = {},
	terminal_buf = nil,
	terminal_win = nil,
	terminal_job = nil,
	terminal_timer = nil,
	terminal_output = {},
	terminal_output_text = "",
	input_breakpoint_ids = {},
	syscall_breakpoint_ids = {},
	syscall_catchpoint_active = false,
	input_breakpoint_hit = false,
	input_syscall_breakpoint_hit = false,
	waiting_for_input = false,
	status_text = "Ready",
	follow_pc = true,
	follow_memory = true,
	stack_regions = {},
	executable = nil,
	architecture = nil,
	instructions = {},
	regs = {},
	pc = nil,
	sp = nil,
	fp = nil,
	started = false,
	running = false,
	step_request_pending = false,
	finished = false,
	finishing_after_main_return = false,
	awaiting_user_return = false,
	user_return_pc = nil,
	in_main = false,
	main_return_pc = nil,
	current_frame_name = nil,
	output = {},
	source_path = nil,
	source_lines = {},
	source_display = {},
	source_line = nil,
	closing = false,
}

local function notify(message, level)
	vim.schedule(function()
		vim.notify(message, level or vim.log.levels.INFO)
	end)
end

local function setup_highlights()
	local palette = {
		AsmDebugTitle = { fg = "#CBA6F7", bold = true },
		AsmDebugAccent = { fg = "#A6F7B2", bold = true },
		AsmDebugCurrent = { fg = "#1E1E2E", bg = "#A6F7B2", bold = true },
		-- Registers: distinct color categories.
		AsmDebugRegister = { fg = "#CBA6F7", bold = true },
		AsmDebugRegisterPC = { fg = "#F38BA8", bold = true },
		AsmDebugRegisterSP = { fg = "#A6E3A1", bold = true },
		AsmDebugRegisterFP = { fg = "#F9E2AF", bold = true },
		AsmDebugRegisterLR = { fg = "#89B4FA", bold = true },
		AsmDebugRegisterGeneral = { fg = "#74D7F0" },
		AsmDebugChanged = { fg = "#1E1E2E", bg = "#F9E2AF", bold = true },
		AsmDebugStackPointer = { fg = "#1E1E2E", bg = "#A6E3A1", bold = true },
		AsmDebugBasePointer = { fg = "#1E1E2E", bg = "#F9E2AF", bold = true },
		-- Memory dump: address, bytes, ASCII, and SP pointer.
		AsmDebugMemoryAddress = { fg = "#89B4FA", bold = true },
		AsmDebugMemoryPointer = { fg = "#1E1E2E", bg = "#A6E3A1", bold = true },
		AsmDebugMemoryFramePointer = { fg = "#1E1E2E", bg = "#F9E2AF", bold = true },
		AsmDebugMemoryZero = { fg = "#6C7086" },
		-- Rainbow: a stable color for each byte position (0–15).
		AsmDebugMemoryByte1 = { fg = "#FF6B6B", bold = true },
		AsmDebugMemoryByte2 = { fg = "#FF9F43", bold = true },
		AsmDebugMemoryByte3 = { fg = "#FFD93D", bold = true },
		AsmDebugMemoryByte4 = { fg = "#A8E66B", bold = true },
		AsmDebugMemoryByte5 = { fg = "#4ECDC4", bold = true },
		AsmDebugMemoryByte6 = { fg = "#45B7D1", bold = true },
		AsmDebugMemoryByte7 = { fg = "#5D8BF4", bold = true },
		AsmDebugMemoryByte8 = { fg = "#9B72CF", bold = true },
		AsmDebugMemoryByte9 = { fg = "#D66EAD", bold = true },
		AsmDebugMemoryByte10 = { fg = "#FF6B6B", bold = true },
		AsmDebugMemoryByte11 = { fg = "#FF9F43", bold = true },
		AsmDebugMemoryByte12 = { fg = "#FFD93D", bold = true },
		AsmDebugMemoryByte13 = { fg = "#A8E66B", bold = true },
		AsmDebugMemoryByte14 = { fg = "#4ECDC4", bold = true },
		AsmDebugMemoryByte15 = { fg = "#45B7D1", bold = true },
		AsmDebugMemoryByte16 = { fg = "#5D8BF4", bold = true },
		AsmDebugMemoryAscii1 = { fg = "#FF6B6B", bold = true },
		AsmDebugMemoryAscii2 = { fg = "#FF9F43", bold = true },
		AsmDebugMemoryAscii3 = { fg = "#FFD93D", bold = true },
		AsmDebugMemoryAscii4 = { fg = "#A8E66B", bold = true },
		AsmDebugMemoryAscii5 = { fg = "#4ECDC4", bold = true },
		AsmDebugMemoryAscii6 = { fg = "#45B7D1", bold = true },
		AsmDebugMemoryAscii7 = { fg = "#5D8BF4", bold = true },
		AsmDebugMemoryAscii8 = { fg = "#9B72CF", bold = true },
		AsmDebugMemoryAscii9 = { fg = "#D66EAD", bold = true },
		AsmDebugMemoryAscii10 = { fg = "#FF6B6B", bold = true },
		AsmDebugMemoryAscii11 = { fg = "#FF9F43", bold = true },
		AsmDebugMemoryAscii12 = { fg = "#FFD93D", bold = true },
		AsmDebugMemoryAscii13 = { fg = "#A8E66B", bold = true },
		AsmDebugMemoryAscii14 = { fg = "#4ECDC4", bold = true },
		AsmDebugMemoryAscii15 = { fg = "#45B7D1", bold = true },
		AsmDebugMemoryAscii16 = { fg = "#5D8BF4", bold = true },
		AsmDebugMnemonic = { fg = "#D6A6FF", bold = true },
		AsmDebugOperandRegister = { fg = "#74D7F0", bold = true },
		AsmDebugOperandNumber = { fg = "#FFB86C" },
		AsmDebugOperandSymbol = { fg = "#A6E3A1", italic = true },
		AsmDebugOutput = { link = "Normal" },
		AsmDebugMuted = { link = "Comment" },
		AsmDebugError = { link = "DiagnosticError" },
		AsmDebugBorder = { fg = "#CBA6F7" },
		AsmDebugStatus = { fg = "#A6F7B2", bold = true },
	}
	for name, spec in pairs(palette) do
		vim.api.nvim_set_hl(0, name, spec)
	end
end

local function set_lines(name, lines)
	local buf = S.buffers[name]
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
end

local function status(text)
	S.status_text = text
	local exe = S.executable and vim.fn.fnamemodify(S.executable, ":t") or "—"
	set_lines("status", {
		string.format(
		" ASM DEBUG │ %s │ %s │ %s │ F5/c Cont  F6/s Step  F7/n Next  F8/p Pause  F9/r Restart  a ASM  v SRC  R REG  m MEM  j/k Scroll  f CodeFollow  F MemFollow  I Input  q Close",
			text,
			exe,
			S.backend or "detecting backend"
		),
	})
	local buf = S.buffers.status
	if buf and vim.api.nvim_buf_is_valid(buf) then
		local ns = vim.api.nvim_create_namespace("asmdebug-status")
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugStatus", 0, 0, 11)
	end
end

local function render_output()
	local lines = vim.deepcopy(S.output)
	vim.list_extend(lines, S.terminal_output or {})
	while #lines > 1000 do
		table.remove(lines, 1)
	end
	set_lines("output", lines)
	local win = S.windows.output
	if win and vim.api.nvim_win_is_valid(win) then
		pcall(vim.api.nvim_win_set_cursor, win, { math.max(1, #lines), 0 })
	end
end

local function append_output(text)
	if not text or text == "" then return end
	for line in (text .. "\n"):gmatch("(.-)\n") do
		S.output[#S.output + 1] = line
	end
	while #S.output > 300 do table.remove(S.output, 1) end
	render_output()
end

local function sync_terminal_output(buf)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	while #lines > 0 and lines[#lines] == "" do table.remove(lines) end
	local snapshot = table.concat(lines, "\n")
	if snapshot == S.terminal_output_text then return end
	S.terminal_output_text = snapshot
	S.terminal_output = lines
	render_output()
end

local function close()
	S.closing = true
	if S.job then
		if S.backend == "LLDB-DAP" then
			-- DAP has no guaranteed synchronous shutdown command; stopping the adapter is safe.
			pcall(vim.fn.jobstop, S.job)
		else
			S.mi_token = S.mi_token + 1
			pcall(vim.fn.chansend, S.job, tostring(S.mi_token) .. "-gdb-exit\n")
			pcall(vim.fn.jobstop, S.job)
		end
		S.job = nil
	end
	if S.terminal_job and S.terminal_job > 0 then
		pcall(vim.fn.jobstop, S.terminal_job)
		S.terminal_job = nil
	end
	if S.terminal_timer then
		S.terminal_timer:stop()
		S.terminal_timer:close()
		S.terminal_timer = nil
	end
	for _, win in pairs(S.windows) do
		if vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end
	if S.terminal_win and vim.api.nvim_win_is_valid(S.terminal_win) then
		pcall(vim.api.nvim_win_close, S.terminal_win, true)
	end
	S.windows, S.buffers, S.pending, S.mi_pending = {}, {}, {}, {}
	S.terminal_buf, S.terminal_win = nil, nil
	S.closing = false
end

local function panel(name, title, width, height, row, col, opts)
	opts = opts or {}
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	local config = {
		relative = "editor",
		width = math.max(10, width),
		height = math.max(1, height),
		row = math.max(0, row),
		col = math.max(0, col),
		style = "minimal",
		border = opts.border == false and "none" or "rounded",
	}
	if opts.border ~= false then
		config.title = " " .. title .. " "
		config.title_pos = "center"
	end
	local win = vim.api.nvim_open_win(buf, true, config)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].wrap = false
	vim.wo[win].cursorline = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].winhighlight = "FloatBorder:AsmDebugBorder,NormalFloat:Normal"
	S.buffers[name], S.windows[name] = buf, win
	return buf
end

local function focus_debugger_panel(name)
	local win = S.windows[name or "assembly"]
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
		local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
		if mode == "t" then
			local normal_mode = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
			vim.api.nvim_input(normal_mode)
		elseif mode == "i" then
			vim.api.nvim_input(vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
		end
	end
end

local function field(text, name)
	return text and text:match(name .. '="([^"]*)"')
end

local function mi_unescape(text)
	if not text then
		return ""
	end
	local ok, value = pcall(vim.json.decode, '"' .. text .. '"')
	if ok and type(value) == "string" then
		return value
	end
	return text:gsub("\\n", "\n"):gsub("\\r", "\r"):gsub("\\t", "\t"):gsub('\\"', '"'):gsub("\\\\", "\\")
end

local function mi_send(command, callback, quiet_error)
	if not S.job then
		return
	end
	S.mi_token = S.mi_token + 1
	local token = tostring(S.mi_token)
	S.mi_pending[token] = { callback = callback or function() end, quiet_error = quiet_error == true }
	local ok, result = pcall(vim.fn.chansend, S.job, token .. command .. "\n")
	if not ok or result == 0 then
		S.mi_pending[token] = nil
		notify("Failed to send a command to GDB.", vim.log.levels.ERROR)
	end
end

local function dap_send(command, arguments, callback)
	if not S.job then
		return
	end
	S.seq = S.seq + 1
	local seq = S.seq
	local message = {
		seq = seq,
		type = "request",
		command = command,
		arguments = arguments or {},
	}
	if callback then
		S.pending[seq] = callback
	end
	local body = vim.json.encode(message)
	local packet = string.format("Content-Length: %d\r\n\r\n%s", #body, body)
	local ok, result = pcall(vim.fn.chansend, S.job, packet)
	if not ok or result == 0 then
		S.pending[seq] = nil
		notify("Failed to send a request to LLDB-DAP.", vim.log.levels.ERROR)
	end
end

local function dap_respond(request, success, body, message)
	if not S.job then return end
	S.seq = S.seq + 1
	local response = {
		seq = S.seq,
		type = "response",
		request_seq = request.seq,
		command = request.command,
		success = success,
		body = body or {},
	}
	if message then response.message = message end
	local encoded = vim.json.encode(response)
	local packet = string.format("Content-Length: %d\r\n\r\n%s", #encoded, encoded)
	pcall(vim.fn.chansend, S.job, packet)
end

local function terminal_window_config()
	local available_width = math.max(1, vim.o.columns - 4)
	local available_height = math.max(1, vim.o.lines - vim.o.cmdheight - 4)
	local width = math.max(1, math.min(available_width, 110))
	local height = math.max(1, math.min(available_height, 12, math.floor(vim.o.lines * 0.30)))
	return {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.min(vim.o.lines - height - vim.o.cmdheight - 2, vim.o.lines - height - 3)),
		col = math.max(0, math.floor((vim.o.columns - width) / 2)),
		style = "minimal",
		border = "rounded",
		title = " PROGRAM INPUT / OUTPUT ",
		title_pos = "center",
	}
end

local function show_terminal()
	if not S.terminal_buf or not vim.api.nvim_buf_is_valid(S.terminal_buf) then return false end
	if S.terminal_win and vim.api.nvim_win_is_valid(S.terminal_win) then
		vim.api.nvim_set_current_win(S.terminal_win)
		return true
	end
	local ok, win = pcall(vim.api.nvim_open_win, S.terminal_buf, true, terminal_window_config())
	if not ok then return false end
	S.terminal_win = win
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].wrap = false
	vim.wo[win].signcolumn = "no"
	return true
end

local function hide_terminal()
	if S.terminal_win and vim.api.nvim_win_is_valid(S.terminal_win) then
		pcall(vim.api.nvim_win_close, S.terminal_win, true)
	end
	S.terminal_win = nil
end

local function send_input_and_continue()
	if not S.waiting_for_input or not S.terminal_job then return end
	local ok, sent = pcall(vim.fn.chansend, S.terminal_job, "\n")
	if not ok or sent == 0 then
		notify("Could not send input to the program.", vim.log.levels.ERROR)
		return
	end
	hide_terminal()
	focus_debugger_panel("assembly")
	S.waiting_for_input = false
	S.running = true
	status("Input sent — continuing")
	if S.backend and S.backend:match("LLDB%-DAP") then
		dap_send("continue", { threadId = S.thread_id })
	else
		mi_send("-exec-continue")
	end
end

local function open_terminal(command, opts, prefer_split)
	-- `vim.fn` converts an empty Lua table to a Vim list. termopen expects its
	-- second argument to be a dictionary, so preserve the empty-dictionary type.
	opts = opts or vim.empty_dict()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "hide"
	S.terminal_buf = buf
	local function set_terminal_window(win)
		S.terminal_win = win
		vim.wo[win].number = false
		vim.wo[win].relativenumber = false
		vim.wo[win].wrap = false
		vim.wo[win].signcolumn = "no"
	end
	local function open_split()
		for _, candidate in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_get_config(candidate).relative == "" then
				vim.api.nvim_set_current_win(candidate)
				break
			end
		end
		local ok, win = pcall(function()
			vim.cmd("botright 8split")
			local split = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(split, buf)
			return split
		end)
		if ok then set_terminal_window(win) end
		return ok, win
	end
	local ok, win
	local window_error
	if prefer_split then
		ok, win = open_split()
		if not ok then
			window_error = tostring(win)
			ok, win = pcall(vim.api.nvim_open_win, buf, true, terminal_window_config())
			if ok then set_terminal_window(win) end
		end
	else
		ok, win = pcall(vim.api.nvim_open_win, buf, true, terminal_window_config())
		if ok then
			set_terminal_window(win)
		else
			window_error = tostring(win)
			ok, win = open_split()
		end
	end
	if not ok then
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
		S.terminal_buf, S.terminal_win = nil, nil
		return nil, nil, nil, "could not create terminal window: " .. tostring(window_error or win)
	end
	local function start_job()
		local started, job_id = pcall(vim.api.nvim_buf_call, buf, function()
			return vim.fn.termopen(command, opts)
		end)
		if started and type(job_id) == "number" and job_id > 0 then
			return job_id
		end
		return nil, started and ("termopen returned " .. tostring(job_id)) or tostring(job_id)
	end
	local job, terminal_error = start_job()
	if not job and S.terminal_win and vim.api.nvim_win_is_valid(S.terminal_win) then
		pcall(vim.api.nvim_win_close, S.terminal_win, true)
		S.terminal_win = nil
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].bufhidden = "hide"
		S.terminal_buf = buf
		local split_ok, split_win = open_split()
		if split_ok then
			win = split_win
			job, terminal_error = start_job()
		else
			terminal_error = terminal_error .. "; split fallback failed: " .. tostring(split_win)
		end
	end
	if not job or job <= 0 then
		if S.terminal_win and vim.api.nvim_win_is_valid(S.terminal_win) then
			pcall(vim.api.nvim_win_close, S.terminal_win, true)
		end
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
		S.terminal_buf, S.terminal_win, S.terminal_job = nil, nil, nil
		return nil, nil, nil, tostring(terminal_error or "could not start terminal job")
	end
	S.terminal_buf, S.terminal_win, S.terminal_job = buf, win, job
	vim.keymap.set("t", "<CR>", send_input_and_continue, { buffer = buf, silent = true, desc = "Send program input and continue" })
	S.terminal_timer = vim.uv.new_timer()
	S.terminal_timer:start(100, 150, vim.schedule_wrap(function()
		if S.terminal_buf == buf then sync_terminal_output(buf) end
	end))
	vim.api.nvim_create_autocmd("TermClose", {
		buffer = buf,
		once = true,
		callback = function() sync_terminal_output(buf) end,
	})
	sync_terminal_output(buf)
	return buf, win, job
end

local function handle_run_in_terminal(request)
	local args = request.arguments or {}
	if type(args.args) ~= "table" or #args.args == 0 then
		dap_respond(request, false, nil, "LLDB-DAP did not provide a program to run in the terminal.")
		return
	end
	local env = {}
	for key, value in pairs(args.env or {}) do
		if type(key) == "number" and type(value) == "string" then
			local name, contents = value:match("^([^=]+)=(.*)$")
			if name then env[name] = contents end
		elseif type(key) == "string" then
			env[key] = value
		end
	end
	local _, _, job, terminal_error = open_terminal(args.args, {
		cwd = args.cwd,
		env = next(env) and env or nil,
	})
	if not job then
		local message = "Could not open the program input/output terminal: " .. tostring(terminal_error)
		status(message)
		notify(message, vim.log.levels.ERROR)
		dap_respond(request, false, nil, message)
		return
	end
	append_output("Program I/O terminal is hidden until the debugger detects a stdin read.")
	dap_respond(request, true, { processId = vim.fn.jobpid(job) })
	hide_terminal()
	focus_debugger_panel("assembly")
end

local function number_from_value(value)
	if not value then
		return nil
	end
	local hex = value:match("0[xX]([%da-fA-F]+)")
	if hex then
		return tonumber(hex, 16)
	end
	return tonumber(value)
end

local function current_pc()
	return number_from_value(S.pc)
end

local function current_sp()
	return number_from_value(S.sp)
end

local function is_at_main_return()
	local pc = current_pc()
	if not pc then
		return false
	end

	local is_return = false
	for _, instruction in ipairs(S.instructions or {}) do
		if number_from_value(instruction.address) == pc then
			local mnemonic = (instruction.inst or ""):match("^%s*([%w%.]+)")
			-- Disassemblers use suffixes such as retq/retl for x86 returns.
			is_return = mnemonic and mnemonic:match("^ret[%w]*$") ~= nil
			break
		end
	end
	if not is_return then
		return false
	end

	-- The frame must be exactly main, with or without Mach-O's "_" prefix.
	-- The source line alone is not enough: multiple functions can contain a ret,
	-- and source-to-assembly mappings can point to the wrong function.
	local frame_name = (S.current_frame_name or ""):lower():gsub("%s*%+.*$", "")
	frame_name = frame_name:match("^([%w_.$]+)") or frame_name
	while frame_name:sub(1, 1) == "_" do
		frame_name = frame_name:sub(2)
	end
	return frame_name == "main"
end

local function mark_program_finished(reason)
	S.finished = true
	S.running = false
	S.in_main = false
	status("Program exited — " .. reason .. " | F9 to restart")
end

local function render_assembly()
	local win = S.windows.assembly
	local saved_view
	if not S.follow_pc and win and vim.api.nvim_win_is_valid(win) then
		saved_view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
	end
	local lines = { "ADDRESS          INSTRUCTION", string.rep("─", 42) }
	local current_line
	local ins_lines = {}
	for _, ins in ipairs(S.instructions) do
		local addr = ins.address or "?"
		local marker = S.pc and number_from_value(addr) == current_pc() and "▶" or " "
		local is_current = marker == "▶"
		lines[#lines + 1] = string.format("%s %-16s %s", marker, addr, ins.inst or "?")
		ins_lines[#ins_lines + 1] = { line = #lines - 1, text = ins.inst or "", current = is_current, base_col = #marker + 1 + 16 + 1 }
		if is_current then
			current_line = #lines
		end
	end
	if #S.instructions == 0 then
		lines[#lines + 1] = "Waiting for disassembly…"
	end
	set_lines("assembly", lines)
	local buf = S.buffers.assembly
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local ns = vim.api.nvim_create_namespace("asmdebug-assembly")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local arm_mnemonics = {
		bl = true, blr = true, br = true, ret = true, adrp = true, adr = true,
		mov = true, movz = true, movk = true, movn = true, add = true, adds = true,
		sub = true, subs = true, mul = true, madd = true, msub = true,
		ldr = true, ldrb = true, ldrh = true, ldur = true, str = true, strb = true,
		strh = true, stur = true, stp = true, ldp = true, cmp = true, cmn = true,
		tst = true, b = true, cbz = true, cbnz = true, tbz = true, tbnz = true,
		nop = true, svc = true, brk = true, ["and"] = true, orr = true, eor = true,
		lsl = true, lsr = true, asr = true, sxtw = true, uxtw = true, csel = true,
		cset = true, fmov = true, fadd = true, fsub = true, fmul = true, fdiv = true,
		push = true, pop = true, call = true, syscall = true, lea = true, xor = true,
		test = true, jmp = true, je = true, jne = true, jz = true, jnz = true,
		["or"] = true, ["not"] = true, ["int"] = true,
	}
	local x86_registers = {
		rax = true, rbx = true, rcx = true, rdx = true, rsi = true, rdi = true,
		rsp = true, rbp = true, rip = true, r8 = true, r9 = true, r10 = true,
		r11 = true, r12 = true, r13 = true, r14 = true, r15 = true,
		eax = true, ebx = true, ecx = true, edx = true, esi = true, edi = true,
		esp = true, ebp = true, eip = true,
	}
	for _, item in ipairs(ins_lines) do
		local row = item.line
		if item.current then
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugCurrent", row, 0, -1)
		end
		local text = item.text
		local a, b, mnemonic = text:find("^%s*([%w%.]+)")
		if mnemonic and arm_mnemonics[mnemonic:lower()] then
			local start = text:find(mnemonic, 1, true)
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMnemonic", row, item.base_col + start - 1, item.base_col + start - 1 + #mnemonic)
		end
		for start, token, finish in text:gmatch("()([%a][%w]*)()") do
			local lower = token:lower()
			if lower:match("^x%d+$") or lower:match("^w%d+$") or x86_registers[lower] or
				({ sp = true, fp = true, lr = true, pc = true, xzr = true, wzr = true })[lower] then
				vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugOperandRegister", row, item.base_col + start - 1, item.base_col + finish - 1)
			end
		end
		for start, token, finish in text:gmatch("()(0[xX][%da-fA-F]+)()") do
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugOperandNumber", row, item.base_col + start - 1, item.base_col + finish - 1)
		end
		for start, token, finish in text:gmatch("()(<[%w_%.@$]+>)()") do
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugOperandSymbol", row, item.base_col + start - 1, item.base_col + finish - 1)
		end
	end
	if win and vim.api.nvim_win_is_valid(win) then
		if S.follow_pc and current_line then
		pcall(vim.api.nvim_win_set_cursor, win, { current_line, 0 })
		pcall(vim.api.nvim_win_call, win, function() vim.cmd("normal! zz") end)
		elseif saved_view then
			pcall(vim.api.nvim_win_call, win, function() vim.fn.winrestview(saved_view) end)
		end
	end
end

local function build_source_display()
	local display = {}
	for original_line, raw in ipairs(S.source_lines or {}) do
		local code = raw:gsub("//.*$", ""):gsub(";.*$", "")
		code = code:gsub("^%s+", ""):gsub("%s+$", "")
		display[#display + 1] = {
			source_line = original_line,
			text = raw,
			executable = code ~= "" and not code:match("^%.") and not code:match("^[%w_.$]+:%s*$"),
		}
	end
	S.source_display = display
end

local function next_executable_source_line(from_line, direction)
	local display = S.source_display or {}
	local start = from_line or (direction > 0 and 0 or (#S.source_lines + 1))
	for line = start + direction, direction > 0 and #S.source_lines or 1, direction do
		for _, item in ipairs(display) do
			if item.source_line == line and item.executable then return line end
		end
	end
	return from_line
end

local function normalized_symbol_name(name)
	name = (name or ""):lower()
	name = name:gsub("%s*%+.*$", "")
	name = name:match("^([%w_.$]+)") or name
	while name:sub(1, 1) == "_" do name = name:sub(2) end
	return name
end

local function is_local_asm_label(label)
	local lower = (label or ""):lower()
	return lower:sub(1, 1) == "."
		or lower:match("^lbb") ~= nil
		or lower:match("^ltmp") ~= nil
		or lower:match("^lfunc") ~= nil
		or lower:match("^lcpi") ~= nil
		or lower:match("^ljti") ~= nil
end

-- Find the section of the file corresponding to the current function.
-- Local labels (.LBB..., Ltmp..., etc.) do not end a function.
local function source_function_range(frame_name)
	local wanted = normalized_symbol_name(frame_name)
	if wanted == "" then return nil, nil end
	for line_number, raw in ipairs(S.source_lines or {}) do
		local label = raw:match("^%s*([%w_.$]+):")
		if label and not is_local_asm_label(label) and normalized_symbol_name(label) == wanted then
			local end_line = #(S.source_lines or {})
			for next_line = line_number + 1, #(S.source_lines or {}) do
				local next_label = S.source_lines[next_line]:match("^%s*([%w_.$]+):")
				if next_label and not is_local_asm_label(next_label) then
					end_line = next_line - 1
					break
				end
			end
			return line_number, end_line
		end
	end
	return nil, nil
end

-- Assembly line tables are not always available.
-- If the PC enters a function without source lines, find its label.
local function source_line_for_function(frame_name)
	local start_line = source_function_range(frame_name)
	if not start_line then return nil end
	return next_executable_source_line(start_line, 1) or start_line
end

local function render_source()
	local win = S.windows.source
	local saved_view
	if not S.follow_pc and win and vim.api.nvim_win_is_valid(win) then
		saved_view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
	end
	local lines = {}
	local current_line = S.source_line
	if not S.source_path or #S.source_lines == 0 then
		set_lines("source", {
			"FILE: ASM source",
			string.rep("─", 36),
			"Source unavailable.",
			"Place the .s file next to the executable",
			"and compile with clang -g.",
		})
		return
	end

	if not S.source_display or #S.source_display == 0 then build_source_display() end
	lines[#lines + 1] = "FILE: " .. vim.fn.fnamemodify(S.source_path, ":t")
	lines[#lines + 1] = string.rep("─", 36)
	local row_for_line = {}
	for _, item in ipairs(S.source_display) do
		local marker = item.source_line == current_line and "▶" or " "
		lines[#lines + 1] = string.format("%s %4d  %s", marker, item.source_line, item.text)
		row_for_line[item.source_line] = #lines - 1
	end
	set_lines("source", lines)

	local buf = S.buffers.source
	if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
	local ns = vim.api.nvim_create_namespace("asmdebug-source")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local row = row_for_line[current_line]
	if row then vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugCurrent", row, 0, -1) end

	-- Source line numbers now correspond 1:1 to rows in the full source buffer (+2 header lines).
	-- Center it on the instruction reported by the debugger; this avoids jumps caused by
	-- rebuilding a moving window of only a subset of the source file.
	if current_line and row and win and vim.api.nvim_win_is_valid(win) then
		if S.follow_pc then
			pcall(vim.api.nvim_win_set_cursor, win, { current_line + 2, 0 })
			pcall(vim.api.nvim_win_call, win, function() vim.cmd("normal! zz") end)
		elseif saved_view then
			pcall(vim.api.nvim_win_call, win, function() vim.fn.winrestview(saved_view) end)
		end
	elseif saved_view and win and vim.api.nvim_win_is_valid(win) then
		pcall(vim.api.nvim_win_call, win, function() vim.fn.winrestview(saved_view) end)
	end
end

local function load_source_for_executable(executable)
	local stem = vim.fn.fnamemodify(executable, ":t"):gsub("%.[^.]+$", "")
	local candidates = {
		vim.fn.fnamemodify(executable, ":h") .. "/" .. stem .. ".s",
		vim.fn.fnamemodify(executable, ":h") .. "/" .. stem .. ".S",
		vim.fn.getcwd() .. "/" .. stem .. ".s",
		vim.fn.getcwd() .. "/" .. stem .. ".S",
	}
	S.source_path, S.source_lines, S.source_display = nil, {}, {}
	for _, candidate in ipairs(candidates) do
		if vim.fn.filereadable(candidate) == 1 then
			S.source_path = candidate
			S.source_lines = vim.fn.readfile(candidate)
			build_source_display()
			return
		end
	end
end

local function hex_to_decimal(hex)
	hex = (hex or ""):gsub("^0[xX]", ""):gsub("[^%da-fA-F]", "")
	if hex == "" then return nil end
	local decimal = "0"
	for i = 1, #hex do
		local digit = tonumber(hex:sub(i, i), 16)
		local carry = digit
		local out = {}
		for j = #decimal, 1, -1 do
			local value = tonumber(decimal:sub(j, j)) * 16 + carry
			out[#out + 1] = tostring(value % 10)
			carry = math.floor(value / 10)
		end
		while carry > 0 do
			out[#out + 1] = tostring(carry % 10)
			carry = math.floor(carry / 10)
		end
		local reversed = {}
		for j = #out, 1, -1 do reversed[#reversed + 1] = out[j] end
		decimal = table.concat(reversed):gsub("^0+", "")
		if decimal == "" then decimal = "0" end
	end
	return decimal
end

local function register_decimal(value)
	if not value then return nil end
	local hex = value:match("0[xX]([%da-fA-F]+)")
	if hex then return hex_to_decimal(hex) end
	local number = tonumber(value)
	if number then return string.format("%.0f", number) end
	return nil
end

local function register_order()
	local order, seen = {}, {}
	local function add(name)
		name = name:lower()
		if not seen[name] then
			seen[name] = true
			order[#order + 1] = name
		end
	end
	if S.architecture == "arm64" then
		for _, name in ipairs({ "pc", "sp", "fp", "lr" }) do add(name) end
		for i = 0, 30 do add("x" .. i) end
	else
		for _, name in ipairs({ "rip", "rax", "rbx", "rcx", "rdx", "rsi", "rdi", "rbp", "rsp", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "eflags" }) do
			add(name)
		end
	end
	-- GDB reports the complete register file, including SIMD, floating point,
	-- segment, and architecture-specific registers. Keep the familiar GPRs first,
	-- then append every other register in a stable order for scrollable display.
	local extra = {}
	local x86_aliases = { pc = true, sp = true, fp = true, lr = true }
	for name, value in pairs(S.regs or {}) do
		local lower_name = type(name) == "string" and name:lower() or ""
		local synthetic_x86_alias = S.architecture ~= "arm64" and x86_aliases[lower_name]
		if lower_name ~= "" and value ~= nil and not seen[lower_name] and not synthetic_x86_alias then
			extra[#extra + 1] = lower_name
		end
	end
	table.sort(extra)
	for _, name in ipairs(extra) do add(name) end
	return order
end

local function register_hex(value)
	if not value then return "?" end
	local hex = value:match("0[xX]([%da-fA-F]+)")
	if hex then
		hex = hex:gsub("^0+", "")
		if hex == "" then hex = "0" end
		return "0x" .. hex:lower()
	end
	local number = tonumber(value)
	if number then return string.format("0x%X", number) end
	return value
end

local function register_ascii(value)
	if not value then return "????????" end
	local hex = value:match("0[xX]([%da-fA-F]+)")
	if not hex then
		local number = tonumber(value)
		if number then hex = string.format("%X", number) end
	end
	if not hex then return "????????" end
	hex = hex:sub(-16)
	hex = string.rep("0", math.max(0, 16 - #hex)) .. hex
	local chars = {}
	-- ARM64/macOS and x86_64/Linux are little-endian: the least-significant
	-- byte is the first byte in memory (0x41 therefore displays as "A.......").
	for i = 15, 1, -2 do
		local byte = tonumber(hex:sub(i, i + 1), 16) or 0
		chars[#chars + 1] = (byte >= 32 and byte <= 126) and string.char(byte) or "."
	end
	return table.concat(chars)
end

local function register_group(name)
	name = name:lower()
	if name == "pc" or name == "rip" then return "AsmDebugRegisterPC" end
	if name == "sp" or name == "rsp" then return "AsmDebugRegisterSP" end
	if name == "fp" or name == "rbp" or name == "x29" then return "AsmDebugRegisterFP" end
	if name == "lr" or name == "x30" then return "AsmDebugRegisterLR" end
	return "AsmDebugRegisterGeneral"
end

local function render_registers()
	local order = register_order()
	local win = S.windows.registers
	local saved_view
	if win and vim.api.nvim_win_is_valid(win) then
		local ok, view = pcall(vim.api.nvim_win_call, win, vim.fn.winsaveview)
		if ok then saved_view = view end
	end
	local columns = math.max(1, S.register_columns or 1)
	local entries = {}
	for _, name in ipairs(order) do
		local value = S.regs[name]
		local hex = register_hex(value)
		local decimal = register_decimal(value) or "?"
		local ascii = register_ascii(value)
		local text = string.format("%-3s %-18s %-20s %s", name:upper(), hex, decimal, ascii)
		entries[#entries + 1] = { name = name, text = text, group = register_group(name) }
	end

	local panel_width = win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_width(win) or vim.o.columns - 2
	local gap = 2
	local col_width = math.max(1, math.floor((panel_width - gap * (columns - 1)) / columns))
	local per_column = math.ceil(#entries / columns)
	local header = string.format("%-3s %-18s %-20s %s", "REG", "HEXADECIMAL", "DECIMAL", "ASCII")
	local lines = {}
	local header_parts = {}
	for col = 1, columns do
		header_parts[#header_parts + 1] = string.format("%-" .. col_width .. "s", header)
	end
	lines[#lines + 1] = table.concat(header_parts, string.rep(" ", gap))

	local positions = {}
	for row = 1, per_column do
		local parts = {}
		for col = 1, columns do
			local index = (col - 1) * per_column + row
			local entry = entries[index]
			if entry then
				parts[#parts + 1] = string.format("%-" .. col_width .. "s", entry.text)
				positions[#positions + 1] = {
					row = row,
					col = (col - 1) * (col_width + gap),
					name = entry.name,
					group = entry.group,
				}
			else
				parts[#parts + 1] = string.rep(" ", col_width)
			end
		end
		lines[#lines + 1] = table.concat(parts, string.rep(" ", gap))
	end
	set_lines("registers", lines)
	if saved_view and win and vim.api.nvim_win_is_valid(win) then
		pcall(vim.api.nvim_win_call, win, function() vim.fn.winrestview(saved_view) end)
	end

	local buf = S.buffers.registers
	if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
	local ns = vim.api.nvim_create_namespace("asmdebug-registers")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, item in ipairs(positions) do
		vim.api.nvim_buf_add_highlight(buf, ns, item.group, item.row, item.col, item.col + #item.name)
	end
end

local function base64_decode(data)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local lookup = {}
	for i = 1, #chars do
		lookup[chars:sub(i, i)] = i - 1
	end
	local out, buffer, bits = {}, 0, 0
	for i = 1, #(data or "") do
		local c = data:sub(i, i)
		if c ~= "=" and lookup[c] then
			buffer = buffer * 64 + lookup[c]
			bits = bits + 6
			if bits >= 8 then
				bits = bits - 8
				local byte = math.floor(buffer / (2 ^ bits)) % 256
				out[#out + 1] = byte
				buffer = buffer % (2 ^ bits)
			end
		end
	end
	return out
end

local function memory_ranges(sp, fp)
	if not sp then return {} end
	-- At process entry (and in functions compiled without frame pointers), RBP/X29
	-- may contain zero or an unrelated value. A real downward-growing stack frame
	-- pointer is aligned and above SP; skip implausible values instead of probing
	-- unmapped memory.
	if fp and (fp < sp or fp - sp > 64 * 1024 * 1024 or fp % 8 ~= 0) then
		fp = nil
	end
	local sp_start = math.max(0, math.floor((sp - 64) / 8) * 8)
	local sp_count = 128
	if not fp or (fp >= sp_start and fp < sp_start + sp_count) then
		return { { address = sp_start, count = sp_count, label = "SP / FP REGION" } }
	end
	local function around(pointer)
		return math.max(0, math.floor((pointer - 32) / 8) * 8)
	end
	return {
		{ address = around(sp), count = 64, label = "SP REGION" },
		{ address = around(fp), count = 64, label = "FP REGION" },
	}
end

local function render_stack_regions(regions)
	S.stack_regions = regions or {}
	local win = S.windows.stack
	local saved_view
	if not S.follow_memory and win and vim.api.nvim_win_is_valid(win) then
		local ok, view = pcall(vim.api.nvim_win_call, win, vim.fn.winsaveview)
		if ok then saved_view = view end
	end
	local sp = current_sp()
	local fp = number_from_value(S.fp) or number_from_value(S.regs.fp) or number_from_value(S.regs.x29) or number_from_value(S.regs.rbp)
	local lines = {
		string.format("SP = %s", sp and string.format("0x%016X", sp) or "unavailable"),
		string.format("FP = %s  (%s)", fp and string.format("0x%016X", fp) or "unavailable", S.architecture == "arm64" and "X29" or "RBP"),
		"SP = green  |  FP = yellow  |  SF = same line  |  bytes + ASCII",
	}
	local row_info = {}
	local sp_row
	for region_index, region in ipairs(regions or {}) do
		if #regions > 1 then
			lines[#lines + 1] = ""
			lines[#lines + 1] = string.format("── %s: 0x%016X ──", region.label or "MEMORY REGION", region.address)
		end
		local bytes = region.bytes or {}
		if region.error then
			lines[#lines + 1] = "?? marks memory that GDB could not read."
		end
		for offset = 0, (region.count or #bytes) - 1, 8 do
			local hex, ascii = {}, {}
			for j = 0, 7 do
				local byte = bytes[offset + j + 1]
				hex[#hex + 1] = byte ~= nil and string.format("%02X", byte) or "??"
				ascii[#ascii + 1] = byte == nil and "?" or ((byte >= 32 and byte <= 126) and string.char(byte) or ".")
			end
			local address = region.address + offset
			local is_sp = sp and sp >= address and sp < address + 8
			local is_fp = fp and fp >= address and fp < address + 8
			local marker = is_sp and is_fp and "SF" or (is_sp and "SP" or (is_fp and "FP" or "  "))
			lines[#lines + 1] = string.format("%s 0x%016X  %s  |%s|", marker, address, table.concat(hex, " "), table.concat(ascii))
			local item = {
				row = #lines - 1,
				is_sp = is_sp,
				is_fp = is_fp,
				address = address,
				offset = offset,
				bytes = bytes,
				region_index = region_index,
			}
			row_info[#row_info + 1] = item
			if is_sp then sp_row = item.row end
		end
	end
	if #regions == 0 then lines[#lines + 1] = "Stack pointer unavailable." end
	set_lines("stack", lines)

	local buf = S.buffers.stack
	if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
	local ns = vim.api.nvim_create_namespace("asmdebug-memory")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, item in ipairs(row_info) do
		vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryAddress", item.row, 3, 21)
		if item.is_sp and item.is_fp then
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryPointer", item.row, 0, 2)
		elseif item.is_sp then
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryPointer", item.row, 0, 2)
		elseif item.is_fp then
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryFramePointer", item.row, 0, 2)
		end
		for j = 1, 8 do
			local byte_col = 23 + (j - 1) * 3
			local ascii_col = 49 + (j - 1)
			local byte_value = item.bytes[item.offset + j]
			if byte_value ~= nil then
				if byte_value == 0 then
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryZero", item.row, byte_col, byte_col + 2)
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryZero", item.row, ascii_col, ascii_col + 1)
				else
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryByte" .. j, item.row, byte_col, byte_col + 2)
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryAscii" .. j, item.row, ascii_col, ascii_col + 1)
				end
				local byte_address = item.address + (j - 1)
				if sp and byte_address == sp then
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryPointer", item.row, byte_col, byte_col + 2)
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryPointer", item.row, ascii_col, ascii_col + 1)
				end
				if fp and byte_address == fp then
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryFramePointer", item.row, byte_col, byte_col + 2)
					vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugMemoryFramePointer", item.row, ascii_col, ascii_col + 1)
				end
			end
		end
	end
	if win and vim.api.nvim_win_is_valid(win) then
		if S.follow_memory and sp_row then
			pcall(vim.api.nvim_win_set_cursor, win, { sp_row + 1, 0 })
			pcall(vim.api.nvim_win_call, win, function() vim.cmd("normal! zz") end)
		elseif saved_view then
			pcall(vim.api.nvim_win_call, win, function() vim.fn.winrestview(saved_view) end)
		end
	end
end

local function parse_mi_instructions(response)
	local instructions = {}
	for tuple in response:gmatch("{[^{}]+}") do
		local address = field(tuple, "address")
		local inst = field(tuple, "inst")
		if address and inst then
			instructions[#instructions + 1] = { address = address, inst = mi_unescape(inst) }
		end
	end
	return instructions
end

local function refresh_mi_assembly()
	local pc = current_pc()
	if not pc then
		return
	end
	local function render_response(response)
		S.instructions = parse_mi_instructions(response)
		render_assembly()
	end
	-- Disassemble the entire containing function so the assembly pane can scroll
	-- through the code instead of stopping at an arbitrary 160-byte window.
	mi_send(string.format("-data-disassemble -a 0x%x -- 0", pc), function(response)
		if response:match("%^error") or #parse_mi_instructions(response) == 0 then
			-- Older GDB releases and stripped binaries may not know a containing
			-- function. Keep a bounded address window as a reliable fallback.
			mi_send(string.format("-data-disassemble -s 0x%x -e 0x%x -- 0", pc, pc + 512), render_response, true)
		else
			render_response(response)
		end
	end, true)
end

local function refresh_mi_stack()
	local sp = current_sp()
	if not sp then
		set_lines("stack", { "STACK / MEMORY", "", "Stack pointer unavailable." })
		return
	end
	local regions = memory_ranges(sp, number_from_value(S.fp) or number_from_value(S.regs.fp) or number_from_value(S.regs.x29) or number_from_value(S.regs.rbp))
	if #regions == 0 then return end
	local remaining = #regions
	local function read_region(region, callback)
		region.bytes = {}
		local unreadable = false
		local function read_chunk(address, offset, count, done)
			mi_send(string.format("-data-read-memory-bytes 0x%x %d", address, count), function(response)
				local contents = field(response, "contents")
				local received = 0
				if contents then
					for byte in contents:gmatch("%x%x") do
						region.bytes[offset + received + 1] = tonumber(byte, 16)
						received = received + 1
					end
				end
				if received == count then
					done()
				elseif count > 8 then
					local first_count = math.floor(count / 16) * 8
					read_chunk(address, offset, first_count, function()
						read_chunk(address + first_count, offset + first_count, count - first_count, done)
					end)
				else
					unreadable = true
					done()
				end
			end, true)
		end
		read_chunk(region.address, 0, region.count, function()
			region.error = unreadable
			callback()
		end)
	end
	for _, region in ipairs(regions) do
		read_region(region, function()
			remaining = remaining - 1
			if remaining == 0 then render_stack_regions(regions) end
		end)
	end
end

local function refresh_mi_registers(callback)
	mi_send("-data-list-register-names", function(names_response)
		local names = {}
		for name in names_response:gmatch('"([^"]*)"') do
			names[#names + 1] = name
		end
		mi_send("-data-list-register-values x", function(values_response)
			local regs = {}
			for tuple in values_response:gmatch("{[^{}]+}") do
				local number = tonumber(field(tuple, "number") or "")
				local value = field(tuple, "value")
				if number and names[number + 1] and names[number + 1] ~= "" then
					regs[names[number + 1]:lower()] = value
				end
			end
			if S.architecture == "arm64" then
				regs.fp = regs.fp or regs.x29
				regs.lr = regs.lr or regs.x30
				regs.pc = regs.pc or regs.rip
				regs.sp = regs.sp or regs.rsp
			else
				regs.pc = regs.pc or regs.rip
				regs.sp = regs.sp or regs.rsp
				regs.fp = regs.fp or regs.rbp
			end
			S.regs = regs
			S.pc = regs.rip or regs.pc or S.pc
			S.sp = regs.rsp or regs.sp or S.sp
			S.fp = regs.rbp or regs.x29 or regs.fp or S.fp
			render_registers()
			if callback then callback() end
		end)
	end)
end

local function refresh_mi_source()
	mi_send("-stack-info-frame", function(response)
		local frame = response:match("frame={(.-)}")
		if not frame then return end
		local line = tonumber(field(frame, "line") or "")
		S.current_frame_name = field(frame, "func") or S.current_frame_name
		local path = field(frame, "fullname") or field(frame, "file")
		if path and vim.fn.filereadable(path) == 1 then
			local full_path = vim.fn.fnamemodify(path, ":p")
			if full_path ~= S.source_path or #S.source_lines == 0 then
				S.source_path = full_path
				S.source_lines = vim.fn.readfile(full_path)
				build_source_display()
			end
		end
		if line and line >= 1 and line <= #S.source_lines then
			S.source_line = line
			render_source()
		else
			local function_line = source_line_for_function(S.current_frame_name)
			if function_line then
				S.source_line = function_line
				render_source()
			end
		end
	end)
end

local function refresh_mi()
	local input_breakpoint_hit = S.input_breakpoint_hit
	S.input_breakpoint_hit = false
	refresh_mi_registers(function()
		if input_breakpoint_hit then
			local input_fd = number_from_value(S.architecture == "arm64" and S.regs.x0 or S.regs.rdi)
			if input_fd == 0 then
				S.waiting_for_input = true
				if show_terminal() then
					status("Input requested — type a line and press Enter")
				else
					status("Input requested, but the program terminal could not be shown")
					notify("Could not show the program input terminal.", vim.log.levels.ERROR)
				end
			else
				S.running = true
				mi_send("-exec-continue")
				return
			end
		end
		refresh_mi_assembly()
		refresh_mi_stack()
		refresh_mi_source()
	end)
end

local function dap_eval(expression, frame_id, callback)
	dap_send("evaluate", { expression = expression, frameId = frame_id, context = "watch" }, function(response)
		if response.success and response.body then
			callback(response.body.result)
		else
			callback(nil)
		end
	end)
end

local function normalize_asm_instruction(text)
	if not text then return "" end
	text = text:lower()
	text = text:gsub("//.*$", ""):gsub(";.*$", "")
	text = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	text = text:gsub("<[^>]*>", "")
	text = text:gsub("0x([%da-f]+)", function(hex)
		return tostring(tonumber(hex, 16))
	end)
	text = text:gsub("#%s*", "#"):gsub("%s*,%s*", ",")
	-- AArch64 disassemblers often print MOV as an alias for MOVZ/MOVN.
	text = text:gsub("^mov([%s])", "movz%1")
	return text
end

-- Map the instruction at the PC to its source line. If the same instruction
-- appears more than once, prefer the current function and PC progression to
-- avoid getting stuck on a line.
local function source_line_for_instruction(instruction, previous_line, frame_name, pc, previous_pc, previous_frame_name)
	local wanted = normalize_asm_instruction(instruction)
	if wanted == "" then return nil end
	local candidates = {}
	for i, source in ipairs(S.source_lines or {}) do
		local code = source:gsub("//.*$", ""):gsub(";.*$", "")
		code = code:gsub("^%s+", ""):gsub("%s+$", "")
		if code ~= "" and not code:match("^%.") and not code:match("^[%w_.$]+:%s*$") then
			code = code:gsub("^[%w_.$]+:%s*", "")
			if normalize_asm_instruction(code) == wanted then
				candidates[#candidates + 1] = i
			end
		end
	end
	if #candidates == 0 then return nil end

	local function_start, function_end = source_function_range(frame_name)
	if function_start and function_end then
		local in_function = {}
		for _, candidate in ipairs(candidates) do
			if candidate >= function_start and candidate <= function_end then
				in_function[#in_function + 1] = candidate
			end
		end
		if #in_function > 0 then candidates = in_function end
	end
	if #candidates == 1 then return candidates[1] end

	local same_function = normalized_symbol_name(frame_name) ~= ""
		and normalized_symbol_name(frame_name) == normalized_symbol_name(previous_frame_name)
	if same_function and previous_line and previous_pc and pc and pc ~= previous_pc then
		if pc > previous_pc then
			local best
			for _, candidate in ipairs(candidates) do
				if candidate > previous_line and (not best or candidate < best) then best = candidate end
			end
			if best then return best end
		else
			local best
			for _, candidate in ipairs(candidates) do
				if candidate < previous_line and (not best or candidate > best) then best = candidate end
			end
			if best then return best end
		end
	end

	if previous_line then
		local best, best_distance
		for _, candidate in ipairs(candidates) do
			local distance = math.abs(candidate - previous_line)
			if not best_distance or distance < best_distance then
				best, best_distance = candidate, distance
			end
		end
		return best
	end
	return candidates[1]
end

local function refresh_dap()
	local previous_pc = current_pc()
	local previous_source_line = S.source_line
	local previous_source_path = S.source_path
	local previous_frame_name = S.current_frame_name
	dap_send("stackTrace", { threadId = S.thread_id, startFrame = 0, levels = 1 }, function(response)
		local frames = response.body and response.body.stackFrames or {}
		S.frame_id = frames[1] and frames[1].id or nil
		S.current_frame_name = frames[1] and (frames[1].name or "") or ""
		local reported_frame_line = frames[1] and tonumber(frames[1].line) or nil
		if frames[1] and frames[1].source and frames[1].source.path and vim.fn.filereadable(frames[1].source.path) == 1 then
			local source_path = vim.fn.fnamemodify(frames[1].source.path, ":p")
			if source_path ~= S.source_path or #S.source_lines == 0 then
				S.source_path = source_path
				S.source_lines = vim.fn.readfile(S.source_path)
				build_source_display()
			end
		end
		local frame = S.frame_id
		if not frame then
			status("Stopped — frame unavailable")
			return
		end
		local names
		if S.architecture == "arm64" then
			names = { "pc", "sp", "fp", "lr" }
			for i = 0, 30 do names[#names + 1] = "x" .. i end
		else
			names = { "rip", "rsp", "rbp", "rax", "rbx", "rcx", "rdx", "rsi", "rdi", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "rflags" }
		end
		local remaining = #names
		local regs = {}
		for _, name in ipairs(names) do
			local expr = "$" .. name
			dap_eval(expr, frame, function(value)
				if value then regs[name] = value end
				remaining = remaining - 1
				if remaining == 0 then
					if S.architecture == "arm64" then
						regs.fp = regs.fp or regs.x29
						regs.lr = regs.lr or regs.x30
						regs.pc = regs.pc or regs.rip
						regs.sp = regs.sp or regs.rsp
					else
						regs.pc = regs.pc or regs.rip
						regs.sp = regs.sp or regs.rsp
						regs.fp = regs.fp or regs.rbp
						regs.eflags = regs.eflags or regs.rflags
					end
					S.regs = regs
					S.pc = regs.pc or regs.rip
					S.sp = regs.sp or regs.rsp
					S.fp = regs.fp or regs.x29 or regs.rbp
					if S.input_breakpoint_hit then
						S.input_breakpoint_hit = false
						local input_fd = number_from_value(S.architecture == "arm64" and regs.x0 or regs.rdi)
						local is_read_syscall = true
						if S.input_syscall_breakpoint_hit then
							local syscall_number
							if S.architecture == "arm64" then
								syscall_number = number_from_value(S.target_format == "Mach-O" and regs.x16 or regs.x8)
							elseif S.target_format == "Mach-O" then
								local register_value = number_from_value(regs.rax)
								syscall_number = register_value and register_value - 0x2000000 or nil
							else
								syscall_number = number_from_value(regs.rax)
							end
							local read_number = S.architecture == "arm64"
								and (S.target_format == "Mach-O" and 3 or 63)
								or 0
							is_read_syscall = syscall_number == read_number
						end
						S.input_syscall_breakpoint_hit = false
						if input_fd == 0 and is_read_syscall then
							S.waiting_for_input = true
							if show_terminal() then
								status("Input requested — type a line and press Enter")
							else
								status("Input requested, but the program terminal could not be shown")
								notify("Could not show the program input terminal.", vim.log.levels.ERROR)
							end
						else
							S.running = true
							dap_send("continue", { threadId = S.thread_id })
							return
						end
					end
					local pc = current_pc()
					render_registers()
					if pc then
						dap_send("disassemble", {
							memoryReference = string.format("0x%x", pc),
							instructionOffset = -12,
							instructionCount = 48,
							resolveSymbols = true,
						}, function(dis_response)
							local instructions = {}
							local current_source_line
							for _, ins in ipairs((dis_response.body and dis_response.body.instructions) or {}) do
								local address = ins.address or "?"
								instructions[#instructions + 1] = {
									address = address,
									inst = ins.instruction or ins.instructionBytes or "?",
								}
								-- DAP DisassembledInstruction can carry the source line
								-- associated with this exact machine instruction.
								if number_from_value(address) == pc and type(ins.line) == "number" then
									current_source_line = ins.line
								end
							end
							S.instructions = instructions
							local current_instruction
							for _, ins in ipairs(instructions) do
								if number_from_value(ins.address) == pc then
									current_instruction = ins.inst
									break
								end
							end
							local mapped_line = source_line_for_instruction(
								current_instruction, previous_source_line, S.current_frame_name, pc, previous_pc, previous_frame_name
							)
							local function valid_line(line)
								return type(line) == "number" and line >= 1 and line <= #(S.source_lines or {})
							end
							if valid_line(mapped_line) then
								S.source_line = mapped_line
							elseif valid_line(current_source_line) and current_source_line ~= previous_source_line then
								S.source_line = current_source_line
							elseif valid_line(reported_frame_line) and reported_frame_line ~= previous_source_line then
								S.source_line = reported_frame_line
							elseif normalized_symbol_name(S.current_frame_name) ~= normalized_symbol_name(previous_frame_name) then
								local function_line = source_line_for_function(S.current_frame_name)
								if function_line then S.source_line = function_line end
							elseif previous_source_path == S.source_path and previous_source_line and pc and previous_pc and pc ~= previous_pc then
								local direction = pc > previous_pc and 1 or -1
								local next_line = next_executable_source_line(previous_source_line, direction)
								if next_line then S.source_line = next_line end
							elseif valid_line(current_source_line) then
								S.source_line = current_source_line
							elseif valid_line(reported_frame_line) then
								S.source_line = reported_frame_line
							else
								local function_line = source_line_for_function(S.current_frame_name)
								if function_line then S.source_line = function_line end
							end
							render_source()
							render_assembly()
						end)
					else
						render_source()
					end
					local sp = current_sp()
					if sp then
						local regions = memory_ranges(sp, number_from_value(S.fp) or number_from_value(S.regs.fp) or number_from_value(S.regs.x29) or number_from_value(S.regs.rbp))
						local remaining = #regions
						for i, region in ipairs(regions) do
							local index = i
							dap_send("readMemory", {
								memoryReference = string.format("0x%x", region.address),
								count = region.count,
							}, function(mem_response)
								local data = mem_response.body and mem_response.body.data
								if data then
									regions[index].bytes = base64_decode(data)
								else
									regions[index].error = true
								end
								remaining = remaining - 1
								if remaining == 0 then render_stack_regions(regions) end
							end)
						end
					end

				end
			end)
		end
	end)
end

local function mi_handle_line(line)
	local token, result = line:match("^(%d+)%^(%w+)")
	if token then
		local pending = S.mi_pending[token]
		S.mi_pending[token] = nil
		local callback = type(pending) == "table" and pending.callback or pending
		if result == "error" then
			local message = mi_unescape(field(line, "msg") or "Unknown GDB error")
			if not (type(pending) == "table" and pending.quiet_error) then
				status("GDB error: " .. message)
			end
			if callback then callback(line) end
		elseif callback then
			callback(line)
		end
		return
	end
	if line:sub(1, 1) == "@" then
		append_output(mi_unescape(line:sub(2):match('^"(.*)"') or ""))
	elseif line:match("^%*running") then
		S.running, S.started = true, true
		status("Running")
	elseif line:match("^%*stopped") then
		S.running, S.started = false, true
		S.step_request_pending = false
		local reason = field(line, "reason") or "stopped"
		if reason:match("exited") then
			S.finished = true
			S.finishing_after_main_return = false
			local code = field(line, "exit-code")
			status(code and ("Program exited — code " .. code .. " | F9 to restart") or "Program exited | F9 to restart")
			append_output("Exit code: " .. tostring(code or "unknown"))
		elseif S.finishing_after_main_return then
			-- After main returns, ignore intermediate runtime stops and wait for
			-- the actual exit event, as LLDB-DAP does.
			S.running = true
			mi_send("-exec-continue")
		elseif reason == "syscall-return" and S.syscall_catchpoint_active then
			-- The matching read/readv completed after the user submitted input.
			-- Do not leave the debugger paused on the syscall's return edge.
			S.running = true
			mi_send("-exec-continue")
		else
			local breakpoint_id = field(line, "bkptno")
			S.input_breakpoint_hit = (reason == "syscall-entry" and S.syscall_catchpoint_active)
				or (reason == "breakpoint-hit" and breakpoint_id and S.input_breakpoint_ids[breakpoint_id] == true)
			local stop_description = reason
			if reason == "signal-received" then
				stop_description = field(line, "signal-name") or "signal received"
			end
			status("Paused — " .. stop_description)
			refresh_mi()
		end
	elseif line:match("^=thread%-group%-exited") then
		S.running, S.finished = false, true
		S.finishing_after_main_return = false
		status("Program exited | F9 to restart")
		append_output("Exit code: unknown")
	end
end

local function mi_feed_stdout(data)
	data = data or {}
	for index, fragment in ipairs(data) do
		S.mi_stdout_buffer = (S.mi_stdout_buffer or "") .. fragment
		-- Neovim gives complete lines except for the final item in each callback.
		-- Only join fragments across callbacks; treating each callback as a line
		-- breaks MI records when a long response arrives in multiple chunks.
		if index < #data or fragment == "" then
			local line = S.mi_stdout_buffer:gsub("\r$", "")
			S.mi_stdout_buffer = ""
			if line ~= "" and not line:match("^%(%gdb%)") then
				mi_handle_line(line)
			end
		end
	end
end

local function dap_handle_message(message)
	if message.type == "response" then
		local callback = S.pending[message.request_seq]
		S.pending[message.request_seq] = nil
		if not message.success then
			local error_message = message.message or (message.body and message.body.error and message.body.error.format) or "LLDB-DAP error"
			status("LLDB error: " .. error_message)
			if callback then callback(message) end
		elseif callback then
			callback(message)
		end
		return
	end
	if message.type == "request" then
		if message.command == "runInTerminal" then
			handle_run_in_terminal(message)
		else
			dap_respond(message, false, nil, "Unsupported reverse request: " .. tostring(message.command))
		end
		return
	end
	if message.type ~= "event" then
		return
	end
	if message.event == "initialized" and not S.dap_launched then
		-- DAP breakpoints are configured after the "initialized" event.
		S.dap_launched = true
		local functions = { "main", "read", "__read", "read$NOCANCEL" }
		local breakpoints = {}
		for _, name in ipairs(functions) do
			breakpoints[#breakpoints + 1] = { name = name }
		end
		dap_send("setFunctionBreakpoints", {
			-- Stop at main and at common stdin read functions. Read breakpoints
			-- are filtered by fd=0 after the register state is refreshed.
			breakpoints = breakpoints,
		}, function(bp_response)
			S.input_breakpoint_ids = {}
			for index = 2, #functions do
				local breakpoint = bp_response.body and bp_response.body.breakpoints and bp_response.body.breakpoints[index]
				if breakpoint and breakpoint.id and breakpoint.verified ~= false then
					S.input_breakpoint_ids[breakpoint.id] = true
				end
			end
			local function configuration_done()
				dap_send("configurationDone", {}, function(config_response)
					if config_response.success then
						status("Program launched — waiting for main")
					end
				end)
			end
			local syscall_lines = {}
			for line_number, source_line in ipairs(S.source_lines or {}) do
				if source_line:match("%f[%w]svc%f[%W]") or source_line:match("%f[%w]syscall%f[%W]") then
					syscall_lines[#syscall_lines + 1] = { line = line_number }
				end
			end
			if S.source_path and #syscall_lines > 0 then
				dap_send("setBreakpoints", {
					source = { path = S.source_path },
					breakpoints = syscall_lines,
				}, function(source_response)
					S.syscall_breakpoint_ids = {}
					for _, breakpoint in ipairs((source_response.body and source_response.body.breakpoints) or {}) do
						if breakpoint.id and breakpoint.verified ~= false then
							S.syscall_breakpoint_ids[breakpoint.id] = true
						end
					end
					configuration_done()
				end)
			else
				configuration_done()
			end
		end)
	elseif message.event == "stopped" then
		S.thread_id = (message.body and message.body.threadId) or S.thread_id
		S.running, S.started = false, true
		S.step_request_pending = false
		if S.finishing_after_main_return then
			-- Ignore stops in the macOS runtime and continue until the exited event.
			S.running = true
			dap_send("continue", { threadId = S.thread_id })
			return
		end
		local reason = (message.body and message.body.reason) or "stopped"
		S.input_breakpoint_hit = false
		S.input_syscall_breakpoint_hit = false
		if reason == "breakpoint" then
			for _, breakpoint_id in ipairs((message.body and message.body.hitBreakpointIds) or {}) do
				if S.input_breakpoint_ids[breakpoint_id] then
					S.input_breakpoint_hit = true
					break
				elseif S.syscall_breakpoint_ids[breakpoint_id] then
					S.input_breakpoint_hit = true
					S.input_syscall_breakpoint_hit = true
					break
				end
			end
		end
		status("Paused — " .. reason)
		refresh_dap()
	elseif message.event == "continued" then
		S.running = true
		status("Running")
	elseif message.event == "exited" then
		S.running, S.finished = false, true
		S.finishing_after_main_return = false
		-- The process has exited: clear the execution cursor so the old source
		-- line is not shown as active.
		S.source_line = nil
		S.pc, S.sp, S.fp = nil, nil, nil
		S.regs, S.instructions = {}, {}
		render_source()
		render_assembly()
		render_registers()
		set_lines("stack", { "STACK / MEMORY", "", "Process exited; registers and memory are no longer refreshed." })
		local code = message.body and message.body.exitCode
		status(code ~= nil and ("Program exited — code " .. tostring(code) .. " | F9 to restart") or "Program exited | F9 to restart")
		append_output("Exit code: " .. tostring(code ~= nil and code or "unknown"))
	elseif message.event == "terminated" then
		S.running, S.finished = false, true
		S.finishing_after_main_return = false
		S.source_line = nil
		S.pc, S.sp, S.fp = nil, nil, nil
		S.regs, S.instructions = {}, {}
		render_source()
		render_assembly()
		render_registers()
		set_lines("stack", { "STACK / MEMORY", "", "Process exited; registers and memory are no longer refreshed." })
		status("Program exited | F9 to restart")
		append_output("Exit code: unknown")
	elseif message.event == "output" then
		local body = message.body or {}
		-- Show only actual program output, never debugger console output.
		if body.output and (body.category == "stdout" or body.category == "stderr") then
			append_output(body.output)
		end
	end
end

local function dap_feed(lines)
	-- Neovim's jobstart callback delivers stdout as an array of lines.
	-- table.concat preserves the separators represented by that array and
	-- avoids adding an extra newline after every callback (which corrupts
	-- Content-Length framed DAP messages).
	S.dap_buffer = S.dap_buffer .. table.concat(lines or {}, "\n")
	while true do
		if not S.dap_expected then
			local crlf_end = S.dap_buffer:find("\r\n\r\n", 1, true)
			local lf_end = S.dap_buffer:find("\n\n", 1, true)
			local header_end
			local delimiter_length
			if crlf_end and (not lf_end or crlf_end <= lf_end) then
				header_end, delimiter_length = crlf_end, 4
			elseif lf_end then
				header_end, delimiter_length = lf_end, 2
			else
				return
			end

			local header = S.dap_buffer:sub(1, header_end - 1)
			S.dap_buffer = S.dap_buffer:sub(header_end + delimiter_length)
			S.dap_expected = tonumber(header:match("[Cc]ontent%-[Ll]ength:%s*(%d+)"))
			if not S.dap_expected then
				S.dap_buffer = ""
				return
			end
		end

		if #S.dap_buffer < S.dap_expected then
			return
		end

		local body = S.dap_buffer:sub(1, S.dap_expected)
		S.dap_buffer = S.dap_buffer:sub(S.dap_expected + 1)
		S.dap_expected = nil
		local ok, message = pcall(vim.json.decode, body)
		if ok and type(message) == "table" then
			dap_handle_message(message)
		else
		end
	end
end

local function dap_start()
	local dap = vim.fn.system({ "xcrun", "-f", "lldb-dap" }):gsub("%s+$", "")
	if vim.v.shell_error ~= 0 or dap == "" or vim.fn.executable(dap) == 0 then
		notify("Could not locate lldb-dap through xcrun.", vim.log.levels.ERROR)
		close()
		return
	end
	S.backend = "LLDB-DAP / Mach-O " .. S.architecture
	status("Connecting to LLDB-DAP…")
	S.job = vim.fn.jobstart({ dap }, {
		stdin = "pipe",
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = function(_, data)
			vim.schedule(function() dap_feed(data) end)
		end,
		on_stderr = function(_, data)
			-- Ignore LLDB-DAP stderr; it contains adapter diagnostics.
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				S.job = nil
				if not S.closing then status("LLDB-DAP stopped (code " .. code .. ")") end
			end)
		end,
	})
	if not S.job or S.job <= 0 then
		S.job = nil
		notify("Could not start LLDB-DAP.", vim.log.levels.ERROR)
		return
	end
	dap_send("initialize", {
		clientID = "MIVN",
		clientName = "MIVN ASM Debugger",
		adapterID = "lldb",
		pathFormat = "path",
		linesStartAt1 = true,
		columnsStartAt1 = true,
		supportsVariableType = true,
		supportsVariablePaging = true,
		supportsRunInTerminalRequest = true,
	}, function(response)
		if not response.success then
			notify("LLDB-DAP rejected initialization.", vim.log.levels.ERROR)
			return
		end
		dap_send("launch", {
			program = S.executable,
			cwd = vim.fn.fnamemodify(S.executable, ":h"),
			stopOnEntry = false,
			args = {},
			env = {},
			console = "integratedTerminal",
			runInTerminal = true,
		}, function(launch_response)
			if not launch_response.success then
				status("Launch failed — see output")
				return
			end
			status("Launch requested from LLDB-DAP…")
		end)
	end)
end

local function gdb_start()
	local gdb = vim.fn.exepath("gdb")
	if gdb == "" then
		notify("GDB was not found in PATH.", vim.log.levels.ERROR)
		return
	end
	local shell = vim.fn.exepath("sh")
	if shell == "" then shell = "/bin/sh" end
	local terminal_buf, _, _, terminal_error = open_terminal({ shell, "-c", "while :; do sleep 3600; done" }, nil, true)
	if not terminal_buf then
		notify("Could not open the program input terminal: " .. tostring(terminal_error), vim.log.levels.ERROR)
		return
	end
	-- Neovim exposes a terminal job's PTY through channel metadata; term_gettty()
	-- is a Vim function and is not available in Neovim.
	local terminal_channel = vim.bo[terminal_buf].channel
	local channel_info = terminal_channel > 0 and vim.api.nvim_get_chan_info(terminal_channel) or {}
	local inferior_tty = channel_info.pty or ""
	if inferior_tty == "" then
		hide_terminal()
		if S.terminal_job and S.terminal_job > 0 then
			pcall(vim.fn.jobstop, S.terminal_job)
			S.terminal_job = nil
		end
		notify("Could not get the program input terminal device.", vim.log.levels.ERROR)
		return
	end
	hide_terminal()
	-- Creating and closing the PTY split changes Neovim's current window. The
	-- debugger controls are buffer-local, so restore focus before GDB starts.
	focus_debugger_panel("assembly")
	append_output("Program I/O terminal is hidden until GDB detects a read from fd 0.")
	S.backend = "GDB/MI2 / ELF"
	S.mi_stdout_buffer = ""
	status("Connecting to GDB…")
	S.job = vim.fn.jobstart({ gdb, "--quiet", "--nx", "--interpreter=mi2" }, {
		stdin = "pipe",
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = function(_, data)
			vim.schedule(function()
				mi_feed_stdout(data)
			end)
		end,
		on_stderr = function(_, data)
			vim.schedule(function()
				-- Ignore GDB stderr; it contains debugger diagnostics.
			end)
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				S.job = nil
				if not S.closing then status("GDB stopped (code " .. code .. ")") end
			end)
		end,
	})
	if not S.job or S.job <= 0 then
		S.job = nil
		notify("Could not start GDB.", vim.log.levels.ERROR)
		return
	end
	local function start_at_main_or_entry()
		local entry_symbols = { "main", "_start" }
		local function try_entry(index)
			local symbol = entry_symbols[index]
			if not symbol then
				-- Symbol-less binaries can still start at their ELF entry point.
				mi_send('-interpreter-exec console "starti"')
				return
			end
			mi_send("-break-insert -t " .. symbol, function(breakpoint_response)
				if not breakpoint_response:match("%d+%^done") then
					try_entry(index + 1)
					return
				end
				mi_send("-exec-run", function(run_response)
					if run_response:match("%d+%^error") then
						status("GDB could not start the program")
					end
				end)
			end, true)
		end
		try_entry(1)
	end
	local function load_executable()
		local function install_function_fallback(index)
			local names = { "read", "readv", "__read", "__libc_read" }
			local name = names[index]
			if not name then
				if next(S.input_breakpoint_ids) then
					append_output("Waiting for read/readv function breakpoints; the input window opens when fd 0 is read.")
				else
					append_output("GDB could not install stdin read breakpoints; use I to open the input terminal manually.")
				end
				start_at_main_or_entry()
				return
			end
			mi_send("-break-insert -f " .. name, function(response)
				local breakpoint_id = field(response, "number")
				if not response:match("%^error") and breakpoint_id then
					S.input_breakpoint_ids[breakpoint_id] = true
				end
				install_function_fallback(index + 1)
			end, true)
		end
		local function install_input_detection()
			-- `-catch-syscall` is not a GDB/MI command. Use the documented CLI
			-- catchpoint through MI's interpreter bridge, then fall back to libc
			-- function breakpoints on GDB/targets without syscall catch support.
			mi_send('-interpreter-exec console "catch syscall read readv"', function(response)
				if response:match("%^error") then
					S.syscall_catchpoint_active = false
					install_function_fallback(1)
				else
					S.syscall_catchpoint_active = true
					append_output("Waiting for read/readv syscalls; the input window opens when fd 0 is read.")
					start_at_main_or_entry()
				end
			end, true)
		end
		mi_send("-inferior-tty-set " .. inferior_tty, function(tty_response)
			if tty_response:match("%^error") then
				status("GDB could not set the program input terminal")
				return
			end
			mi_send("-file-exec-and-symbols " .. string.format("%q", S.executable), function(file_response)
				if file_response:match("%^error") then
					status("GDB could not load the executable")
					return
				end
				install_input_detection()
			end)
		end)
	end
	local function configure_gdb()
		mi_send("-gdb-set pagination off", function()
			mi_send("-gdb-set confirm off", function()
				if S.architecture == "x86_64" then
					mi_send("-gdb-set disassembly-flavor intel", load_executable)
				else
					load_executable()
				end
			end)
		end)
	end
	-- MI is synchronous by default. Enable async before starting the inferior so
	-- step/continue produce the *running/*stopped events that drive every refresh.
	mi_send("-gdb-set mi-async on", function(response)
		if response:match("%^error") then
			mi_send("-gdb-set target-async on", function() configure_gdb() end, true)
		else
			configure_gdb()
		end
	end, true)
end

local function detect_target(executable)
	local output = vim.fn.system({ "file", "-b", executable })
	if vim.v.shell_error ~= 0 then
		return nil, "La commande `file` n'a pas pu identifier le binaire."
	end
	local description = output:lower()
	if description:find("mach%-o") then
		local archs = vim.fn.system({ "lipo", "-archs", executable })
		if vim.v.shell_error == 0 and archs ~= "" then
			local list = " " .. archs:gsub("%s+", " ") .. " "
			if list:find(" arm64 ", 1, true) then
				return { format = "Mach-O", arch = "arm64", description = output }
			elseif list:find(" x86_64 ", 1, true) then
				return { format = "Mach-O", arch = "x86_64", description = output }
			end
		end
		if description:find("arm64") or description:find("aarch64") then
			return { format = "Mach-O", arch = "arm64", description = output }
		elseif description:find("x86_64") or description:find("x86%-64") then
			return { format = "Mach-O", arch = "x86_64", description = output }
		end
		return nil, "Mach-O binary detected, but its architecture could not be determined: " .. output
	elseif description:find("elf") then
		local arch
		if description:find("x86%-64") or description:find("x86_64") then
			arch = "x86_64"
		elseif description:find("aarch64") then
			arch = "arm64"
		elseif description:find("80386") or description:find("intel 80386") then
			arch = "x86"
		end
		if arch == "x86" then
			return nil, "32-bit x86 ELF executables are not supported yet."
		end
		if arch then
			return { format = "ELF", arch = arch, description = output }
		end
		return nil, "ELF binary detected, but its architecture is unsupported: " .. output
	end
	return nil, "Unrecognized executable format. `file` output: " .. output
end

local function focus_panel(direction)
	local current = vim.api.nvim_get_current_win()
	local cfg = vim.api.nvim_win_get_config(current)
	local function coord(value)
		return type(value) == "table" and (value[1] or 0) or (value or 0)
	end
	local row, col = coord(cfg.row), coord(cfg.col)
	local cx, cy = col + vim.api.nvim_win_get_width(current) / 2, row + vim.api.nvim_win_get_height(current) / 2
	local best, best_score
	for _, win in pairs(S.windows) do
		if win ~= current and vim.api.nvim_win_is_valid(win) then
			local wc = vim.api.nvim_win_get_config(win)
			local x = coord(wc.col) + vim.api.nvim_win_get_width(win) / 2
			local y = coord(wc.row) + vim.api.nvim_win_get_height(win) / 2
			local dx, dy = x - cx, y - cy
			local primary, secondary
			if direction == "h" then primary, secondary = -dx, math.abs(dy)
			elseif direction == "l" then primary, secondary = dx, math.abs(dy)
			elseif direction == "j" then primary, secondary = dy, math.abs(dx)
			else primary, secondary = -dy, math.abs(dx) end
			if primary > 0 then
				local score = primary + secondary * 1.5
				if not best_score or score < best_score then best, best_score = win, score end
			end
		end
	end
	if best then vim.api.nvim_set_current_win(best) end
end

-- macOS's LLDB does not always interpret DAP stepIn/next as a machine
-- instruction step. Using explicit LLDB commands ensures BL/B does not also
-- consume the instruction at the target address.
local function step_dap_instruction(lldb_commands, description)
	if not S.job or S.step_request_pending or S.running then return end
	S.step_request_pending = true
	S.running = true
	status(description or "Machine step — waiting to stop…")
	if type(lldb_commands) == "string" then lldb_commands = { lldb_commands } end
	local function attempt(index)
		local command = lldb_commands[index]
		if not command then
			S.step_request_pending = false
			S.running = false
			status("LLDB machine step failed — no compatible instruction-step command was accepted")
			return
		end
		dap_send("evaluate", {
			expression = "`" .. command,
			frameId = S.frame_id,
			context = "repl",
		}, function(response)
			local result = response.body and response.body.result or ""
			local command_error = not response.success or (type(result) == "string" and result:lower():find("error:", 1, true) ~= nil)
			if command_error then
				if lldb_commands[index + 1] then
					attempt(index + 1)
				else
					S.step_request_pending = false
					S.running = false
					status("LLDB machine step failed: " .. tostring(result ~= "" and result or response.message))
				end
			end
		end)
	end
	attempt(1)
end

local function step_mi(command)
	S.step_request_pending = true
	S.running = true
	status("Instruction step — waiting to stop…")
	mi_send(command, function(response)
		if response:match("%^error") then
			S.step_request_pending = false
			S.running = false
			status("Instruction step failed")
		elseif response:match("%^running") then
			-- Keep the lock until the *stopped event arrives.
		elseif response:match("%^done") and S.step_request_pending then
			-- Some older/foreground MI targets report completion synchronously and
			-- omit an asynchronous *stopped record.
			S.step_request_pending = false
			S.running, S.started = false, true
			status("Paused — instruction step complete")
			refresh_mi()
		end
	end)
end

local function bind_keys(buf)
	local function map(key, callback, description)
		vim.keymap.set("n", key, callback, { buffer = buf, silent = true, nowait = true, desc = description })
	end
	local function continue_gdb()
		if not S.job or S.running then return end
		S.running = true
		status("Running")
		mi_send("-exec-continue", function(response)
			if response:match("%^error") then
				S.running = false
				status("GDB could not continue the program")
			elseif response:match("%^done") and S.running then
				-- Synchronous MI completes only after the next stop.
				S.running, S.started = false, true
				status("Paused")
				refresh_mi()
			end
		end)
	end
	local function continue_program()
		if not S.job then return end
		if S.finished then
			status("Program exited — press F9 or r to restart")
			return
		end
		if S.backend and S.backend:match("LLDB%-DAP") then
			if not S.started then
				status("Waiting for LLDB-DAP launch…")
			elseif not S.running then
				dap_send("continue", { threadId = S.thread_id })
			end
		elseif not S.started then
			status("GDB is preparing the program…")
		elseif not S.running then
			continue_gdb()
		end
	end
	local function step_instruction(step_over)
		if S.finished then
			status("Program exited — press F9 or r to restart")
			return
		end
		if not S.job or not S.started or S.running or S.step_request_pending then return end
		if is_at_main_return() then
			-- Let ret and the runtime exit normally to collect the real exit code.
			S.finishing_after_main_return = true
			status("Main returned — waiting for exit code…")
			if S.backend and S.backend:match("LLDB%-DAP") then
				S.running = true
				dap_send("continue", { threadId = S.thread_id })
			else
				continue_gdb()
			end
			return
		end
		if S.backend and S.backend:match("LLDB%-DAP") then
			if step_over then
				-- LLDB command spelling varies between Apple and upstream releases.
				step_dap_instruction({ "thread step-inst-over", "thread step-over-inst" }, "Step over one machine instruction…")
			else
				step_dap_instruction("thread step-inst", "Step one machine instruction…")
			end
		elseif step_over then
			step_mi("-exec-next-instruction")
		else
			step_mi("-exec-step-instruction")
		end
	end
	local function restart_program()
		if S.executable then M.open(S.executable) end
	end
	local function interrupt_program()
		if not S.job or not S.running then return end
		if S.backend and S.backend:match("LLDB%-DAP") then
			dap_send("pause", { threadId = S.thread_id })
		else
			mi_send("-exec-interrupt")
		end
	end
	local function focus_assembly()
		local win = S.windows.assembly
		if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_set_current_win(win) end
	end
	local function focus_source()
		local win = S.windows.source
		if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_set_current_win(win) end
	end
	local function focus_registers()
		local win = S.windows.registers
		if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_set_current_win(win) end
	end
	local function focus_memory()
		local win = S.windows.stack
		if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_set_current_win(win) end
	end
	local function scroll(motion)
		return function()
			local win = vim.api.nvim_get_current_win()
			if not vim.api.nvim_win_is_valid(win) then return end
			if win == S.windows.assembly or win == S.windows.source then
				S.follow_pc = false
			elseif win == S.windows.stack then
				S.follow_memory = false
			end
			local delta
			if motion == "j" then delta = 1
			elseif motion == "k" then delta = -1
			elseif motion == "<C-d>" then delta = math.max(1, math.floor(vim.api.nvim_win_get_height(win) / 2))
			else delta = -math.max(1, math.floor(vim.api.nvim_win_get_height(win) / 2)) end
			local cursor = vim.api.nvim_win_get_cursor(win)
			local last_line = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
			vim.api.nvim_win_set_cursor(win, { math.max(1, math.min(last_line, cursor[1] + delta)), cursor[2] })
		end
	end
	map("q", close, "Close debugger")
	map("I", function()
		S.waiting_for_input = true
		if show_terminal() then
			status("Input terminal opened — type a line and press Enter")
		else
			S.waiting_for_input = false
			vim.notify("The program input terminal is unavailable.", vim.log.levels.WARN)
		end
	end, "Focus program input/output terminal")
	map("<leader>wh", function() focus_panel("h") end, "Left panel")
	map("<leader>wj", function() focus_panel("j") end, "Bottom panel")
	map("<leader>wk", function() focus_panel("k") end, "Top panel")
	map("<leader>wl", function() focus_panel("l") end, "Right panel")
	map("<F5>", continue_program, "Start / continue")
	map("<F6>", function() step_instruction(false) end, "Step one instruction and enter calls")
	map("<F7>", function() step_instruction(true) end, "Step one instruction without entering calls")
	map("<F8>", interrupt_program, "Interrupt program")
	map("<F9>", restart_program, "Restart program from the beginning")
	-- Letter shortcuts work in the debugger even when the terminal intercepts Fn keys.
	map("c", continue_program, "Continue")
	map("s", function() step_instruction(false) end, "Step into one instruction")
	map("n", function() step_instruction(true) end, "Step over one instruction")
	map("p", interrupt_program, "Pause program")
	map("r", restart_program, "Restart program")
	map("a", focus_assembly, "Focus assembly panel")
	map("v", focus_source, "Focus source panel")
	map("R", focus_registers, "Focus register panel")
	map("m", focus_memory, "Focus memory panel")
	for _, key in ipairs({ "j", "k", "<C-d>", "<C-u>" }) do
		map(key, scroll(key), "Scroll panel; code and memory follow pause while scrolling")
	end
	map("f", function()
		S.follow_pc = not S.follow_pc
		if S.follow_pc then
			render_assembly()
			render_source()
		end
		status(S.follow_pc and "Auto-following the current instruction" or "Auto-follow off — scroll with j/k; press f to follow again")
	end, "Toggle automatic code following")
	map("F", function()
		S.follow_memory = not S.follow_memory
		if S.follow_memory then render_stack_regions(S.stack_regions) end
		status(S.follow_memory and "Memory view following SP" or "Memory auto-follow off — scroll with j/k; press F to follow SP")
	end, "Toggle automatic memory following")
end

function M.open(executable)
	if not executable or executable == "" then
		notify("Usage: :AsmDebug ./my_executable", vim.log.levels.WARN)
		return
	end
	executable = vim.fn.fnamemodify(executable, ":p")
	if vim.fn.filereadable(executable) == 0 then
		notify("File not found: " .. executable, vim.log.levels.ERROR)
		return
	end

	local target, err = detect_target(executable)
	if not target then
		notify(err, vim.log.levels.ERROR)
		return
	end
	local host = vim.uv.os_uname().sysname
	if target.format == "Mach-O" and host ~= "Darwin" then
		notify("This Mach-O executable must be debugged on macOS.", vim.log.levels.ERROR)
		return
	end
	if target.format == "ELF" and host ~= "Linux" then
		notify(
			"This ELF/Linux executable cannot run directly on macOS. Run MIVN in a Linux VM or compile a native ARM64 Mach-O binary.",
			vim.log.levels.ERROR
		)
		return
	end
	if target.format == "Mach-O" and target.arch == "arm64" and host == "Darwin" then
		-- LLDB-DAP is the native macOS ARM64 backend.
	elseif target.format == "ELF" and (target.arch == "x86_64" or target.arch == "arm64") and host == "Linux" then
		-- GDB/MI2 is used for ELF binaries when Neovim itself runs on Linux.
	elseif target.format == "Mach-O" and host == "Darwin" then
		-- LLDB-DAP also handles native macOS x86_64 and universal Mach-O binaries.
	else
		notify("Unsupported host/target combination: " .. host .. " / " .. target.format .. " " .. target.arch, vim.log.levels.ERROR)
		return
	end

	close()
	setup_highlights()
	S.executable = executable
	S.architecture = target.arch
	S.target_format = target.format
	S.instructions, S.regs, S.output = {}, {}, {}
	S.pc, S.sp, S.fp = nil, nil, nil
	S.source_line = nil
	S.follow_pc = true
	S.follow_memory = true
	S.stack_regions = {}
	load_source_for_executable(executable)
	S.started, S.running, S.finished, S.dap_launched = false, false, false, false
	S.step_request_pending = false
	S.finishing_after_main_return = false
	S.in_main, S.main_return_pc = false, nil
	S.current_frame_name = nil
	S.pending, S.mi_pending = {}, {}
	S.seq, S.mi_token = 0, 0
	S.thread_id = 1
	S.dap_buffer, S.dap_expected = "", nil
	S.input_breakpoint_ids, S.syscall_breakpoint_ids = {}, {}
	S.syscall_catchpoint_active = false
	S.input_breakpoint_hit, S.input_syscall_breakpoint_hit = false, false
	S.waiting_for_input = false
	S.terminal_output, S.terminal_output_text = {}, ""

	local width, height = vim.o.columns, vim.o.lines
	local margin, content_row = 1, 2
	local full_width = math.max(20, width - margin * 2)
	local register_count = #register_order()
	-- Each column has room for a 64-bit hex value, its exact decimal value and 8 ASCII bytes.
	-- On narrow terminals use fewer columns rather than clipping register values.
	local register_columns = math.max(1, math.min(4, math.floor((full_width + 2) / 54)))
	S.register_columns = register_columns
	local registers_height = math.ceil(register_count / register_columns) + 1
	local body_row = content_row + registers_height + 2
	local body_height = math.max(8, height - body_row - 4)
	local body_width = math.max(40, full_width)
	local left_width = math.max(30, math.floor((body_width - 4) * 0.54))
	local right_width = math.max(22, body_width - left_width - 4)
	local right_col = margin + left_width + 4
	local inner_height = math.max(5, body_height - 2)
	local assembly_height = math.max(4, math.floor(inner_height * 0.58))
	local source_height = math.max(3, body_height - assembly_height - 2)
	local output_height = math.max(3, math.min(6, math.floor(body_height * 0.20)))
	local stack_height = math.max(3, body_height - output_height - 2)

	panel("status", "CONTROLS", width - margin * 2, 1, 0, margin, { border = false })
	panel("registers", "REGISTERS — HEX / DECIMAL / ASCII", full_width, registers_height, content_row, margin)
	panel("assembly", "DISASSEMBLY", left_width, assembly_height, body_row, margin)
	panel("source", "ASM SOURCE", left_width, source_height, body_row + assembly_height + 2, margin)
	panel("stack", target.arch == "arm64" and "STACK / MEMORY — SP / FP" or "STACK / MEMORY — RSP / RBP", right_width, stack_height, body_row, right_col)
	panel("output", "PROGRAM OUTPUT", right_width, output_height, body_row + stack_height + 2, right_col)
	for _, buf in pairs(S.buffers) do bind_keys(buf) end
	focus_debugger_panel("assembly")

	status(string.format("Target detected: %s %s", target.format, target.arch))
	local description_lines = vim.split(vim.trim(target.description or ""), "\n", { plain = true, trimempty = true })
	local assembly_intro = { "Inspecting target…" }
	vim.list_extend(assembly_intro, description_lines)
	set_lines("assembly", assembly_intro)
	render_source()
	set_lines("registers", { "Waiting for registers…" })
	set_lines("stack", { "Waiting for memory…" })
	set_lines("output", {})

	if target.format == "Mach-O" then
		dap_start()
	else
		gdb_start()
	end
end

local function pick_executable()
	local cwd = vim.fn.getcwd()
	local scan = vim.uv.fs_scandir(cwd)
	local executables = {}
	if scan then
		while true do
			local name, kind = vim.uv.fs_scandir_next(scan)
			if not name then break end
			local path = vim.fs.joinpath(cwd, name)
			local stat = (kind == "file" or kind == "link") and vim.uv.fs_stat(path) or nil
			if stat and stat.type == "file" and vim.fn.executable(path) == 1 then
				executables[#executables + 1] = path
			end
		end
	end

	if #executables == 0 then
		notify("No executable files found in " .. cwd, vim.log.levels.WARN)
		return
	end
	table.sort(executables)

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	pickers.new({}, {
		prompt_title = "Executables — " .. vim.fn.fnamemodify(cwd, ":~"),
		finder = finders.new_table({
			results = executables,
			entry_maker = function(path)
				local relative = vim.fs.relpath(cwd, path) or path
				return { value = path, display = relative, ordinal = relative, filename = path }
			end,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection then M.open(selection.value) end
			end)
			return true
		end,
	}):find()
end

function M.setup()
	vim.api.nvim_create_user_command("AsmDebug", function(opts)
		M.open(opts.args)
	end, {
		nargs = 1,
		complete = "file",
		desc = "Assembly debugger with automatic target detection",
	})
	vim.keymap.set("n", "<leader>ad", function()
		pick_executable()
	end, { desc = "Assembly debugger" })
end

return M
