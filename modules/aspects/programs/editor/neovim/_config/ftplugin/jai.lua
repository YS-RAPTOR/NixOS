if vim.b.did_ftplugin then
    return
end
vim.b.did_ftplugin = true

vim.bo.commentstring = "// %s"
vim.bo.comments = "s1:/*,mb:*,ex:*/,://"
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.autoindent = true
vim.bo.suffixesadd = ".jai"
vim.opt_local.formatoptions:remove("t")

vim.b.undo_ftplugin =
    "setlocal commentstring< comments< expandtab< tabstop< shiftwidth< softtabstop< autoindent< suffixesadd< formatoptions<"
