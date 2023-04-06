**This repo contains multiple settings and configuration files for several programs.**

ASCII art fonts were created using:
- http://patorjk.com/software/taag/#p=display&f=Epic&t=github.com%2FSimonLammer%2Fdotfiles
- http://patorjk.com/software/taag/#p=display&f=Ivrit&t=github.com%2FSimonLammer%2Fdotfiles

Below is a collection of wisdom, useful for setting up computers.

# Usage

1. Install git and clone repo:

    ~~~
    sudo apt install -y git && git clone git@github.com:SimonLammer/dotfiles.git ~/.dotfiles
    ~~~

2. Perform ansible magic:

    ~~~
    make setup
    ~~~

    or

    ~~~
    ansible-galaxy install -r requirements.yml
    ansible-playbook setup.yml -e 'ansible_python_interpreter=/usr/bin/python3' -u slammer
    ~~~

3. Remaining setup

    - Programs not yet installed automatically

        - [Mega](#mega)

---

# System setup

## Partitioning

~~~
+---------------+ +----------------+ +--------------------------------------------------------+
| EFI partition | | Boot partition | | Logical volume 1 | Logical volume 2 | Logical volume 3 |
|               | |                | |                  |                  |                  |
| [EFI]         | | /boot          | | [SWAP]           | /                | /disks/main      |
|               | |                | |                  |                  |                  |
| fat32         | | ext4           | | [swap]           | ext4             | ext4             |
|               | |                | |                  |                  |                  |
| 500 MiB       | | 500 MiB        | |  20 GiB          | 35 GiB           | <Rest>           |
|               | |                | |                  |                  |                  |
|               | |                | | /dev/luks/swap   | /dev/luks/root   | /dev/luks/data   |
|               | |                | +------------------+------------------+------------------+
|               | |                | |             LUKS2 encrypted partition                  |
| /dev/sda1     | | /dev/sda2      | |                    /dev/sda3                           |
+---------------+ +----------------+ +--------------------------------------------------------+
~~~

### LUKS setup

~~~
cryptsetup luksFormat /dev/sda3
cryptsetup open /dev/sda3 luks
~~~

#### Wipe partition

~~~
sudo cryptsetup open --type plain -d /dev/urandom /dev/sda3 luks
sudo dd if=/dev/zero of=/dev/mapper/luks status=progress
sudo cryptsetup close luks
~~~

#### LVM (on LUKS) setup

~~~
pvcreate /dev/mapper/luks
vgcreate luks /dev/mapper/luks
lvcreate -n swap -L 20G luks
lvcreate -n root -L 35G luks
lvcreate -n data -L 1.7T luks
~~~

#### Backup LUKS header

~~~shell
sudo cryptsetup luksHeaderBackup /dev/sdaX --header-backup-file /path/to/new_backup_file
~~~

References:
- https://www.cyberciti.biz/security/how-to-backup-and-restore-luks-header-on-linux/

## Install OS

| Device                | Usage | Filesystem |
|:----------------------|:------|:----------:|
| /dev/sda1             | EFI   | fat32      |
| /dev/sda2             | /boot | ext4       |
| /dev/mapper/luks-root | /     | ext4       |
| /dev/mapper/luks-swap | swap  | swap       |


## Configure GRUB

### Chroot into new installation

~~~
mount /dev/luks/root /mnt
mount /dev/sda2 /mnt/boot
mount /dev/sda1 /mnt/boot/efi
for fs in proc sys dev dev/pts run etc/resolv.conf; do mount --bind /$fs /mnt/$fs; done
chroot /mnt
~~~

### Edit `/etc/default/grub`:
~~~
GRUB_CMDLINE_LINUX="cryptdevice=UUID=<UUID of /dev/sda3>"
~~~

~~~
update-grub
~~~

### Edit `/etc/crypttab`:

~~~
# <target name> <source device> <key file> <options>
luks UUID=<UUID of /dev/sda3> none luks,discard
~~~

~~~
update-initramfs -ck all
~~~

*Obtain UUIDs via `sudo blkid`.*

## eCryptfs

*Not necessary with FDE.*

### Encrypt existing home directory

*Run this as another user*
~~~
ecryptfs-migrate-home -u user_to_migrate
~~~

### Manually decrypt directory

~~~
ecryptfs-recover-private path/to/.Private
~~~

# Fonts

## Installation

Copy the font files to `/usr/share/fonts/<some-awesome-font>/*.otf`

## [NerdFonts](https://www.nerdfonts.com/#home)

[Anonymous Pro](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/AnonymousPro/complete)

Other candidates I liked:
- FantasqueSansMono Nerd Font
- FiraMono Nerd Font
- Hasklug Nerd Font
- Hurmit Nerd Font
- Monoid Nerd Font
- Mononoki Nerd Font
- RobotoMono Nerd Font
- Sauce Code Pro Nerd Font

Others I've used:
- [CodeNewRoman Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CodeNewRoman.zip)

### Patch fonts

~~~
docker run -v `pwd`:/in -v `pwd`/patched:/out nerdfonts/patcher -c
~~~

References:
- https://github.com/ryanoasis/nerd-fonts#font-patcher

# LVM2 Snapshots

*(run as root)*
~~~
lvcreate -L 100M -n original vg
mkfs.ext4 /dev/vg/original
mkdir /mnt/original
mount /dev/vg/original /mnt/original
echo "This is the content of a file." > /mnt/original/file.txt

lvcreate -L 12M -s /dev/vg/original -n snap vg
mkdir /mnt/snapshot
mount /dev/vg/snap /mnt/snapshot
cat /mnt/snapshot/file.txt # This is the content of a file.

echo "With a 2nd line." >> /mnt/original/file.txt
diff /mnt/original/file.txt /mnt/snapshot/file.txt
# 2d1
# < With a 2nd line.

umount /mnt/original /mnt/snapshot

lvconvert --merge /dev/vg/snap
# Merging of volume vg/snap started.
# vg/original: Merged: 100,00%
~~~

[Reference](https://www.theurbanpenguin.com/maning-lvm-snapshots/)

# Grub

[Reference](http://tipsonubuntu.com/2018/03/11/install-grub-customizer-ubuntu-18-04-lts/)

~~~
sudo add-apt-repository ppa:danielrichter2007/grub-customizer
sudo apt-get update
sudo apt-get install grub-customizer
~~~

# Hibernate

[Reference](http://chriseiffel.com/uncategorized/step-by-step-how-to-get-hibernate-working-for-linux-ubuntu-11-04-mint-11/)
[Reference 2](http://ubuntuhandbook.org/index.php/2017/10/enable-hibernate-ubuntu-17-10/)
[Reference 3](https://ubuntuforums.org/showthread.php?t=2391841)

Ensure there is enough swap space.
~~~shell
free -m
~~~

Add `resume=UUID=b59dd444-58f7-4fc9-90eb-eaa27dcec7e6` to `/etc/default/grub` in the line starting with `GRUB_CMDLINE_LINUX=` and run `sudo update-grub`

~~~shell
sudo apt install -y pm-utils
~~~

Use ```sudo pm-hibernate``` to hibernate. (Does not request password when resuming!)

~~~shell
sudo sed -Ei '/^\[Disable hibernate/,/^$/ {s/^\[Disable hibernate .* (in)/[Enable hibernate \1/; s/^(ResultActive=)no/\1yes/}' /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
echo -e '\n[Re-enable hibernate for multiple users by default in logind]\nIdentity=unix-user:*\nAction=org.freedesktop.login1.hibernate-multiple-sessions\nResultActive=yes' | sudo tee -a /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
~~~

## [Gnome extension](https://extensions.gnome.org/extension/755/hibernate-status-button/)

# KDE

## Linux Mint 19.3

[Reddit installation thread](https://www.reddit.com/r/linuxmint/comments/eq9hr7/unable_to_install_kde_plamsa_on_mint_cinnamon/)

# Limit ```/var/log/journal``` size

[Reference](https://bbs.archlinux.org/viewtopic.php?id=172399)

Edit ```/etc/systemd/journald.conf``` like so:
~~~
[Journal]
SystemMaxUse=500M
RuntimeMaxUse=200M
~~~

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

## Bind mount home directories (Move home directories to other drive)

[Reference 1](https://www.tecmint.com/move-home-directory-to-new-partition-disk-in-linux/)
[Reference 2](https://askubuntu.com/questions/550348/how-to-make-mount-bind-permanent)

Create a backup:
```
sudo mkdir /disks/main/home-backup
sudo rsync -av /home/* /disks/main/home-backup
```

Move /home/* to /disks/main/home/*:
```
sudo mkdir /disks/main/home
sudo rsync -ah --progress /disks/main/home-backup/* /disks/main/home
sudo rm -Rf /home/*
echo '/disks/main/home /home none bind 0 0' | sudo tee -a /etc/fstab
```

Remove backup **after making sure everything works**:
```
sudo rm -Rf /disks/main/home-backup
```

# "Open Folder" uses wrong application

Application:
- System settings > MIME Type Editor
- System settings > Default Applications

Setting: `directory/inode`

References:
- https://superuser.com/questions/1512714/transmission-right-click-open-folder-opens-xfburn-instead-of-thunar

# SSD

[Increase Performance and lifespan of SSDs & SD Cards](https://haydenjames.io/increase-performance-lifespan-ssds-sd-cards/)

# Systemd

## Speed up boot by disabling services

[Reference](https://www.maketecheasier.com/make-linux-boot-faster/)

~~~
systemd-analyze blame
systemd-analyze critical-chain
~~~

# Unity

## Tweak tool

[Reference](https://ubuntoid.com/install-unity-tweak-tool-ubuntu-16-04/)
~~~shell
sudo apt install -y unity-tweak-tool
~~~

# Gnome shell

## Extensions

### [gnome-shell-extension-installer](https://github.com/brunelli/gnome-shell-extension-installer)

~~~
wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
chmod +x gnome-shell-extension-installer
mv gnome-shell-extension-installer /usr/bin/
~~~

~~~
gnome-shell-extension-installer 15 1160 1236 1267 8 352 906 1112 826 --restart-shell
~~~

- [AlternateTab](https://extensions.gnome.org/extension/15/alternatetab/): `15`
- [Dash to Panel](https://extensions.gnome.org/extension/1160/dash-to-panel/): `1160`
- [NoAnnoyance](https://extensions.gnome.org/extension/1236/noannoyance/): `1236`
- [No Title Bar](https://extensions.gnome.org/extension/1267/no-title-bar/): `1267`
- [Places  Status Indicator](https://extensions.gnome.org/extension/8/places-status-indicator/): `8`
- [Quick Close in Overview](https://extensions.gnome.org/extension/352/middle-click-to-close-in-overview/): `352`
- [Sound Input & Output Device Chooser](https://extensions.gnome.org/extension/906/sound-output-device-chooser/): `906`
- [Screenshot Tool](https://extensions.gnome.org/extension/1112/screenshot-tool/): `1112`
- [Suspend Button](https://extensions.gnome.org/extension/826/suspend-button/): `826`

### Configuring extensions

~~~
# Night light color temperature
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4800

# Dash-to-Panel
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas set org.gnome.shell.extensions.dash-to-panel panel-position 'TOP'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas set org.gnome.shell.extensions.dash-to-panel panel-size 24
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas set org.gnome.shell.extensions.dash-to-panel appicon-padding 0
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas set org.gnome.shell.extensions.dash-to-panel appicon-margin 0
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas set org.gnome.shell.extensions.dash-to-panel taskbar-position 'CENTEREDMONITOR'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas set org.gnome.shell.extensions.dash-to-panel show-activities-button true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas set org.gnome.shell.extensions.dash-to-panel isolate-workspaces true

# NoTitlebar
gsettings --schemadir ~/.local/share/gnome-shell/extensions/no-title-bar@franglais125.gmail.com/schemas set org.gnome.shell.extensions.no-title-bar only-main-monitor false

# Middleclickclose (Quit Close in Overview)
gsettings --schemadir ~/.local/share/gnome-shell/extensions/middleclickclose@paolo.tranquilli.gmail.com/schemas set org.gnome.shell.extensions.middleclickclose rearrange-delay 200

# Screenshot Tool
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '' # default: 'Print'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gnome-shell-screenshot@ttll.de/schemas set org.gnome.shell.extensions.screenshot shortcut-select-desktop "['Print']"
~~~

## Lid closed action

[Reference](http://tipsonubuntu.com/2018/04/28/change-lid-close-action-ubuntu-18-04-lts/)

```
sudo vim /etc/systemd/logind.conf
```

## PPPOE network connection

`nmcli con edit type pppoe con-name "connection-name"`:

```
set pppoe.username username
set connection.autoconnect no
save
quit
```

Network Settings > Wired > connection-name

## Specify different GTK_THEME for application

### .desktop file
https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu
```
env GTK2_RC_FILES= GTK_DATA_PREFIX= GTK_THEME=Adwaita /usr/bin/the_usual_executable 
```

[Reference](https://askubuntu.com/a/778388)

### Firefox

~~~ shell
sudo sed -Ei '/export MOZ_APP_LAUNCHER/a\\n# Use specific GTK_THEME instead of system default\nGTK_THEME=Yaru\nexport GTK_THEME' /usr/lib/firefox/firefox.sh
~~~

## Create a .desktop file to launch an application

[Reference](https://askubuntu.com/questions/418407/how-do-i-create-a-desktop-file-to-launch-eclipse)

`/usr/share/applications/eclipse.desktop`:
~~~
[Desktop Entry]
Name=Eclipse
Comment=Eclipse
Exec=/home/user/eclipse/eclipse
Icon=/home/user/eclipse/icon.xpm
Terminal=false
Type=Application
Categories=Development;IDE
~~~

# Graphic Tablets

## Restrict graphic tablet to one display

`xinput`: ` HUION H420 Pen (0)                        id=23   [slave  pointer  (2)]`
`xrandr`: `eDP-1-1 connected 1920x1080+485+1440 (normal left inverted right x axis y axis) 344mm x 193mm`

~~~shell
xinput map-to-output 23 eDP-1-1
~~~

# Touchpad

Enable: `sh -c "xinput list | grep 'SynPS/2 Synaptics TouchPad' | sed -E 's/.*id=([0-9]+).*/set-prop \1 \"Device Enabled\" 1/g' | xargs xinput"`
Disable: `sh -c "xinput list | grep 'SynPS/2 Synaptics TouchPad' | sed -E 's/.*id=([0-9]+).*/set-prop \1 \"Device Enabled\" 0/g' | xargs xinput"`

# Miscellanious errors

## `apt upgrade`: `mkinitramfs failure cpio`, `cannot write compressed block`

`/boot` has probably filled up, free some space with `sudo apt pure linux-image-5.0.0-36-generic` (adapted to the kernel you want to remove).

References:
- https://askubuntu.com/questions/1207958/error-24-write-error-cannot-write-compressed-block

# Virtual audio device

~~~shell
sudo modprobe snd-dummy
~~~

Creating a virtual audio device can be used to record audio whilst keeping speakers muted.

References:
- https://askubuntu.com/a/1223529/776650

---

# ag [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)

~~~shell
sudo apt-get install -y silversearcher-ag
~~~

# Android Studio

~~~shell
flatpak install flathub com.google.AndroidStudio
sudo flatpak override --filesystem=host com.google.AndroidStudio
~~~

# Anki

Installation guide: https://docs.ankiweb.net/platform/linux/installing.html

## Desktop

### .desktop file

~~~
[Desktop Entry]
Name=Anki
Comment=Flashcard SRS
Exec=/opt/anki/bin/anki
Icon=anki.svg
Type=Application
Categories=Education;
Terminal=true
~~~

### Addons (for Anki 2.1)

|     ID     | Name |
|:----------:|:-----:|
| 2179254157 | [Card Info During Review](https://ankiweb.net/shared/info/2179254157) |
| 1084228676 | [Color Confirmation](https://ankiweb.net/shared/info/1084228676) |
|   24411424 | [Customize Keyboard Shortcuts](https://ankiweb.net/shared/info/24411424) |
|  877182321 | [Enhance main window](https://ankiweb.net/shared/info/877182321) |
|  516643804 | [Frozen Fields](https://ankiweb.net/shared/info/516643804) |
|  594329229 | [Hierarchical Tags 2](https://ankiweb.net/shared/info/594329229) |
| 1374772155 | [Image Occlusion Enhanced for Anki 2.1 (alpha)](https://ankiweb.net/shared/info/1374772155) |
| 1949865265 | [Learning Step and Review Interval Retention](https://ankiweb.net/shared/info/1949865265) |
| 2084557901 | [LPCG (Lyrics/Poetry Cloze Generator)](https://ankiweb.net/shared/info/2084557901) |
|  738807903 | [More Overview Stats 2.1](https://ankiweb.net/shared/info/738807903) |
| 1508357010 | [Remaining time (for Anki 2.1)](https://ankiweb.net/shared/info/1508357010) |
| 1828603731 | [Stats Overview Pie Graph with Distinct 'Learning' and-or 'Relearning' Sections](https://ankiweb.net/shared/info/1828603731) |
|  613684242 | [True Retention](https://ankiweb.net/shared/info/613684242) |

Maybe:
- https://ankiweb.net/shared/info/817108664
- https://ankiweb.net/shared/info/2616209911
- https://ankiweb.net/shared/info/734898866
- https://ankiweb.net/shared/info/1672712021
- https://ankiweb.net/shared/info/1009670238

#### Plugins not used anymore (since 2.1.45)

|     ID     | Name |
|:----------:|:-----:|
| 291119185 | [Batch Editing](https://ankiweb.net/shared/info/291119185) |
| 1421528223 | [Deck Stats](https://ankiweb.net/shared/info/1421528223) |
|  295889520 | [Mini Format Pack](https://ankiweb.net/shared/info/295889520) |
|  323586997 | [ReMemorize: Rescheduler with sibling and logging (v1.4.0)](https://ankiweb.net/shared/info/323586997) |


### Errors

#### `Anki requires a UTF-8 locale`
```
/opt/anki-2.1.22-linux-amd64$ ./bin/anki
Traceback (most recent call last):
  File "runanki", line 3, in <module>
  File "<frozen importlib._bootstrap>", line 991, in _find_and_load
  File "<frozen importlib._bootstrap>", line 975, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 671, in _load_unlocked
  File "/home/dae/Local/py514/lib/python3.8/site-packages/PyInstaller-4.0.dev0+g2886519-py3.8.egg/PyInst
  File "aqt/__init__.py", line 15, in <module>
  File "<frozen importlib._bootstrap>", line 991, in _find_and_load
  File "<frozen importlib._bootstrap>", line 975, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 671, in _load_unlocked
  File "/home/dae/Local/py514/lib/python3.8/site-packages/PyInstaller-4.0.dev0+g2886519-py3.8.egg/PyInst
  File "anki/__init__.py", line 13, in <module>
Exception: Anki requires a UTF-8 locale.
[5926] Failed to execute script runanki
```

**Solution**

```shell
export LC_CTYPE=en_CA.UTF-8
```

#### `mpv not found`

**Solution**

```
sudo add-apt-repository ppa:mc3man/mpv-tests
sudo apt-get install mpv
```

References:
- https://anki.tenderapp.com/discussions/ankidesktop/36650-error-message-exception-anki-requires-a-utf-8-locale
- https://www.reddit.com/r/Anki/comments/e2zbcl/mpv_not_found/

#### Blurry text

Start anki with `ANKI_WEBSCALE=1 ANKI_NOHIGHDPI=1` environment variables.
I.e. `env ANKI_WEBSCALE=1 ANKI_NOHIGHDPI=1 anki` for a XFCE launcher.

# ansible

References:
- https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu

# AnyDesk

## Disable autostart

~~~shell
sudo systemctl disable anydesk
~~~

References:
- https://www.reddit.com/r/AnyDesk/comments/g49lqo/anydesk_runs_wild_upon_booting_into_linux_how_to/

# [autojump](https://github.com/wting/autojump)

~~~shell
sudo apt-get install -y autojump
~~~

# AppImage

## Extract `.desktop` file

```shell
myprogram.AppImage --appimage-extract
cp  `find squashfs-root -name '*.desktop'` .
rm -rf squashfs-root
```

# clang-format

## Update default clang-format version
~~~shell
sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-9 1000 
~~~
[Reference](https://bugs.launchpad.net/ubuntu/+source/llvm-defaults/+bug/1769737)

# cowsay

## Show cows

`for cow in `cowsay -l`; do cowsay -f $cow $cow; done`

# datamash

GNU datamash is a command-line program which performs basic numeric, textual and statistical operations on input textual data files. 

~~~shell
sudo apt install datamash
~~~

References:
- https://www.gnu.org/software/datamash/

# DaVinci Resolve

Download: [https://www.blackmagicdesign.com/products/davinciresolve/](https://www.blackmagicdesign.com/products/davinciresolve/)

## Import mp4 in DaVinci Resolve

### mjpeg

```
ffmpeg -i input_file.mp4 -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov output_file.mov
```

batch:
```
for f in *.mp4; do ffmpeg -i "$f" -hide_banner -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov "$f.mov"; done
```

References:
- https://www.youtube.com/watch?v=WLcW4UWPC5Y
- https://brushlesswhoop.com/converting-fpv-footage-for-davinci-resolve/
- https://superuser.com/a/1273941

# Docker

[Reference](https://docs.docker.com/install/linux/docker-ce/ubuntu/#upgrade-docker-ce-1)
~~~shell
wget -O- get.docker.com | bash
~~~
~~~shell
curl -fsSL http://get.docker.com/ | sh
~~~

## Check if installation was successful

```shell
docker run --rm -i hello-world
```

## Use `docker` without `sudo`

~~~shell
sudo groupadd docker # create the docker group
sudo usermod -aG docker $USER # add current user to the docker group
newgrp docker # re-evaluate group membership
~~~

References:
- https://docs.docker.com/engine/install/linux-postinstall/

## Move data directory

1. `sudo service docker stop`
2. Add the following to `/etc/docker/daemon.json`

    ```
    {
        "data-root": "/path/to/your/docker"
    }
    ```

3. `sudo rsync -aP /var/lib/docker/ /path/to/your/docker
4. `sudo mv /var/lib/docker /var/lib/docker.old`
5. `sudo service docker start
6. Test if your docker containers still work!
6. `sudo rm -rf /var/lib/docker.old`


References:
- https://www.guguweb.com/2019/02/07/how-to-move-docker-data-directory-to-another-location-on-ubuntu/

## Install latest docker-compose

[Reference](https://gist.github.com/deviantony/2b5078fe1675a5fedabf1de3d1f2652a)

~~~shell
sudo apt remove -y docker-compose # remove old version
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
wget -O- get.docker.com | bash
~~~

## Install latest docker-compose

[Reference](https://gist.github.com/deviantony/2b5078fe1675a5fedabf1de3d1f2652a)

~~~shell
sudo apt remove -y docker-compose # remove old version
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
~~~

# [DrawIO](https://app.diagrams.net/)

~~~shell
sudo ln -s /media/data/storage/programs/drawio-x86_64-16.4.0.AppImage /usr/local/bin/drawio
sudo cp $DOTFILES_HOME/data/drawio/drawio.desktop /usr/local/share/applications/
~~~

# Eclipse

[Download page](https://www.eclipse.org/downloads/)

~~~shell
tar -xf eclipse*.tar.gz
eclipse-installer/eclipse-inst # Installation Folder: ~
~~~

## Lombok

[Download page](https://projectlombok.org/download)

# Elasticsearch

[Download page](https://www.elastic.co/downloads)

Debian:
~~~shell
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.deb.sha512
shasum -a 512 -c elasticsearch-6.4.0.deb.sha512 && sudo dpkg -i elasticsearch-6.4.0.deb
~~~

# Firefox

## Add-ons

- [Adblock Plus](https://addons.mozilla.org/en-US/firefox/addon/adblock-plus/)
- [Bupass Paywalls Clean](https://addons.mozilla.org/en-US/firefox/addon/bypass-paywalls-clean/)
- [Chessvision.ai](https://addons.mozilla.org/en-CA/firefox/addon/chessvision-ai-for-firefox/)
- [Cookie-Editor](https://addons.mozilla.org/en-US/firefox/addon/cookie-editor/)
- [Keepa.com - Amazon Price Tracker](https://addons.mozilla.org/en-GB/firefox/addon/keepa/)
- [Netflix 1080p](https://addons.mozilla.org/en-US/firefox/addon/netflix-1080p-firefox/)
- [Recommendation Tweaker for YouTube](https://addons.mozilla.org/en-US/firefox/addon/recommendation-tweaker-yt/)
- [Reverse Image Search](https://addons.mozilla.org/en-US/firefox/addon/image-reverse-search/)
- [Save Page WE](https://addons.mozilla.org/en-CA/firefox/addon/save-page-we/)
- [Tabliss](https://addons.mozilla.org/en-US/firefox/addon/tabliss/)
- [uBlock Origin](https://addons.mozilla.org/en-CA/firefox/addon/ublock-origin)
- [Video DownloadHelper](https://addons.mozilla.org/en-US/firefox/addon/video-downloadhelper/)
- [Vimium-FF](https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/)
- [Vue.js devtools](https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/)

## Settings

| Name | Value |
|-----:|:------|
| Open previous windows and tabs | yes |
| Ask to save logins and password for websites | no |

# GCC / G++

[Reference](https://askubuntu.com/a/1149383/776650)

~~~shell
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install gcc-9 g++-9
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9
~~~

# Git

~~~shell
sudo apt install -y git
~~~

## Dotfiles

Https:
~~~shell
git clone https://github.com/SimonLammer/dotfiles ~/.dotfiles
~~~

SSH:
~~~shell
git clone git@github.com:SimonLammer/dotfiles.git ~/.dotfiles
~~~

Create symlinks:
~~~shell
~/.dotfiles/gradlew \
  actions-git-link\
  actions-tmux-link\
  actions-vim-link\
  actions-vscode-link\
  actions-zsh-link
~~~

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/data/git/_.gitconfig ~/.gitconfig
~~~

# Gnucash

The apt version is behind (as of 2020-08-02).
~~~shell
flatpack install flathub org.gnucash.GnuCash
sudo flatpak override --filesystem=host org.gnucash.GnuCash
~~~

References:
- https://unix.stackexchange.com/a/525104/367736

# gscan2pdf

~~~shell
sudo apt install gscan2pdf tesseract-ocr-deu
~~~

# [Gti](https://github.com/rwos/gti)

~~~shell
sudo add-apt-repository ppa:mamantoha/gti
sudo apt-get update
sudo apt-get install -y gti
~~~


# Gnome Shell

~~~shell
sudo apt-get install chrome-gnome-shell
~~~

# Inkscape

~~~shell
sudo apt-get install -y inkscape
~~~

# Java

~~~shell
sudo apt install -y openjdk-8-jdk openjdk-8-doc
~~~

# Latex

[Reference](https://milq.github.io/install-latex-ubuntu-debian/)

```
sudo apt-get install texlive-full
```

# Lutris

*I like the idea, but it didn't work for me, so I'll stay on [Play on Linux](#Play-on-Linux) for now*

[Reference](https://lutris.net/downloads/)

# Mega

[Download page](https://mega.nz/sync)

Settings > Advanced > Excluded file and folder names:

- \*-local
- \*-local.\*

# Neovim

## Installation

~~~shell
sudo su
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod ugo+x nvim.appimage
version=`./nvim.appimage --version | head -n 1 | sed -E -e 's/.*v(.*)/\1/' -e 's/\./_/g'`
mv nvim.appimage /usr/local/bin/nvim_$version.appimage
update-alternatives --install /usr/local/bin/nvim nvim /usr/local/bin/nvim_$version.appimage 100
update-alternatives --config nvim
~~~

## Link `vim` to `nvim`

~~~shell
sudo su
update-alternatives --install /usr/local/bin/vim vim /usr/local/bin/nvim 150
update-alternatives --config vim
~~~


# NodeJS

[Download page](https://nodejs.org/en/download/)

## 8.x
~~~shell
sudo apt-get install curl python-software-properties
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install nodejs
~~~

## NPM

### Permission denied when installing packages globally (`-g`)

**Error:**
~~~
🡲 npm install -g github-app-installation-token
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /usr/lib/node_modules/github-app-installation-token
npm ERR! errno -13
npm ERR! Error: EACCES: permission denied, mkdir '/usr/lib/node_modules/github-app-installation-token'
npm ERR!  [Error: EACCES: permission denied, mkdir '/usr/lib/node_modules/github-app-installation-token'] {
npm ERR!   errno: -13,
npm ERR!   code: 'EACCES',
npm ERR!   syscall: 'mkdir',
npm ERR!   path: '/usr/lib/node_modules/github-app-installation-token'
npm ERR! }
npm ERR!
npm ERR! The operation was rejected by your operating system.
npm ERR! It is likely you do not have the permissions to access this file as the current user
npm ERR!
npm ERR! If you believe this might be a permissions issue, please double-check the
npm ERR! permissions of the file and its containing directories, or try running
npm ERR! the command again as root/Administrator.

npm ERR! A complete log of this run can be found in:
npm ERR!     /home/slammer/.npm/_logs/2022-10-20T12_52_46_296Z-debug-0.log
~~~

**Solution:**

~~~shell
folder="~/.local/share/npm"
mkdir "$folder"
npm config set prefix "$folder"
~~~

References:
- https://www.youtube.com/watch?v=qlVciUJCgAo

# NoiseTorch

[Download page](https://github.com/lawl/NoiseTorch)
> NoiseTorch is an easy to use open source application for Linux with PulseAudio. It creates a virtual microphone that suppresses noise, in any application. Use whichever conferencing or VOIP application you like and simply select the NoiseTorch Virtual Microphone as input to torch the sound of your mechanical keyboard, computer fans, trains and the likes.

## Autostart

[Reference](https://github.com/lawl/NoiseTorch/wiki/Start-automatically-with-Systemd)

# [Open Video Downloader (youtube-dl-gui)](https://jely2002.github.io/youtube-dl-gui/)

~~~shell
sudo ln -s /media/data/storage/programs/Open-Video-Downloader-2.4.0.AppImage /usr/local/bin/open-video-downloader
sudo cp $DOTFILES_HOME/data/open-video-downloader/open-video-downloader.desktop /usr/local/share/applications/
~~~

# Plantuml

https://github.com/plantuml/plantuml

# Play on Linux

~~~shell
sudo apt install -y playonlinux
~~~

## Winetricks

~~~shell
sudo apt install winetricks
~~~

## Move ```~/.PlayOnLinux``` to current directory (on other partition)

~~~shell
# cd /disks/main/$(whoami)/programs/
mv ~/.PlayOnLinux ./PlayOnLinux
ln -s $(pwd)/PlayOnLinux ~/.PlayOnLinux
~~~

## Steam (within POL)

### No voices

[Reference](https://www.reddit.com/r/linux_gaming/comments/99i4se/skyrim_on_linux_steam_play_no_voiceno_music_audio/)

In the wine `Libraries` tab create overrides for the properties `xaudio2_6` and `xaudio2_7`, setting both to `native`.

### Error: Content Servers Unreachable

[Reference](https://www.reddit.com/r/wine_gaming/comments/8r0gh6/steam_in_winedevel_content_servers_unreachable/)

Open Shell via wine:
~~~shell
sed -iE "$(grep -nm 1 CM "Program Files/Steam/config/config.vdf" | cut -d: -f 1)"' a\\t\t\t\t"CS"\t\t"valve511.steamcontent.com;valve501.steamcontent.com;valve517.steamcontent.com;valve557.steamcontent.com;valve513.steamcontent.com;valve535.steamcontent.com;valve546.steamcontent.com;valve538.steamcontent.com;valve536.steamcontent.com;valve530.steamcontent.com;valve559.steamcontent.com;valve545.steamcontent.com;valve518.steamcontent.com;valve548.steamcontent.com;valve555.steamcontent.com;valve556.steamcontent.com;valve506.steamcontent.com;valve544.steamcontent.com;valve525.steamcontent.com;valve567.steamcontent.com;valve521.steamcontent.com;valve510.steamcontent.com;valve542.steamcontent.com;valve519.steamcontent.com;valve526.steamcontent.com;valve504.steamcontent.com;valve500.steamcontent.com;valve554.steamcontent.com;valve562.steamcontent.com;valve524.steamcontent.com;valve502.steamcontent.com;valve505.steamcontent.com;valve547.steamcontent.com;valve560.steamcontent.com;valve503.steamcontent.com;valve507.steamcontent.com;valve553.steamcontent.com;valve520.steamcontent.com;valve550.steamcontent.com;valve531.steamcontent.com;valve558.steamcontent.com;valve552.steamcontent.com;valve563.steamcontent.com;valve540.steamcontent.com;valve541.steamcontent.com;valve537.steamcontent.com;valve528.steamcontent.com;valve523.steamcontent.com;valve512.steamcontent.com;valve532.steamcontent.com;valve561.steamcontent.com;valve549.steamcontent.com;valve522.steamcontent.com;valve514.steamcontent.com;valve551.steamcontent.com;valve564.steamcontent.com;valve543.steamcontent.com;valve565.steamcontent.com;valve529.steamcontent.com;valve539.steamcontent.com;valve566.steamcontent.com;valve165.steamcontent.com;valve959.steamcontent.com;valve164.steamcontent.com;valve1611.steamcontent.com;valve1601.steamcontent.com;valve1617.steamcontent.com;valve1603.steamcontent.com;valve1602.steamcontent.com;valve1610.steamcontent.com;valve1615.steamcontent.com;valve909.steamcontent.com;valve900.steamcontent.com;valve905.steamcontent.com;valve954.steamcontent.com;valve955.steamcontent.com;valve1612.steamcontent.com;valve1607.steamcontent.com;valve1608.steamcontent.com;valve1618.steamcontent.com;valve1619.steamcontent.com;valve1606.steamcontent.com;valve1605.steamcontent.com;valve1609.steamcontent.com;valve907.steamcontent.com;valve901.steamcontent.com;valve902.steamcontent.com;valve1604.steamcontent.com;valve908.steamcontent.com;valve950.steamcontent.com;valve957.steamcontent.com;valve903.steamcontent.com;valve1614.steamcontent.com;valve904.steamcontent.com;valve952.steamcontent.com;valve1616.steamcontent.com;valve1613.steamcontent.com;valve958.steamcontent.com;valve956.steamcontent.com;valve906.steamcontent.com"' "Program Files/Steam/config/config.vdf"
~~~

### Skyrim + Nexus Mod Manager

Install Steam as listed in POL. (update wine version afterwards)

# Prolog

## SWI-Prolog

~~~shell
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:swi-prolog/stable
sudo apt-get update
sudo apt-get install swi-prolog
~~~

References:
- https://www.swi-prolog.org/build/PPA.html

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

### Stuck in 'Locking ...'

Either: Wait for a bit

Or: `pipenv lock --clear && pipenv install`

References:
- https://stackoverflow.com/a/56440091/2808520

# qpaeq / pulseaudio-equalizer

~~~shell
sudo apt install pulseaudio-equalizer
~~~

## Dbus module not loaded

**Error**:
~~~
$ qpaeq
qt5ct: using qt5ct plugin
There was an error connecting to pulseaudio, please make sure you have the pulseaudio dbus module loaded, exiting...
~~~

**Solution**:
Add the following lines to `/etc/pulse/default.pa`:
~~~
load-module module-equalizer-sink
load-module module-dbus-protocol
~~~

References:
- https://linuxhint.com/install-pulseaudio-equalizer-linux-mint/

# [Ranger](https://github.com/ranger/ranger)

~~~shell
sudo apt install -y ranger
~~~

# Redmine

## Install

https://github.com/SimonLammer/services/tree/master/docker-compose/redmine

## Plugins

| Name | Description | Link |
|---|---|---|
| Bestest Punch Clock for Redmine | This is an awesome punch clock/timer plugin for Redmine. It's great. It's the bestest. | https://github.com/LeviticusMB/bestest_timer |
| Dashboard | Plugin adds an issues dashboard to the application  | https://github.com/akpaevj/Dashboard |
| Kanban | Kanban plugin for redmine | https://github.com/happy-se-life/kanban |
| Redmine Auto Resubmission plugin | This plugin provides a resubmission tool for issues | https://github.com/HugoHasenbein/redmine_auto_resubmission |
| Redmine Checklists plugin (Light version) | This is a issue checklist plugin for Redmine | https://www.redmineup.com/pages/plugins/checklists |
| Redmine Subtask List Accordion plugin | This plugin provide accordion to subtask list of issue. | https://github.com/GEROMAX/redmine_subtask_list_accordion |
| Redmine view customize plugin | This a plugin allows you to customize the view for the Redmine. | https://github.com/onozaty/redmine-view-customize |

### Other interesting Plugins

| Name | Description | Link |
|---|---|---|
| issue_recurring | Redmine plugin: schedule Redmine issue recurrence based on multiple conditions. | https://github.com/cryptogopher/issue_recurring |
| Issue View Columns | Redmine plugin to customize shown columns in subtasks and related issues on issue page | https://github.com/AlphaNodes/redmine_issue_view_columns/tree/2.0.0 |
| Issue To-do Lists Plugin | Organize issues in to-do lists by manually ordering their priority | https://github.com/canidas/redmine_issue_todo_lists |



# Ruby

[Reference](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-and-set-up-a-local-programming-environment-on-ubuntu-16-04)

~~~shell
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
wget -O - https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install ruby --default
~~~

# Sqlite Browser

[Download Page](https://sqlitebrowser.org/)

~~~shell
sudo apt-get install sqlitebrowser
~~~

# SSH

~~~shell
sudo apt install -y ssh
~~~

## [Generate a SSH key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#generating-a-new-ssh-key)

~~~shell
ssh-keygen -o -a 100 -t ed25519 -C "lammer.simon@gmail.com"
~~~
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

# Subversion (SVN)

~~~
sudo apt install subversion
~~~

# Thunderbird

## Change date format

[Reference](http://kb.mozillazine.org/Change_the_Date_Format)

# Tmux 

~~~shell
sudo apt install -y tmux xclip
~~~

## Per project configuration

Some configurations are stored in [data/tmux/configurations](data/tmux/configurations).

References:
- https://spin.atomicobject.com/2015/03/08/dev-project-workspace-tmux/

## Install other version

[Download the latest release from github](https://github.com/tmux/tmux/releases)
~~~shell
sudo apt-get install -y libevent-dev libncurses5-dev libncursesw5-dev
wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
tar xf tar xf libevent-2.1.8-stable.tar.gz
wget https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz
tar xf tmux-2.7.tar.gz
cd tmux-2.7.tar.gz
./configure && make
sudo make install
~~~

## Plugins

### [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

~~~shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~~~

#### Install Plugins

Within tmux hit ```<prefix>-I```.

### [Tmux-GitBar](https://github.com/arl/tmux-gitbar)

~~~shell
git clone https://github.com/arl/tmux-gitbar.git ~/.tmux-gitbar
~~~

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/data/tmux/_.tmux.conf ~/.tmux.conf
ln -isv ~/.dotfiles/data/tmux/scripts ~/.tmux/scripts
~~~

# [VeraCrypt](https://www.veracrypt.fr/code/VeraCrypt/)

## Settings

| Location | Info |
|:---------|:-----|
| Security > Filesystem > Preserve modification timestamp of file containers | Disable to sync containers to cloud automatically |

# VIM

~~~shell
sudo apt install -y vim
~~~

## Cheatsheet

| Action | Description | Reference |
|:------:|:-----------:|:---------:|
| `:cq` | Quit vim with an error code, disregarding changes in the file. | https://vimdoc.sourceforge.net/htmldoc/quickfix.html |

## [vim-plug](https://github.com/junegunn/vim-plug)

The plugin manager will be installed automatically from the ```.vimrc```.

### Install plugins

```shell
vim +PlugInstall +qall
```

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/data/vim/_.vimrc ~/.vimrc
~~~

# Edit binary files

`%!xxd` produces a hex-view of binary.

`%!xxd -r` formats the hex-view to binary again.

References:
- https://vi.stackexchange.com/a/2234/40980

# VirtualBox

[Download page](https://www.virtualbox.org/wiki/Downloads)

## Move ```~/VirtualBox VMs``` to current directory (on other partition)

~~~shell
# cd /disks/main/$(whoami)/programs/VirtualBox
mv ~/VirtualBox\ VMs .
ln -s $(pwd)/VirtualBox\ VMs ~/.
~~~

## Setup

### Mac OS X

[Reference](https://techsviewer.com/install-macos-high-sierra-virtualbox-windows/)

### Windows 10

[ISO Download page](https://www.microsoft.com/en-us/software-download/windows10ISO)

## USB Passthrough

### No devices available

Add the user to the `vboxusers` group.

~~~
sudo adduser $USER vboxusers
~~~

[Reference](https://superuser.com/a/957636)

# Visual Studio Code

[Download page](https://code.visualstudio.com/download)

## Link [dotfiles]

~~~shell
ln -isv ~/.dotfiles/data/vscode/settings.json ~/.config/Code/User/.
ln -isv ~/.dotfiles/data/vscode/keybindings.json ~/.config/Code/User/.
~~~

## Install Extensions

~~~shell
for ext in \
  'coenraads.bracket-pair-colorizer'\
  'Gruntfuggly.activitusbar'\
  'kenhowardpdx.vscode-gist'\
  'ms-python.python'\
  'ms-vscode.cpptools'\
  'vscodevim.vim'\
  'mathiasfrohlich.Kotlin'\
;do code --install-extension $ext; done
~~~

# VLC

~~~shell
sudo apt install -y vlc
~~~

# xfce4-terminal

## Color schemes

### [gruvbox-dark](https://github.com/vifo/xfce4-terminal-colorschemes/blob/master/colorschemes/gruvbox-dark.theme)

~~~shell
curl --create-dirs -o "$HOME/.config/xfce4/terminal/colorschemes/gruvbox-dark.theme" "https://raw.githubusercontent.com/vifo/xfce4-terminal-colorschemes/master/colorschemes/gruvbox-dark.theme" && chmod 0644 "$HOME/.config/xfce4/terminal/colorschemes/gruvbox-dark.theme"
~~~

# [Xournal++](https://xournalpp.github.io/)

~~~shell
sudo ln -s /media/data/storage/programs/xournalpp-1.1.1-x86_64.AppImage /usr/local/bin/xournalpp
sudo cp $DOTFILES_HOME/data/xournalpp/xournalpp.desktop /usr/local/share/applications/
~~~

## LaTeX

**Error**:

> Global template file is not a regular file. Please check your settings.

**Solution**:

~~~shell
sudo mkdir /usr/local/share/xournalpp
sudo cp $DOTFILES_HOME/data/xournalpp/default_template.tex /usr/local/share/xournalpp
~~~

Select `/usr/local/share/xournalpp/default_template.tex` in the setting: Edit > Preferences > LaTeX > Global template file path

References:
- https://github.com/xournalpp/xournalpp.github.io/issues/33

# ZSH

~~~shell
sudo apt install -y zsh
~~~

## [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh)

~~~shell
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
~~~

**Logout to update default shell**

### [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)
~~~shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
~~~

### [ZSH Theme "nothing"](https://github.com/eendroroy/nothing)
~~~shell
git clone https://github.com/eendroroy/nothing.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/nothing
ln -isv ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/nothing/nothing.zsh-theme ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/.
~~~

## Link [dotfiles]:

~~~shell
ln -isv ~/.dotfiles/data/zsh/_.zshrc ~/.zshrc
~~~

---

~~~shell
sudo apt install -y \
  autojump\
  curl\
  git\
  gparted\
  htop\
  openjdk-8-jdk openjdk-8-doc\
  ssh\
  tree\
  tmux\
  xclip\
  vim\
  zsh
~~~

Fun additions:
~~~shell
sudo apt install -y \
  cmatrix\
  cowsay\
  sl
~~~

[Ninite](https://ninite.com/)

---

# TODO

- Gnome Shell
  - Fix Airplane mode after suspend
    - https://www.reddit.com/r/archlinux/comments/62lk65/arch_gnome_stopped_suspend_now_how_do_i_prevent/
- Anki
- Entr
- Firefox
  - Informative default page
- Latex
  - md -> latex (pandoc?)
- POL
  - Skyrim
    - voices
    - Mods
- SSH
  - Login with key instead of password
    - Add key of localhost
  - Automatically trust GH and GL
- Tmux
  - Hide window name on current window if not named
- Vim
  - Clipboard interaction
- ? Powerline font
  - Tmux powerline theme
- ? ENV Variable
  - Dark/Light theme
- Autogenerated ascii art
  - cache so it works without network connection



[dotfiles]: #dotfiles
