return {
    "nvim-neotest/neotest",

    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-jest",
    },

    -- You can also switch to key-based lazy-loading if you want
    event = "VeryLazy",

    -- Keep opts for future extension, but don't call require() here
    opts = {},

    config = function(_, opts)
        local ok_neotest, neotest = pcall(require, "neotest")
        if not ok_neotest then
            return
        end

        local adapters = opts.adapters or {}

        -- Safely require neotest-jest *after* plugin+deps are loaded
        local ok_jest, jest = pcall(require, "neotest-jest")
        if ok_jest then
            table.insert(adapters, jest({
                jestCommand = "npm test --",
                env = { CI = true },
                cwd = function()
                    return vim.fn.getcwd()
                end,
            }))
        else
            vim.notify(
                "[neotest] neotest-jest not found; Jest adapter disabled",
                vim.log.levels.WARN
            )
        end

        opts.adapters = adapters
        neotest.setup(opts)
    end,
}