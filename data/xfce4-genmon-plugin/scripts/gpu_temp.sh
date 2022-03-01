#!/bin/sh

coloredbar="$DOTFILES_HOME/data/xfce4-genmon-plugin/scripts/coloredbar.sh"

# https://www.reddit.com/r/linux_gaming/comments/5je3qm/comment/dbffs6v/?utm_source=share&utm_medium=web2x&context=3
deg=`nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits`

################################################################################

$coloredbar $deg \
  30 100 \
  50 75 90 \
  191 191 191 \
  240 240 0 \
  255 15 15
echo "<tool>GPU temperature: $deg°C</tool>"

