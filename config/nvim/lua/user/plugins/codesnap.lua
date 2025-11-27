return {
    "mistricky/codesnap.nvim",
    build = "make build_generator",

    -- Lazy-load on keypress or when commands are used
    keys = {
        {
            "<leader>cc",
            "<cmd>CodeSnap<CR>",
            mode = "x",
            desc = "Save selected code snapshot into clipboard",
        },
        {
            "<leader>cs",
            "<cmd>CodeSnapSave<CR>",
            mode = "x",
            desc = "Save selected code snapshot in ~/Pictures",
        },
    },
    cmd = { "CodeSnap", "CodeSnapSave" },

    opts = {
        -- Expand ~ so it works even if shell expansion isn’t used
        save_path = vim.fn.expand("~/Pictures/snapshots"),
        has_breadcrumbs = false,
        bg_theme = "bamboo",
        mac_window_bar = true,
        code_font_family = "Cascadia Code",
        watermark = "GitHub @RayYH",
    },
}