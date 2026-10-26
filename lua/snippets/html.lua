local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node
local rep = require("luasnip.extras").rep

return {
	s("html5", { t({ "<!doctype html>", '<html lang="' }), i(1, "en"), t({ '">', "<head>", '    <meta charset="UTF-8">', '    <meta name="viewport" content="width=device-width, initial-scale=1.0">', "    <title>" }), i(2, "Page title"), t({ "</title>", "</head>", "<body>", "    " }), i(0), t({ "", "</body>", "</html>" }) }),
	s("div", { t('<div class="'), i(1, "container"), t({ '">', "    " }), i(0), t({ "", "</div>" }) }),
	s("a", { t('<a href="'), i(1, "#"), t('">'), i(2, "link"), t("</a>"), i(0) }),
	s("img", { t('<img src="'), i(1, "image.png"), t('" alt="'), i(2, "description"), t('">'), i(0) }),
	s("button", { t('<button type="'), i(1, "button"), t('">'), i(2, "Click me"), t("</button>"), i(0) }),
	s("form", { t({ '<form action="', }), i(1, "/submit"), t({ '" method="post">', "    " }), i(0), t({ "", "</form>" }) }),
	s("linkcss", { t('<link rel="stylesheet" href="'), i(1, "styles.css"), t('">'), i(0) }),
	s("script", { t('<script src="'), i(1, "app.js"), t('"></script>'), i(0) }),
	s("nav", { t({ '<nav aria-label="' }), i(1, "Main"), t({ '">', "    <ul>", '        <li><a href="#home">Home</a></li>', "    </ul>", "</nav>" }), i(0) }),
	s("section", { t('<section aria-labelledby="'), i(1, "section-title"), t({ '">', '    <h2 id="' }), rep(1), t('">'), i(2, "Section title"), t({ "</h2>", "    " }), i(0), t({ "", "</section>" }) }),
	s("input", { t('<label for="'), i(1, "field"), t('">'), i(2, "Label"), t({ '</label>', '<input id="' }), rep(1), t('" name="'), rep(1), t('" type="'), i(3, "text"), t('">'), i(0) }),
}
