return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- Mason itself must exist, but it will already be in your setup
    dependencies = {
        "williamboman/mason.nvim",
    },

    -- No need to run this at startup; let it fire once things are settled
    event = "VeryLazy",

    opts = {
        ensure_installed = {
            -- LSP servers
            "bash-language-server",
            "gopls",
            "json-lsp",
            "lua-language-server",
            "phpactor",
            "pyright",
            "tailwindcss-language-server",
            "typescript-language-server",
            "vue-language-server",

            -- Formatters / linters / extras
            "black",
            "clang-format",
            "eslint_d",
            "goimports-reviser",
            "golines",
            "jq",
            "pint",
            "prettier",
            "stylua",

            -- Debuggers
            "delve",
        },

        auto_update = true,
        start_delay = 10000, -- ms; ~10s after startup
        -- Optional: don't spam updates if you open/close often
        -- debounce_hours = 5,
    },
}