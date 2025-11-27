local g  = vim.g
local o  = vim.o
local opt = vim.opt
local fn = vim.fn

-- Globals -----------------------------------------------------

g.have_nerd_font = false
g.netrw_liststyle = 3
g.netrw_localcopydircmd = "cp -r"
g.polyglot_disabled = { "ftdetect" }

-- Use stdpath instead of $HOME for portability
o.spellfile = fn.stdpath("config") .. "/spell/en.utf-8.add"

-- General -----------------------------------------------------

opt.exrc = true
opt.secure = true

opt.title = true
opt.titlestring = "%f // nvim"

opt.termguicolors = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.redrawtime = 10000
opt.cmdheight = 0
opt.confirm = true

-- UI / Interface ----------------------------------------------

opt.background = "dark"

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

opt.scrolloff = 8
opt.sidescrolloff = 8

opt.wrap = false
opt.linebreak = true

opt.showmode = false
opt.cursorline = true

opt.list = true
opt.listchars = {
    tab   = "» ",
    trail = "·",
    nbsp  = "␣",
}

opt.fillchars:append({
    eob   = " ",
    vert  = "▏",
    horiz = "▁",
})

opt.shortmess:append({ I = true })

opt.wildmode = "longest:full,full"

opt.mouse = "a"
opt.mousemoveevent = true

opt.hlsearch = true

-- Editing -----------------------------------------------------

opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4

opt.smartindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true

-- Use list form; easier to tweak and matches new-style options
opt.completeopt = { "menuone", "longest", "preview" }

opt.inccommand = "split"
opt.spell = true

-- Backup / Undo -----------------------------------------------

opt.backup = true
opt.backupdir:remove(".")  -- don’t pollute cwd
opt.undofile = true

-- Clipboard ---------------------------------------------------

opt.clipboard = "unnamedplus"

-- Split behavior ----------------------------------------------

opt.splitbelow = true
opt.splitright = true