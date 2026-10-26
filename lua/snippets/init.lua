local M = {}

local modules = {
	asm = "snippets.asm",
	c = "snippets.c",
	cpp = "snippets.cpp",
	python = "snippets.python",
	sh = "snippets.sh",
	bash = "snippets.sh",
	lua = "snippets.lua",
	javascript = "snippets.javascript",
	javascriptreact = "snippets.javascript",
	typescript = "snippets.typescript",
	typescriptreact = "snippets.typescript",
	html = "snippets.html",
	css = "snippets.css",
	json = "snippets.json",
}

function M.register(luasnip, priority)
	priority = type(priority) == "number" and priority or 2000
	for filetype, module in pairs(modules) do
		luasnip.add_snippets(filetype, require(module), {
			key = "mivn-" .. filetype,
			default_priority = priority,
		})
	end
end

return M
