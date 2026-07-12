source $VIMRUNTIME/defaults.vim

" Automatic installation of vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Container of plugins
call plug#begin()

" List your plugins here
Plug 'joshdick/onedark.vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'mbbill/undotree'
Plug 'justinmk/vim-sneak'
Plug 'wellle/targets.vim'

call plug#end()

" Set the background variant and the colorscheme
set background=dark
colorscheme dracula

let mapleader = " "

syntax on
filetype indent on

set nocompatible
set softtabstop=2
set shiftwidth=4
set tabstop=4
set autoindent
set clipboard=unnamedplus
set number
set relativenumber
" Toggle on/off relativenumber depending on mode
augroup NumberToggle
  autocmd!
  autocmd InsertEnter * set norelativenumber
  autocmd InsertLeave * set relativenumber
augroup END

" Clear highlights
nnoremap <silent> <Esc><Esc> :noh<CR>

" Enable 24-bit RGB true color if supported by your terminal
if (has("termguicolors"))
  set termguicolors
endif

" Define folder paths
let swapdir = expand('$HOME/.vim/swp')
let undodir = expand('$HOME/.vim/undo')

" Automatically create directories if they do not exist
if !isdirectory(swapdir)
    call mkdir(swapdir, 'p', 0700)
endif

if !isdirectory(undodir)
    call mkdir(undodir, 'p', 0700)
endif

" Assign the directories to Vim settings
set directory=$HOME/.vim/swp//
set undodir=$HOME/.vim/undo//

" Enable persistent undo history
set undofile

" Toggle undo history ui
nnoremap <F5> :UndotreeToggle<cr>

" Toggle NERDTree
nnoremap <F3> :NERDTreeToggle<CR>

" Splits below :term command
set splitbelow

noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l
