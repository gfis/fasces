#!perl

# @(#) $Id$
# 2019-01-21, Georg Fischer
#
use strict;
use integer;

my $lim = 16;
if (scalar(@ARGV) > 0) {
	$lim = shift(@ARGV);
}
my $num;
if (1) {
	map {
		$num = $_;
		print sprintf("%10d %48b %48b\n", $num, 2*$num*$num - 1, 2*$num*$num - 1)
	} (1, 18480, 8388480, 89, 281, 881, 7, 151, 641, 6700417);
}
for $num (1..$lim) {
	my $sq = 2 * $num*$num - 1;
	print sprintf("%048b %20d\n", $sq, $sq);
}


__DATA__
x0*y0+
10x1*y0+
100x2*y0+
1000x3*y0+
10000x4*y0+
100000x5*y0+
10x0*y1+
100x1*y1+
1000x2*y1+
10000x3*y1+
100000x4*y1+
1000000x5*y1+
100x0*y2+
1000x1*y2+
10000x2*y2+
100000x3*y2+
1000000x4*y2+
10000000x5*y2+
1000x0*y3+
10000x1*y3+
100000x2*y3+
1000000x3*y3+
10000000x4*y3+
100000000x5*y3+
10000x0*y4+
100000x1*y4+
1000000x2*y4+
10000000x3*y4+
100000000x4*y4+
1000000000x5*y4+
100000x0*y5+
1000000x1*y5+
10000000x2*y5+
100000000x3*y5+
1000000000x4*y5+
10000000000x5*y5


A247205		Numbers n such that 2*n^2 - 1 divides 2^n - 1.		1
1, 18480, 8388480 (list; graph; refs; listen; history; edit; text; internal format)
OFFSET	
1,2

COMMENTS	
a(4) > 2*10^10. - Chai Wah Wu, Dec 06 2014

EXAMPLE	
1 is in this sequence because 2*1^2 - 1 = 1 divides 2^1 - 1 = 1.

PROG	
(MAGMA) [n: n in [1..100000] | Denominator((2^n-1)/(2*n^2-1)) eq 1];

(PARI) for(n=1, 10^9, if(Mod(2, 2*n^2-1)^n==+1, print1(n, ", "))); \\ Joerg Arndt, Nov 30 2014

CROSSREFS	
Cf. A247219, A247221.

KEYWORD	
nonn,more,bref

AUTHOR	
Juri-Stepan Gerasimov, Nov 30 2014

EXTENSIONS	
a(3) from Joerg Arndt, Nov 30 2014

STATUS	
approved
