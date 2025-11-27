return {
    "wintermute-cell/gitignore.nvim",

    -- Load only when needed
    cmd = { "Gitignore" },
    keys = {
        {
            "<leader>gi",
            function()
                require("gitignore").generate()
            end,
            mode = "n",
            desc = "Generate .gitignore for project",
        },
    },

    -- Optional: telescope for multi-select, auto-used if present
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },

    config = function()
        -- Ensure module is loaded so :Gitignore and gitignore.generate exist
        require("gitignore")
    end,
}