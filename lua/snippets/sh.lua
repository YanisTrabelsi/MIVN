local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
	s("shebang", { t({ "#!/usr/bin/env bash", "set -euo pipefail", "", "" }), i(0) }),
	s("main", { t({ "#!/usr/bin/env bash", "set -euo pipefail", "", "main() {", "    " }), i(1, "echo \"Hello, world!\""), t({ "", "}", "", "main \"$@\"" }), i(0) }),
	s("func", { i(1, "function_name"), t({ "() {", "    " }), i(0, "echo \"value\""), t({ "", "}" }) }),
	s("if", { t("if [[ "), i(1, "condition"), t({ " ]]; then", "    " }), i(0, "echo \"yes\""), t({ "", "fi" }) }),
	s("for", { t("for "), i(1, "item"), t(" in "), i(2, '"$@"'), t({ "; do", "    " }), i(0, "echo \"$item\""), t({ "", "done" }) }),
	s("case", { t("case \"${"), i(1, "value"), t({ "}\" in", "    " }), i(2, "pattern"), t({ ")", "        " }), i(3, "command"), t({ "", "        ;;", "    *)", "        " }), i(4, ";;"), t({ "", "esac" }), i(0) }),
	s("printf", { t("printf '%s\\n' \""), i(1, "value"), t("\""), i(0) }),
	s("while", { t("while [[ "), i(1, "condition"), t({ " ]]; do", "    " }), i(0, "command"), t({ "", "done" }) }),
	s("read", { t("IFS= read -r "), i(1, "value"), t(" < "), i(0, "input.txt") }),
	s("trap", { t("trap '"), i(1, "cleanup"), t("' "), i(0, "EXIT") }),
	s("getopts", { t("while getopts \":"), i(1, "f:"), t({ '" option; do', '    case "$option" in', '        f) file="$OPTARG" ;;', '        *) exit 1 ;;', '    esac', 'done' }) }),
}
