return {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",

    -- Only load when there’s an actual file buffer
    event = { "BufReadPost", "BufNewFile" },

    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },

    opts = {
        -- barbecue will infer highlight groups from your colorscheme;
        -- this just picks the built-in Tokyonight theme preset.
        theme = "tokyonight",
        -- attach_navic = true, -- default is true; uncomment if you want to be explicit
    },
}
