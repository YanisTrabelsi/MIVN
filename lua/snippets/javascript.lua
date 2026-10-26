local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node
local rep = require("luasnip.extras").rep

return {
	s("log", { t("console.log("), i(1, "value"), t(");"), i(0) }),
	s("func", { t("function "), i(1, "functionName"), t("("), i(2), t({ ") {", "    " }), i(0), t({ "", "}" }) }),
	s("arrow", { t("const "), i(1, "functionName"), t(" = ("), i(2), t({ ") => {", "    " }), i(0), t({ "", "};" }) }),
	s("async", { t("async function "), i(1, "functionName"), t("("), i(2), t({ ") {", "    const " }), i(3, "result"), t(" = await "), i(4, "operation()"), t({ ";", "    " }), i(0), t({ "", "}" }) }),
	s("try", { t({ "try {", "    " }), i(1, "operation();"), t({ "", "} catch (" }), i(2, "error"), t({ ") {", "    console.error(" }), i(3, "error"), t({ ");", "}" }), i(0) }),
	s("foreach", { i(1, "items"), t(".forEach(("), i(2, "item"), t({ ") => {", "    " }), i(0), t({ "", "});" }) }),
	s("import", { t('import { '), i(1, "name"), t(' } from "'), i(2, "module"), t('";'), i(0) }),
	s("class", { t("class "), i(1, "Name"), t({ " {", "    constructor(" }), i(2), t({ ") {", "        " }), i(0), t({ "", "    }", "}" }) }),
	s("promise", { t("new Promise((resolve, reject) => {"), t({ "", "    " }), i(1, "resolve(value)"), t({ "", "})" }), i(0) }),
	s("fetch", { t("const response = await fetch("), i(1, '"/api"'), t({ ");", "if (!response.ok) throw new Error(`HTTP ${response.status}`);", "const data = await response.json();" }), i(0) }),
	s("switch", { t("switch ("), i(1, "value"), t({ ") {", "    case " }), i(2, "caseValue"), t({ ":", "        " }), i(3, "break;"), t({ "", "    default:", "        " }), i(0, "break;"), t({ "", "}" }) }),
	s("map", { i(1, "items"), t(".map(("), i(2, "item"), t({ ") => {", "    return " }), i(0, "item"), t({ ";", "});" }) }),
	s("filter", { i(1, "items"), t(".filter(("), i(2, "item"), t(") => "), i(0, "item.active"), t(");") }),
	s("component", { t("function "), i(1, "Component"), t({ "() {", "    return (", "        <" }), i(2, "div"), t({ ">", "            " }), i(3, "Hello"), t({ "", "        </" }), rep(2), t({ ">", "    );", "}" }), i(0) }),
}
