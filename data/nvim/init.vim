set mouse=a

set autoindent    " Enable autoindenting
set tabstop=2     " Tabs display as 2 spaces
set expandtab     " Replace tabs with spaces
set shiftwidth=4
set softtabstop=2 " Indents use 2 columns

colors desert        " Choose cholorscheme
syntax on            " Enable syntax-highlighting
set wrap             " Enable wrapping
set nu               " Display line numbers

set autochdir

"  __  __                   _                 
" |  \/  | __ _ _ __  _ __ (_)_ __   __ _ ___ 
" | |\/| |/ _` | '_ \| '_ \| | '_ \ / _` / __|
" | |  | | (_| | |_) | |_) | | | | | (_| \__ \
" |_|  |_|\__,_| .__/| .__/|_|_| |_|\__, |___/
"              |_|   |_|            |___/     

" Escape insert mode whilst avoiding carpal tunnel syndrome
imap jj <ESC>
