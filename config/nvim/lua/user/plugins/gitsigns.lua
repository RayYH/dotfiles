return {
    "lewis6991/gitsigns.nvim",

    -- no need for lazy = false; load when editing real files
    event = { "BufReadPre", "BufNewFile" },

    -- tell lazy.nvim which module gets the opts
    main = "gitsigns",

    opts = {
        preview_config = {
            border = { "", "", "", " " },
        },

        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 500,
            ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",

        signs = {
            add = { text = "│" },
            change = { text = "│" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "┄" },
            untracked = { text = "┊" },
        },

        -- Set up buffer-local keymaps when gitsigns attaches to a buffer
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            -- Navigation
            map("n", "]h", gs.next_hunk, "Next git hunk")
            map("n", "[h", gs.prev_hunk, "Previous git hunk")

            -- Actions
            map("n", "gs", gs.stage_hunk, "Stage hunk")
            map("n", "gS", gs.undo_stage_hunk, "Undo stage hunk")
            map("n", "gp", gs.preview_hunk, "Preview hunk")
            map("n", "gb", gs.blame_line, "Blame line")
        end,
    },
}
