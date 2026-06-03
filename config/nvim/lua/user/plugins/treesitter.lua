local languages = {
    "arduino",
    "bash",
    "css",
    "diff",
    "dockerfile",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "go",
    "html",
    "http",
    "ini",
    "javascript",
    "json",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "passwd",
    "php",
    "phpdoc",
    "python",
    "regex",
    "ruby",
    "rust",
    "sql",
    "svelte",
    "typescript",
    "vim",
    "vue",
    "xml",
    "yaml",
}

local filetypes = vim.list_extend(vim.deepcopy(languages), { "jsonc" })

return {
    "neovim-treesitter/nvim-treesitter",

    -- The maintained rewrite manages parsers/queries through a registry and
    -- explicitly does not support lazy-loading.
    lazy = false,
    build = function()
        if vim.fn.executable("tree-sitter") == 1 then
            vim.cmd.TSUpdate()
        end
    end,

    dependencies = {
        "neovim-treesitter/treesitter-parser-registry",
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            main = "ts_context_commentstring",
            opts = {
                custom_calculation = function(_, language_tree)
                    if
                        vim.bo.filetype == "blade"
                        and language_tree._lang ~= "javascript"
                    then
                        return "{{-- %s --}}"
                    end
                end,
            },
            init = function()
                vim.g.skip_ts_context_commentstring_module = true
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            config = function()
                require("nvim-treesitter-textobjects").setup({
                    select = {
                        lookahead = true,
                    },
                })

                local select = require("nvim-treesitter-textobjects.select")

                vim.keymap.set({ "x", "o" }, "if", function()
                    select.select_textobject("@function.inner", "textobjects")
                end, { desc = "Select inner function" })

                vim.keymap.set({ "x", "o" }, "af", function()
                    select.select_textobject("@function.outer", "textobjects")
                end, { desc = "Select outer function" })

                vim.keymap.set({ "x", "o" }, "ia", function()
                    select.select_textobject("@parameter.inner", "textobjects")
                end, { desc = "Select inner parameter" })

                vim.keymap.set({ "x", "o" }, "aa", function()
                    select.select_textobject("@parameter.outer", "textobjects")
                end, { desc = "Select outer parameter" })
            end,
        },
    },

    config = function()
        local treesitter = require("nvim-treesitter")
        treesitter.setup()

        vim.treesitter.language.register("json", "jsonc")

        vim.api.nvim_create_user_command("TSInstallConfigured", function()
            if vim.fn.executable("tree-sitter") ~= 1 then
                vim.notify(
                    "Install tree-sitter CLI before installing parsers",
                    vim.log.levels.WARN
                )
                return
            end

            treesitter.install(languages)
        end, {})

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("TreesitterStart", {
                clear = true,
            }),
            pattern = filetypes,
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)

                if vim.bo[args.buf].filetype ~= "yaml" then
                    vim.bo[args.buf].indentexpr =
                        "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
