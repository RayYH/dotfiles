local api = vim.api
local cmd = vim.cmd
local opt_local = vim.opt_local

local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

-- Filetype / buffer-local tweaks ------------------------------

local filetype_group = augroup("FileTypeOverrides", { clear = true })

autocmd("TermOpen", {
    group = filetype_group,
    callback = function()
        opt_local.spell = false
    end,
})

autocmd("FileType", {
    group = filetype_group,
    pattern = { "sh", "go", "rust" },
    callback = function()
        opt_local.textwidth = 80
    end,
})

autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.mdx" },
    callback = function()
        vim.bo.filetype = "markdown"
    end,
})

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "Jenkinsfile" },
    callback = function()
        vim.bo.filetype = "groovy"
    end,
})

-- Highlight on yank ------------------------------------------ 

local hl_yank = augroup("HighlightYank", { clear = true })

autocmd("TextYankPost", {
    group = hl_yank,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Save / restore folds for markdown --------------------------

local folds_group = augroup("AutoFolds", { clear = true })

local ignore_filetypes = {
    gitcommit = true,
    gitrebase = true,
    svg = true,
    hgcommit = true,
}

autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
    group = folds_group,
    callback = function(args)
        local buf = args.buf
        if vim.bo[buf].filetype == "markdown" and vim.b[buf].view_activated then
            cmd.mkview({ mods = { emsg_silent = true } })
        end
    end,
})

autocmd("BufWinEnter", {
    group = folds_group,
    callback = function(args)
        local buf = args.buf

        if vim.b[buf].view_activated then
            return
        end

        local filetype = api.nvim_get_option_value("filetype", { buf = buf })
        local buftype = api.nvim_get_option_value("buftype", { buf = buf })

        if buftype ~= "" or not filetype or filetype == "" then
            return
        end

        -- Only manage folds for markdown, and skip some special filetypes
        if filetype ~= "markdown" or ignore_filetypes[filetype] then
            return
        end

        vim.b[buf].view_activated = true
        cmd.loadview({ mods = { emsg_silent = true } })
    end,
})