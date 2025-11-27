return {
    "tpope/vim-surround",

    -- Load when you first use any surround mapping
    keys = {
        -- normal mode
        { "cs", mode = "n", desc = "Change surrounding" },
        { "ds", mode = "n", desc = "Delete surrounding" },
        { "ys", mode = "n", desc = "Add surrounding (motion)" },
        { "yS", mode = "n", desc = "Add surrounding (line, big)" },
        { "yss", mode = "n", desc = "Add surrounding (line)" },
        { "ySs", mode = "n", desc = "Add surrounding (line, big)" },

        -- visual mode
        { "S", mode = "x", desc = "Surround selection" },
        { "gS", mode = "x", desc = "Surround selection (block)" },
    },
}
