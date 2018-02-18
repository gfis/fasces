#!/usr/bin/perl
# Generate OEIS sequence A220952 like the Maple program of R. J. Mathar, Aug 25 2017
# 2017-08-30: Georg Fischer, new version in Perl
#
# usage : 
#     perl mathar.pl [limit]
#-----------------------------------------------
use strict;
use integer; # avoid division problems with reals

my $prs = "/0,1/1,2/2,3/3,4/4,9/9,14/14,19/18,19/17,18/16,17/11,16/11,12/12,13/8,13/7,8/6,7/5,6/5,10/10,15/15,20/20,21/21,22/22,23/23,24/";
my $n = 0;
my @memory = (); # for "option remember" in &iterate
my $limit = 100;
if (scalar(@ARGV) > 0) {
	$limit = shift(@ARGV);
}
print "# n, a(n) for n = 0..$limit\n";
while ($n <= $limit) {
    print "$n " . &iterate($n) . "\n";
    $n ++;
} # while n
#--------
# Test if aseq and bseq are adjacent in the 5x5 grid
# @param aseq The sequentialized representation of point a (0..24)
# @param bseq The sequentialized representation of point b (0..24)
sub isAdjVseq {
    my ($aseq, $bseq) = @_;
    return index($prs, "/$aseq,$bseq/") >= 0;
} # isAdjVseq
#--------
# Test whether points (a1, a2) and (b1, b2) are adjacent.
# @parm a1 horizontal coordinate of point a (0..4)
# @parm a2 vertical coordinate of point a (0..4)
# @parm b1 horizontal coordinate of point b (0..4)
# @parm b2 vertical coordinate of point b (0..4)
sub isAdjV {
    my ($a1, $a2, $b1, $b2) = @_;
    # skip test if (a1, a2) = (b2, b2)
    if ($a1 == $b1 and $a2 == $b2) {
        return 1;
    }
    # map the x and y coordinates to a unique representation (0..24)
    my $aseq = 5 * $a1 + $a2;
    my $bseq = 5 * $b1 + $b2;
    return &isAdjVseq($aseq < $bseq ? $aseq : $bseq, $aseq > $bseq ? $aseq : $bseq);
} # isAdjV
#--------
sub min {
    # return a number in base $base, 
    my ($a, $b) = @_;
    return $a < $b ? $a : $b;
} # min
#--------
sub max {
    # return a number in base $base, 
    my ($a, $b) = @_;
    return $a > $b ? $a : $b;
} # max
#--------
sub convert5 {
    # return a number in base 5
    my $base = 5;
    my ($num) = @_;
    my $result = "";
    while ($num > 0) {
       $result = ($num % $base) . $result;
       $num   /= $base;
    } # while $idig
    return $result eq "" ? "0" : $result; 
} # convert5
#--------
# Test whether integers a and b are adjacent as in Knuth's Amer. Math. Monthly Problem 11733
# @param a first integer
# @param b second integer
sub isKAdj {
    my ($a, $b) = @_;
    # point is not adjacent to itself
    if ($a == $b) {
        return 0;
    }
    # obtain the two sequences of the base 5 digits
    my $a5 = &convert5($a < $b ? $a : $b) ;
    my $b5 = &convert5($a > $b ? $a : $b) ;
    # fill with zeros if the number of digits differs
    while (length($a5) < length($b5)) {
        $a5 = "0$a5";
    } # while filling
    my $len = length($a5);
    # test each pair of digits in the base-5 representation
    for (my $j = 0; $j < $len - 1; $j ++) {
        for (my $i = $j + 1; $i < $len; $i++) {
            if (&isAdjV(substr($a5, $len - 1 - $i, 1), substr($a5, $len - 1 - $j, 1)
                    ,   substr($b5, $len - 1 - $i, 1), substr($b5, $len - 1 - $j, 1)) == 0) {
                return 0;
            }
        } # for i
    } # for j
    return 1 ;
} # isKAdj
#--------
sub iterate { # recursive
    my ($n) = @_;
    my ($a, $nprev);
    if ($n == 0) {
        return 0;
    } else {
        $a = 0; 
        while (1) {
            if (&isKAdj($a, $memory[$n - 1])) {
                my $known = 0;
                my $busy = 1;
                $nprev = 0; 
                while ($busy == 1 and $nprev <= $n - 1) {
                    if ($memory[$nprev] == $a) {
                        $known = 1;
                        $busy = 0;
                    }
                    $nprev ++;
                } # while $busy
                if ($known <= 0) {
                    $memory[$n] = $a;
                    return $a;
                }
            } # if isKAdj
            $a ++;
        } # for $a
    } # != 0
} # iterate
# seq( A220952(n), n=0..100) ; # R. J. Mathar, Aug 25 2017
