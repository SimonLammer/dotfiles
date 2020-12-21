#!/bin/perl -nw

# This converts ANSI color escape sequences to TMUX color escape sequences,
#   which can be used in the status line.
# Example: "\x1b[31mERROR\x1b[0m" -> "#[fg=red,]ERROR#[default,]"

# The following SGR codes are supported:
# - 0
# - 1
# - 30 - 49
# - 90 - 97
# - 100 - 107

use warnings;
use strict;

my @colors = ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white");
while(/(.*?)(\x1b\[((\d+;?)+)m)/gc) {
	print "$1#[";
	my @sgr = split /;/, $3;
	for(my $i = 0; $i <= $#sgr; $i++) {
		if ($sgr[$i] eq "0") {
			print "default";
		} elsif ($sgr[$i] eq "1") {
			print "bright";
		} elsif ($sgr[$i] =~ /(3|4|9|10)(\d)/) {
			if ($1 eq "3") {
				print "fg=";
			} elsif ($1 eq "4") {
				print "bg=";
			} elsif ($1 eq "9") {
				print "fg=bright";
			} elsif ($1 eq "4") {
				print "bg=bright";
			}
			if ($2 eq "8") { # SGR 38 or 48
				$i++;
				if ($sgr[$i] eq "5") {
					$i++;
					print "colour" . $sgr[$i];
				} elsif ($sgr[$i] eq "2") {
					printf("#%02X%02X%02X", $sgr[$i + 1], $sgr[$i + 2], $sgr[$i + 3]);
					$i += 3;
				} else {
					die "Invalid SGR 38;" . $sgr[$i];
				}
			} elsif ($2 eq "9") {
				print "default";
			} else {
				print $colors[$2];
			}
		} else { # Unknown/ignored SGR code
			next;
		}
		print ",";
	}
	print "]";
}
/\G(.*)/gs;
print "$1";
