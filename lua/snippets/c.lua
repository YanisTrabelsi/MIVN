local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node
local rep = require("luasnip.extras").rep

return {
	s("main", { t({ "#include <stdio.h>", "", "int main(void) {", "    " }), i(1, "/* code */"), t({ "", "    return 0;", "}" }), i(0) }),
	s("func", { i(1, "void"), t(" "), i(2, "function_name"), t("("), i(3, "void"), t({ ") {", "    " }), i(0, "/* code */"), t({ "", "}" }) }),
	s("for", { t("for (int "), i(1, "i = 0"), t("; "), i(2, "i < count"), t("; "), i(3, "i++"), t({ ") {", "    " }), i(0, "/* code */"), t({ "", "}" }) }),
	s("while", { t("while ("), i(1, "condition"), t({ ") {", "    " }), i(0, "/* code */"), t({ "", "}" }) }),
	s("if", { t("if ("), i(1, "condition"), t({ ") {", "    " }), i(0, "/* code */"), t({ "", "}" }) }),
	s("else", { t({ "} else {", "    " }), i(0, "/* code */"), t({ "", "}" }) }),
	s("printf", { t('printf("'), i(1, "%s\\n"), t('", '), i(2, "value"), t(");"), i(0) }),
	s("include", { t("#include <"), i(1, "stdio.h"), t(">"), i(0) }),
	s("struct", { t("typedef struct "), i(1, "Name"), t({ " {", "    " }), i(2, "int value;"), t({ "", "} " }), i(3, "Name"), t(";"), i(0) }),
	s("switch", {
		t("switch ("), i(1, "value"), t({ ") {", "case " }), i(2, "0"), t({ ":", "    " }),
		i(3, "break;"), t({ "", "default:", "    " }), i(4, "break;"), t({ "", "}" }), i(0),
	}),
	s("do", { t("do {"), t({ "", "    " }), i(1, "/* code */"), t({ "", "} while (" }), i(2, "condition"), t(");"), i(0) }),
	s("enum", { t("enum "), i(1, "Name"), t({ " {", "    " }), i(0, "FIRST,\n    SECOND"), t({ "", "};" }) }),
	s("typedef", { t("typedef "), i(1, "struct"), t(" "), i(2, "Name"), t(" "), rep(2), t(";"), i(0) }),
	s("malloc", { t("malloc(sizeof("), i(1, "int"), t("));"), i(0) }),
	s("assert", { t("assert("), i(1, "condition"), t(");"), i(0) }),
	s("mainargs", { t({ "#include <stdio.h>", "", "int main(int argc, char **argv) {", "    " }), i(1, "(void)argc; (void)argv;"), t({ "", "    return 0;", "}" }), i(0) }),
}
