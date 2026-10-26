local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
	s("main", { t({ "def main():", "    " }), i(1, "pass"), t({ "", "", 'if __name__ == "__main__":', "    main()" }), i(0) }),
	s("def", { t("def "), i(1, "function_name"), t("("), i(2), t({ "):", "    " }), i(0, "pass") }),
	s("class", {
		t("class "), i(1, "ClassName"), t(":"),
		t({ "", "    def __init__(self, " }), i(2), t({ "):", "        " }), i(3, "pass"),
		t({ "", "" }), i(0),
	}),
	s("for", { t("for "), i(1, "item"), t(" in "), i(2, "items"), t({ ":", "    " }), i(0, "pass") }),
	s("fori", { t({ "for " }), i(1, "index"), t(" in range("), i(2, "count"), t({ "):", "    " }), i(0, "pass") }),
	s("if", { t("if "), i(1, "condition"), t({ ":", "    " }), i(0, "pass") }),
	s("elif", { t("elif "), i(1, "condition"), t({ ":", "    " }), i(0, "pass") }),
	s("try", {
		t({ "try:", "    " }), i(1, "operation()"), t({ "", "except " }), i(2, "Exception"),
		t(" as "), i(3, "error"), t({ ":", "    " }), i(4, "print(error)"),
		t({ "", "finally:", "    " }), i(0, "pass"),
	}),
	s("with", { t("with "), i(1, "open(path)"), t(" as "), i(2, "file"), t({ ":", "    " }), i(0, "pass") }),
	s("lambda", { i(1, "value"), t(": "), i(0, "value") }),
	s("listcomp", { t("["), i(1, "item"), t(" for "), i(2, "item"), t(" in "), i(3, "items"), t("]"), i(0) }),
	s("print", { t("print("), i(1), t(")"), i(0) }),
	s("test", { t("def test_"), i(1, "behavior"), t({ "():", "    " }), i(0, "assert actual == expected") }),
	s("asyncdef", { t("async def "), i(1, "function_name"), t("("), i(2), t({ "):", "    " }), i(0, "return await operation()") }),
	s("enumerate", { t("for "), i(1, "index"), t(", "), i(2, "item"), t(" in enumerate("), i(3, "items"), t({ "):", "    " }), i(0, "print(index, item)") }),
	s("dictcomp", { t("{"), i(1, "key"), t(": "), i(2, "value"), t(" for "), i(3, "key, value"), t(" in "), i(4, "items.items()"), t("}"), i(0) }),
	s("dataclass", { t({ "from dataclasses import dataclass", "", "@dataclass", "class " }), i(1, "Record"), t({ ":", "    " }), i(0, "name: str") }),
	s("match", { t("match "), i(1, "value"), t({ ":", "    case " }), i(2, "pattern"), t(":"), t({ "", "        " }), i(0, "pass") }),
	s("pytest", { t("def test_"), i(1, "behavior"), t({ "():", "    " }), i(2, "result = function()"), t({ "", "    assert " }), i(0, "result == expected") }),
}
