return {
    "famiu/bufdelete.nvim",
    config = function()
        vim.keymap.set(
            "n",
            "<Leader>qb",
            ":Bdelete<CR>",
            { desc = "Delete buffer" }
        )
        vim.keymap.set(
            "n",
            "<Leader>qB",
            ":bufdo Bdelete<CR>",
            { desc = "Delete all buffers" }
        )
    end,
}
