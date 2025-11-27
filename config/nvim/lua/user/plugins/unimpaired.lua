return {
    "tpope/vim-unimpaired",

    -- Load when you first use common unimpaired mappings
    keys = {
        -- buffer navigation
        { "[b", desc = "Previous buffer" },
        { "]b", desc = "Next buffer" },

        -- quickfix navigation
        { "[q", desc = "Previous quickfix item" },
        { "]q", desc = "Next quickfix item" },

        -- location list navigation
        { "[e", desc = "Previous location item" },
        { "]e", desc = "Next location item" },
    },
}