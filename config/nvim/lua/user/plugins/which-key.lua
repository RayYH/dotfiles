return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = {
        "echasnovski/mini.icons",
    },

    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,

    -- this is passed into which-key.setup()
    opts = {
        filter = function(mapping)
            return mapping.desc ~= nil and mapping.desc ~= ""
        end,
    },

    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        -- normal-mode mappings / groups
        wk.add({
            -- git / comment
            { "gb", desc = "Git blame line" },

            { "gc", group = "comment" },
            { "gcc", desc = "Comment current line" },
            {
                "gcu",
                desc = "Uncomment current and adjacent commented lines",
            },
            {
                "gcgc",
                desc = "Uncomment current and adjacent commented lines",
            },

            -- Markdown
            { "<leader>M", group = "Markdown" },
            {
                "<leader>Mp",
                "<cmd>MarkdownPreview<CR>",
                desc = "Preview Markdown",
            },
            {
                "<leader>MP",
                "<cmd>PeekOpen<CR>",
                desc = "Preview Markdown via Peek",
            },
            {
                "<leader>MC",
                "<cmd>PeekClose<CR>",
                desc = "Close Markdown Peek",
            },
            {
                "<leader>Ms",
                "<cmd>MarkdownPreviewStop<CR>",
                desc = "Stop Markdown preview",
            },
            {
                "<leader>Mt",
                "<cmd>MarkdownPreviewToggle<CR>",
                desc = "Toggle Markdown preview",
            },

            -- console / CLI
            { "<leader>c", group = "console/cli" },
            { "<leader>cg", desc = "Open Lazygit" },
            {
                "<leader>cc",
                desc = "Take screenshot (clipboard)",
            },
            {
                "<leader>cs",
                desc = "Take screenshot (save to filesystem)",
            },

            -- DAP
            { "<leader>d", group = "debug" },
            {
                "<leader>db",
                "<cmd>lua require('dap').toggle_breakpoint()<CR>",
                desc = "Toggle breakpoint",
            },
            {
                "<leader>dc",
                "<cmd>lua require('dap').continue()<CR>",
                desc = "Continue",
            },
            {
                "<leader>dd",
                "<cmd>lua require('dap').step_over()<CR>",
                desc = "Step over",
            },
            {
                "<leader>di",
                "<cmd>lua require('dap').step_into()<CR>",
                desc = "Step into",
            },
            {
                "<leader>do",
                "<cmd>lua require('dap').step_out()<CR>",
                desc = "Step out",
            },
            {
                "<leader>dr",
                "<cmd>lua require('dap').repl.toggle()<CR>",
                desc = "Toggle REPL",
            },
            {
                "<leader>ds",
                "<cmd>lua require('dap').close()<CR>",
                desc = "Stop",
            },

            -- file / telescope
            { "<leader>f", group = "file" },
            { "<leader>fa", desc = "Find all files" },
            { "<leader>fb", desc = "Find buffers" },
            { "<leader>fd", desc = "Document symbols" },
            { "<leader>ff", desc = "Find file" },
            { "<leader>fg", desc = "Find word" },
            { "<leader>fh", desc = "Find help" },
            { "<leader>fr", desc = "Recent files" },
            { "<leader>fs", "<cmd>w<CR>", desc = "Save buffer" },
            {
                "<leader>fu",
                "<cmd>Lazy update<CR>",
                desc = "Update plugins (Lazy)",
            },

            -- mode / formatting / treesj
            { "<leader>m", group = "mode" },
            { "<leader>mj", desc = "Join Treesitter nodes" },
            { "<leader>mm", desc = "Toggle split/join (Treesj)" },
            { "<leader>mp", desc = "Format document" },
            { "<leader>ms", desc = "Split Treesitter nodes" },

            -- file / folder (neo-tree etc.)
            { "<leader>n", group = "File/Folder" },

            -- quit / buffers
            { "<leader>q", group = "quit" },
            { "<leader>qB", desc = "Close all buffers" },
            { "<leader>qb", desc = "Close buffer" },

            -- splits
            { "<leader>s", group = "split" },
            {
                "<leader>sh",
                "<cmd>split<CR>",
                desc = "Split horizontal",
            },
            {
                "<leader>sv",
                "<cmd>vsplit<CR>",
                desc = "Split vertical",
            },

            -- tests / neotest
            { "<leader>t", group = "test" },
            {
                "<leader>tM",
                "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<CR>",
                desc = "Test method (DAP)",
            },
            {
                "<leader>tf",
                "<cmd>lua require('neotest').run.run({ vim.fn.expand('%') })<CR>",
                desc = "Test file",
            },
            {
                "<leader>tm",
                "<cmd>lua require('neotest').run.run()<CR>",
                desc = "Test method",
            },
        })

        -- visual-mode codesnap group
        wk.add({
            { "c", group = "codesnap", mode = "x" },
            {
                "cc",
                "<cmd>CodeSnap<CR>",
                mode = "x",
                desc = "Save code snapshot to clipboard",
            },
            {
                "cs",
                "<cmd>CodeSnapSave<CR>",
                mode = "x",
                desc = "Save code snapshot to ~/Pictures",
            },
        })
    end,
}