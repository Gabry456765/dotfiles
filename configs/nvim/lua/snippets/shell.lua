local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("sh", {
  s("if", {
    t("if [ "), i(1), t(" ]; then"),
    t({ "", "  " }), i(2),
    t({ "", "fi" }),
  }),
})

ls.add_snippets("sh", {
  s("elif", {
    t("if [ "), i(1), t(" ]; then"),
    t({ "", "  " }), i(2), 
    t({ "", "elif [ " }), i(3), t(" ]; then"),
    t({ "", "  " }), i(4),  
    t({ "", "fi" }),
  }),
})
