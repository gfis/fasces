#!perl

# Check for disproof of Problem 13.3/.4 on
# http://faculty.evansville.edu/ck6/integer/unsolved.html
# 2018-02-24, Georg Fischer
#------------------------------------------------------
# usage:
#   perl a1313.pl 88 32000 | perl chain388.pl
#------------------------------------------------------
# Problems and Rewards: $25 for proof (or $20 for counterexample) of each of the following propositions.
# (1) a(k) runs through all the positive integers; 
# (2) d(k) runs through all the integers; 
# (3) if d(k) > 0, then d(k+1) > 0 or d(k+2) > 0 or d(k+3) > 0; 
# (4) if d(k) < 0, then d(k+1) < 0 or d(k+2) < 0 or d(k+3) < 0.
#--------------------------------------------------------
use strict;

my @d;
my $k = 0;
while (<>) {
	$k ++;
	s/\s+\Z//;
	my ($ak, $dk) = split(/\s+/);
    $d[$k] = $dk;
	next if $k < 3;
    if (0) {
	} elsif ($d[$k - 3] > 0) {
		if ($d[$k - 2] <= 0 and $d[$k - 1] <= 0 and $d[$k] <= 0) {
			print "found> $k: d[k-3]=$d[$k-3], d[k-2]=$d[$k-2], d[k-1]=$d[$k-1], d[k]=$d[$k]\n";
		}
	} elsif ($d[$k - 3] < 0) {
		if ($d[$k - 2] >= 0 and $d[$k - 1] >= 0 and $d[$k] >= 0) {
			print "found< $k: d[k-3]=$d[$k-3], d[k-2]=$d[$k-2], d[k-1]=$d[$k-1], d[k]=$d[$k]\n";
		}
    }
} # while <>