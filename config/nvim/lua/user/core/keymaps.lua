-- Space is my leader.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

-- Clear search highlighting.
keymap.set(
    "n",
    "<Esc>",
    "<cmd>nohlsearch<CR>",
    { desc = "Clear search highlighting when pressing <Esc>" }
)

-- Open the current file in the default program
keymap.set(
    "n",
    "<leader>oo",
    ":!open %<cr><cr>",
    { desc = "Open the current file in the default program" }
)

-- Diagnostics.
keymap.set(
    "n",
    "[d",
    vim.diagnostic.goto_prev,
    { desc = "Go to previous [d]iagnostic" }
)
keymap.set(
    "n",
    "]d",
    vim.diagnostic.goto_next,
    { desc = "Go to next [d]iagnostic" }
)

-- Allow gf to open non-existent files.
-- keymap.set("n", "gf", ":edit <cfile><CR>", { desc = "Open file under cursor" })
keymap.set("n", "gf", function()
    return "<cmd>edit <cfile><CR>"
end, { noremap = false, expr = true })

-- Reselect visual selection after indenting.
keymap.set(
    "v",
    "<",
    "<gv",
    { desc = "Reselect visual selection after indenting" }
)
keymap.set(
    "v",
    ">",
    ">gv",
    { desc = "Reselect visual selection after indenting" }
)

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
keymap.set(
    "v",
    "y",
    "myy`y",
    { desc = "Maintain the cursor position when yanking a visual selection" }
)
keymap.set(
    "v",
    "Y",
    "myY`y",
    { desc = "Maintain the cursor position when yanking a visual selection" }
)

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
keymap.set(
    "n",
    "k",
    "v:count == 0 ? 'gk' : 'k'",
    { expr = true, desc = "Move up by terminal rows" }
)
keymap.set(
    "n",
    "j",
    "v:count == 0 ? 'gj' : 'j'",
    { expr = true, desc = "Move down by terminal rows" }
)

-- Paste replace visual selection without copying it.
keymap.set(
    "v",
    "p",
    '"_dP',
    { desc = "Paste replace visual selection without copying it" }
)

-- Reselect pasted text
keymap.set("n", "p", "p`[v`]", { desc = "Reselect pasted text after pasting" })

-- Easy insertion of a trailing ; or , from insert mode.
keymap.set("i", ";;", "<Esc>A;<Esc>", { desc = "" })
keymap.set("i", ",,", "<Esc>A,<Esc>", { desc = "" })

-- Disable annoying command line thing.
keymap.set(
    "n",
    "q:",
    ":q<CR>",
    { desc = "Disable annoying command line thing" }
)

-- Move text up and down
keymap.set("i", "<A-j>", "<Esc>:move .+1<CR>==gi", { desc = "Move text down" })
keymap.set("i", "<A-k>", "<Esc>:move .-2<CR>==gi", { desc = "Move text up" })
keymap.set("n", "<A-j>", ":move .+1<CR>==", { desc = "Move text down" })
keymap.set("n", "<A-k>", ":move .-2<CR>==", { desc = "Move text up" })
keymap.set("v", "<A-j>", ":move '>+1<CR>gv=gv", { desc = "Move text down" })
keymap.set("v", "<A-k>", ":move '<-2<CR>gv=gv", { desc = "Move text up" })

-- Disable arrow keys.
keymap.set("n", "<Up>", "<Nop>")
keymap.set("n", "<Down>", "<Nop>")
keymap.set("n", "<Left>", "<Nop>")
keymap.set("n", "<Right>", "<Nop>")

keymap.set("i", "<Up>", "<Nop>")
keymap.set("i", "<Down>", "<Nop>")
keymap.set("i", "<Left>", "<Nop>")
keymap.set("i", "<Right>", "<Nop>")

keymap.set("v", "<Up>", "<Nop>")
keymap.set("v", "<Down>", "<Nop>")
keymap.set("v", "<Left>", "<Nop>")
keymap.set("v", "<Right>", "<Nop>")
