-- lua/user/plugins/lspconfig.lua
return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "b0o/schemastore.nvim",
        {
            "nvimtools/none-ls.nvim",
            dependencies = {
                "nvimtools/none-ls-extras.nvim",
            },
        },
        -- your fork
        "rayyh/mason-null-ls.nvim",
    },

    config = function()
        ----------------------------------------------------------------------
        -- Mason
        ----------------------------------------------------------------------
        require("mason").setup({
            ui = {
                height = 0.8,
            },
        })

        require("mason-lspconfig").setup({
            automatic_installation = true,
        })

        ----------------------------------------------------------------------
        -- Capabilities
        ----------------------------------------------------------------------
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        ----------------------------------------------------------------------
        -- Diagnostics & signs (global)
        ----------------------------------------------------------------------
        vim.diagnostic.config({
            virtual_text = false,
            float = {
                source = "if_many",
            },
        })

        local signs = {
            DiagnosticSignError = "",
            DiagnosticSignWarn  = "",
            DiagnosticSignInfo  = "",
            DiagnosticSignHint  = "",
        }

        for name, text in pairs(signs) do
            vim.fn.sign_define(name, { text = text, texthl = name })
        end

        ----------------------------------------------------------------------
        -- LSP keymaps (buffer-local, on attach)
        ----------------------------------------------------------------------
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
            callback = function(args)
                local bufnr = args.buf

                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                -- Diagnostics
                map("n", "<Leader>d", vim.diagnostic.open_float, "Show line diagnostics")

                -- LSP (Telescope-powered where appropriate)
                map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Goto definition")
                map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Goto implementation")
                map("n", "gr", "<cmd>Telescope lsp_references<CR>", "Goto references")
                map("n", "ga", vim.lsp.buf.code_action, "Code actions")
                map("n", "K", vim.lsp.buf.hover, "Hover")
                map("n", "<Leader>rn", vim.lsp.buf.rename, "Rename symbol")
            end,
        })

        -- Global command (keep it, handy for null-ls or LSP)
        vim.api.nvim_create_user_command("Format", function()
            vim.lsp.buf.format({ timeout_ms = 5000 })
        end, {})

        ----------------------------------------------------------------------
        -- LSP servers
        ----------------------------------------------------------------------
        local util = require("lspconfig.util")

        -- Go (gopls)
        require("lspconfig.gopls").setup({
            capabilities = capabilities,
            cmd = { "gopls" },
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            root_dir = util.root_pattern("go.work", "go.mod", ".git"),
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
        require("lspconfig.pyright").setup({
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

        -- PHP (phpactor) – diagnostics & most LS features disabled
        require("lspconfig.phpactor").setup({
            capabilities = capabilities,
            on_attach = function(client, _)
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

        -- Vue (volar)
        require("lspconfig.volar").setup({
            capabilities = capabilities,
            on_attach = function(client, _)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end,
        })

        -- TypeScript / JavaScript (tsserver replacement: ts_ls)
        require("lspconfig.ts_ls").setup({
            capabilities = capabilities,
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
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
        require("lspconfig.tailwindcss").setup({
            capabilities = capabilities,
        })

        -- JSON (with schemastore)
        require("lspconfig.jsonls").setup({
            capabilities = capabilities,
            settings = {
                json = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
                },
            },
        })

        -- Bash
        require("lspconfig.bashls").setup({
            capabilities = capabilities,
            filetypes = { "sh", "zsh" },
        })

        -- Lua
        require("lspconfig.lua_ls").setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            "${3rd}/luv/library",
                            unpack(vim.api.nvim_get_runtime_file("", true)),
                        },
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                },
            },
        })

        ----------------------------------------------------------------------
        -- null-ls / none-ls
        ----------------------------------------------------------------------
        local null_ls = require("null-ls")
        local formatting = null_ls.builtins.formatting
        local diagnostics = null_ls.builtins.diagnostics
        local completion = null_ls.builtins.completion

        local sources = {
            -- formatting
            formatting.stylua,
            formatting.jq,
            formatting.black,
            formatting.prettier.with({
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
            formatting.pint.with({
                condition = function(utils)
                    return utils.root_has_file({ "vendor/bin/pint" })
                end,
            }),

            -- diagnostics
            diagnostics.trail_space.with({
                disabled_filetypes = { "NvimTree" },
            }),

            -- completion
            completion.spell,

            -- none-ls-extras (eslint_d)
            require("none-ls.code_actions.eslint_d"),
            require("none-ls.diagnostics.eslint_d"),
            require("none-ls.formatting.eslint_d"),
        }

        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

        null_ls.setup({
            temp_dir = "/tmp",
            sources = sources,
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

        ----------------------------------------------------------------------
        -- mason-null-ls
        ----------------------------------------------------------------------
        require("mason-null-ls").setup({
            automatic_installation = true,
            ensure_installed = { "stylua", "jq", "black" },
        })

        ----------------------------------------------------------------------
        -- Misc LSP helpers
        ----------------------------------------------------------------------
        -- Nice to have a global restart binding still
        vim.keymap.set("n", "<Leader>lr", "<cmd>LspRestart<CR>", {
            silent = true,
            desc = "Restart LSP",
        })
    end,
}