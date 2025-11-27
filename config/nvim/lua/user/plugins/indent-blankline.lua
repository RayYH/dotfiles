return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",

    -- Only load when editing real files
    event = { "BufReadPost", "BufNewFile" },

    opts = {
        scope = {
            show_start = false,
        },
        exclude = {
            filetypes = { "dashboard" },
        },
    },
}
