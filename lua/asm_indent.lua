local M = {}

function M.get_indent()
	local line_number = vim.v.lnum
	local line = vim.fn.getline(line_number)

	-- Keep assembler labels and directives at column zero.
	if line:match("^%s*[%w_.$]+:") or line:match("^%s*[%.%%][%w_]+") then
		return 0
	end

	local previous_number = vim.fn.prevnonblank(line_number - 1)
	if previous_number == 0 then
		return 0
	end

	local previous_line = vim.fn.getline(previous_number)
	local previous_indent = vim.fn.indent(previous_number)
	if previous_line:match("^%s*[%w_.$]+:") or previous_line:match("\\%s*$") then
		return previous_indent + vim.bo.shiftwidth
	end

	return previous_indent
end

return M
