return {
    "farmergreg/vim-lastplace",

    -- Only matters when reading files, so load then
    event = "BufReadPost",

    -- (Optional) explicit defaults, uncomment if you want to tweak later
    -- init = function()
    --     vim.g.lastplace_ignore_buftype = "quickfix,nofile,help"
    --     vim.g.lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
    --     vim.g.lastplace_open_folds = 1
    -- end,
}
