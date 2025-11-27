return {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    -- Lazy-load on first use of these keys
    keys = {
        {
            "<leader>mj",
            function()
                require("treesj").join()
            end,
            mode = "n",
            desc = "Treesj: join node",
        },
        {
            "<leader>ms",
            function()
                require("treesj").split()
            end,
            mode = "n",
            desc = "Treesj: split node",
        },
        {
            "<leader>mm",
            function()
                require("treesj").toggle()
            end,
            mode = "n",
            desc = "Treesj: toggle split/join",
        },
    },

    -- Explicit main module for opts
    main = "treesj",

    opts = {
        use_default_keymaps = false,
        -- you can add more config here later, e.g.:
        -- max_join_length = 120,
    },
}