return {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    enabled = true,
    build = function()
        require("nvim-treesitter.install").update({
            with_sync = true,
        })
    end,
    dependencies = {
        {
            "nvim-treesitter/playground",
            cmd = "TSPlaygroundToggle",
        },
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
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
        },
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    main = "nvim-treesitter.configs",
    opts = {
        ensure_installed = {
            "arduino",
            "bash",
            "comment",
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
            "jsonc",
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
        },
        auto_install = true,
        highlight = {
            enable = true,
        },
        indent = {
            enable = true,
            disable = { "yaml" },
        },
        rainbow = {
            enable = true,
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["if"] = "@function.inner",
                    ["af"] = "@function.outer",
                    ["ia"] = "@parameter.inner",
                    ["aa"] = "@parameter.outer",
                },
            },
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
        require("ts_context_commentstring").setup({})
        vim.g.skip_ts_context_commentstring_module = true
    end,
}
