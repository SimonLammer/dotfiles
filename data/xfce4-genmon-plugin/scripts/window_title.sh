#!/bin/sh
# xfce4-genmon-plugin script for displaying the window name of the currently selected window.

name=`xdotool getactivewindow getwindowname`
name_abridged=`printf '%-50s' "$(echo $name | cut -c -50)"`

echo "<txt>$name_abridged</txt>"
echo "<tool>$name</tool>"
