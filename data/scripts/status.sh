#!/bin/sh

# This script can be used to copy the last /proc/<pid>/status file that contains 'VmHWP' (i.e. memory information) to a temporary file.
# The <`ps` identifier> is used to search for the target process in the last column of `ps x`.
# It does not work for processes that terminate very fast (anything living longer than about 50ms works on my machine).
# Adapt the penultimate line to print different information from /proc/<pid>/status.
#
# Example:
# $ ./stat.sh "/usr/bin/python3 -c" &
# [1] 173934
# $ python3 -c "print(sum(list(range(1000000))))"
# PID 174353
# 499999500000
#
# VmPeak:    57484 kB
# VmSize:    57484 kB
# VmLck:         0 kB
# VmPin:         0 kB
# VmHWM:     47984 kB
# VmRSS:     47984 kB
# VmData:    42392 kB
# VmStk:       136 kB
# VmExe:      2784 kB
# VmLib:      2436 kB
# VmPTE:       144 kB
# VmSwap:        0 kB

if [ $# -ne 1 ]; then
  echo "Usage: $0 <\`ps\` identifier>"
  exit 1
fi
psid=$1

f=`mktemp`
ff=`mktemp`
while [ `ps x | grep "[0-9] $psid" >/dev/null; printf $?` -ne 0 ]; do
  sleep .001
done
pid=`ps x | grep "[0-9] $psid" | sed -E "s/^[^0-9]+([0-9]+).*/\\1/"`
echo PID $pid
while [ `cp /proc/$pid/status $ff 2>/dev/null; printf $?` -eq 0 ]; do
  if [ `grep "^VmHWM" $ff >/dev/null; printf $?` -ne 0 ]; then
    break
  fi
  cp $ff $f
  sleep .005
done
rm $ff
echo ""
grep "^Vm" $f # print memory info
rm $f
