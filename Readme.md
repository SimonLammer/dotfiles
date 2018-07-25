**This repo contains multiple settings and configuration files for several programs.**

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

[Download page][eclipse_download]

~~~shell
tar -xf eclipse*.tar.gz
eclipse-installer/eclipse-inst # Installation Folder: ~
~~~

# Firefox

## Use different GTK_THEME

[Reference][firefox_gtk_theme]

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

# Mega

[Download page][megasync_download]

Settings > Advanced > Excluded file and folder names:

- \*-local
- \*-local.\*

# [Ranger][ranger_github]

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

# Tmux 
~~~shell
sudo apt install -y tmux xclip
~~~

## [Tmux Plugin Manager][tmux_plugin_manager]

~~~shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~~~

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/tmux/.tmux.conf ~/.
~~~

# VirtualBox

[Download page][virtualbox_download]

# Visual Studio Code

[Download page][vsc_download]

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/vscode/settings.json ~/.config/Code/User/.
ln -isv ~/.dotfiles/vscode/keybindings.json ~/.config/Code/User/.
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
sudo apt install -y cowsay curl git gparted htop pm-utils ssh tmux xclip zsh
~~~

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



[Ninite](ninite)

[eclipse_download]: https://www.eclipse.org/downloads/
[dotfiles]: #dotfiles
[firefox_gtk_theme]: https://askubuntu.com/a/778388
[megasync_download]: https://mega.nz/sync
[ninite]: https://ninite.com/
[ranger_github]: https://github.com/ranger/ranger
[tmux_plugin_manager]: https://github.com/tmux-plugins/tpm
[virtualbox_download]: https://www.virtualbox.org/wiki/Downloads
[vsc_download]: https://code.visualstudio.com/download