return {
    "tpope/vim-abolish",

    -- Load only when you need it
    keys = {
        -- Coercions (operator: use like `crs`, `crc` on motions / text objects)
        { "crs", mode = { "n", "x" }, desc = "Coerce to snake_case" },
        { "crc", mode = { "n", "x" }, desc = "Coerce to camelCase" },
        {
            "cru",
            mode = { "n", "x" },
            desc = "Coerce to UPPER_SNAKE_CASE",
        },
        { "crm", mode = { "n", "x" }, desc = "Coerce to MixedCase" },
        { "cr-", mode = { "n", "x" }, desc = "Coerce to dash-case" },
        { "cr.", mode = { "n", "x" }, desc = "Coerce to dot.case" },
        { "cr<space>", mode = { "n", "x" }, desc = "Coerce to space case" },
    },

    cmd = {
        "Subvert",
        "Abolish",
    },
}
