local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

return {
	s("func", { t("local function "), i(1, "function_name"), t("("), i(2), t({ ")", "    " }), i(0), t({ "", "end" }) }),
	s("local", { t("local "), i(1, "name"), t(" = "), i(0, "value") }),
	s("fori", { t("for "), i(1, "index"), t(" = "), i(2, "1"), t(", "), i(3, "#items"), t({ " do", "    " }), i(0), t({ "", "end" }) }),
	s("pairs", { t("for "), i(1, "key"), t(", "), i(2, "value"), t(" in pairs("), i(3, "items"), t({ ") do", "    " }), i(0), t({ "", "end" }) }),
	s("ipairs", { t("for "), i(1, "index"), t(", "), i(2, "value"), t(" in ipairs("), i(3, "items"), t({ ") do", "    " }), i(0), t({ "", "end" }) }),
	s("if", { t("if "), i(1, "condition"), t({ " then", "    " }), i(0), t({ "", "end" }) }),
	s("module", { t({ "local M = {}", "", "" }), i(0), t({ "", "", "return M" }) }),
	s("req", { t("local "), i(1, "module"), t(' = require("'), i(2, "module"), t('")'), i(0) }),
	s("pcall", { t("local ok, result = pcall(function()"), t({ "", "    " }), i(1, "operation()"), t({ "", "end)", "if not ok then", "    vim.notify(tostring(result), vim.log.levels.ERROR)", "end" }), i(0) }),
	s("table", { t("local "), i(1, "items"), t(" = {"), t({ "", "    " }), i(2, "value"), t({ ",", "}" }), i(0) }),
	s("keymap", { t('vim.keymap.set("'), i(1, "n"), t('", "'), i(2, "<leader>x"), t('", function()'), t({ "", "    " }), i(3, "-- action"), t({ "", 'end, { desc = "' }), i(4, "Description"), t('" })'), i(0) }),
}
