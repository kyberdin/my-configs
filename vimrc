" Can also be set as $PLUGGED, but don't rely on that. Bad things can happen
" if the directory doesn't already exist.
call plug#begin('$HOME/.vim/plugged')

" Colorschemes
Plug 'morhetz/gruvbox'

" Main Plugins
Plug 'easymotion/vim-easymotion'

Plug 'junegunn/fzf'

call plug#end()

let g:pymode_python = 'python'

set fileformat=unix
set clipboard=unnamedplus
set laststatus=1

" for fuzzy finder
set rtp+=$FZF

" ui
syntax enable
set nu
set ruler
set wildmenu
set mouse=a
set scrolloff=3
set colorcolumn=80

" Indentation
set tabstop=8
set shiftwidth=8
set expandtab
set autoindent
set smartindent
set cindent
set cinoptions=>1s
filetype plugin indent on
filetype plugin on

" Set 2-space indentation for YAML files
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2

" Set 8-space indentation for C/C++ files
autocmd FileType c setlocal shiftwidth=8 tabstop=8
autocmd FileType cpp setlocal shiftwidth=8 tabstop=8

" Set 3-space indentation for restructuredText files
autocmd FileType rst setlocal shiftwidth=3 tabstop=3

" Wrap Git Commmit messages at 70 characters
au FileType gitcommit set tw=70

" encoding
set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,iso-8859-1

" english
set langmenu=en_US.UTF8
let $LANG = 'en_US'
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
set hlsearch
highlight Search ctermbg=LightBlue

" GUI Options and Colorscheme
" Change Row/Column to match terminal settings
" set lines=55 columns=110 " laptop
" set lines=72 columns=125 " desktop
colorscheme gruvbox
set guifont=Consolas:h11
set background=dark
highlight ColorColumn ctermbg=black

" Disable cursor blinking
set guicursor+=n-v-c:blinkon0
" fix backspace between lines bug
set backspace=indent,eol,start
" trailing whitespace is evil
highlight WhitespaceEOL ctermbg=red
match WhitespaceEOL /\s\+$/
set noswapfile

" Plugin - Easymotion
let g:EasyMotion_do_mapping = 0 "Disable default mappings
nmap \ :noh<cr>
" Turn on case-sensitive feature
let g:EasyMotion_smartcase = 1
map / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" Plugin - FZF
" Shrink fzf window size
let g:fzf_layout = { 'down': '~20%' }
" Give fzf its own window (Neovim only)
"let g:fzf_layout = { 'window': '-tabnew' }
" Search without respecting VCS ignores
command! -bang FZFnoVCS
    \ call fzf#run(fzf#wrap('fzf-no-vcs', {'source': 'fd -L --type f --no-ignore-vcs'}, <bang>0))
" Search while respecting VCS ignores
command! -bang FZFwVCS
    \ call fzf#run(fzf#wrap('fzf-w-vcs', {'source': 'fd -L --type f'}, <bang>0))

" Key Remapping
nnoremap <C-p> :FZFwVCS<CR>
nnoremap <C-i> :FZFnoVCS<CR>

nnoremap <C-j> :tabprevious<CR>
nnoremap <C-k> :tabnext<CR>

" Removing trailing whitespace from file
nnoremap <C-w> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

let mapleader="\<Space>"
