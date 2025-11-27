return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },

    -- Put your autopairs options here if you ever need them
    opts = {
        -- fast_wrap = {},
        -- disable_filetype = { "TelescopePrompt", "vim" },
    },

    config = function(_, opts)
        local ok_pairs, autopairs = pcall(require, "nvim-autopairs")
        if not ok_pairs then
            return
        end

        autopairs.setup(opts)

        -- Safely hook into nvim-cmp if available
        local ok_cmp, cmp = pcall(require, "cmp")
        if not ok_cmp then
            return
        end

        local ok_cmp_pairs, cmp_autopairs =
            pcall(require, "nvim-autopairs.completion.cmp")
        if not ok_cmp_pairs then
            return
        end

        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
}
