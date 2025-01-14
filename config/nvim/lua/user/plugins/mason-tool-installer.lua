return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
        "williamboman/mason.nvim",
    },
    config = function()
        require("mason-tool-installer").setup({
            ensure_installed = {
                "bash-language-server",
                "black",
                "clang-format",
                "delve",
                "eslint_d",
                "goimports-reviser",
                "golines",
                "gopls",
                "jq",
                "json-lsp",
                "lua-language-server",
                "phpactor",
                "pint",
                "prettier",
                "pyright",
                "stylua",
                "tailwindcss-language-server",
                "typescript-language-server",
                "vue-language-server",
            },
            auto_update = true,
            start_delay = 10000,
        })
    end,
}
