local group = vim.api.nvim_create_augroup("FileTypeOverrides", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    pattern = "*",
    command = "setlocal nospell",
})

local hl_yank = vim.api.nvim_create_augroup("highlight-yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = hl_yank,
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sh", "go", "rust" },
    command = "setlocal textwidth=80",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.mdx" },
    command = "set filetype=markdown",
})

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
    group = vim.api.nvim_create_augroup("AutoSaveFolds", { clear = true }),
    pattern = { "markdown" },
    callback = function(args)
        if vim.b[args.buf].view_activated then
            vim.cmd.mkview({ mods = { emsg_silent = true } })
        end
    end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("AutoLoadFolds", { clear = true }),
    pattern = { "markdown" },
    callback = function(args)
        if not vim.b[args.buf].view_activated then
            local filetype =
                vim.api.nvim_get_option_value("filetype", { buf = args.buf })
            local buftype =
                vim.api.nvim_get_option_value("buftype", { buf = args.buf })
            local ignore_filetypes = {
                "gitcommit",
                "gitrebase",
                "svg",
                "hgcommit",
            }
            if
                buftype == ""
                and filetype
                and filetype ~= ""
                and not vim.tbl_contains(ignore_filetypes, filetype)
            then
                vim.b[args.buf].view_activated = true
                vim.cmd.loadview({ mods = { emsg_silent = true } })
            end
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "Jenkinsfile" },
    command = "set filetype=groovy",
})
