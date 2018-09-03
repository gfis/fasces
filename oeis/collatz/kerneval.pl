#!perl

# Evaluate the connection between lkern and 3-2-free right kernels
# @(#) $Id$
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
                    my 
                    @parts = split(/\./, $lkern);
                    my $lknum = 3**$parts[0] * 2**$parts[1] * $parts[2];
                    @parts = split(/\./, $rkern);
                    my $rknum = 3**$parts[0] * 2**$parts[1] * $parts[2];
	                sprintf("%10s =%7d %8s =%7d %2d", $lkern, $lknum, $rkern, $rknum, $len)
                } split(/\r?\n/, `grep -E \"\\.$ikern,\" $infile`); # left kernel
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
#================================
__DATA__
The output is:
# --------
   lkern      rkern  len
       4      1.0.5    1
      34      3.0.5    5
     304      5.0.5    9
    2734      7.0.5   13
   24604      9.0.5   17
   
lkern is the input. It increases n -> 9n-2 in all lines.
The numbers before the first "." are the powers of 3,
which correlate with the length.
rkern * 3^k = 4*lkern - 1 in all lines.
# --------
       2      0.0.7    0
      16      2.0.7    3
     142      4.0.7    7
    1276      6.0.7   11
   11482      8.0.7   15
  103336     10.0.7   19
# --------
       3     0.0.11    0
      25     2.0.11    4
     223     4.0.11    8
    2005     6.0.11   12
   18043     8.0.11   16
  162385    10.0.11   20
# --------
      10     1.0.13    2
      88     3.0.13    6
     790     5.0.13   10
    7108     7.0.13   14
   63970     9.0.13   18
# --------
      13     1.0.17    1
     115     3.0.17    5
    1033     5.0.17    9
    9295     7.0.17   13
   83653     9.0.17   17
# --------
       5     0.0.19    0
      43     2.0.19    3
     385     4.0.19    7
    3463     6.0.19   11
   31165     8.0.19   15
# --------
       6     0.0.23    0
      52     2.0.23    4
     466     4.0.23    8
    4192     6.0.23   12
   37726     8.0.23   16
# --------
      19     1.0.25    2
     169     3.0.25    6
    1519     5.0.25   10
   13669     7.0.25   14
  123019     9.0.25   18
# --------
      22     1.0.29    1
     196     3.0.29    5
    1762     5.0.29    9
   15856     7.0.29   13
  142702     9.0.29   17
# --------
       8     0.0.31    0
      70     2.0.31    3
     628     4.0.31    7
    5650     6.0.31   11
   50848     8.0.31   15
# --------
       9     0.0.35    0
      79     2.0.35    4
     709     4.0.35    8
    6379     6.0.35   12
   57409     8.0.35   16
# --------
      28     1.0.37    2
     250     3.0.37    6
    2248     5.0.37   10
   20230     7.0.37   14
# --------
      31     1.0.41    1
     277     3.0.41    5
    2491     5.0.41    9
   22417     7.0.41   13
# --------
      11     0.0.43    0
      97     2.0.43    3
     871     4.0.43    7
    7837     6.0.43   11
   70531     8.0.43   15
# --------
      12     0.0.47    0
     106     2.0.47    4
     952     4.0.47    8
    8566     6.0.47   12
   77092     8.0.47   16
# --------
      37     1.0.49    2
     331     3.0.49    6
    2977     5.0.49   10
   26791     7.0.49   14
# --------
      40     1.0.53    1
     358     3.0.53    5
    3220     5.0.53    9
   28978     7.0.53   13
# --------
      14     0.0.55    0
     124     2.0.55    3
    1114     4.0.55    7
   10024     6.0.55   11
   90214     8.0.55   15
# --------
      15     0.0.59    0
     133     2.0.59    4
    1195     4.0.59    8
   10753     6.0.59   12
   96775     8.0.59   16
# --------
      46     1.0.61    2
     412     3.0.61    6
    3706     5.0.61   10
   33352     7.0.61   14
# --------
      49     1.0.65    1
     439     3.0.65    5
    3949     5.0.65    9
   35539     7.0.65   13
# --------
