return {
    "nvim-treesitter/nvim-treesitter",

    -- Set up when you actually open/edit files
    event = { "BufReadPost", "BufNewFile" },

    -- Recommended build command for Treesitter
    build = ":TSUpdate",

    main = "nvim-treesitter.configs",

    dependencies = {
        {
            "nvim-treesitter/playground",
            cmd = "TSPlaygroundToggle",
        },
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            main = "ts_context_commentstring",
            opts = {
                -- your custom Blade logic
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
                -- If you're using Comment.nvim, this keeps it from loading
                -- its own ts-context-commentstring module.
                vim.g.skip_ts_context_commentstring_module = true
            end,
        },
        "nvim-treesitter/nvim-treesitter-textobjects",
    },

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

        -- If you’re using Comment.nvim or similar, this is the usual pattern:
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
        },

        -- Only effective if you have a rainbow plugin wired in elsewhere
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
}