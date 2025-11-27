return {
    "famiu/bufdelete.nvim",

    -- Load only when these keys are pressed
    keys = {
        {
            "<leader>qb",
            "<cmd>Bdelete<CR>",
            mode = "n",
            desc = "Delete buffer",
        },
        {
            "<leader>qB",
            "<cmd>bufdo Bdelete<CR>",
            mode = "n",
            desc = "Delete all buffers",
        },
    },
}
