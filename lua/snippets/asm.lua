local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep

return {
	s("func", {
		t({ ".text", ".globl " }),
		i(1, "function_name"),
		t({ "", "" }),
		rep(1),
		t({ ":", "    " }),
		i(0, "ret"),
	}),
	s("main", {
		t({ ".text", ".globl " }),
		i(1, "main"),
		t({ "", "" }),
		rep(1),
		t({ ":", "    " }),
		i(0, "ret"),
	}),
	s("rodata", {
		t({ ".section .rodata", "message:" }),
		t('.asciz "'),
		i(1, "Hello, world!"),
		t('"'),
		i(0),
	}),
}
