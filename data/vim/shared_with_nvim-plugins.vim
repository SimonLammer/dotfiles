"    _  _        _            _________ _______ 
"   / )( (    /|( \  |\     /|\__   __/(       )
"  / / |  \  ( | \ \ | )   ( |   ) (   | () () |
" ( (  |   \ | |  ) )| |   | |   | |   | || || |    ____  _             _           
" | |  | (\ \) |  | |( (   ) )   | |   | |(_)| |   |  _ \| |_   _  __ _(_)_ __  ___ 
" ( (  | | \   |  ) ) \ \_/ /    | |   | |   | |   | |_) | | | | |/ _` | | '_ \/ __|
"  \ \ | )  \  | / /   \   /  ___) (___| )   ( |   |  __/| | |_| | (_| | | | | \__ \
"   \_)|/    )_)(_/     \_/   \_______/|/     \|   |_|   |_|\__,_|\__, |_|_| |_|___/
"                                                                 |___/             

if has('nvim')
  let MYVIMDIR = "$HOME/.config/dotfiles/data/nvim"
else
  let MYVIMDIR = "$HOME/.config/dotfiles/data/vim"
endif
if empty(glob(MYVIMDIR . '/autoload/plug.vim'))
  silent !curl -fLo $MYVIMDIR/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'vim-scripts/RltvNmbr.vim'
Plug 'flazz/vim-colorschemes'
if has('nvim')
  Plug 'rbgrouleff/bclose.vim' " Required for 'franoiscabrol/ranger.vim' in nvim
endif
Plug 'francoiscabrol/ranger.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'Glench/Vim-Jinja2-Syntax'
call plug#end()
    
" Other Plugins I might want to checkout sometime:
" junegunn/fzf.vim
" thaerkh/vim-workspace
" ms-jpq/coq-nvim
" preservim/tagbar


let g:enable_bold_font = 1
set background=dark
"call RltvNmbr#RltvNmbrCtrl(1)
colorscheme gruvbox


"  __  __                   _                 
" |  \/  | __ _ _ __  _ __ (_)_ __   __ _ ___ 
" | |\/| |/ _` | '_ \| '_ \| | '_ \ / _` / __|
" | |  | | (_| | |_) | |_) | | | | | (_| \__ \
" |_|  |_|\__,_| .__/| .__/|_|_| |_|\__, |___/
"              |_|   |_|            |___/     

