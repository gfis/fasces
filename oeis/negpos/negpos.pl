#!perl

# Generate OEIS Sequence A131393 and its companions
# 2018-02-24, Georg Fischer
#------------------------------------------------------
# usage:
#   perl negpos.pl [noeis [n [oper a1 d1]]]
#       noeis = "131388|131389|1313393|131394..."
#       n     = length of sequence to be generated
#       oper  = ak, dk, dp, dn, ia, id 
#       a1    = starting value for a(1)
#       d1    = starting value for d(1)
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

my $noeis = "131393";
if (scalar(@ARGV) > 0) {
    $noeis = substr(shift(@ARGV), 1); # 1st argument without "A"
}
my $n = 1000;
if (scalar(@ARGV) > 0) {
    $n = shift(@ARGV); 
}
my $oper = "ak";
if (scalar(@ARGV) > 0) {
    $oper = shift(@ARGV); # 2nd argument: ak, dk, dp, dn, ia, id ...
}
my $a1 = 1;
if (scalar(@ARGV) > 0) {
    $a1 = shift(@ARGV); 
}
my $d1 = 0;
if (scalar(@ARGV) > 0) {
    $d1 = shift(@ARGV); 
}
my $k = 1;
my $ak = $a1; my $akm1 = $ak; my %aset = ($ak, $k);
my $dk = $d1; my $dkm1 = $dk; my %dset = ($dk, $k);
print "# http://oeis.org/A$noeis/b$noeis.txt:"
        . " table n,a(n),n=1..$n\n";
#    print "# ak = $ak, dk = $dk, akm1 = $akm1, dkm1 = $dkm1 \n";
print "$k " . (($oper eq "ak") ? $ak : $dk) . "\n";
$k ++;
while ($k <= $n) {
    my $busy = 1;
    $dk = -1;
    if (($noeis =~ m{131393|131394}) && $dkm1 < 0) { 
        $dk = $dkm1 - 1;
    } # else 131388|131389: without this condition
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
    if (0) {
    } elsif ($oper eq "ak") {
    	print "$k $ak";
    } elsif ($oper eq "dk") {
    	print "$k $dk";
    }
    # print "\t# ak = $ak, dk = $dk, akm1 = $akm1, dkm1 = $dkm1";
    print "\n";
    $akm1 = $ak; $dkm1 = $dk;
    $k ++; # iterate
} # while $k
if (1) { # output of operations other than "ak", "dk"
    if (0) {
    } elsif ($oper eq "dp") {
    	print "$k $ak";
    } elsif ($oper eq "dn") {
    	print "$k $dk";
    }
} # other oper
# https://oeis.org/wiki/User:Georg_Fischer Feb. 24, 2018
