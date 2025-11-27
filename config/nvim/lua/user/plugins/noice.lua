return {
    "folke/noice.nvim",
    event = "VeryLazy",

    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },

    -- lazy.nvim will call require("noice").setup(opts)
    opts = {
        lsp = {
            -- override markdown rendering so cmp and others use Treesitter
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
        },
        presets = {
            bottom_search = true,         -- classic bottom cmdline for search
            command_palette = true,       -- cmdline + popupmenu together
            long_message_to_split = true, -- long messages go to split
            inc_rename = false,           -- for inc-rename.nvim
            lsp_doc_border = false,       -- border for hover/signature
        },
    },
}