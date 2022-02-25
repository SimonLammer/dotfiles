# Get the current cpu utilization in %.
# Adapted from https://rosettacode.org/wiki/Linux_CPU_utilization
BEGIN {
  prev_total = 0
  prev_idle = 0
  while (getline < "/proc/stat") {
    close("/proc/stat")
    idle = $5
    total = 0
    for (i=2; i<=NF; i++)
      total += $i
    if (prev_total != 0) {
      printf("%d\n", (1-(idle-prev_idle)/(total-prev_total))*100)
      exit(0)
    }
    prev_idle = idle
    prev_total = total
    system("sleep 1")
  }
}
