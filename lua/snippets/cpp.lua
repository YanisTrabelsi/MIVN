local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
	s("main", { t({ "#include <iostream>", "", "int main() {", "    " }), i(1, "std::cout << \"Hello\" << std::endl;"), t({ "", "    return 0;", "}" }), i(0) }),
	s("cout", { t("std::cout << "), i(1, "value"), t(" << std::endl;"), i(0) }),
	s("func", { i(1, "void"), t(" "), i(2, "function_name"), t("("), i(3, "") , t({ ") {", "    " }), i(0, "// code"), t({ "", "}" }) }),
	s("class", { t("class "), i(1, "Name"), t({ " {", "public:", "    " }), i(0, "Name() = default;"), t({ "", "};" }) }),
	s("for", { t("for (const auto& "), i(1, "item"), t(" : "), i(2, "items"), t({ ") {", "    " }), i(0, "// code"), t({ "", "}" }) }),
	s("vector", { t("std::vector<"), i(1, "int"), t("> "), i(2, "values"), t("{"), i(3), t("};"), i(0) }),
	s("include", { t("#include <"), i(1, "iostream"), t(">"), i(0) }),
	s("namespace", { t("namespace "), i(1, "name"), t({ " {", "    " }), i(0), t({ "", "}" }) }),
	s("template", { t({ "template <typename " }), i(1, "T"), t({ ">", "" }), i(2, "T"), t(" "), i(3, "function_name"), t("("), i(4, "T value"), t({ ") {", "    " }), i(0, "return value;"), t({ "", "}" }) }),
	s("try", { t({ "try {", "    " }), i(1, "operation();"), t({ "", "} catch (const std::exception& " }), i(2, "error"), t({ ") {", "    std::cerr << " }), i(3, "error.what()"), t({ " << std::endl;", "}" }), i(0) }),
	s("unique", { t("auto "), i(1, "value"), t(" = std::make_unique<"), i(2, "Type"), t(">("), i(3), t(");"), i(0) }),
	s("map", { t("std::transform("), i(1, "items.begin()"), t(", "), i(2, "items.end()"), t(", "), i(3, "std::back_inserter(result)"), t(", "), i(4, "[](const auto& item) { return item; }"), t(");"), i(0) }),
}
