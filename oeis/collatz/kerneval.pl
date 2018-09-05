#!perl

# Evaluate the connection between lkern and 3-2-free right kernels
# @(#) $Id$
# 2018-09-05: new kernel format
# 2018-08-31, Georg Fischer; Rainer Th. = 76
#------------------------------------------------------
# Usage:
#   perl collatz_rails.pl -a simple -n 1000000 > rails.html
#   make kernels
#   perl kerneval.pl -n 256 kernels.tmp
#--------------------------------------------------------
use strict;
use integer;
#----------------
# get commandline options
my $debug  = 0;
my $maxn   = 256; # max. start value
my $action = "simple";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my $infile = shift(@ARGV);
#----------------
# initialization
#----------------
# perform one of the possible actions
if (0) { # switch action
} elsif ($action =~ m{simple}) { # straightforward incrementing of the start values
    my $ikern = 1;
    while ($ikern < $maxn) {
        if ($ikern % 3 != 0) { # is 3-2-free
            print "# " . sprintf("%d", $ikern) . " --------\n";
            my @result = map {
                	my ($lkern, $rkern, $len) = split(/[\,\>]/, $_);
                    my $lknum = &from_kernel($lkern);
                    my $rknum = &from_kernel($rkern);
	                sprintf("%10s =%7d %8s =%7d %2d", $lkern, $lknum, $rkern, $rknum, $len)
                } split(/\r?\n/, `grep -E \">$ikern\[:\\.\]\" $infile`); # right kernel
            print join("\n", @result) . "\n";
        } # 3-2-free
        $ikern += 2;
    } # while $ikern
} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
# output the resulting array
#----------------
# termination
# end main
#----------------
sub from_kernel { # for a kernel, return n
    my ($elem)  = @_;
    my @kern    = split(/[\.\:]/, $elem);
    $kern[1] = 0 if ($kern[1] eq "");
    $kern[2] = 0 if (scalar(@kern) == 2);
    my $result = $kern[0] * 2**$kern[1] * 3**$kern[2];
    return $result;
} # from_kernel
#================================
__DATA__
lkern is the input. It increases n -> 9n-2 in all lines.
The numbers before the first "." are the powers of 3,
which correlate with the length.
rkern * 3^k = 4*lkern - 1 in all lines.
The output is:

     lkern             rkern           len
# 1 --------
        1. =      1      1:1 =      2  1
        7. =      7      1:3 =      8  3
       61. =     61      1:5 =     32  5
      547. =    547      1:7 =    128  7
     4921. =   4921      1:9 =    512  9
# 5 --------
       1.2 =      4      5:1 =     10  1
      17.1 =     34      5:3 =     40  3
      19.4 =    304      5:5 =    160  5
    1367.1 =   2734      5:7 =    640  7
# 7 --------
       1.1 =      2       7. =      7  0
       1.4 =     16      7:2 =     28  2
      71.1 =    142      7:4 =    112  4
     319.2 =   1276      7:6 =    448  6
    5741.1 =  11482      7:8 =   1792  8
# 11 --------
       1:1 =      2      11. =     11  0
       25. =     25     11:2 =     44  2
      223. =    223     11:4 =    176  4
     2005. =   2005     11:6 =    704  6
# 13 --------
       5.1 =     10     13:1 =     26  1
      11.3 =     88     13:3 =    104  3
     395.1 =    790     13:5 =    416  5
    1777.2 =   7108     13:7 =   1664  7
# 17 --------
       13. =     13     17:1 =     34  1
      115. =    115     17:3 =    136  3
     1033. =   1033     17:5 =    544  5
     9295. =   9295     17:7 =   2176  7
# 19 --------