return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "b0o/schemastore.nvim",
        {
            "nvimtools/none-ls.nvim",
            dependencies = { "nvimtools/none-ls-extras.nvim" },
        },
        "rayyh/mason-null-ls.nvim",
    },

    config = function()
        ----------------------------------------------------------------------
        -- Mason / mason-lspconfig
        ----------------------------------------------------------------------
        require("mason").setup({
            ui = { height = 0.8 },
        })

        -- Let Mason auto-install LSP servers, but we will enable them ourselves
        require("mason-lspconfig").setup({
            automatic_installation = true,
            automatic_enable = false,
        })

        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        ----------------------------------------------------------------------
        -- LSP server configs (vim.lsp.config)
        ----------------------------------------------------------------------

        -- Go (gopls)
        vim.lsp.config("gopls", {
            capabilities = capabilities,
            settings = {
                gopls = {
                    completeUnimported = true,
                    usePlaceholders = true,
                    analyses = {
                        unusedparams = true,
                        shadow = true,
                        unusedwrite = true,
                        fieldalignment = true,
                        nilness = true,
                        unusedresult = true,
                        staticcheck = true,
                    },
                },
            },
        })

        -- Python (pyright)
        vim.lsp.config("pyright", {
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace",
                    },
                },
            },
        })

        -- PHP (phpactor) – keep it for refactor tools, but disable LSP UI.
        vim.lsp.config("phpactor", {
            capabilities = capabilities,
            on_attach = function(client)
                local caps = client.server_capabilities
                caps.completionProvider = false
                caps.hoverProvider = false
                caps.implementationProvider = false
                caps.referencesProvider = false
                caps.renameProvider = false
                caps.selectionRangeProvider = false
                caps.signatureHelpProvider = false
                caps.typeDefinitionProvider = false
                caps.workspaceSymbolProvider = false
                caps.definitionProvider = false
                caps.documentHighlightProvider = false
                caps.documentSymbolProvider = false
                caps.documentFormattingProvider = false
                caps.documentRangeFormattingProvider = false
            end,
            init_options = {
                ["language_server_phpstan.enabled"] = false,
                ["language_server_psalm.enabled"] = false,
            },
            handlers = {
                ["textDocument/publishDiagnostics"] = function() end,
            },
        })

        -- Vue / vue_ls (formerly volar)
        vim.lsp.config("vue_ls", {
            capabilities = capabilities,
            on_attach = function(client)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider =
                    false
            end,
        })

        -- TS/JS (ts_ls) with Vue typescript plugin
        vim.lsp.config("ts_ls", {
            capabilities = capabilities,
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        -- uses global npm install; adjust if needed
                        location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
                        languages = { "javascript", "typescript", "vue" },
                    },
                },
            },
            filetypes = {
                "javascript",
                "javascriptreact",
                "javascript.jsx",
                "typescript",
                "typescriptreact",
                "typescript.tsx",
                "vue",
            },
        })

        -- Tailwind CSS
        vim.lsp.config("tailwindcss", {
            capabilities = capabilities,
        })

        -- JSON (with schemastore)
        vim.lsp.config("jsonls", {
            capabilities = capabilities,
            settings = {
                json = {
                    schemas = require("schemastore").json.schemas(),
                },
            },
        })

        -- Bash (sh + zsh)
        vim.lsp.config("bashls", {
            capabilities = capabilities,
            filetypes = { "sh", "zsh" },
        })

        -- Lua
        vim.lsp.config("lua_ls", {
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            "${3rd}/luv/library",
                            ---@diagnostic disable-next-line: deprecated
                            unpack(vim.api.nvim_get_runtime_file("", true)),
                        },
                    },
                },
            },
        })

        ----------------------------------------------------------------------
        -- Enable servers (Mason takes care of installing them)
        ----------------------------------------------------------------------
        local servers = {
            "gopls",
            "pyright",
            "phpactor",
            "vue_ls",
            "ts_ls",
            "tailwindcss",
            "jsonls",
            "bashls",
            "lua_ls",
        }

        for _, server in ipairs(servers) do
            vim.lsp.enable(server)
        end

        ----------------------------------------------------------------------
        -- null-ls / none-ls (formatting, diagnostics)
        ----------------------------------------------------------------------
        local null_ls = require("null-ls")
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

        null_ls.setup({
            temp_dir = "/tmp",
            sources = {
                -- basic tools
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.completion.spell,
                require("none-ls.code_actions.eslint_d"),
                require("none-ls.diagnostics.eslint_d"),
                require("none-ls.formatting.eslint_d"),
                require("none-ls.formatting.jq"),

                -- trailing spaces
                null_ls.builtins.diagnostics.trail_space.with({
                    disabled_filetypes = { "NvimTree" },
                }),

                -- PHP Pint
                null_ls.builtins.formatting.pint.with({
                    condition = function(utils)
                        return utils.root_has_file({ "vendor/bin/pint" })
                    end,
                }),

                -- Prettier only if project config exists
                null_ls.builtins.formatting.prettier.with({
                    condition = function(utils)
                        return utils.root_has_file({
                            ".prettierrc",
                            ".prettierrc.json",
                            ".prettierrc.yml",
                            ".prettierrc.js",
                            "prettier.config.js",
                        })
                    end,
                }),

                -- Python
                null_ls.builtins.formatting.black,
            },
            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_clear_autocmds({
                        group = augroup,
                        buffer = bufnr,
                    })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({
                                bufnr = bufnr,
                                timeout_ms = 5000,
                            })
                        end,
                    })
                end
            end,
        })

        require("mason-null-ls").setup({
            automatic_installation = true,
            ensure_installed = { "stylua", "jq", "black" },
        })

        ----------------------------------------------------------------------
        -- Keymaps, commands, diagnostics, signs
        ----------------------------------------------------------------------
        local map = vim.keymap.set

        map("n", "<Leader>d", vim.diagnostic.open_float)
        map("n", "gd", "<cmd>Telescope lsp_definitions<CR>")
        map("n", "ga", vim.lsp.buf.code_action)
        map("n", "gi", "<cmd>Telescope lsp_implementations<CR>")
        map("n", "gr", "<cmd>Telescope lsp_references<CR>")
        map("n", "<Leader>lr", "<cmd>LspRestart<CR>", { silent = true })
        map("n", "K", vim.lsp.buf.hover)
        map("n", "<Leader>rn", vim.lsp.buf.rename)

        vim.api.nvim_create_user_command("Format", function()
            vim.lsp.buf.format({ timeout_ms = 5000 })
        end, {})

        vim.diagnostic.config({
            virtual_text = false,
            float = { source = true },
        })

        vim.fn.sign_define("DiagnosticSignError", {
            text = "",
            texthl = "DiagnosticSignError",
        })
        vim.fn.sign_define("DiagnosticSignWarn", {
            text = "",
            texthl = "DiagnosticSignWarn",
        })
        vim.fn.sign_define("DiagnosticSignInfo", {
            text = "",
            texthl = "DiagnosticSignInfo",
        })
        vim.fn.sign_define("DiagnosticSignHint", {
            text = "",
            texthl = "DiagnosticSignHint",
        })
    end,
}
