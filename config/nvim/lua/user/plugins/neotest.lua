return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "rayyh/neotest-jest",
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-jest")({
                    jestCommand = "npm test --",
                    env = { CI = true },
                    cwd = function(_)
                        return vim.fn.getcwd()
                    end,
                }),
            },
        })
    end,
}
