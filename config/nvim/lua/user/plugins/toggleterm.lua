return {
    "akinsho/nvim-toggleterm.lua",
    config = function()
        require("toggleterm").setup({
            size = 20,
            open_mapping = [[<C-\>]],
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
        })

        vim.api.nvim_set_keymap(
            "n",
            "<leader>ct",
            "<cmd>ToggleTerm<CR>",
            { noremap = true, silent = true }
        )

        local Terminal = require("toggleterm.terminal").Terminal
        local lazygit = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            float_opts = {
                border = "double",
            },
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(
                    term.bufnr,
                    "n",
                    "q",
                    "<cmd>close<CR>",
                    { noremap = true, silent = true }
                )
            end,
            on_close = function(_)
                vim.cmd("startinsert!")
            end,
        })

        function ToggleLazyGit()
            lazygit:toggle()
        end

        vim.api.nvim_set_keymap(
            "n",
            "<leader>cg",
            "<cmd>lua ToggleLazyGit()<CR>",
            { noremap = true, silent = true }
        )
    end,
}
