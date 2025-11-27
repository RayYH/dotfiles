return {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },

    -- Configure via opts so you can tweak later
    opts = {
        -- You can customize if needed:
        -- enable_rename = true,
        -- enable_close_on_slash = true,
    },

    config = function(_, opts)
        local ok, autotag = pcall(require, "nvim-ts-autotag")
        if not ok then
            return
        end
        autotag.setup(opts)
    end,
}
