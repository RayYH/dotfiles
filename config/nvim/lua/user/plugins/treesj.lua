return {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
        {
            "<leader>mj",
            function()
                require("treesj").join()
            end,
        },
        {
            "<leader>ms",
            function()
                require("treesj").split()
            end,
        },
        {
            "<leader>mm",
            function()
                require("treesj").toggle()
            end,
        },
    },
    opts = {
        use_default_keymaps = false,
    },
}
