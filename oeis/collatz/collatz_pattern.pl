#!perl

# FOllow patterns in the Collatz graph
# @(#) $Id$
# 2018-08-20, Georg Fischer
#------------------------------------------------------
# usage:
#   perl collatz_pattern.pl start
#
# c.f. example behind __DATA__, below,
#--------------------------------------------------------
use strict;
use integer;

my $debug  = 0;
my $elem0  = 8;
my $maxn   = shift(@ARGV); # start value
while ($elem0 < $maxn) {
	if ($elem0 % 3 != 0) {
		&rope2($elem0);
	}
	$elem0 += 2;
} # while incrementing

sub rope2 {
	my ($elem0) = @_;
	print "$elem0\t";
	my $elem1  = $elem0; # 2 parallel threads: $elem0 (upper, left), $elem1 (lowe, right)
	my $state  = ">>"; # both resulted from mult.
	my $busy   = 1; # as long as loop should continue
	# print "($elem0 $elem1) $state ";	
	while ($busy == 1) {
		if (0) {
		} elsif ($state eq ">>") { 
			$elem0 = ($elem0 - 1) / 3; # possible because of preparation above
			$elem1 = $elem1 * 2;
			$state = "<<";
		} elsif ($state eq "<<") { 
			$elem0 = $elem0 * 2; # always possible
			$elem1 = $elem1 * 2;
			$state = "*";
		} elsif ($state eq "*") { 
			if (($elem1 - 1) % 3 == 0) {
				$elem1 = ($elem1 - 1) / 3;
				$elem0 = $elem0 * 2; # always possible
				$state = "/";
				if ($elem0 % 3 == 0) {
					$busy  = 0;
					$state = " 0/3";
				} elsif ($elem1 % 3 == 0) {
					$busy  = 0;
					$state = " 1/3";
				}
			} else {
				$busy  = 0;
				$state = " 1n3";
			}
		} elsif ($state eq "/") { 
			if (($elem0 - 1) % 3 == 0) {
				$elem0 = ($elem0 - 1) / 3;
				$elem1 = $elem1 * 2; # always possible
				$state = "*";
				if ($elem0 % 3 == 0) {
					$busy  = 0;
					$state = " 0/3";
				} elsif ($elem1 % 3 == 0) {
					$busy  = 0;
					$state = " 1/3";
				}
			} else {
				$state = " 0n3";
				$busy  = 0;
			}
		} else { 
			die "invalid state \"$state\"\n";
        }
        print "$elem0,$elem1 $state ";
	} # while busy
	print "\n";
} # rope2
#-----------------
__DATA__
A070165:
142/104: [142 m  71 d 214 m 107 d 322 m 161 d 484 m  242 m 121 d | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
           +1  *6+4    +1  *6+4    +1  *6+4    +1   *6+4  *6+2     =     =   ...
143/104: [143 d 430 m 215 d 646 m 323 d 970 m 485 d 1456 m 728 m | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
              i     i     i     i     i     i     i      1     1       0
124 m 62 m  31 d 94 m  47 d 142 m
 +2   +1  *6+4    +1 *6+4    +1
126 m 63 d 190 m 95 d 286 m 143 d
         i     i    i     i     i