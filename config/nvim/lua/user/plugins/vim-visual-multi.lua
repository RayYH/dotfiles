return {
    "mg979/vim-visual-multi",
    branch = "master",

    -- Load when you first use common VM mappings
    keys = {
        {
            "<C-n>",
            mode = { "n", "x" },
            desc = "Visual-Multi: select word / add cursor",
        },
        {
            "<C-Down>",
            mode = { "n", "x" },
            desc = "Visual-Multi: add cursor down",
        },
        {
            "<C-Up>",
            mode = { "n", "x" },
            desc = "Visual-Multi: add cursor up",
        },
        {
            "gb",
            mode = "n",
            desc = "Visual-Multi: select all occurrences",
        },
    },
}
