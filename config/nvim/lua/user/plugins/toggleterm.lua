return {
    "akinsho/toggleterm.nvim",
    version = "*",

    -- Lazy-load on first use
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
        {
            "<C-\\>",
            "<cmd>ToggleTerm<CR>",
            mode = { "n", "t" },
            desc = "Toggle terminal",
        },
        {
            "<leader>ct",
            "<cmd>ToggleTerm<CR>",
            mode = "n",
            desc = "Toggle terminal",
        },
        {
            "<leader>cg",
            function()
                require("toggleterm-lazygit").toggle()
            end,
            mode = "n",
            desc = "Toggle Lazygit",
        },
    },

    opts = {
        size = 20,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
    },

    config = function(_, opts)
        local ok, toggleterm = pcall(require, "toggleterm")
        if not ok then
            return
        end

        toggleterm.setup(opts)

        local Terminal = require("toggleterm.terminal").Terminal

        -- Lazygit terminal wrapped in its own module-like table
        local lazygit = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            float_opts = {
                border = "double",
            },
            on_open = function(term)
                vim.cmd("startinsert!")
                -- buffer-local mapping to close with `q`
                vim.keymap.set("n", "q", "<cmd>close<CR>", {
                    buffer = term.bufnr,
                    noremap = true,
                    silent = true,
                })
            end,
            on_close = function(_)
                vim.cmd("startinsert!")
            end,
        })

        -- Expose a small helper module so our keymap can require it
        package.loaded["toggleterm-lazygit"] = {
            toggle = function()
                lazygit:toggle()
            end,
        }

        -- Extra mapping for normal mode toggle (in case cmd/keys aren’t enough)
        vim.keymap.set("n", "<leader>ct", "<cmd>ToggleTerm<CR>", {
            noremap = true,
            silent = true,
            desc = "Toggle terminal",
        })
    end,
}
