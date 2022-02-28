#!/bin/sh
# Creates the xml tags for a colored progress bar to be used with xfce4-genmon-plugin.
# Colors are computed by linear interpolation on a 3-color color scale.
#
# This script uses the genmon `css` tags, which are not officially released yet.
# Use the git version (https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin)
#   to allow usage of them.

if [ $# -le 1 ]; then exit 1; fi
value=$1

MIN_VALUE=0    # Values lower than this are interpreted as 0%
MAX_VALUE=100  # Values higher than this are interpreted as 100%

LOW_VALUE=0    # Values lower than this will be colored with LOW_COLOR_*
MID_VALUE=50   # Midpoint value for the color scale
HIGH_VALUE=100 # Values higher than this will be colored with HIGH_COLOR_*

# RGB values
LOW_COLOR_RED=0
LOW_COLOR_GREEN=210
LOW_COLOR_BLUE=0
MID_COLOR_RED=210
MID_COLOR_GREEN=210
MID_COLOR_BLUE=0
HIGH_COLOR_RED=210
HIGH_COLOR_GREEN=0
HIGH_COLOR_BLUE=0

if [ $# -ge 2 ];  then MIN_VALUE=${2}; fi
if [ $# -ge 3 ];  then MAX_VALUE=${3}; fi
if [ $# -ge 4 ];  then LOW_VALUE=${4}; fi
if [ $# -ge 5 ];  then MID_VALUE=${5}; fi
if [ $# -ge 6 ];  then HIGH_VALUE=${6}; fi
if [ $# -ge 7 ];  then LOW_COLOR_RED=${7}; fi
if [ $# -ge 8 ];  then LOW_COLOR_GREEN=${8}; fi
if [ $# -ge 9 ];  then LOW_COLOR_BLUE=${9}; fi
if [ $# -ge 10 ]; then MID_COLOR_RED=${10}; fi
if [ $# -ge 11 ]; then MID_COLOR_GREEN=${11}; fi
if [ $# -ge 12 ]; then MID_COLOR_BLUE=${12}; fi
if [ $# -ge 13 ]; then HIGH_COLOR_RED=${13}; fi
if [ $# -ge 14 ]; then HIGH_COLOR_GREEN=${14}; fi
if [ $# -ge 15 ]; then HIGH_COLOR_BLUE=${15}; fi

################################################################################

if [ $value -lt $MIN_VALUE ]; then
  value_percent=0
elif [ $value -gt $MAX_VALUE ]; then
  value_percent=100
else
  value_percent=`expr 100 \* \( $value - $MIN_VALUE \) / \( $MAX_VALUE - $MIN_VALUE \)`
fi

if [ $value -lt $LOW_VALUE ]; then
  red=$LOW_COLOR_RED
  green=$LOW_COLOR_GREEN
  blue=$LOW_COLOR_BLUE
elif [ $value -gt $HIGH_VALUE ]; then
  red=$HIGH_COLOR_RED
  green=$HIGH_COLOR_GREEN
  blue=$HIGH_COLOR_BLUE
else
  if [ $value -lt $MID_VALUE ]; then
    p=`expr 100 \* \( $value - $LOW_VALUE \) / \( $MID_VALUE - $LOW_VALUE \)`
    r=$LOW_COLOR_RED
    g=$LOW_COLOR_GREEN
    b=$LOW_COLOR_BLUE
  else
    p=`expr 100 \* \( $value - $HIGH_VALUE \) / \( $MID_VALUE - $HIGH_VALUE \)`
    r=$HIGH_COLOR_RED
    g=$HIGH_COLOR_GREEN
    b=$HIGH_COLOR_BLUE
  fi
  red=`expr $r + \( $MID_COLOR_RED - $r \) \* $p / 100`
  green=`expr $g + \( $MID_COLOR_GREEN - $g \) \* $p / 100`
  blue=`expr $b + \( $MID_COLOR_BLUE - $b \) \* $p / 100`
fi

# the css selector can be checked with GtkInspector `GTK_DEBUG=interactive xfce4-panel -r &` - https://docs.xfce.org/xfce/xfce4-panel/theming
echo "<css>.genmon_progressbar progress {background-color: rgb($red, $green, $blue);} .genmon_value {color: rgb($red, $green, $blue);}</css>"

echo "<bar>$value_percent</bar>"

