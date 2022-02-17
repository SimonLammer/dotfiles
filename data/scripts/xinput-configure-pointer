#!/bin/sh
# Limits a pointer to a display with an orientation.
# This can be used to limit a rotated graphics tablet to one display.

set -e

ZENITY='zenity --width 500 --height 500'

# Select pointer
pointers=`xinput | grep pointer | tail -n +2 | sed -E 's/[^a-zA-Z0-9]*((\S+ ?)+[a-zA-Z0-9\(\)]+)\s*id=([0-9]+)\s*(.*)/"\3" "\1" "\4"/'`
#echo $pointers
pointer=`echo $pointers | xargs $ZENITY --list --text "Choose a pointer" --column Id --column Name --column Info`
#echo $pointer

# Select display
displays=`xrandr | grep \ con | sed -E 's/(\S+)[^0-9]*(.*)/"\1" "\2"/'`
#echo $displays
display=`echo $displays | xargs $ZENITY --list --text "Choose a display" --column Id --column Info`
#echo $display

# Map pointer to display to get initial coordinate transformation matrix
xinput map-to-output "$pointer" "$display"
mat0=`xinput list-props $pointer | grep "Coordinate Transformation Matrix" | cut -d ':' -f 2`

# Select orientation
o1="0°C"
o2="90°C"
o3="180°C"
o4="270°C"
orientation=`$ZENITY --list --text "Choose an orientation" --column Orientation --column Name "$o1" "Normal" "$o2" "Rotate left" "$o3" "Invert" "$o4" "Rotate right"`
# https://wiki.ubuntu.com/X/InputCoordinateTransformation
if [ "$orientation" = "$o1" ]; then
  mat1="1 0 0 0 1 0 0 0 1"
elif [ "$orientation" = "$o2" ]; then
  mat1="0 -1 1 1 0 0 0 0 1"
elif [ "$orientation" = "$o3" ]; then
  mat1="-1 0 1 0 -1 1 0 0 1"
else
  mat1="0 1 0 -1 0 1 0 0 1"
fi

# Multiply matrices (mat2 = mat0 * mat1)
# https://www.mymathtables.com/calculator/matrix/3-cross-3-matrix-multiplication.html
perl_expr="@a=split(/,? /,'$mat0');@b=split(/ /,'$mat1');print \"\"\
  .(\$a[0]*\$b[0]+\$a[1]*\$b[3]+\$a[2]*\$b[6]).\" \".(\$a[0]*\$b[1]+\$a[1]*\$b[4]+\$a[2]*\$b[7]).\" \".(\$a[0]*\$b[2]+\$a[1]*\$b[5]+\$a[2]*\$b[8]).\" \"\
  .(\$a[3]*\$b[0]+\$a[4]*\$b[3]+\$a[5]*\$b[6]).\" \".(\$a[3]*\$b[1]+\$a[4]*\$b[4]+\$a[5]*\$b[7]).\" \".(\$a[3]*\$b[2]+\$a[4]*\$b[5]+\$a[5]*\$b[8]).\" \"\
  .(\$a[6]*\$b[0]+\$a[7]*\$b[3]+\$a[8]*\$b[6]).\" \".(\$a[6]*\$b[1]+\$a[7]*\$b[4]+\$a[8]*\$b[7]).\" \".(\$a[6]*\$b[2]+\$a[7]*\$b[5]+\$a[8]*\$b[8]).\" \"\
  .\"\\n\""
#echo $perl_expr
mat2=`perl -E "$perl_expr"`

xinput set-prop "$pointer" --type=float "Coordinate Transformation Matrix" $mat2

