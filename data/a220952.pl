#!/usr/bin/perl
# 2017-08-21, Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
use strict;
use integer; # avoid division problems with reals

my $base   = 5; 
my $maxexp = 3;  # compute b-file up to $base**$maxexp

my @ent    = (0, 1, 2, 3, 4);   # "occupied" values, first power block 
my @ocp    = (0, 1, 2, 3, 4);   # "occupied" values, first power block 
my $pbl    = $base; # power block length: 5, 25, 125 ...
my $obl    = 1;     # old   block length:    5,  25  ...
my $iexp   = 2;     #                     1  2   3   ...
my $num    = 0;     # number corresponding to @digs
my $delta  = 1;     # +1, -1, or 0 if block is exhausted
my $idig   = 0;     # position of digit (for base $base) to be modified

while ($iexp <= $maxexp) {
	&exhaust_block();
	$iexp ++;
} # while $iexp

# print the b-file
# print "n\t\ta(n)\n";
my $ient = 0;
while ($ient <= $pbl) { # print b-file lines
	print "$ient";
	print "\t " . &based($ient, $pbl);
 	print "\t$ent[$ient]";
	print "\t " . &based($ent[$ient], $pbl);
	print "\t " . &based($ocp[$ient], $pbl);
	print "\n";
	$ient ++;
} # while printing

#--------
sub exhaust_block {
	$obl = $pbl;
	$pbl *= $base; # = $base**$iexp
	my $ibl = 0;
	while ($ibl < $obl) { # copy complement of old block (reversed) to upper end of block
		$ent[$pbl - 1 - $ibl] = $pbl - 1 - $ent[$ibl];
		$ibl ++;
	} # while copying
	$ent[$pbl] = 2 * $pbl - 1;
	while ($ibl < $pbl - $obl) { # fill rest of block with "unknown"
		$ent[$ibl] = -1; # "unknown"
		$ocp[$ibl] = -1; # "free"
		$ibl ++;
	} # while filling
	my $oen = $obl + $obl - 1;
	$idig = $iexp;
	print "#---- exhaust pbl=$pbl, iexp=$iexp, idig=$idig, oen=$oen\n";
	&store($obl, $oen);
	$ibl = $obl + 1;
	my $half = ($pbl - 1) >> 1; 
	my $repeat = 0;
	my $ddig   = 1; # delta for $idig
	while ($ibl <= $half) { # compute the unknown entries
		my $nen = &advance($oen, $idig);
		print "#advance[$ibl] " . &based($oen, $pbl) . "->". &based($nen, $pbl) . ", rep=$repeat\n";
		if ($nen >= 0 and $ent[$ibl] < 0 and $ent[$pbl - 1 - $ibl] < 0 and $ocp[$nen] < 0) { # possible
			&store($ibl, $nen);
			$repeat = 0;
		} else {
			$repeat ++;
			if (0) {
			} elsif ($repeat == 1) { # move same direction
				$idig += 1;
				if ($idig >= $iexp or $idig < 0) {
					$idig -= 1; # try again in next repetition
				}
			} elsif ($repeat == 2) {
				$delta = - $delta;
			} elsif ($repeat == 3) { # move opposite direction
				$ddig = - $ddig;
				$idig += -1;
				if ($idig >= $iexp or $idig < 0) {
					$idig -= -1; # try again in next repetition
				}
			} elsif ($repeat == 4) {
				$delta = - $delta;
			} else {
				$repeat = 0;
			}
		} # repetition
		if ($repeat <= 0) {
			$oen = $nen;
			$ibl ++;
		}
	} # while computing
} # exhaust_block
#--------
sub store {
	# store an entry at the beginning 
	# and its complement at the end of the block 
	# and return 1
	# if those positions are not yet occupied, 
	# or return 0 if at least one was occupied
	my ($ibl, $num) = @_;
	$ent[$ibl]            = $num;
	$ent[$pbl - 1 - $ibl] = $pbl - 1 - $num;
	$ocp[$num]            = $num;
	$ocp[$pbl - 1 - $num] = $pbl - 1 - $num;
	print "#  set[$ibl] = " . &based($num, $pbl) . "," . &based($pbl - 1- $num, $pbl) . "\n";
} # store
#--------
sub advance {
	# increment resp. decrement the digit at position $ipos
	# return the modified number, 
	# or -1 if advancing was not possible
	my $result = -1;
	my ($num, $idig) = @_;
	my $ipos = $idig;
	my $tnum = $num; # temporary
	my $bpow = $delta; # signed power of base
	while ($ipos > 0) {
		$tnum = $tnum / $base;
		$bpow *= $base;
		$ipos --;
	} # while $ipos
	my $digit = $tnum % $base + $delta;
	if ($digit >= $base or $digit < 0) {
		$result = -1; # not possible
	} else {
		$result = $num + $bpow;
	}
	return $result;
} # advance
#--------
sub based {
	# return a number in base $base
	my ($num, $pbl) = @_;
	my $bpow = 1;
	my $result = "";
	if ($num < 0) {
		$result = $num;
	} else {
		while ($bpow < $pbl) {
			$result = ($num % $base) . $result;
			$num    /= $base;
			$bpow   *= $base;
		} # while $idig
	}
	return "$result"; # ($base)";
} # based
#--------
__DATA__
n		a(n)	base 5: 
0		0   	00       
1		1   	01      
2		2   	02      
3		3   	03      
4		4   	04      
5		9   	14      
6		14  	24      
7		19  	34      
8		18  	33      
9		17  	32      
10		16  	31      
11		11  	21      
12		12  	22      
13		13  	23      
14		8   	13      
15		7   	12      
16		6   	11      
17		5   	10      
18		10  	20      
19		15  	30      
20		20  	40      
21		21  	41      
22		22  	42      
23		23  	43      
24		24  	44      
25		49  	144     

X
 X 
  X
   X
    X
         X
              X
                   X
                  X
                 X
                X
           X
            X
             X
        X
       X
      X
     X
          X
               X
                    X
                     X
                      X
                       X   
                        X
                                                 X