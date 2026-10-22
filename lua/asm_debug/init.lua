local M = {}

local S = {
	job = nil,
	token = 0,
	pending = {},
	buffers = {},
	windows = {},
	status = "Prêt",
	executable = nil,
	instructions = {},
	regs = {},
	pc = nil,
	rsp = nil,
	started = false,
	running = false,
	output = {},
	output_bytes = 0,
	output_limit = 500,
	closing = false,
}

-- Palette MIVN : violet principal et vert secondaire.
local function setup_highlights()
	local palette = {
		AsmDebugTitle = { fg = "#CBA6F7", bold = true },
		AsmDebugAccent = { fg = "#A6F7B2", bold = true },
		AsmDebugAddress = { link = "Type" },
		AsmDebugCurrent = { fg = "#1E1E2E", bg = "#A6F7B2", bold = true },
		AsmDebugRegister = { fg = "#CBA6F7", bold = true },
		AsmDebugChanged = { fg = "#A6F7B2", bold = true },
		AsmDebugStackPointer = { fg = "#1E1E2E", bg = "#A6F7B2", bold = true },
		AsmDebugBasePointer = { fg = "#1E1E2E", bg = "#F9E2AF", bold = true },
		AsmDebugMnemonic = { fg = "#D6A6FF", bold = true },
		AsmDebugOperandRegister = { fg = "#74D7F0", bold = true },
		AsmDebugOperandNumber = { fg = "#FFB86C" },
		AsmDebugOperandSymbol = { fg = "#A6E3A1", italic = true },
		AsmDebugInstructionType = { fg = "#F38BA8", bold = true },
		AsmDebugStackAddress = { fg = "#CBA6F7" },
		AsmDebugStackValue = { link = "String" },
		AsmDebugByte1 = { fg = "#F38BA8", bold = true },
		AsmDebugByte2 = { fg = "#FAB387", bold = true },
		AsmDebugByte3 = { fg = "#F9E2AF", bold = true },
		AsmDebugByte4 = { fg = "#A6E3A1", bold = true },
		AsmDebugByte5 = { fg = "#94E2D5", bold = true },
		AsmDebugByte6 = { fg = "#89DCEB", bold = true },
		AsmDebugByte7 = { fg = "#89B4FA", bold = true },
		AsmDebugByte8 = { fg = "#CBA6F7", bold = true },
		AsmDebugDecimal = { link = "Number" },
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

local function notify(message, level)
	vim.schedule(function()
		vim.notify(message, level or vim.log.levels.INFO)
	end)
end

local function valid_buf(name)
	local buf = S.buffers[name]
	return buf and vim.api.nvim_buf_is_valid(buf)
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

local function append_output(text)
	if not text or text == "" then
		return
	end

	for line in (text .. "\n"):gmatch("(.-)\n") do
		S.output[#S.output + 1] = line
	end

	while #S.output > S.output_limit do
		table.remove(S.output, 1)
	end

	set_lines("output", S.output)
	local win = S.windows.output
	if win and vim.api.nvim_win_is_valid(win) then
		pcall(vim.api.nvim_win_set_cursor, win, {
			math.max(1, #S.output),
			0,
		})
	end
end

local function close()
	S.closing = true

	if S.job then
		pcall(vim.fn.chansend, S.job, "999-gdb-exit\n")
		pcall(vim.fn.jobstop, S.job)
		S.job = nil
	end

	for _, win in pairs(S.windows) do
		if vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end

	S.windows = {}
	S.buffers = {}
	S.pending = {}
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

	S.buffers[name] = buf
	S.windows[name] = win
	return buf
end

local function field(text, name)
	return text:match(name .. '="([^"]*)"')
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

local function quoted(text)
	return '"' .. text:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

local function send(command, callback)
	if not S.job then
		return
	end

	S.token = S.token + 1
	local token = tostring(S.token)
	S.pending[token] = callback or function() end

	local ok, result = pcall(vim.fn.chansend, S.job, token .. command .. "\n")

	if not ok or result == 0 then
		S.pending[token] = nil
		notify("Impossible d'envoyer la commande à GDB.", vim.log.levels.ERROR)
	end
	return token
end

local function status(text)
	S.status = text
	local executable = S.executable and vim.fn.fnamemodify(S.executable, ":t") or "—"
	set_lines("status", {
		string.format(
			" ASM DEBUG  │ %s │ %s │ F5 Continuer  F6 Step-in  F7 Next  F8 Stop  q Fermer │ <leader>w{h,j,k,l} Panneaux",
			text,
			executable
		),
	})
	local buf = S.buffers.status
	if buf and vim.api.nvim_buf_is_valid(buf) then
		local ns = vim.api.nvim_create_namespace("asmdebug-status")
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugStatus", 0, 0, 11)
	end
end

local function highlight_line(name, line, group)
	local buf = S.buffers[name]
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local ns = vim.api.nvim_create_namespace("asmdebug-" .. name)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, group, line - 1, 0, -1)
end

local function render_assembly()
	local lines = {
		"ADRESSE          INSTRUCTION",
		string.rep("─", 42),
	}
	local current_line
	local instruction_lines = {}

	for _, ins in ipairs(S.instructions) do
		if ins.section then
			lines[#lines + 1] = ""
			lines[#lines + 1] = "── Fonction appelée : " .. ins.section .. " ──"
		else
			local current = S.pc and ins.address and tonumber(ins.address) == tonumber(S.pc)
			lines[#lines + 1] =
				string.format("%s %-16s %s", current and "▶" or " ", ins.address or "?", ins.inst or "?")
			local line_number = #lines
			local marker = current and "▶" or " "
			local address = ins.address or "?"
			-- Les colonnes de Neovim sont en octets UTF-8 : ▶ occupe 3 octets.
			local instruction_col = #marker + 1 + math.max(16, #address) + 1
			instruction_lines[#instruction_lines + 1] = {
				line = line_number,
				text = ins.inst or "",
				current = current,
				instruction_col = instruction_col,
			}
			if current then
				current_line = line_number
			end
		end
	end

	if #S.instructions == 0 then
		lines[#lines + 1] = "En attente du désassemblage…"
	end

	set_lines("assembly", lines)
	local buf = S.buffers.assembly
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local ns = vim.api.nvim_create_namespace("asmdebug-assembly-syntax")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	-- Palette syntaxique : mnémoniques, registres, nombres et symboles.
	local mnemonics = {
		mov = true,
		movzx = true,
		movsx = true,
		movsxd = true,
		lea = true,
		push = true,
		pop = true,
		call = true,
		ret = true,
		leave = true,
		enter = true,
		add = true,
		sub = true,
		adc = true,
		sbb = true,
		imul = true,
		mul = true,
		idiv = true,
		div = true,
		inc = true,
		dec = true,
		neg = true,
		cmp = true,
		test = true,
		["and"] = true,
		["or"] = true,
		xor = true,
		["not"] = true,
		shl = true,
		shr = true,
		sar = true,
		sal = true,
		rol = true,
		ror = true,
		rcl = true,
		rcr = true,
		jmp = true,
		je = true,
		jne = true,
		jz = true,
		jnz = true,
		jg = true,
		jge = true,
		jl = true,
		jle = true,
		ja = true,
		jae = true,
		jb = true,
		jbe = true,
		jo = true,
		jno = true,
		js = true,
		jns = true,
		jp = true,
		jnp = true,
		jcxz = true,
		jecxz = true,
		jrcxz = true,
		loop = true,
		loope = true,
		loopne = true,
		syscall = true,
		sysenter = true,
		int = true,
		nop = true,
		cdqe = true,
		cqo = true,
		rep = true,
		repe = true,
		repz = true,
		repne = true,
		repnz = true,
		cmove = true,
		cmovne = true,
		cmovz = true,
		cmovnz = true,
		sete = true,
		setne = true,
		setl = true,
		setle = true,
		setg = true,
		setge = true,
		seta = true,
		setae = true,
		setb = true,
		setbe = true,
	}
	local registers = {
		rax = true,
		rbx = true,
		rcx = true,
		rdx = true,
		rsi = true,
		rdi = true,
		rbp = true,
		rsp = true,
		eax = true,
		ebx = true,
		ecx = true,
		edx = true,
		esi = true,
		edi = true,
		ebp = true,
		esp = true,
		ax = true,
		bx = true,
		cx = true,
		dx = true,
		si = true,
		di = true,
		bp = true,
		sp = true,
		ip = true,
		rip = true,
		eip = true,
		eflags = true,
		rflags = true,
		al = true,
		ah = true,
		bl = true,
		bh = true,
		cl = true,
		ch = true,
		dl = true,
		dh = true,
		sil = true,
		dil = true,
		bpl = true,
		spl = true,
		cs = true,
		ds = true,
		es = true,
		fs = true,
		gs = true,
		ss = true,
	}

	for _, item in ipairs(instruction_lines) do
		local row = item.line - 1
		local base_col = item.instruction_col -- colonne exacte en octets UTF-8

		-- La ligne courante fournit le fond vert ; les couleurs syntaxiques
		-- sont ajoutées ensuite afin de conserver leurs couleurs de premier plan.
		if item.current then
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugCurrent", row, 0, -1)
		end

		-- Coloration du mnémonique : les colonnes sont calculées depuis le
		-- texte complet de l'instruction, sans décalage relatif aux opérandes.
		local mnemonic_start, mnemonic_end, mnemonic = item.text:find("^%s*([%w_%.]+)")
		if mnemonic_start and mnemonic then
			local name = mnemonic:lower()
			if mnemonics[name] or name:match("^j[%w]+$") or name:match("^set[%w]+$") or name:match("^cmov[%w]+$") then
				local word_start = item.text:find(mnemonic, 1, true)
				if word_start then
					vim.api.nvim_buf_add_highlight(
						buf,
						ns,
						"AsmDebugMnemonic",
						row,
						base_col + word_start - 1,
						base_col + word_start - 1 + #mnemonic
					)
				end
			end
		end

		-- Registres : repérés dans l'instruction entière pour garder les
		-- colonnes exactes même lorsque le mnémonique change de longueur.
		for a, token, b in item.text:gmatch("()([%a][%w]*)()") do
			local name = token:lower()
			if registers[name] or name:match("^r%d+[bwd]?$") then
				vim.api.nvim_buf_add_highlight(
					buf,
					ns,
					"AsmDebugOperandRegister",
					row,
					base_col + a - 1,
					base_col + b - 1
				)
			end
		end

		-- Constantes numériques et adresses.
		for a, token, b in item.text:gmatch("()(0[xX][%da-fA-F]+)()") do
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugOperandNumber", row, base_col + a - 1, base_col + b - 1)
		end
		for a, token, b in item.text:gmatch("()(%-?%d+)()") do
			if not token:match("^0[xX]") then
				vim.api.nvim_buf_add_highlight(
					buf,
					ns,
					"AsmDebugOperandNumber",
					row,
					base_col + a - 1,
					base_col + b - 1
				)
			end
		end

		-- Symboles entre chevrons, par exemple <print_int> ou <end>.
		for a, token, b in item.text:gmatch("()(<[%w_%.@$]+>)()") do
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugOperandSymbol", row, base_col + a - 1, base_col + b - 1)
		end

		-- Réappliquer le mnémonique après les autres règles pour qu'aucune
		-- coloration d'opérande ne puisse le recouvrir.
		local _, _, final_mnemonic = item.text:find("^%s*([%w_%.]+)")
		if final_mnemonic then
			local lower = final_mnemonic:lower()
			if
				mnemonics[lower]
				or lower:match("^j[%w]+$")
				or lower:match("^set[%w]+$")
				or lower:match("^cmov[%w]+$")
			then
				local word_start = item.text:find(final_mnemonic, 1, true)
				if word_start then
					vim.api.nvim_buf_add_highlight(
						buf,
						ns,
						"AsmDebugMnemonic",
						row,
						base_col + word_start - 1,
						base_col + word_start - 1 + #final_mnemonic
					)
				end
			end
		end

		-- Qualificateurs de taille de mémoire.
		for a, token, b in item.text:gmatch("()([%a]+)()") do
			local name = token:lower()
			if name == "byte" or name == "word" or name == "dword" or name == "qword" or name == "ptr" then
				vim.api.nvim_buf_add_highlight(
					buf,
					ns,
					"AsmDebugInstructionType",
					row,
					base_col + a - 1,
					base_col + b - 1
				)
			end
		end
	end
end

-- Conversion hexadécimal -> décimal sans perte de précision Lua (uint64).
local function hex_to_decimal(hex)
	local digits = (hex or ""):gsub("^0[xX]", ""):gsub("^0+", "")
	if digits == "" then
		return "0"
	end
	local decimal = "0"
	for i = 1, #digits do
		local nibble = tonumber(digits:sub(i, i), 16) or 0
		local carry = nibble
		local out = {}
		for j = #decimal, 1, -1 do
			local n = (tonumber(decimal:sub(j, j)) or 0) * 16 + carry
			out[#out + 1] = tostring(n % 10)
			carry = math.floor(n / 10)
		end
		while carry > 0 do
			out[#out + 1] = tostring(carry % 10)
			carry = math.floor(carry / 10)
		end
		local reversed = {}
		for j = #out, 1, -1 do
			reversed[#reversed + 1] = out[j]
		end
		decimal = table.concat(reversed)
	end
	return decimal
end

local function unsigned_decimal(hex)
	if not hex then
		return "?"
	end
	return hex_to_decimal(hex)
end

local function signed_decimal(hex)
	local digits = (hex or ""):gsub("^0[xX]", "")
	if digits == "" then
		return "—"
	end
	if #digits < 16 or not digits:sub(1, 1):match("[89a-fA-F]") then
		return hex_to_decimal(digits)
	end
	-- Complément à deux : -(2^64 - valeur), calculé en hexadécimal.
	local inverted = {}
	for i = 1, #digits do
		local n = tonumber(digits:sub(i, i), 16) or 0
		inverted[#inverted + 1] = string.format("%x", 15 - n)
	end
	local magnitude = hex_to_decimal(table.concat(inverted))
	-- Ajouter 1 à la magnitude décimale.
	local carry, out = 1, {}
	for i = #magnitude, 1, -1 do
		local n = tonumber(magnitude:sub(i, i)) + carry
		out[#out + 1] = tostring(n % 10)
		carry = math.floor(n / 10)
	end
	if carry > 0 then
		out[#out + 1] = tostring(carry)
	end
	local rev = {}
	for i = #out, 1, -1 do
		rev[#rev + 1] = out[i]
	end
	return "-" .. table.concat(rev)
end

local function render_registers()
	local lines = {
		"REGISTRE     HEXADÉCIMAL             SIGNÉ / NON SIGNÉ",
		string.rep("─", 65),
	}

	local order = {
		"rip",
		"rax",
		"rbx",
		"rcx",
		"rdx",
		"rsi",
		"rdi",
		"rbp",
		"rsp",
		"r8",
		"r9",
		"r10",
		"r11",
		"r12",
		"r13",
		"r14",
		"r15",
		"eflags",
	}

	for _, name in ipairs(order) do
		local value = S.regs[name]
		if value then
			local signed = signed_decimal(value)
			local unsigned = unsigned_decimal(value)

			lines[#lines + 1] = string.format("%-10s   %-22s %s / %s", name:upper(), value, signed, unsigned)
		end
	end

	if #lines == 2 then
		lines[#lines + 1] = "En attente des registres…"
	end

	set_lines("registers", lines)
end

local function parse_memory(contents)
	local bytes = {}
	for byte in (contents or ""):gmatch("%x%x") do
		bytes[#bytes + 1] = tonumber(byte, 16)
	end
	return bytes
end

local function render_stack(address, bytes, rsp, rbp)
	local lines = {
		"PILE — MÉMOIRE : RSP vert · RBP jaune · octets arc-en-ciel",
		"Chaque ligne = 8 octets ; RSP et RBP sont repérés séparément.",
		"",
	}
	local byte_rows = {}

	for offset = 0, #bytes - 1, 8 do
		local cell, hex, ascii = {}, {}, {}
		for j = 0, 7 do
			cell[#cell + 1] = bytes[offset + j + 1] or 0
		end
		for j = 1, 8 do
			hex[#hex + 1] = string.format("%02x", cell[j])
			local byte = cell[j]
			ascii[#ascii + 1] = (byte >= 32 and byte <= 126) and string.char(byte) or "."
		end

		-- Les octets mémoire sont little-endian : reconstruire le mot dans
		-- l'ordre inverse, puis convertir sans limitation de précision.
		local word_hex = {}
		for j = 8, 1, -1 do
			word_hex[#word_hex + 1] = string.format("%02x", cell[j])
		end
		local pointer = address + offset
		local has_rsp = rsp >= pointer and rsp < pointer + 8
		local has_rbp = rbp and rbp >= pointer and rbp < pointer + 8
		local marker = has_rsp and "▶" or (has_rbp and "◆" or " ")
		local row = #lines
		local decimal = hex_to_decimal(table.concat(word_hex))
		lines[#lines + 1] = string.format(
			"%s 0x%016x  %s  %-20s  %s",
			marker,
			pointer,
			table.concat(hex, " "),
			decimal,
			table.concat(ascii)
		)
		byte_rows[#byte_rows + 1] = { line = row, pointer = pointer, has_rsp = has_rsp, has_rbp = has_rbp }
	end

	set_lines("stack", lines)
	local buf = S.buffers.stack
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local ns = vim.api.nvim_create_namespace("asmdebug-stack")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	-- Colonne de l'adresse : marque la ligne qui contient réellement RSP.
	for _, row in ipairs(byte_rows) do
		if row.has_rsp then
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugStackPointer", row.line, 0, 19)
		elseif row.has_rbp then
			vim.api.nvim_buf_add_highlight(buf, ns, "AsmDebugBasePointer", row.line, 0, 19)
		end
		-- Chaque octet conserve sa couleur dans les colonnes hexadécimales
		-- et ASCII. La valeur décimale est un mot 64 bits agrégé, donc elle
		-- reste neutre : elle ne correspond pas à un octet unique.
		local first_byte_col = 22
		local first_ascii_col = 69
		for i = 1, 8 do
			local group = "AsmDebugByte" .. i
			local hex_col = first_byte_col + (i - 1) * 3
			vim.api.nvim_buf_add_highlight(buf, ns, group, row.line, hex_col, hex_col + 2)
			vim.api.nvim_buf_add_highlight(buf, ns, group, row.line, first_ascii_col + i - 1, first_ascii_col + i)
		end
	end
end

local function refresh_stack()
	if not S.rsp then
		set_lines("stack", {
			"PILE — MÉMOIRE",
			"",
			"RSP indisponible.",
		})
		return
	end

	local rsp = tonumber(S.rsp) or tonumber(S.rsp:gsub("^0x", ""), 16)

	if not rsp then
		return
	end

	-- Vue de 128 octets : 64 avant RSP et 64 à partir de RSP.
	local start = math.max(0, math.floor((rsp - 64) / 8) * 8)

	send(string.format("-data-read-memory-bytes 0x%x 128", start), function(response)
		local contents = field(response, "contents")
		if not contents then
			set_lines("stack", {
				"PILE — MÉMOIRE",
				"",
				"GDB ne peut pas lire cette plage mémoire.",
			})
			return
		end

		render_stack(
			start,
			parse_memory(contents),
			rsp,
			tonumber(S.regs.rbp) or tonumber((S.regs.rbp or ""):gsub("^0x", ""), 16)
		)
	end)
end

local function refresh_assembly()
	if not S.pc then
		return
	end

	local pc = tonumber(S.pc) or tonumber(S.pc:gsub("^0x", ""), 16)
	if not pc then
		return
	end

	local function collect(response)
		local instructions = {}
		for tuple in response:gmatch("{[^{}]+}") do
			local addr = field(tuple, "address")
			local inst = field(tuple, "inst")
			if addr and inst then
				instructions[#instructions + 1] = {
					address = addr,
					inst = mi_unescape(inst),
				}
			end
		end
		return instructions
	end

	local function append_called_function(instructions)
		-- Trouve le premier appel nommé (par exemple <print_int>) et ajoute
		-- le désassemblage de cette fonction sous celui de la fonction courante.
		local symbol
		for _, ins in ipairs(instructions) do
			symbol = ins.inst:match("call[%w%s]*[^<]*<([%w_%.@$]+)")
			if symbol then
				break
			end
		end
		if not symbol then
			S.instructions = instructions
			render_assembly()
			return
		end

		send("-data-evaluate-expression " .. quoted("&" .. symbol), function(eval_response)
			local value = field(eval_response, "value")
			local address = value and value:match("0x[%da-fA-F]+")
			if not address then
				S.instructions = instructions
				render_assembly()
				return
			end
			send("-data-disassemble -a " .. address .. " -- 0", function(function_response)
				local called = collect(function_response)
				if #called > 0 then
					instructions[#instructions + 1] = { section = symbol }
					for _, ins in ipairs(called) do
						instructions[#instructions + 1] = ins
					end
				end
				S.instructions = instructions
				render_assembly()
			end)
		end)
	end

	send(string.format("-data-disassemble -a 0x%x -- 0", pc), function(response)
		local instructions = collect(response)
		if #instructions > 0 then
			append_called_function(instructions)
			return
		end
		-- Sans symboles de fonction, RIP est une frontière sûre pour démarrer.
		send(string.format("-data-disassemble -s 0x%x -e 0x%x -- 0", pc, pc + 160), function(fallback)
			append_called_function(collect(fallback))
		end)
	end)
end

local function refresh_registers(callback)
	send("-data-list-register-names", function(names_response)
		local names = {}
		for name in names_response:gmatch('"([^"]*)"') do
			names[#names + 1] = name
		end

		send("-data-list-register-values x", function(values_response)
			local regs = {}

			for tuple in values_response:gmatch("{[^{}]+}") do
				local number = tonumber(field(tuple, "number") or "")
				local value = field(tuple, "value")

				if number and names[number + 1] and names[number + 1] ~= "" then
					regs[names[number + 1]] = value
				end
			end

			S.regs = regs
			S.pc = regs.rip or regs.pc or S.pc
			S.rsp = regs.rsp or regs.sp or S.rsp

			render_registers()

			if callback then
				callback()
			end
		end)
	end)
end

local function refresh()
	refresh_registers(function()
		refresh_assembly()
		refresh_stack()
	end)
end

local function start_program()
	if not S.job then
		return
	end

	status("Démarrage à la première instruction…")
	send('-interpreter-exec console "starti"', function(response)
		if response:match("%^error") then
			return
		end
		S.started = true
	end)
end

local function focus_panel(direction)
	local current = vim.api.nvim_get_current_win()
	local current_config = vim.api.nvim_win_get_config(current)
	local function coordinate(value)
		if type(value) == "table" then
			return value[1] or 0
		end
		return value or 0
	end
	local current_row = coordinate(current_config.row)
	local current_col = coordinate(current_config.col)
	local current_height = vim.api.nvim_win_get_height(current)
	local current_width = vim.api.nvim_win_get_width(current)
	local cx = current_col + current_width / 2
	local cy = current_row + current_height / 2
	local best, best_score

	for name, win in pairs(S.windows) do
		if win ~= current and vim.api.nvim_win_is_valid(win) then
			local cfg = vim.api.nvim_win_get_config(win)
			local row = coordinate(cfg.row)
			local col = coordinate(cfg.col)
			local x = col + vim.api.nvim_win_get_width(win) / 2
			local y = row + vim.api.nvim_win_get_height(win) / 2
			local dx, dy = x - cx, y - cy
			local primary, secondary

			if direction == "h" then
				primary, secondary = -dx, math.abs(dy)
			elseif direction == "l" then
				primary, secondary = dx, math.abs(dy)
			elseif direction == "j" then
				primary, secondary = dy, math.abs(dx)
			else
				primary, secondary = -dy, math.abs(dx)
			end

			if primary > 0 then
				local score = primary + secondary * 1.5
				if not best_score or score < best_score then
					best, best_score = win, score
				end
			end
		end
	end

	-- If there is no window in that direction, wrap to the opposite edge.
	if not best then
		for _, win in pairs(S.windows) do
			if win ~= current and vim.api.nvim_win_is_valid(win) then
				local cfg = vim.api.nvim_win_get_config(win)
				local row = coordinate(cfg.row)
				local col = coordinate(cfg.col)
				local x = col + vim.api.nvim_win_get_width(win) / 2
				local y = row + vim.api.nvim_win_get_height(win) / 2
				local score
				if direction == "h" then
					score = -x
				elseif direction == "l" then
					score = x
				elseif direction == "j" then
					score = y
				else
					score = -y
				end
				if not best_score or score < best_score then
					best, best_score = win, score
				end
			end
		end
	end

	if best then
		vim.api.nvim_set_current_win(best)
	end
end

local function bind_keys(buf)
	local function map(key, callback, description)
		vim.keymap.set("n", key, callback, {
			buffer = buf,
			silent = true,
			nowait = true,
			desc = description,
		})
	end

	map("q", close, "Fermer le débogueur")

	-- Réutilise les raccourcis de navigation des fenêtres de MIVN/WhichKey.
	map("<leader>wh", function()
		focus_panel("h")
	end, "Panneau gauche")
	map("<leader>wj", function()
		focus_panel("j")
	end, "Panneau inférieur")
	map("<leader>wk", function()
		focus_panel("k")
	end, "Panneau supérieur")
	map("<leader>wl", function()
		focus_panel("l")
	end, "Panneau droit")

	map("<F5>", function()
		if not S.started or S.status:match("terminé") or S.status:match("Erreur") then
			start_program()
		elseif not S.running then
			send("-exec-continue")
		end
	end, "Démarrer / continuer")

	map("<F6>", function()
		if S.started and not S.running then
			-- GDB "step" avec step-mode on : entre dans les fonctions
			-- même lorsqu'elles n'ont pas d'informations de lignes.
			send("-exec-step")
		end
	end, "Pas à pas, entrer dans les fonctions")

	map("<F7>", function()
		if S.started and not S.running then
			send("-exec-next-instruction")
		end
	end, "Instruction suivante sans entrer")

	map("<F8>", function()
		if S.running then
			send("-exec-interrupt")
		end
	end, "Interrompre le programme")
end

local function handle_line(line)
	local token, result = line:match("^(%d+)%^(%w+)")

	if token then
		local callback = S.pending[token]
		S.pending[token] = nil

		if result == "error" and S.disassembly_probe == token then
			S.disassembly_probe = nil
			if callback then
				callback(line)
			end
			return
		end
		if result == "error" then
			local message = mi_unescape(field(line, "msg") or "Erreur GDB inconnue")
			status("Erreur : " .. message)
			notify("GDB : " .. message, vim.log.levels.ERROR)
		elseif callback then
			callback(line)
		end
		return
	end

	-- En MI, @ représente la sortie du programme débogué.
	if line:sub(1, 1) == "@" then
		append_output(mi_unescape(line:sub(2):match('^"(.*)"') or ""))
		return
	end

	-- Les flux ~ et & sont les flux de console/log de GDB,
	-- et non la sortie standard du programme.
	if line:match("^%*running") then
		S.running = true
		S.started = true
		status("Exécution en cours")
	elseif line:match("^%*stopped") then
		S.running = false
		S.started = true

		local reason = field(line, "reason") or "arrêt"
		if reason:match("exited") then
			status("Programme terminé")
		else
			status("En pause — " .. reason)
			refresh()
		end
	elseif line:match("^=thread%-group%-exited") then
		S.running = false
		status("Programme terminé")
	end
end

function M.open(executable)
	if not executable or executable == "" then
		notify("Utilisation : :AsmDebug ./itoa", vim.log.levels.WARN)
		return
	end

	executable = vim.fn.fnamemodify(executable, ":p")

	if vim.fn.executable("gdb") == 0 then
		notify("GDB n'est pas installé.", vim.log.levels.ERROR)
		return
	end

	if vim.fn.filereadable(executable) == 0 then
		notify("Fichier introuvable : " .. executable, vim.log.levels.ERROR)
		return
	end

	close()
	setup_highlights()

	S.executable = executable
	S.instructions = {}
	S.regs = {}
	S.pc = nil
	S.rsp = nil
	S.started = false
	S.running = false
	S.output = {}
	S.pending = {}
	S.token = 0

	local width = vim.o.columns
	local height = vim.o.lines

	-- Barre de commandes sans bordure, puis deux colonnes.
	local margin = 2
	local content_row = 2
	local content_height = math.max(12, height - content_row - 4)
	local left_width = math.max(24, math.floor((width - 8) * 0.43))
	local right_width = math.max(22, width - left_width - 8)
	local right_col = left_width + 4

	-- La mémoire est prioritaire : registres compacts, sortie courte,
	-- et tout l'espace restant est donné à la pile.
	local right_total = math.max(12, content_height)
	local registers_height = math.max(6, math.floor(right_total * 0.20))
	local output_height = math.max(4, math.floor(right_total * 0.15))
	local stack_height = math.max(5, right_total - registers_height - output_height - 4)
	local assembly_height = content_height

	panel("status", "CONTRÔLES", width - margin * 2, 1, 0, margin, { border = false })
	panel("assembly", "ASSEMBLAGE", left_width, assembly_height, content_row, margin)
	panel("registers", "REGISTRES — HEX / DÉCIMAL", right_width, registers_height, content_row, right_col)
	panel(
		"stack",
		"PILE / MÉMOIRE — 128 OCTETS AUTOUR DE RSP",
		right_width,
		stack_height,
		content_row + registers_height + 2,
		right_col
	)
	panel(
		"output",
		"SORTIE DU PROGRAMME",
		right_width,
		output_height,
		content_row + registers_height + stack_height + 4,
		right_col
	)

	for _, buf in pairs(S.buffers) do
		bind_keys(buf)
	end

	status("Connexion à GDB…")
	set_lines("assembly", { "Chargement du programme…" })
	set_lines("registers", { "Attente des registres…" })
	set_lines("stack", { "Attente de la mémoire…" })
	set_lines("output", { "La sortie du programme apparaîtra ici." })

	S.job = vim.fn.jobstart({
		"gdb",
		"--quiet",
		"--nx",
		"--interpreter=mi2",
	}, {
		stdin = "pipe",
		stdout_buffered = false,
		stderr_buffered = false,

		on_stdout = function(_, data)
			vim.schedule(function()
				for _, line in ipairs(data or {}) do
					if line ~= "" then
						handle_line(line)
					end
				end
			end)
		end,

		on_stderr = function(_, data)
			vim.schedule(function()
				for _, line in ipairs(data or {}) do
					if line ~= "" then
						append_output("[GDB] " .. line)
					end
				end
			end)
		end,

		on_exit = function(_, code)
			vim.schedule(function()
				S.job = nil
				if not S.closing then
					status("GDB arrêté (code " .. code .. ")")
				end
			end)
		end,
	})

	if not S.job or S.job <= 0 then
		S.job = nil
		status("Impossible de démarrer GDB")
		notify("Échec du démarrage de GDB.", vim.log.levels.ERROR)
		return
	end

	send("-gdb-set pagination off", function()
		send("-gdb-set confirm off", function()
			send("-gdb-set disassembly-flavor intel", function()
				-- Autorise le step à s'arrêter dans les fonctions sans informations de lignes.
				send('-interpreter-exec console "set step-mode on"', function()
					send("-file-exec-and-symbols " .. quoted(executable), function()
						start_program()
					end)
				end)
			end)
		end)
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("AsmDebug", function(opts)
		M.open(opts.args)
	end, {
		nargs = 1,
		complete = "file",
		desc = "Débogueur assembleur visuel",
	})

	vim.keymap.set("n", "<leader>ad", function()
		M.open("./itoa")
	end, {
		desc = "Débogueur assembleur visuel",
	})
end

return M
