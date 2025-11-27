return {
    "iamcco/markdown-preview.nvim",

    -- Load only for markdown files or when these commands are used
    ft = { "markdown" },
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },

    -- Use shell build instead of calling mkdp#util#install()
    -- This runs in the plugin's root directory.
    build = "cd app && yarn install",

    init = function()
        -- Limit plugin behavior to markdown
        vim.g.mkdp_filetypes = { "markdown" }
        -- Optional tweaks:
        -- vim.g.mkdp_auto_start = 0
        -- vim.g.mkdp_auto_close = 1
    end,
}