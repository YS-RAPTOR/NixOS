vim.filetype.add({ extension = { jai = "jai" } })

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                jai_lsp = {
                    mason = false,
                    cmd = { vim.fn.expand("~/.local/bin/jai-lsp") },
                    filetypes = { "jai" },
                    root_dir = function(bufnr, on_dir)
                        -- Tutorials are standalone programs: keep their compiler indexes separate.
                        on_dir(vim.api.nvim_buf_get_name(bufnr))
                    end,
                    before_init = function(params, config)
                        -- Set b:jai_entry_file to share a project entry point across files.
                        local bufnr = vim.fn.bufnr(config.root_dir)
                        local entry = vim.b[bufnr].jai_entry_file or config.root_dir
                        local directory = vim.fs.dirname(entry)
                        config.cmd_cwd = directory
                        params.rootPath = directory
                        params.rootUri = vim.uri_from_fname(directory)
                        params.workspaceFolders = { { uri = params.rootUri, name = directory } }
                        config.cmd_env = {
                            JAI_COMPILER = vim.fn.exepath("jai"),
                            JAI_LSP_ENTRY_FILE = entry,
                            JAI_LSP_INLAY_HINTS = "true",
                        }
                    end,
                },
            },
        },
    },
    {
        "nvim-mini/mini.icons",
        opts = {
            filetype = { jai = { glyph = "󰬑", hl = "MiniIconsOrange" } },
        },
    },
}
