vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        io.write("\27]12;#CBA6F7\7")
        io.flush()
    end,
})
