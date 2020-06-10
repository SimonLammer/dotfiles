#     _______  _______           _______  _______ 
#    / ___   )(  ____ \|\     /|(  ____ )(  ____ \
#    \/   )  || (    \/| )   ( || (    )|| (    \/
#        /   )| (_____ | (___) || (____)|| |      
#       /   / (_____  )|  ___  ||     __)| |      
#      /   /        ) || (   ) || (\ (   | |      
#  _  /   (_/\/\____) || )   ( || ) \ \__| (____/\
# (_)(_______/\_______)|/     \||/   \__/(_______/
#                                                 

# Source ~/.profile if it exists
# https://superuser.com/a/398990
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export PATH=/usr/local/cuda-10.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64:$LD_LIBRARY_PATH

# Path to your oh-my-zsh installation.
export ZSH=$(echo $HOME)/.oh-my-zsh

# tmux
ZSH_TMUX_AUTOSTART=false # will be started at the bottom

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
if [ -z "$TMUX" ]; then
  ZSH_THEME="mortalscumbag"
else
  ZSH_THEME="nothing"
fi

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=4

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  autojump
  command-not-found
  common-aliases
  dirhistory
  encode64
  git
  #ssh-agent
  sudo
  tmux
  zsh-autosuggestions
)
# Remove tmux plugin if tmux is not installed
which tmux >/dev/null 2>&1
if [ $? -ne 0 ]; then
  plugins=$(echo $plugins | sed -E 's/ ?tmux//g')
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# Load aliases
[[ -e ~/.dotfiles/data/shell/alias.sh ]] && emulate sh -c 'source ~/.dotfiles/data/shell/alias.sh'

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code -nw'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias cdl="source ~/.dotfiles/data/zsh/cdl.sh $@"
alias jl="source ~/.dotfiles/data/zsh/jl.sh $@"

# Spark
if [ -d "/opt/spark" ]; then
  export SPARK_HOME=/opt/spark
  export PATH="$PATH:$SPARK_HOME/bin"
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
if [ -d "$HOME/.rvm/bin" ]; then
  export PATH="$PATH:$HOME/.rvm/bin"
fi

