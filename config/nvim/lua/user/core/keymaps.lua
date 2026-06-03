-- Leader keys -------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set
local fn = vim.fn

-- Small helper so mappings are silent by default
local function with_opts(o)
    o = o or {}
    if o.silent == nil then
        o.silent = true
    end
    return o
end

local function visual_selection()
    local _, start_row, start_col = unpack(fn.getpos("'<"))
    local _, end_row, end_col = unpack(fn.getpos("'>"))
    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

    if #lines == 0 then
        return ""
    end

    lines[#lines] = string.sub(lines[#lines], 1, end_col)
    lines[1] = string.sub(lines[1], start_col)

    return table.concat(lines, "\n")
end

local function search_visual_selection(backward)
    local selection = visual_selection()
    if selection == "" then
        return
    end

    vim.fn.setreg("/", vim.fn.escape(selection, [[\/.*$^~[]]))
    vim.opt.hlsearch = true
    vim.cmd(backward and "normal! N" or "normal! n")
end

local root_markers = { ".git", "composer.json", "*.lsn", "go.mod" }

local function has_root_marker(dir)
    for _, marker in ipairs(root_markers) do
        if marker:find("*", 1, true) then
            if #vim.fn.globpath(dir, marker, false, true) > 0 then
                return true
            end
        elseif vim.uv.fs_stat(dir .. "/" .. marker) then
            return true
        end
    end

    return false
end

local function find_project_root(start)
    local normalized = vim.fs.normalize(start)
    local stat = vim.uv.fs_stat(normalized)
    local dir = vim.fs.dirname(normalized)
    if stat and stat.type == "directory" then
        dir = normalized
    end

    while dir do
        if has_root_marker(dir) then
            return dir
        end

        local parent = vim.fs.dirname(dir)
        if parent == dir then
            break
        end
        dir = parent
    end
end

local function set_project_root()
    local name = vim.api.nvim_buf_get_name(0)
    local start = name ~= "" and name or vim.uv.cwd()
    local root = find_project_root(start)

    if not root then
        vim.notify("No project root found", vim.log.levels.WARN)
        return
    end

    vim.cmd.cd(vim.fn.fnameescape(root))
    vim.notify("Project root: " .. root, vim.log.levels.INFO)
end

local function select_range(row, start_col, end_col)
    vim.api.nvim_win_set_cursor(0, { row, start_col - 1 })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { row, end_col - 1 })
end

local function select_markup_attribute(inner)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local cursor_col = col + 1
    local line = vim.api.nvim_get_current_line()
    local search_from = 1

    while search_from <= #line do
        local name_start, equals_col =
            line:find("[%a_:][%w:_.-]*%s*=", search_from)

        if not name_start then
            break
        end

        local value_start = equals_col + 1
        while line:sub(value_start, value_start):match("%s") do
            value_start = value_start + 1
        end

        local quote = line:sub(value_start, value_start)
        local value_end
        local outer_end

        if quote == '"' or quote == "'" then
            value_end = line:find(quote, value_start + 1, true)
            if not value_end then
                break
            end
            outer_end = value_end
        else
            local next_space = line:find("[%s>]", value_start)
            outer_end = next_space and next_space - 1 or #line
            value_end = outer_end
        end

        if name_start <= cursor_col and cursor_col <= outer_end then
            if inner then
                if quote == '"' or quote == "'" then
                    value_start = value_start + 1
                    value_end = value_end - 1
                end

                select_range(row, value_start, value_end)
            else
                select_range(row, name_start, outer_end)
            end
            return
        end

        search_from = outer_end + 1
    end
end

----------------------------------------------------------------
-- Basic actions
----------------------------------------------------------------

-- Clear search highlighting.
map(
    "n",
    "<Esc>",
    "<cmd>nohlsearch<CR>",
    with_opts({ desc = "Clear search highlighting when pressing <Esc>" })
)

-- Open the current file in the default program.
map(
    "n",
    "<leader>oo",
    "<cmd>!open %<CR><CR>",
    with_opts({ desc = "Open the current file in the default program" })
)

----------------------------------------------------------------
-- Diagnostics
----------------------------------------------------------------

map(
    "n",
    "[d",
    vim.diagnostic.goto_prev,
    with_opts({ desc = "Go to previous [d]iagnostic" })
)

map(
    "n",
    "]d",
    vim.diagnostic.goto_next,
    with_opts({ desc = "Go to next [d]iagnostic" })
)

----------------------------------------------------------------
-- File navigation
----------------------------------------------------------------

-- Allow gf to open non-existent files (no need for expr mapping here).
map(
    "n",
    "gf",
    ":edit <cfile><CR>",
    with_opts({ desc = "Open file under cursor (create if needed)" })
)

----------------------------------------------------------------
-- Visual mode quality of life
----------------------------------------------------------------

-- Reselect visual selection after indenting.
map(
    "v",
    "<",
    "<gv",
    with_opts({ desc = "Reselect visual selection after indenting" })
)

map(
    "v",
    ">",
    ">gv",
    with_opts({ desc = "Reselect visual selection after indenting" })
)

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
map(
    "v",
    "y",
    "myy`y",
    with_opts({
        desc = "Maintain the cursor position when yanking a visual selection",
    })
)

map(
    "v",
    "Y",
    "myY`y",
    with_opts({
        desc = "Maintain the cursor position when yanking a visual selection",
    })
)

-- Paste replace visual selection without copying it.
map(
    "v",
    "p",
    '"_dP',
    with_opts({ desc = "Paste replace visual selection without copying it" })
)

map("x", "*", function()
    search_visual_selection(false)
end, with_opts({ desc = "Search for visual selection" }))

map("x", "#", function()
    search_visual_selection(true)
end, with_opts({ desc = "Search backward for visual selection" }))

map({ "x", "o" }, "ax", function()
    select_markup_attribute(false)
end, with_opts({ desc = "Select outer markup attribute" }))

map({ "x", "o" }, "ix", function()
    select_markup_attribute(true)
end, with_opts({ desc = "Select inner markup attribute" }))

----------------------------------------------------------------
-- Movement tweaks
----------------------------------------------------------------

-- When text is wrapped, move by display lines unless a count is provided.
map(
    "n",
    "k",
    "v:count == 0 ? 'gk' : 'k'",
    with_opts({ expr = true, desc = "Move up by display rows" })
)

map(
    "n",
    "j",
    "v:count == 0 ? 'gj' : 'j'",
    with_opts({ expr = true, desc = "Move down by display rows" })
)

-- Reselect pasted text.
map(
    "n",
    "p",
    "p`[v`]",
    with_opts({ desc = "Reselect pasted text after pasting" })
)

map("n", "[b", "<cmd>bprevious<CR>", with_opts({ desc = "Previous buffer" }))
map("n", "]b", "<cmd>bnext<CR>", with_opts({ desc = "Next buffer" }))
map(
    "n",
    "[q",
    "<cmd>cprevious<CR>",
    with_opts({ desc = "Previous quickfix item" })
)
map("n", "]q", "<cmd>cnext<CR>", with_opts({ desc = "Next quickfix item" }))
map(
    "n",
    "[e",
    "<cmd>lprevious<CR>",
    with_opts({ desc = "Previous location item" })
)
map(
    "n",
    "]e",
    "<cmd>lnext<CR>",
    with_opts({ desc = "Next location item" })
)
map("n", "<leader>pr", set_project_root, with_opts({ desc = "Set project root" }))

----------------------------------------------------------------
-- Insert mode helpers
----------------------------------------------------------------

-- Easy insertion of a trailing ; or , from insert mode.
map("i", ";;", "<Esc>A;<Esc>", with_opts({ desc = "Append ; at end of line" }))
map("i", ",,", "<Esc>A,<Esc>", with_opts({ desc = "Append , at end of line" }))

----------------------------------------------------------------
-- Misc
----------------------------------------------------------------

-- Disable annoying command line window.
map(
    "n",
    "q:",
    "<cmd>q<CR>",
    with_opts({ desc = "Disable command-line window (quit instead)" })
)

----------------------------------------------------------------
-- Move text up and down
----------------------------------------------------------------

map(
    "i",
    "<A-j>",
    "<Esc>:move .+1<CR>==gi",
    with_opts({ desc = "Move text down" })
)
map(
    "i",
    "<A-k>",
    "<Esc>:move .-2<CR>==gi",
    with_opts({ desc = "Move text up" })
)

map("n", "<A-j>", ":move .+1<CR>==", with_opts({ desc = "Move text down" }))
map("n", "<A-k>", ":move .-2<CR>==", with_opts({ desc = "Move text up" }))

map("v", "<A-j>", ":move '>+1<CR>gv=gv", with_opts({ desc = "Move text down" }))
map("v", "<A-k>", ":move '<-2<CR>gv=gv", with_opts({ desc = "Move text up" }))

-- Leave terminal mode with Esc Esc
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], {
    noremap = true,
    silent = true,
})

-- Move from terminal mode to windows/tmux panes smoothly
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { silent = true })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { silent = true })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { silent = true })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { silent = true })

----------------------------------------------------------------
-- Disable arrow keys
----------------------------------------------------------------

for _, mode in ipairs({ "n", "i", "v" }) do
    map(mode, "<Up>", "<Nop>", with_opts({ desc = "Disable arrow keys" }))
    map(mode, "<Down>", "<Nop>", with_opts({ desc = "Disable arrow keys" }))
    map(mode, "<Left>", "<Nop>", with_opts({ desc = "Disable arrow keys" }))
    map(mode, "<Right>", "<Nop>", with_opts({ desc = "Disable arrow keys" }))
end
