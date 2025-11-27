return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },

    config = function()
        local conform = require("conform")

        -- Common format options used in both on-save and keymap
        local format_opts = {
            lsp_fallback = true,
            async = false,
            timeout_ms = 1000,
        }

        -- Filetypes that all use prettier
        local prettier_ft = {
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "svelte",
            "css",
            "html",
            "json",
            "markdown",
            "graphql",
            "liquid",
        }

        local formatters_by_ft = {
            cpp = { "clang-format" },
            yaml = { "yamlfmt" },
            lua = {
                "stylua",
                -- if you want a custom config:
                -- extra_args = { "--config-path", vim.fn.stdpath("config") .. "/.stylua.toml" },
            },
            sql = { "sleek" },
            python = { "black" },
            go = { "gofumpt", "goimports-reviser", "golines" },
        }

        for _, ft in ipairs(prettier_ft) do
            formatters_by_ft[ft] = { "prettier" }
        end

        conform.setup({
            formatters = {
                sleek = { command = "sleek" },
            },
            formatters_by_ft = formatters_by_ft,
            format_on_save = format_opts,
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format(format_opts)
        end, { desc = "Format file or range (in visual mode)", silent = true })
    end,
}