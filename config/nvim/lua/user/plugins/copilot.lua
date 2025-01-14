return {
    "github/copilot.vim",
    config = function()
        vim.api.nvim_set_keymap(
            "i",
            "<M-CR>",
            'copilot#Accept("<CR>")',
            { silent = true, expr = true, noremap = true }
        )
        vim.g.copilot_no_tab_map = true

        function ToggleCopilot()
            if vim.g.copilot_enabled then
                vim.g.copilot_enabled = false
                print("Copilot Disabled")
            else
                vim.g.copilot_enabled = true
                print("Copilot Enabled")
            end
        end
        vim.api.nvim_set_keymap(
            "n",
            "<leader>mc",
            ":lua ToggleCopilot()<CR>",
            { noremap = true, silent = true }
        )

        -- disable copilot by default
        vim.g.copilot_enabled = false
    end,
}
