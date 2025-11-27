return {
    "airblade/vim-rooter",

    -- Load only when we actually need it
    cmd = { "Rooter" },

    init = function()
        -- Only run Rooter when explicitly called
        vim.g.rooter_manual_only = 1

        -- Directories/files that define a project root
        vim.g.rooter_patterns = { ".git", "composer.json", "*.lsn", "go.mod" }
    end,

    keys = {
        {
            "<leader>pr",
            "<cmd>Rooter<CR>",
            desc = "Set project root (vim-rooter)",
        },
    },
}
