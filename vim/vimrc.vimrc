" GVim stuff
set guifont=Courier\ New:h13
set mouse=c                  " Disable mouse clicks

" Overall appearance
colors desert    " Choose cholorscheme
syntax on        " Enable syntax-highlighting
set wrap!        " Disable wrapping
set nu           " Display line numbers

" Indenting
set autoindent    " Enable autoindenting
set tabstop=4     " Tabs display as 4 spaces
set expandtab     " Replace tabs with spaces
set shiftwidth=4
set softtabstop=4 " Indents use 4 columns

" Backspace
set backspace=indent,eol,start " Enable removal of indents, EOLs and starts using backspace

" Disable arrow keys
no  <up>    <Nop>
no  <left>  <Nop>
no  <down>  <Nop>
no  <right> <Nop>
ino <up>    <Nop>
ino <left>  <Nop>
ino <down>  <Nop>
ino <right> <Nop>
vno <up>    <Nop>
vno <left>  <Nop>
vno <down>  <Nop>
vno <right> <Nop>

" Change leader
let mapleader="#"

" Quick pairs
imap <leader>' ''<ESC>i
imap <leader>" ""<ESC>i
imap <leader>{ {}<ESC>i
imap <leader>[ []<ESC>i
imap <leader>( ()<ESC>i
imap <leader>< <><ESC>i

" Simple escape from insert mode
ino <leader>e <ESC>
no <leader>e <Nop>

" Pathogen
execute pathogen#infect()
