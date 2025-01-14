return {
    "mistricky/codesnap.nvim",
    build = "make build_generator",
    keys = {
        {
            "<leader>cc",
            "<cmd>CodeSnap<cr>",
            mode = "x",
            desc = "Save selected code snapshot into clipboard",
        },
        {
            "<leader>cs",
            "<cmd>CodeSnapSave<cr>",
            mode = "x",
            desc = "Save selected code snapshot in ~/Pictures",
        },
    },
    opts = {
        save_path = "~/Pictures/snapshots",
        has_breadcrumbs = false,
        bg_theme = "bamboo",
        mac_window_bar = true,
        code_font_family = "Cascadia Code",
        watermark = "RayYH",
    },
}
