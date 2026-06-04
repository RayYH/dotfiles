" Shared config for plain Vim and IdeaVim.
" Kept intentionally small — for quick edits of small files.

set nocompatible

let mapleader = " "
let maplocalleader = " "

" === Options ===
set number
set relativenumber
set ignorecase
set smartcase
set incsearch
set hlsearch
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set smartindent
set breakindent
set scrolloff=8
set sidescrolloff=8
set splitbelow
set splitright
set clipboard=unnamedplus
set mouse=a
set confirm
set nowrap
set linebreak
set showmatch
set showcmd
set hidden
set history=1000
set wildmenu
set wildmode=longest:full,full
set backspace=indent,eol,start
set shortmess+=I
set ttimeoutlen=10

" Plain Vim niceties — IdeaVim silently ignores unknown options.
silent! syntax enable
silent! filetype plugin indent on
silent! set list
silent! set listchars=tab:▸\ ,trail:·,nbsp:␣
silent! set signcolumn=yes
silent! set termguicolors
silent! set undofile

" Colorscheme — matches kitty/nvim/emacs. IdeaVim ignores :colorscheme.
silent! colorscheme tokyonight-night

" === Mappings ===

" Clear search highlighting.
nnoremap <Esc> :nohlsearch<CR>

" Reselect visual selection after indenting.
vnoremap < <gv
vnoremap > >gv

" Maintain the cursor position when yanking a visual selection.
vnoremap y myy`y
vnoremap Y myY`y

" When text is wrapped, move by terminal rows, not lines, unless a count is provided.
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')

" Paste over selection without yanking the replaced text.
vnoremap p "_dP

" Easy insertion of a trailing ; or , from insert mode.
inoremap ;; <Esc>A;<Esc>
inoremap ,, <Esc>A,<Esc>

" Disable annoying command-line window.
nnoremap q: :q<CR>

" Move lines up and down.
nnoremap <A-j> :move .+1<CR>==
nnoremap <A-k> :move .-2<CR>==
vnoremap <A-j> :move '>+1<CR>gv=gv
vnoremap <A-k> :move '<-2<CR>gv=gv

" Disable arrow keys.
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>

inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

vnoremap <Up> <Nop>
vnoremap <Down> <Nop>
vnoremap <Left> <Nop>
vnoremap <Right> <Nop>
