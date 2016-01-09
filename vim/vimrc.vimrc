"              __    __    _____     __    __     ______       ____  
"              ) )  ( (   (_   _)    \ \  / /    (   __ \     / ___) 
"             ( (    ) )    | |      () \/ ()     ) (__) )   / /     
"              \ \  / /     | |      / _  _ \    (    __/   ( (      
"               \ \/ /      | |     / / \/ \ \    ) \ \  _  ( (      
"         __     \  /      _| |__  /_/      \_\  ( ( \ \_))  \ \___  
"        (__)     \/      /_____( (/          \)  )_) \__/    \____) 
"
"
" Font: Jacky - http://patorjk.com/software/taag/#p=display&f=Jacky

" Encoding
set encoding=utf-8

" GVim stuff
set guifont=Courier\ New:h13 " avoid eye cancer
set mouse=c                  " Disable mouse clicks

" Overall appearance
colors desert        " Choose cholorscheme
syntax on            " Enable syntax-highlighting
set wrap!            " Disable wrapping
set nu               " Display line numbers
set relativenumber "Display relative numbers

" Indenting
set autoindent    " Enable autoindenting
set tabstop=4     " Tabs display as 4 spaces
set expandtab     " Replace tabs with spaces
set shiftwidth=4
set softtabstop=4 " Indents use 4 columns

" Backspace
set backspace=indent,eol,start " Enable removal of indents, EOLs and starts using backspace

" Change working directory to currently opened file
set autochdir

"  _____    _____       __    __      _____     _____      __      _    _____ 
" (  __ \  (_   _)      ) )  ( (     / ___ \   (_   _)    /  \    / )  / ____\
"  ) )_) )   | |       ( (    ) )   / /   \_)    | |     / /\ \  / /  ( (___  
" (  ___/    | |        ) )  ( (   ( (  ____     | |     ) ) ) ) ) )   \___ \ 
"  ) )       | |   __  ( (    ) )  ( ( (__  )    | |    ( ( ( ( ( (        ) )
" ( (      __| |___) )  ) \__/ (    \ \__/ /    _| |__  / /  \ \/ /    ___/ / 
" /__\     \________/   \______/     \____/    /_____( (_/    \__/    /____/  
                                                                             
" Pathogen
execute pathogen#infect()

" Powerline
set laststatus=2 " Show powerline

" NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif " close window instead of maximizing nerdtree

"   __    __      ____    _____  _____  _____     __      _   _____    _____  
"   \ \  / /     (    )  (  __ \(  __ \(_   _)   /  \    / ) / ___ \  / ____\ 
"   () \/ ()     / /\ \   ) )_) )) )_) ) | |    / /\ \  / / / /   \_)( (___   
"   / _  _ \    ( (__) ) (  ___/(  ___/  | |    ) ) ) ) ) )( (  ____  \___ \  
"  / / \/ \ \    )    (   ) )    ) )     | |   ( ( ( ( ( ( ( ( (__  )     ) ) 
" /_/      \_\  /  /\  \ ( (    ( (     _| |__ / /  \ \/ /  \ \__/ /  ___/ /  
"(/          \)/__(  )__\/__\   /__\   /_____((_/    \__/    \____/  /____/   

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
