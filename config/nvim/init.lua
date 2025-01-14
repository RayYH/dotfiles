require("user.core.init")
require("user.lazy")

function ReloadConfig()
    vim.cmd("source $MYVIMRC")
    require("noice").notify("Neovim configuration reloaded!")
end

vim.api.nvim_set_keymap(
    "n",
    "<leader>rr",
    ":lua ReloadConfig()<CR>",
    { noremap = true, silent = true }
)
