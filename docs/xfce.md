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
4. Window Buttons
5. Separator
6. Status Tray
7. Notifications
8. System Management Plugins
9. xfce4-genmon-plugin indicators

    | Description | Period | Command |
    |:-----------:|-------:|:--------|
    | [Memory](../data/scripts/xfce4_genmon_plugin-memory.sh) | 15 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-memory.sh` |
    | [Swap](../data/scripts/xfce4_genmon_plugin-memory.sh) | 30 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-memory.sh Swap` |
    | [CPU utilization](../data/scripts/xfce4_genmon_plugin-cpu_util.sh) | 10 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-cpu_util.sh` |
    | [CPU temperature](../data/scripts/xfce4_genmon_plugin-cpu_temp.sh) | 10 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-cpu_temp.sh` |
    | [GPU utilization](../data/scripts/xfce4_genmon_plugin-gpu_util.sh) | 10 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-gpu_util.sh` |
    | [GPU temperature](../data/scripts/xfce4_genmon_plugin-gpu_temp.sh) | 10 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-gpu_temp.sh` |
    | ['/' usage](../data/scripts/xfce4_genmon_plugin-filesystem.sh) | 300 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-filesystem.sh /` |
    | ['/media/data' usage](../data/scripts/xfce4_genmon_plugin-filesystem.sh) | 300 | `/home/slammer/.config/dotfiles/data/scripts/xfce4_genmon_plugin-filesystem.sh /media/data 90 93 97 99` |

10. DateTime

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

