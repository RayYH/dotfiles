return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",

    keys = {
        {
            "<C-n>",
            mode = { "n", "x" },
            desc = "Multicursor: add next match",
        },
        {
            "<C-Down>",
            mode = { "n", "x" },
            desc = "Multicursor: add cursor down",
        },
        {
            "<C-Up>",
            mode = { "n", "x" },
            desc = "Multicursor: add cursor up",
        },
        {
            "gb",
            mode = { "n", "x" },
            desc = "Multicursor: select all matches",
        },
    },

    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        vim.keymap.set({ "n", "x" }, "<C-n>", function()
            mc.matchAddCursor(1)
        end, { desc = "Multicursor: add next match" })

        vim.keymap.set({ "n", "x" }, "<C-Down>", function()
            mc.lineAddCursor(1)
        end, { desc = "Multicursor: add cursor down" })

        vim.keymap.set({ "n", "x" }, "<C-Up>", function()
            mc.lineAddCursor(-1)
        end, { desc = "Multicursor: add cursor up" })

        vim.keymap.set({ "n", "x" }, "gb", function()
            mc.matchAllAddCursors()
        end, { desc = "Multicursor: select all matches" })

        mc.addKeymapLayer(function(layer_set)
            layer_set("n", "<Esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)

        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { reverse = true })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn" })
        hl(0, "MultiCursorMatchPreview", { link = "Search" })
        hl(0, "MultiCursorDisabledCursor", { reverse = true })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
}
