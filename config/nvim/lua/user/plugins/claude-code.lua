return {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume" },
    keys = {
        { "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude Code" },
        { "<leader>ar", "<cmd>ClaudeCodeResume<CR>", desc = "Resume Claude session" },
    },
    opts = {
        window = {
            position = "right",
            split_ratio = 0.4,
        },
    },
}
