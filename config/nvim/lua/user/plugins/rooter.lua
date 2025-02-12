return {
    "airblade/vim-rooter",
    init = function()
        vim.g.rooter_manual_only = 1
        vim.g.rooter_patterns = { ".git", "composer.json", "*.lsn", "go.mod" }
    end,
    config = function()
        vim.cmd("Rooter")
    end,
}
