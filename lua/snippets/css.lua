local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
	s("rule", { t("."), i(1, "class"), t({ " {", "    " }), i(0, "color: #333;"), t({ "", "}" }) }),
	s("id", { t("#"), i(1, "id"), t({ " {", "    " }), i(0, "display: block;"), t({ "", "}" }) }),
	s("flex", { t({ "display: flex;", "align-items: " }), i(1, "center"), t({ ";", "justify-content: " }), i(2, "space-between"), t(";"), i(0) }),
	s("grid", { t({ "display: grid;", "grid-template-columns: repeat(" }), i(1, "2"), t(", minmax(0, 1fr));"), i(0) }),
	s("media", { t("@media (") , i(1, "max-width: 768px"), t({ ") {", "    " }), i(0, "/* styles */"), t({ "", "}" }) }),
	s("keyframes", { t("@keyframes "), i(1, "fadeIn"), t({ " {", "    from { opacity: 0; }", "    to { opacity: 1; }", "}" }), i(0) }),
	s("center", { t({ "display: flex;", "align-items: center;", "justify-content: center;" }), i(0) }),
	s("transition", { t("transition: "), i(1, "all 0.2s ease-in-out"), t(";"), i(0) }),
	s("variable", { t(":root {"), t({ "", "    --" }), i(1, "color-primary"), t(": "), i(2, "#000000"), t({ ";", "}" }), i(0) }),
	s("hover", { t("&:hover {"), t({ "", "    " }), i(0, "opacity: 0.8;"), t({ "", "}" }) }),
	s("reset", { t({ "* {", "    box-sizing: border-box;", "    margin: 0;", "    padding: 0;", "}" }), i(0) }),
}
