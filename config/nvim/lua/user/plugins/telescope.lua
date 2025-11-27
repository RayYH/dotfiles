return {
    "nvim-telescope/telescope.nvim",

    -- Don't force eager load; keys/commands will pull it in
    cmd = "Telescope",
    keys = {
        {
            "<leader>fa",
            function()
                require("telescope.builtin").find_files({
                    no_ignore = true,
                    prompt_title = "All Files",
                })
            end,
            desc = "Find all files (no ignore)",
        },
        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Find buffers",
        },
        {
            "<leader>ff",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "Find files",
        },
        {
            "<leader>fg",
            function()
                require("telescope").extensions.live_grep_args.live_grep_args()
            end,
            desc = "Live grep (with args)",
        },
        {
            "<leader>fh",
            function()
                require("telescope.builtin").help_tags()
            end,
            desc = "Find help",
        },
        {
            "<leader>fr",
            function()
                require("telescope.builtin").oldfiles()
            end,
            desc = "Find recent files",
        },
        {
            "<leader>fd",
            function()
                require("telescope.builtin").lsp_document_symbols()
            end,
            desc = "Document symbols",
        },
    },

    lazy = true,

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope-live-grep-args.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local lga_actions = require("telescope-live-grep-args.actions")

        telescope.setup({
            defaults = {
                path_display = { "truncate" },
                prompt_prefix = "   ",
                selection_caret = "  ",
                layout_config = {
                    prompt_position = "top",
                },
                preview = {
                    timeout = 200,
                },
                sorting_strategy = "ascending",
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<C-Down>"] = actions.cycle_history_next,
                        ["<C-Up>"] = actions.cycle_history_prev,
                    },
                },
                file_ignore_patterns = { ".git/" },
            },

            extensions = {
                live_grep_args = {
                    mappings = {
                        i = {
                            ["<C-k>"] = lga_actions.quote_prompt(),
                            ["<C-i>"] = lga_actions.quote_prompt({
                                postfix = " --iglob ",
                            }),
                        },
                    },
                },
            },

            pickers = {
                find_files = {
                    hidden = true,
                },
                buffers = {
                    previewer = false,
                    layout_config = {
                        width = 80,
                    },
                },
                oldfiles = {
                    prompt_title = "History",
                },
                lsp_references = {
                    previewer = false,
                },
                lsp_definitions = {
                    previewer = false,
                },
                lsp_document_symbols = {
                    symbol_width = 55,
                },
            },
        })

        -- Safely load extensions
        pcall(telescope.load_extension, "fzf")
        pcall(telescope.load_extension, "live_grep_args")
    end,
}
