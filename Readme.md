**This repo contains multiple settings and configuration files for several programs.**

ASCII art fonts were created using:
- http://patorjk.com/software/taag/#p=display&f=Epic&t=github.com%2FSimonLammer%2Fdotfiles
- http://patorjk.com/software/taag/#p=display&f=Ivrit&t=github.com%2FSimonLammer%2Fdotfiles

Below is a collection of wisdom, useful for setting up computers.

---

# Hibernate

[Reference](http://chriseiffel.com/uncategorized/step-by-step-how-to-get-hibernate-working-for-linux-ubuntu-11-04-mint-11/)
[Reference 2](http://ubuntuhandbook.org/index.php/2017/10/enable-hibernate-ubuntu-17-10/)

Ensure there is enough swap space.
~~~shell
free -m
~~~

~~~shell
sudo apt install -y pm-utils
~~~

Use ```sudo pm-hibernate``` to hibernate. (Does not request password when resuming!)

~~~shell
sudo sed -Ei '/^\[Disable hibernate/,/^$/ {s/^\[Disable hibernate .* (in)/[Enable hibernate \1/; s/^(ResultActive=)no/\1yes/}' /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
echo -e '\n[Re-enable hibernate for multiple users by default in logind]\nIdentity=unix-user:*\nAction=org.freedesktop.login1.hibernate-multiple-sessions\nResultActive=yes' | sudo tee -a /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
~~~

## [Gnome extension](https://extensions.gnome.org/extension/755/hibernate-status-button/)

# Mount disks

~~~shell
sudo mkdir /disks
~~~

~~~shell
# find the device with 'sudo fdisk -l'
dev=/dev/sda2
target=/disks/main

mkdir -p $target
sudo blkid | grep "^$dev" -m 1 | sed -E 's@.* UUID=\"([^"]+).* TYPE="([^"]+).*@# '$dev'\nUUID=\1 '$target' \2@' | sudo tee -a /etc/fstab
~~~

---

# Eclipse

[Download page](https://www.eclipse.org/downloads/)

~~~shell
tar -xf eclipse*.tar.gz
eclipse-installer/eclipse-inst # Installation Folder: ~
~~~

## Create a .desktop file to launch eclipse

[Reference](https://askubuntu.com/questions/418407/how-do-i-create-a-desktop-file-to-launch-eclipse)

~~~
Name=Eclipse
Comment=Eclipse
Exec=/home/user/eclipse/eclipse
Icon=/home/user/eclipse/icon.xpm
Terminal=false
Type=Application
Categories=
~~~

# Firefox

## Use different GTK_THEME

[Reference](https://askubuntu.com/a/778388)

~~~ shell
sudo sed -Ei '/export MOZ_APP_LAUNCHER/a\\n# Use specific GTK_THEME instead of system default\nGTK_THEME=Adwaita:light\nexport GTK_THEME' /usr/lib/firefox/firefox.sh
~~~

# Git

~~~shell
sudo apt install -y git
~~~

## Dotfiles

~~~shell
git clone https://github.com/SimonLammer/dotfiles ~/.dotfiles
~~~

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/git/.gitconfig ~/.
~~~

# Gnome Shell

~~~shell
sudo apt-get install chrome-gnome-shell
~~~

# Java

~~~shell
sudo apt install -y openjdk-8-jdk openjdk-8-doc
~~~

# Lutris

*I like the idea, but it didn't work for me, so I'll stay on [Play on Linux](#Play-on-Linux) for now*

[Reference](https://lutris.net/downloads/)

# Mega

[Download page](https://mega.nz/sync)

Settings > Advanced > Excluded file and folder names:

- \*-local
- \*-local.\*

# Play on Linux

~~~shell
sudo apt install -y playonlinux
~~~

## Move ```~/.PlayOnLinux``` to current directory (on other partition)

~~~shell
# cd /disks/main/$(whoami)/programs/
mv ~/.PlayOnLinux ./PlayOnLinux
ln -s $(pwd)/PlayOnLinux ~/.PlayOnLinux
~~~

## Steam (within POL)

### Error: Content Servers Unreachable

[Reference](https://www.reddit.com/r/wine_gaming/comments/8r0gh6/steam_in_winedevel_content_servers_unreachable/)

Open Shell via wine:
~~~shell
sed -iE "$(grep -nm 1 CM "Program Files/Steam/config/config.vdf" | cut -d: -f 1)"' a\\t\t\t\t"CS"\t\t"valve511.steamcontent.com;valve501.steamcontent.com;valve517.steamcontent.com;valve557.steamcontent.com;valve513.steamcontent.com;valve535.steamcontent.com;valve546.steamcontent.com;valve538.steamcontent.com;valve536.steamcontent.com;valve530.steamcontent.com;valve559.steamcontent.com;valve545.steamcontent.com;valve518.steamcontent.com;valve548.steamcontent.com;valve555.steamcontent.com;valve556.steamcontent.com;valve506.steamcontent.com;valve544.steamcontent.com;valve525.steamcontent.com;valve567.steamcontent.com;valve521.steamcontent.com;valve510.steamcontent.com;valve542.steamcontent.com;valve519.steamcontent.com;valve526.steamcontent.com;valve504.steamcontent.com;valve500.steamcontent.com;valve554.steamcontent.com;valve562.steamcontent.com;valve524.steamcontent.com;valve502.steamcontent.com;valve505.steamcontent.com;valve547.steamcontent.com;valve560.steamcontent.com;valve503.steamcontent.com;valve507.steamcontent.com;valve553.steamcontent.com;valve520.steamcontent.com;valve550.steamcontent.com;valve531.steamcontent.com;valve558.steamcontent.com;valve552.steamcontent.com;valve563.steamcontent.com;valve540.steamcontent.com;valve541.steamcontent.com;valve537.steamcontent.com;valve528.steamcontent.com;valve523.steamcontent.com;valve512.steamcontent.com;valve532.steamcontent.com;valve561.steamcontent.com;valve549.steamcontent.com;valve522.steamcontent.com;valve514.steamcontent.com;valve551.steamcontent.com;valve564.steamcontent.com;valve543.steamcontent.com;valve565.steamcontent.com;valve529.steamcontent.com;valve539.steamcontent.com;valve566.steamcontent.com;valve165.steamcontent.com;valve959.steamcontent.com;valve164.steamcontent.com;valve1611.steamcontent.com;valve1601.steamcontent.com;valve1617.steamcontent.com;valve1603.steamcontent.com;valve1602.steamcontent.com;valve1610.steamcontent.com;valve1615.steamcontent.com;valve909.steamcontent.com;valve900.steamcontent.com;valve905.steamcontent.com;valve954.steamcontent.com;valve955.steamcontent.com;valve1612.steamcontent.com;valve1607.steamcontent.com;valve1608.steamcontent.com;valve1618.steamcontent.com;valve1619.steamcontent.com;valve1606.steamcontent.com;valve1605.steamcontent.com;valve1609.steamcontent.com;valve907.steamcontent.com;valve901.steamcontent.com;valve902.steamcontent.com;valve1604.steamcontent.com;valve908.steamcontent.com;valve950.steamcontent.com;valve957.steamcontent.com;valve903.steamcontent.com;valve1614.steamcontent.com;valve904.steamcontent.com;valve952.steamcontent.com;valve1616.steamcontent.com;valve1613.steamcontent.com;valve958.steamcontent.com;valve956.steamcontent.com;valve906.steamcontent.com"' "Program Files/Steam/config/config.vdf"
~~~

# Python

[Download page](https://www.python.org/getit/)

[Reference](https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-ubuntu-16-04)
~~~shell
sudo apt install -y python3-pip build-essential libssl-dev libffi-dev python-dev
~~~

## pipenv

[Reference](https://packaging.python.org/tutorials/managing-dependencies/#managing-dependencies)

~~~shell
pip3 install --user pipenv
~~~

# [Ranger](https://github.com/ranger/ranger)

~~~shell
sudo apt install -y ranger
~~~

# SSH

~~~shell
sudo apt install -y ssh
~~~

## [Generate a SSH key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key)

~~~shell
ssh-keygen -t rsa -b 4096 -C "lammer.simon@gmail.com"
~~~

## [SSH Agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#adding-your-ssh-key-to-the-ssh-agent)

~~~shell
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
~~~

## Add SSH Key

~~~shell
xclip -sel clip < ~/.ssh/id_rsa.pub
~~~

~~~bat
type %userprofile%\.ssh\id_rsa.pub | clip
~~~

- [Github](https://github.com/settings/ssh/new)\
  https://help.github.com/articles/github-s-ssh-key-fingerprints/

- [Gitlab](https://gitlab.com/profile/keys)\
  https://docs.gitlab.com/ee/user/gitlab_com/#ssh-host-keys-fingerprints

# Steam

## Can't launch

[Reference](https://askubuntu.com/questions/962737/steam-not-opening-tar-this-does-not-look-like-a-tar-archive#1018230)

Output of ```steam```:
~~~shell
tar: This does not look like a tar archive
xz: (stdin): File format not recognized
tar: Child returned status 1
tar: Error is not recoverable: exiting now
find: ‘/home/slammer/.steam/ubuntu12_32/steam-runtime’: No such file or directory
~~~

To fix this, create the folder mentioned:
~~~shell
mkdir ~/.steam/ubuntu12_32/steam-runtime
~~~

# Tmux 
~~~shell
sudo apt install -y tmux xclip
~~~

## [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

~~~shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~~~

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/tmux/.tmux.conf ~/.
~~~

# VIM

~~~shell
sudo apt install -y vim
~~~

## [vim-plug](https://github.com/junegunn/vim-plug)

The plugin manager will be installed automatically from the ```.vimrc```.

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/vim/.vimrc ~/.
~~~

# VirtualBox

[Download page](https://www.virtualbox.org/wiki/Downloads)

# Visual Studio Code

[Download page](https://code.visualstudio.com/download)

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/vscode/settings.json ~/.config/Code/User/.
~~~

## Install Extensions

~~~shell
for ext in \
  'coenraads.bracket-pair-colorizer'\
  'Gruntfuggly.activitusbar'
  'kenhowardpdx.vscode-gist'\
  'ms-python.python'\
  'ms-vscode.cpptools'\
  'vscodevim.vim'\
;do code --install-extension $ext; done
~~~

# ZSH

~~~shell
sudo apt install -y zsh
~~~

## [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh)

~~~shell
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
~~~

### [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)
~~~shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
~~~

**Logout to update default shell**

## Link [dotfiles]:

~~~shell
ln -isv ~/.dotfiles/zsh/.zshrc ~/.
~~~

---

~~~shell
sudo apt install -y \
  cowsay\
  curl\
  git\
  gparted\
  htop\
  openjdk-8-jdk openjdk-8-doc\
  pm-utils\
  python3-pip build-essential libssl-dev libffi-dev python-dev\
  ssh\
  tmux\
  xclip\
  vim\
  zsh
~~~

[Ninite](https://ninite.com/)

---

# TODO

- Anki
- Firefox
  - Informative default page
- GParted
  - Use light theme
- Latex
  - md -> latex
- Lutris
  - Skyrim
    - Mods
- SSH
  - Login with key instead of password
    - Add key of localhost
- ? Powerline font
  - Tmux powerline theme



[dotfiles]: #dotfiles