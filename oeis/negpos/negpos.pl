#!perl

# Generate OEIS Sequence A131393 and its companions
# 2018-02-24, Georg Fischer
#------------------------------------------------------
# C.f. list of sequences in https://oeis.org/search?q=A257705
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
    if (0) {
    } elsif ($oper eq "ak") {
        print "$k $ak\n";
    } elsif ($oper eq "dk") {
        print "$k $dk\n";
    }
my $busy;
$k ++;
while ($k <= $n) {
    $busy = 1;
    $dk = -1;
    if (($noeis =~ m{131393|131394|131395|131396|131397}) && $dkm1 < 0) { 
        $dk = $dkm1 - 1;
    } # else 131388|131389 etc. without this condition
    while ($busy == 1 and $dk > $d1 - $akm1) { # negative
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
        print "$k $ak\n";
    } elsif ($oper eq "dk") {
        print "$k $dk\n";
    }
    # print "\t# ak = $ak, dk = $dk, akm1 = $akm1, dkm1 = $dkm1\n";
    $akm1 = $ak; $dkm1 = $dk;
    $k ++; # iterate
} # while $k
#--------
if ($oper !~ m{ak|dk}) { # output of operations other than "ak", "dk"
    my @ainv = sort(map { $_ = sprintf("%06d %d", $_, $aset{$_}); $_ } keys(%aset));
    my @dpos = sort(map { $_ = sprintf("%06d %d", $dset{$_}, $_); $_ } keys(%dset));
    my $temp = shift(@dpos); # accounts for positions "-1"
    # print join("\n", @dpos) . "\n";
    if (0) {
    } elsif ($oper =~ m{in}) {
        $k = 0;
        $busy = 1;
        while ($busy == 1 and $k < scalar(@ainv)) {
            my ($j, $aj) = split(/ /, $ainv[$k]);
            $j += 0; # removes the leading zeroes
            $busy = ($j == $k + 1 ? 1 : 0);
            if ($busy == 1) {
                print "$j $aj\n";
            }
            $k ++;
        } # while $k
    } elsif ($oper =~ m{dp}) {
        my $k = 0;
        print join("", map { my ($j, $dj) = split(/\s+/); 
                $j --; $_ = "";
                if ($dj > 0) {
                    $k ++;
                    $_ = "$k $j\n";
                }
                $_ } @dpos) . "\n";
    } elsif ($oper =~ m{dn}) {
        my $k = 0;
        print join("", map { my ($j, $dj) = split(/\s+/); 
                $j --; $_ = "";
                if ($dj < 0) {
                    $k ++;
                    $_ = "$k $j\n";
                }
                $_ } @dpos) . "\n";
    }
} # other oper
# https://oeis.org/wiki/User:Georg_Fischer Feb. 24, 2018
