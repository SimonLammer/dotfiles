#!/usr/bin/perl
# source: https://stackoverflow.com/a/596960/2808520

use strict;
use warnings;

use POSIX qw(strftime);
use Time::HiRes qw(gettimeofday usleep);

my $dev = @ARGV ? shift : 'eth0';
my $dir = "/sys/class/net/$dev/statistics";
my %stats = do {
    opendir +(my $dh), $dir;
    local @_ = readdir $dh;
    closedir $dh;
    map +($_, []), grep !/^\.\.?$/, @_;
};

if (-t STDOUT) {
    while (1) {
        print "\033[H\033[J", run();
        my ($time, $us) = gettimeofday();
        my ($sec, $min, $hour) = localtime $time;
        {
            local $| = 1;
            printf '%-31.31s: %02d:%02d:%02d.%06d%8s%8s%8s%8s',
            $dev, $hour, $min, $sec, $us, qw(1s 5s 15s 60s)
        }
        usleep($us ? 1000000 - $us : 1000000);
    }
}
else {print run()}

sub run {
    map {
        chomp (my ($stat) = slurp("$dir/$_"));
        my $line = sprintf '%-31.31s:%16.16s', $_, $stat;
        $line .= sprintf '%8.8s', int (($stat - $stats{$_}->[0]) / 1)
            if @{$stats{$_}} > 0;
        $line .= sprintf '%8.8s', int (($stat - $stats{$_}->[4]) / 5)
            if @{$stats{$_}} > 4;
        $line .= sprintf '%8.8s', int (($stat - $stats{$_}->[14]) / 15)
            if @{$stats{$_}} > 14;
        $line .= sprintf '%8.8s', int (($stat - $stats{$_}->[59]) / 60)
            if @{$stats{$_}} > 59;
        unshift @{$stats{$_}}, $stat;
        pop @{$stats{$_}} if @{$stats{$_}} > 60;
        "$line\n";
    } sort keys %stats;
}

sub slurp {
    local @ARGV = @_;
    local @_ = <>;
    @_;
}
