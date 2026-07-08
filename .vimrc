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
Plug 'ayu-theme/ayu-vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

" Enable syntax highlighting
syntax on

" Enable 24-bit RGB true color if supported by your terminal
if (has("termguicolors"))
  set termguicolors
endif

" Set the background variant and the colorscheme
set background=dark
colorscheme dracula

" Set airline theme
if exists('g:colors_name')
  let g:airline_theme = g:colors_name
else
  let g:airline_theme = 'onedark'
endif

set number
set relativenumber

set clipboard=unnamedplus
