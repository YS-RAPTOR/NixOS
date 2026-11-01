return {
    {
        "nvim-treesitter/nvim-treesitter",
        init = function()
            -- Register for manual :TSInstall jai / :TSUpdate jai; never auto-install it.
            vim.api.nvim_create_autocmd("User", {
                group = vim.api.nvim_create_augroup("jai_treesitter", { clear = true }),
                pattern = "TSUpdate",
                callback = function()
                    require("nvim-treesitter.parsers").jai = {
                        install_info = {
                            url = "https://github.com/constantitus/tree-sitter-jai",
                            revision = "3f8ee754d6531a1672d9e36cd54e81580fcec02c",
                            queries = "queries",
                        },
                    }
                end,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                jai_lsp = {
                    mason = false,
                    filetypes = { "jai" },
                    root_dir = function(bufnr, on_dir)
                        -- One server per tutorial, or per explicit b:jai_entry_file.
                        on_dir(vim.b[bufnr].jai_entry_file or vim.api.nvim_buf_get_name(bufnr))
                    end,
                    cmd = function(dispatchers, config)
                        return vim.lsp.rpc.start({ vim.fn.expand("~/.local/bin/jai-lsp") }, dispatchers, {
                            cwd = vim.fs.dirname(config.root_dir),
                            env = {
                                JAI_COMPILER = vim.fn.exepath("jai"),
                                JAI_LSP_ENTRY_FILE = config.root_dir,
                            },
                        })
                    end,
                    before_init = function(params, config)
                        local directory = vim.fs.dirname(config.root_dir)
                        params.rootPath = directory
                        params.rootUri = vim.uri_from_fname(directory)
                        params.workspaceFolders = { { uri = params.rootUri, name = directory } }
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
