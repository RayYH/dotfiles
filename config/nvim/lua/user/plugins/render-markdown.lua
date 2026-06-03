return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    cmd = { "RenderMarkdown" },
    dependencies = {
        "neovim-treesitter/nvim-treesitter",
        "echasnovski/mini.nvim",
    },
    opts = {
        completions = {
            lsp = { enabled = true },
        },
    },
}
