
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
9. System Load Monitor
10. DateTime

### Directory shortcuts

```
for d in ~/*; do ln -s "$d" "`basename "$d"`"; done
```

### Clock format

`%Y%m%dT%H%M%S`

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

