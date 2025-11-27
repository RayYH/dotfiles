return {
    "christoomey/vim-tmux-navigator",

    -- Load when you first use the navigator keymaps
    keys = {
        { "<C-h>",  mode = { "n", "t" }, desc = "Tmux navigate left" },
        { "<C-j>",  mode = { "n", "t" }, desc = "Tmux navigate down" },
        { "<C-k>",  mode = { "n", "t" }, desc = "Tmux navigate up" },
        { "<C-l>",  mode = { "n", "t" }, desc = "Tmux navigate right" },
        { "<C-\\>", mode = { "n", "t" }, desc = "Tmux navigate previous" },
    },
}