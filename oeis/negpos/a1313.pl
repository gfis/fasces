#!perl

# Generate OEIS Sequence A131393 and its companions
# 2018-02-23, Georg Fischer
#------------------------------------------------------
# usage:
#   perl a1313.pl [oeisno [n]]
#       n   = length of sequence to be generated
#       oeisno = "A131388|A131389|A1313393|A131394..."
#------------------------------------------------------
# Formula:
# a(k) = a(k-1) + d(k) 
# d(k) = max({s, s-1 ... 1-a(k-1)}) such that
#   d(k) not in d(1..k-1) and
#   a(k) not in a(1..k-1)
# if no such d(k) exists, then
# d(k) = min({1,2, ... a(k-1)}) such that
#   d(k) not in d(1..k-1) and
#   a(k) not in a(1..k-1)
# s = -1 for A131388, and s = min(-1, d(k-1)) for A131393
#--------------------------------------------------------
use strict;

my $a1313 = "93";
if (scalar(@ARGV) > 0) {
    $a1313 = substr(shift(@ARGV), -2); # last 2 digits of 1st argument
}
my $n = 1000;
if (scalar(@ARGV) > 0) {
    $n = shift(@ARGV); # 2nd argument
}
my $k = 1;
my $ak = 1; my $akm1 = $ak; my %aset = ($ak, $k);
my $dk = 0; my $dkm1 = $dk; my %dset = ($dk, $k);
print "# http://oeis.org/A1313$a1313/b1313$a1313.txt:"
        . " table n,a(n),n=1..$n\n";
print "$k " . (($a1313 =~ m{88|93}) ? $ak : $dk) . "\n";
$k ++;
while ($k <= $n) {
    my $busy = 1;
    $dk = -1;
    if (($a1313 =~ m{93|94}) && $dkm1 < 0) { 
        $dk = $dkm1 - 1;
    } # else A131388|89: without this condition
    while ($busy == 1 and $dk > 1 - $akm1) { # negative
        $ak = $akm1 + $dk;
        if (!defined($aset{$ak}) and !defined($dset{$dk} and $ak>0)) {
            $busy=0; $aset{$ak} = $k;         $dset{$dk}=$k;
        } else {
            $dk --;
        }
    } # while negative
    if ($busy == 1) {
        $dk = +1;
    }
    while ($busy == 1                    ) { # positive
        $ak = $akm1 + $dk;
        if (!defined($aset{$ak}) and !defined($dset{$dk}          )) {
            $busy=0; $aset{$ak} = $k;         $dset{$dk}=$k;
        } else {
            $dk ++;
        }
    } # while positive
    print "$k " . (($a1313 =~ m{88|93}) ? $ak : $dk);
    # print "\t# ak = $ak, dk = $dk, akm1 = $akm1, dkm1 = $dkm1";
    print "\n";
    $akm1 = $ak; $dkm1 = $dk;
    $k ++; # iterate
} # while $k
# https://oeis.org/wiki/User:Georg_Fischer Feb. 24, 2018
