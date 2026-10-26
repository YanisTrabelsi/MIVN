local function tabline()
    local tabs = vim.fn.tabpagenr("$")

    if tabs <= 1 then
        return ""
    end

    local current = vim.fn.tabpagenr()
    local result = {}

    for i = 1, tabs do
        local buflist = vim.fn.tabpagebuflist(i)
        local winnr = vim.fn.tabpagewinnr(i)
        local bufnr = buflist[winnr]

        local name = vim.fn.bufname(bufnr)

        if name == "" then
            name = "~"
        else
            name = vim.fn.fnamemodify(name, ":t")
        end
        name = name:gsub("%%", "%%%%")

        if i == current then
            table.insert(result, "%#MIVNTabCorner#")
            table.insert(result, "")
            table.insert(result, "%#MIVNTabActive#")
            table.insert(result, " " .. name .. " ")
            table.insert(result, "%#MIVNTabCorner#")
            table.insert(result, "")
        else
            table.insert(result, "%#MIVNTabInactive#")
            table.insert(result, " " .. name .. " ")
        end

        if vim.bo[bufnr].modified then
            table.insert(result, "%#MIVNTabModified#●")
        end

        if i < tabs then
            table.insert(result, "%#MIVNTabSeparator#  ")
        end
    end

    table.insert(result, "%#MIVNTabFill#")

    return table.concat(result)
end

_G.MIVNTabline = tabline

vim.o.showtabline = 1
vim.o.tabline = "%!v:lua.MIVNTabline()"

require("mivn.theme").apply()
