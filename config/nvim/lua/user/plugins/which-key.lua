return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
        filter = function(mapping)
            return mapping.desc and mapping.desc ~= ""
        end,
    },
    config = function()
        local wk = require("which-key")
        wk.setup()
        wk.add({
            { "gb", desc = "Git blame line" },
            { "gc", group = "comment" },
            { "gcc", desc = "comment current line" },
            {
                "gcu",
                desc = "Uncomment the current and adjacent commented lines.",
            },
            {
                "gcgc",
                desc = "Uncomment the current and adjacent commented lines.",
            },
            { "<leader>M", group = "Markdown" },
            {
                "<leader>Mp",
                "<cmd>MarkdownPreview<CR>",
                desc = "Preview Markdown",
            },
            {
                "<leader>MP",
                "<cmd>PeekOpen<CR>",
                desc = "Preview Markdown Via Peek",
            },
            {
                "<leader>MC",
                "<cmd>PeekClose<CR>",
                desc = "Close Preview Markdown",
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
            { "<leader>c", group = "console/cli" },
            { "<leader>cg", desc = "Open Lazygit" },
            { "<leader>cc", desc = "Take screenshot and save it to clipboard" },
            {
                "<leader>cs",
                desc = "Take screenshoot and save it to filesystem",
            },

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

            { "<leader>f", group = "file" },
            { "<leader>fa", desc = "Find all files" },
            { "<leader>fb", desc = "Find buffers" },
            { "<leader>fd", desc = "Document symbols" },
            { "<leader>ff", desc = "Find file" },
            { "<leader>fg", desc = "Find word" },
            { "<leader>fh", desc = "Find help" },
            { "<leader>fr", desc = "Recent files" },
            { "<leader>fs", "<cmd>w<CR>", desc = "Save buffer" },
            { "<leader>fu", "<cmd>Lazy update<CR>", desc = "Update Lazy" },
            { "<leader>m", group = "mode" },
            { "<leader>mj", desc = "Join treesitter nodes" },
            { "<leader>mm", desc = "Toggle treesitter" },
            { "<leader>mp", desc = "Format document" },
            { "<leader>ms", desc = "Split treesitter nodes" },
            { "<leader>n", group = "File/Folder" },
            { "<leader>q", group = "quit" },
            { "<leader>qB", desc = "Close all buffers" },
            { "<leader>qb", desc = "Close buffer" },
            { "<leader>s", group = "split" },
            { "<leader>sh", "<cmd>split<CR>", desc = "Split horizontal" },
            { "<leader>sv", "<cmd>vsplit<CR>", desc = "Split vertical" },
            { "<leader>t", group = "test" },
            {
                "<leader>tM",
                "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
                desc = "Test Method DAP",
            },
            {
                "<leader>tf",
                "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>",
                desc = "Test Class",
            },
            {
                "<leader>tm",
                "<cmd>lua require('neotest').run.run()<cr>",
                desc = "Test Method",
            },
        })

        wk.add({
            {
                mode = { "x" },
                { "c", group = "codesnap" },
                {
                    "cc",
                    "<cmd>CodeSnap<cr>",
                    desc = "Save selected code snapshot into clipboard",
                },
                {
                    "cs",
                    "<cmd>CodeSnapSave<cr>",
                    desc = "Save selected code snapshot in ~/Pictures",
                },
            },
        })
    end,
}
