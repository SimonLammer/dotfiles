#!/bin/bash

echo "     _                                            _____      _               
    | |                                          /  ___|    | |              
 ___| | __ _ _ __ ___  _ __ ___   ___ _ __ ______\\ \`--.  ___| |_ _   _ _ __  
/ __| |/ _\` | '_ \` _ \\| '_ \` _ \\ / _ \\ '__|______|\`--. \\/ _ \\ __| | | | '_ \\ 
\\__ \\ | (_| | | | | | | | | | | |  __/ |         /\\__/ /  __/ |_| |_| | |_) |
|___/_|\\__,_|_| |_| |_|_| |_| |_|\\___|_|         \\____/ \\___|\\__|\\__,_| .__/ 
                                                                      | |    
                                                                      |_|    "

# http://patorjk.com/software/taag/#p=display&f=Doom&t=slammer-Setup

# Constants
workdir=/tmp/slammer-setup

# move to temporary directory
mkdir $workdir
cd $workdir

# download repo to $workdir/repo
wget -O repo.zip https://github.com/SimonLammer/dotfiles/archive/setup.zip
mkdir repo_
unzip repo.zip -d repo_
name=$(ls repo_)
mv repo_/$name repo
rmdir repo_

# install java (so gradle works)
apt-get install -y openjdk-8-jre

# check gradle version
repo/setup/gradlew --version

# remove temporary directory
rm -R $workdir