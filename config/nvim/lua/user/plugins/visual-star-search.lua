return {
    "nelstrom/vim-visual-star-search",

    -- Load when you actually use visual-* search
    keys = {
        { "*", mode = "x", desc = "Search for visual selection (* wildcard)" },
        { "#", mode = "x", desc = "Search for visual selection (backwards)" },
    },
}
