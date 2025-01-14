local g = vim.g
g.have_nerd_font = false
g.netrw_liststyle = 3
g.netrw_localcopydircmd = "cp -r"
g.polyglot_disabled = { "ftdetect" }

-- Set the spellfile to the custom dictionary.
vim.o.spellfile = os.getenv("HOME") .. "/.config/nvim/spell/en.utf-8.add"

local opt = vim.opt

-- General Settings
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

-- Interface
opt.background = "dark"
opt.number = true
opt.hidden = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.linebreak = true
opt.showmode = false
opt.wrap = false
opt.fillchars:append({ eob = " ", vert = "▏", horiz = "▁" })
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.shortmess:append({ I = true })
opt.wildmode = "longest:full,full"
opt.mouse = "a"
opt.mousemoveevent = true
opt.hlsearch = true

-- Editing
opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.smartindent = true
opt.breakindent = true
opt.smartcase = true
opt.ignorecase = true
opt.completeopt = "menuone,longest,preview"
opt.inccommand = "split"
opt.spell = true
opt.cursorline = true

-- Backup and Undo
opt.backup = true
opt.backupdir:remove(".")
opt.undofile = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Split Behavior
opt.splitbelow = true
opt.splitright = true
