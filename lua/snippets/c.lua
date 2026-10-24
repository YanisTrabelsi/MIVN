local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("main", {
		t({ "#include <stdio.h>", "", "int main(void) {", "    " }),
		i(1, "/* code */"),
		t({ "", "    return 0;", "}" }),
		i(0),
	}),
	s("func", {
		i(1, "void"),
		t(" "),
		i(2, "function_name"),
		t("("),
		i(3, "void"),
		t({ ") {", "    " }),
		i(0, "/* code */"),
		t({ "", "}" }),
	}),
	s("for", {
		t("for (int "),
		i(1, "i = 0"),
		t("; "),
		i(2, "i < count"),
		t("; "),
		i(3, "i++"),
		t({ ") {", "    " }),
		i(0, "/* code */"),
		t({ "", "}" }),
	}),
}
