#!/usr/bin/perl
# 2017-08-25, Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952

use strict;
use integer; # avoid division problems with reals

my $debug = 1;
my $base   = 5; 
my $maxexp = 20;  # compute b-file up to $base**$maxexp
if (scalar(@ARGV) > 0) {
    $maxexp = shift(@ARGV);
}

my $ind = 0;
my $bpow = 1;
while ($ind <= $maxexp) {
	print "$ind $bpow\n";
	$ind ++;
	$bpow *= 5;
} # while $ind

__DATA__
0 1
1 5
2 25
3 125
4 625
5 3125
6 15625
7 78125
8 390625
9 1953125
10 9765625
11 48828125
12 244140625
13 1220703125
14 6103515625
15 30517578125
16 152587890625
17 762939453125
18 3814697265625
19 19073486328125
20 95367431640625
