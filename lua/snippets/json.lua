local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
	s("obj", { t({ "{", '  "' }), i(1, "key"), t('": '), i(2, '"value"'), t({ ",", "  " }), i(0, '"anotherKey": true'), t({ "", "}" }) }),
	s("arr", { t({ "[", "  " }), i(1), t({ ",", "  " }), i(0), t({ "", "]" }) }),
	s("config", { t({ "{", '  "name": "' }), i(1, "app-name"), t({ '",', '  "version": "' }), i(2, "1.0.0"), t({ '",', '  "private": true,', '  "scripts": {', '    "start": "' }), i(3, "node index.js"), t({ '"', '  }', '}' }), i(0) }),
	s("pair", { t('"'), i(1, "key"), t('": '), i(0, '"value"') }),
	s("bool", { t('"'), i(1, "enabled"), t('": '), i(0, "true") }),
}
