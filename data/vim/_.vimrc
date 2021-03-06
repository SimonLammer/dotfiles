"          _________ _______  _______  _______ 
" |\     /|\__   __/(       )(  ____ )(  ____ \
" | )   ( |   ) (   | () () || (    )|| (    \/
" | |   | |   | |   | || || || (____)|| |      
" ( (   ) )   | |   | |(_)| ||     __)| |      
"  \ \_/ /    | |   | |   | || (\ (   | |      
"  _\   /  ___) (___| )   ( || ) \ \__| (____/\
" (_)\_/   \_______/|/     \||/   \__/(_______/
"                                             

" GVim stuff
set guifont=Courier\ New:h13 " Avoid eye cancer
set mouse=c                  " Disable mouse clicks

" Overall appearance
colors desert        " Choose cholorscheme
syntax on            " Enable syntax-highlighting
set wrap             " Enable wrapping
set nu               " Display line numbers
set relativenumber "Display relative numbers

" Indenting
set autoindent    " Enable autoindenting
set tabstop=2     " Tabs display as 2 spaces
set expandtab     " Replace tabs with spaces
set shiftwidth=4
set softtabstop=2 " Indents use 2 columns

" Change working directory to currently opened file
set autochdir

"  ____  _             _           
" |  _ \| |_   _  __ _(_)_ __  ___ 
" | |_) | | | | |/ _` | | '_ \/ __|
" |  __/| | |_| | (_| | | | | \__ \
" |_|   |_|\__,_|\__, |_|_| |_|___/
"                |___/             

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'kristijanhusak/vim-hybrid-material'
call plug#end()

let g:enable_bold_font = 1
set background=dark
colorscheme hybrid_reverse

"  __  __                   _                 
" |  \/  | __ _ _ __  _ __ (_)_ __   __ _ ___ 
" | |\/| |/ _` | '_ \| '_ \| | '_ \ / _` / __|
" | |  | | (_| | |_) | |_) | | | | | (_| \__ \
" |_|  |_|\__,_| .__/| .__/|_|_| |_|\__, |___/
"              |_|   |_|            |___/     

" Escape insert mode whilst avoiding carpal tunnel syndrome
imap jj <ESC>

" Change leader
let mapleader=","
no  <leader> <Nop>
"ino <leader> <Nop>
vno <leader> <Nop>

" Plugin bindings
no <leader>n :NERDTreeToggle<cr>

" Disable arrow keys
"no  <up>    <Nop>
"no  <left>  <Nop>
"no  <down>  <Nop>
"no  <right> <Nop>
"ino <up>    <Nop>
"ino <left>  <Nop>
"ino <down>  <Nop>
"ino <right> <Nop>
"vno <up>    <Nop>
"vno <left>  <Nop>
"vno <down>  <Nop>
"vno <right> <Nop>

" Quick pairs
imap <leader>' ''<ESC>i
imap <leader>" ""<ESC>i
imap <leader>{ {}<ESC>i
imap <leader>[ []<ESC>i
imap <leader>( ()<ESC>i
imap <leader>< <><ESC>i

" Replace word with true / false
imap <leader>t ciwtrue<ESC>b
imap <leader>f ciwfalse<ESC>b

" Insert space after cursor
nmap <leader><Space> a <ESC>

" Curly braces
imap <leader>{ {<CR>}<ESC>O