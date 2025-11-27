return {
    "NvChad/nvim-colorizer.lua",
    -- Load when you actually open/edit files
    event = { "BufReadPost", "BufNewFile" },

    -- Explicit module name for opts (good for some lazy.nvim setups)
    main = "colorizer",

    opts = {
        user_default_options = {
            -- disable named colors like "Red", "Blue", etc.
            names = false,
            -- you can add more here later, e.g.:
            -- tailwind = true,
            -- mode = "background",
        },
    },
}
