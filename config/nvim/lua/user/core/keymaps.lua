-- Leader keys -------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Small helper so mappings are silent by default
local function with_opts(o)
    o = o or {}
    if o.silent == nil then
        o.silent = true
    end
    return o
end

----------------------------------------------------------------
-- Basic actions
----------------------------------------------------------------

-- Clear search highlighting.
map(
    "n",
    "<Esc>",
    "<cmd>nohlsearch<CR>",
    with_opts { desc = "Clear search highlighting when pressing <Esc>" }
)

-- Open the current file in the default program.
map(
    "n",
    "<leader>oo",
    "<cmd>!open %<CR><CR>",
    with_opts { desc = "Open the current file in the default program" }
)

----------------------------------------------------------------
-- Diagnostics
----------------------------------------------------------------

map(
    "n",
    "[d",
    vim.diagnostic.goto_prev,
    with_opts { desc = "Go to previous [d]iagnostic" }
)

map(
    "n",
    "]d",
    vim.diagnostic.goto_next,
    with_opts { desc = "Go to next [d]iagnostic" }
)

----------------------------------------------------------------
-- File navigation
----------------------------------------------------------------

-- Allow gf to open non-existent files (no need for expr mapping here).
map(
    "n",
    "gf",
    ":edit <cfile><CR>",
    with_opts { desc = "Open file under cursor (create if needed)" }
)

----------------------------------------------------------------
-- Visual mode quality of life
----------------------------------------------------------------

-- Reselect visual selection after indenting.
map(
    "v",
    "<",
    "<gv",
    with_opts { desc = "Reselect visual selection after indenting" }
)

map(
    "v",
    ">",
    ">gv",
    with_opts { desc = "Reselect visual selection after indenting" }
)

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
map(
    "v",
    "y",
    "myy`y",
    with_opts { desc = "Maintain the cursor position when yanking a visual selection" }
)

map(
    "v",
    "Y",
    "myY`y",
    with_opts { desc = "Maintain the cursor position when yanking a visual selection" }
)

-- Paste replace visual selection without copying it.
map(
    "v",
    "p",
    '"_dP',
    with_opts { desc = "Paste replace visual selection without copying it" }
)

----------------------------------------------------------------
-- Movement tweaks
----------------------------------------------------------------

-- When text is wrapped, move by display lines unless a count is provided.
map(
    "n",
    "k",
    "v:count == 0 ? 'gk' : 'k'",
    with_opts { expr = true, desc = "Move up by display rows" }
)

map(
    "n",
    "j",
    "v:count == 0 ? 'gj' : 'j'",
    with_opts { expr = true, desc = "Move down by display rows" }
)

-- Reselect pasted text.
map(
    "n",
    "p",
    "p`[v`]",
    with_opts { desc = "Reselect pasted text after pasting" }
)

----------------------------------------------------------------
-- Insert mode helpers
----------------------------------------------------------------

-- Easy insertion of a trailing ; or , from insert mode.
map("i", ";;", "<Esc>A;<Esc>", with_opts { desc = "Append ; at end of line" })
map("i", ",,", "<Esc>A,<Esc>", with_opts { desc = "Append , at end of line" })

----------------------------------------------------------------
-- Misc
----------------------------------------------------------------

-- Disable annoying command line window.
map(
    "n",
    "q:",
    "<cmd>q<CR>",
    with_opts { desc = "Disable command-line window (quit instead)" }
)

----------------------------------------------------------------
-- Move text up and down
----------------------------------------------------------------

map("i", "<A-j>", "<Esc>:move .+1<CR>==gi", with_opts { desc = "Move text down" })
map("i", "<A-k>", "<Esc>:move .-2<CR>==gi", with_opts { desc = "Move text up" })

map("n", "<A-j>", ":move .+1<CR>==", with_opts { desc = "Move text down" })
map("n", "<A-k>", ":move .-2<CR>==", with_opts { desc = "Move text up" })

map("v", "<A-j>", ":move '>+1<CR>gv=gv", with_opts { desc = "Move text down" })
map("v", "<A-k>", ":move '<-2<CR>gv=gv", with_opts { desc = "Move text up" })

----------------------------------------------------------------
-- Disable arrow keys
----------------------------------------------------------------

for _, mode in ipairs { "n", "i", "v" } do
    map(mode, "<Up>", "<Nop>", with_opts { desc = "Disable arrow keys" })
    map(mode, "<Down>", "<Nop>", with_opts { desc = "Disable arrow keys" })
    map(mode, "<Left>", "<Nop>", with_opts { desc = "Disable arrow keys" })
    map(mode, "<Right>", "<Nop>", with_opts { desc = "Disable arrow keys" })
end