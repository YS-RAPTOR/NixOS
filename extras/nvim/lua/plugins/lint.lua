return {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
        linters = {
            ["markdownlint-cli2"] = {
                args = { "--config", vim.env.HOME .. "/NixOS/extras/misc/markdownlint-cli2.yaml", "--" },
            },
        },
    },
}
