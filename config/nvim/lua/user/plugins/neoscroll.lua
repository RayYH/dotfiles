return {
    "karb94/neoscroll.nvim",

    -- Don’t run in the hot path of startup
    event = "VeryLazy",

    -- Let lazy.nvim call require("neoscroll").setup(opts)
    opts = {
        -- You can tweak these if you like, keeping defaults close to upstream
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = true,
        cursor_scrolls_alone = true,
        easing_function = nil, -- e.g. "quadratic" if you want easing
        performance_mode = false,
    },
}