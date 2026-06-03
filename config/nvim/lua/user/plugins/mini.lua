return {
    "echasnovski/mini.nvim",
    version = "*",

    -- Don't do anything on startup; you'll call individual modules yourself
    event = "VeryLazy",

    keys = {
        { "gc", mode = { "n", "x", "o" }, desc = "Comment operator" },
        { "gcc", mode = "n", desc = "Comment line" },
        { "gcap", mode = "n", desc = "Comment around paragraph" },
        {
            "<leader>qb",
            function()
                require("mini.bufremove").delete(0, false)
            end,
            mode = "n",
            desc = "Delete buffer",
        },
        {
            "<leader>qB",
            function()
                local bufremove = require("mini.bufremove")
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].buflisted then
                        bufremove.delete(buf, false)
                    end
                end
            end,
            mode = "n",
            desc = "Delete all buffers",
        },
    },

    config = function()
        require("mini.bufremove").setup()
        require("mini.comment").setup()
    end,
}
