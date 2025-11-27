return {
    "tpope/vim-commentary",

    -- Let lazy.nvim load it on first comment action
    keys = {
        -- builtin commentary mappings (so lazy.nvim knows when to load it)
        { "gc", mode = { "n", "x", "o" }, desc = "Comment operator" },
        { "gcc", mode = "n", desc = "Comment line" },

        -- your custom mapping: comment *a paragraph* and restore cursor
        {
            "gcap",
            "my<cmd>normal! vip<bar>gc<CR>`y",
            mode = "n",
            desc = "Comment around paragraph",
            noremap = true,
            silent = true,
        },
    },
}
