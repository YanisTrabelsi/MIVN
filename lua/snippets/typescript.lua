local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node
local rep = require("luasnip.extras").rep

return {
	s("interface", { t("interface "), i(1, "Name"), t({ " {", "    " }), i(0, "property: string;"), t({ "", "}" }) }),
	s("type", { t("type "), i(1, "Name"), t(" = "), i(0, "string"), t(";") }),
	s("func", { t("function "), i(1, "functionName"), t("("), i(2, "value: string"), t("): "), i(3, "void"), t({ " {", "    " }), i(0), t({ "", "}" }) }),
	s("arrow", { t("const "), i(1, "functionName"), t(" = ("), i(2, "value: string"), t("): "), i(3, "void"), t({ " => {", "    " }), i(0), t({ "", "};" }) }),
	s("asyncfn", { t("async function "), i(1, "functionName"), t("("), i(2), t("): Promise<"), i(3, "void"), t({ "> {", "    " }), i(0), t({ "", "}" }) }),
	s("enum", { t("enum "), i(1, "Name"), t({ " {", "    " }), i(0, "First,") , t({ "", "}" }) }),
	s("class", { t("class "), i(1, "Name"), t({ " {", "    constructor(" }), i(2), t({ ") {", "        " }), i(0), t({ "", "    }", "}" }) }),
	s("generic", { t("function "), i(1, "identity"), t("<T>(value: T): T {"), t({ "", "    return value;", "}" }), i(0) }),
	s("async", { t("async function "), i(1, "loadData"), t("(): Promise<"), i(2, "Data"), t({ "> {", "    " }), i(0, "return await fetchData();"), t({ "", "}" }) }),
	s("typeguard", { t("function is"), i(1, "Name"), t("(value: unknown): value is "), rep(1), t(" {"), t({ "", '    return typeof value === "' }), i(2, "string"), t({ '";', "}" }), i(0) }),
	s("readonly", { t("interface "), i(1, "Options"), t({ " {", "    readonly " }), i(2, "name"), t(":"), i(3, "string"), t(";"), i(0), t({ "", "}" }) }),
}
