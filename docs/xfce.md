# XFCE setup

## WM Themes

Stored in `/usr/share/themes`.
```
sudo tar -C /usr/share/themes -xzf theme.tar.gz
```

Current: [XFWM - Minimal-gtk](https://www.xfce-look.org/p/1016504)

Others:
- [prelude-dfr](https://www.xfce-look.org/p/1016457/)

## GTK Themes

Stored in `/usr/share/themes`.
```
sudo tar -C /usr/share/themes -xJf theme.tar.xz
```

Current: [Snow](https://www.xfce-look.org/p/1214421/)

## Cursors

Stored in `/usr/share/icons`.
```
sudo tar -C /usr/share/icons -xJf theme.tar.xz
```

Current: [Qogir cursors](https://www.xfce-look.org/p/1366182)

## Icons

Stored in `/usr/share/icons`.
```
sudo tar -C /usr/share/icons -xJf theme.tar.xz
```

Current: [Papirus](https://www.xfce-look.org/s/XFCE/p/1166289)

Others:
- [Ultimate Maia Icons](https://www.xfce-look.org/s/XFCE/p/1218961)

## Panel Preferences

### Items

1. Whisker Menu
2. Directory Menu
3. Window Menu
4. (xfce-genmon-plugin window title)[../data/xfce4-genmon-plugin/scripts/window_title.sh]

    `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/window_title.sh"`

    Choose a monospaced font to preserve width.

5. Window Buttons
6. Separator
7. Status Tray
8. Notifications
9. Launcher: [Toggle TouchPad](../datas/xinput/scripts/toggle.sh) (`sh -c "$DOTFILES_HOME/data/xinput/scripts/toggle.sh 'SynPS/2 Synaptics TouchPad'"`)
10. System Management Plugins
11. xfce4-genmon-plugin indicators

    | Description | Period [s] | Command |
    |:-----------:|-------:|:--------|
    |              [Memory](../data/xfce4-genmon-plugin/scripts/memory.sh)     |  15 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/memory.sh"` |
    |                [Swap](../data/xfce4-genmon-plugin/scripts/memory.sh)     |  15 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/memory.sh Swap"` |
    |     [CPU utilization](../data/xfce4-genmon-plugin/scripts/cpu_util.sh)   |   5 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/cpu_util.sh"` |
    |     [CPU temperature](../data/xfce4-genmon-plugin/scripts/cpu_temp.sh)   |   5 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/cpu_temp.sh"` |
    |          [GPU memory](../data/xfce4-genmon-plugin/scripts/gpu_memory.sh) |  15 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/gpu_memory.sh"` |
    |     [GPU utilization](../data/xfce4-genmon-plugin/scripts/gpu_util.sh)   |   5 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/gpu_util.sh"` |
    |     [GPU temperature](../data/xfce4-genmon-plugin/scripts/gpu_temp.sh)   |   5 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/gpu_temp.sh"` |
    |           ['/' usage](../data/xfce4-genmon-plugin/scripts/filesystem.sh) | 300 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/filesystem.sh /"` |
    | ['/media/data' usage](../data/xfce4-genmon-plugin/scripts/filesystem.sh) | 300 | `sh -c "$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/filesystem.sh /media/data 90 93 97 99"` |

12. DateTime

### Directory shortcuts

```
for d in ~/*; do ln -s "$d" "`basename "$d"`"; done
```

### Clock format

`%Y%m%dT%H%M%S`

### Plugins

#### [xfce4-genmon-plugin](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin)

Use the git version, because `css` tags have not been released officially yet. - https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin/start#usage

```
cd <repo_directory>
git clone https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin.git .
./autogen.sh
./configure --prefix=/usr
make
sudo make install
```

## Background images

- https://wallhaven.cc/w/p8ek6p

## Xfconf Settings

| Channel | property | value |
|--------:|:---------|:-----:|
| pointers | /DisableTouchpadWhileTyping | True |
| pointers | /SynPS2_Synaptics_Touchpad/ReverseScrolling | True |
| xfce4-keyboard-shortcuts | /commands/custom/<Super>space | xfce4-popup-whiskermenu |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt>Up | up_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt>Left | left_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt>Down | down_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt>Right | right_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt><Super>Up | move_window_up_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt><Super>Left | move_window_left_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt><Super>Down | move_window_down_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Alt><Super>Right | move_window_right_workspace_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Shift><Alt>Up | move_window_up_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Shift><Alt>Left | move_window_left_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Shift><Alt>Down | move_window_down_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Shift><Alt>Right | move_window_right_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Super>Up | tile_up_right_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Super>Left | tile_up_left_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Super>Down | tile_down_left_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Primary><Super>Right | tile_down_right_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Super>Left | tile_left_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Super>Down | tile_down_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Super>Right | tile_right_key |
| xfce4-keyboard-shortcuts | /xfwm4/custom/<Super>Up | maximize_window_key |
| xfce4-panel | /panels/panel-1/mode | 0 |
| xfce4-panel | /panels/panel-1/position | p=11;x=0;y=0 |
| xfce4-panel | /panels/panel-1/position-locked | True |
| xfce4-panel | /panels/panel-1/size | 24 |
| xfce4-screensaver | /saver/fullscreen-inhibit | True |
| xfce4-screensaver | /saver/idle-activation/delay | 10 |
| xfwm4 | /general/snap_to_border | True |
| xfwm4 | /general/snap_to_windows | True |
| xfwm4 | /general/wrap_windows | False |
| xfwm4 | /general/button_layout | CHMO| |
| xsettings | /Gtk/DecorationLayout | close,minimize,maximize,menu: |

