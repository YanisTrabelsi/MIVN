local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("main", {
		t({ "def main():", "    " }),
		i(1, "pass"),
		t({ "", "", 'if __name__ == "__main__":', "    main()" }),
		i(0),
	}),
	s("def", {
		t("def "),
		i(1, "function_name"),
		t("("),
		i(2),
		t({ "):", "    " }),
		i(0, "pass"),
	}),
	s("class", {
		t("class "),
		i(1, "ClassName"),
		t(":"),
		t({ "", "    def __init__(self):", "        " }),
		i(0, "pass"),
	}),
	s("for", {
		t("for "),
		i(1, "item"),
		t(" in "),
		i(2, "items"),
		t({ ":", "    " }),
		i(0, "pass"),
	}),
}
