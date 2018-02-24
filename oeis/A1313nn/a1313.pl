#!perl

# OEIS Sequence A131393
# 2018-02-23, Georg Fischer

# FORMULA   
# The following version of "Rule 2" is defective; see
# Comments. - Clark Kimberling, May 18 2015
# 
# Rule 2 ("positive before negative"): define sequences d( )
# and a( ) as follows: d(1)=0, a(1)=1 and for n>=2, d(n) is
# the least positive integer d such that a(n-1)+d is not among
# a(1), a(2),...,a(n-1), or, if no such d exists, then d(n) is
# the greatest negative integer d such that a(n-1)+d is not
# among a(1), a(2),...,a(n-1). Then a(n)=a(n-1)+d.
# 
# EXAMPLE   
# a(2)=1+1, a(3)=a(2)+2, a(4)=a(3)+(-1), a(5)=a(4)+3,
# a(6)=a(5)+4.
# 
# The first term that differs from A131388 is a(28)=42.
#------------------------------------------------------
# usage:
#   perl posneg.pl [max_n [seq]]
#       n   = length of sequence
#       seq = "A131388|A131389|A1313393|..."
#------------------------------------------------------
use strict;

my $a1313 = "88";
if (scalar(@ARGV) > 0) {
    $a1313 = substr(shift(@ARGV), -2); # last 2 digits of 1st argument
}
my $n = 72;
if (scalar(@ARGV) > 0) {
    $n = shift(@ARGV); # 2nd argument
}
my $k = 1;
my $ak = 1;
my $akm1 = $ak;
my %aset = ($ak, $k);
my $dk = 0;
my $dkm1 = $dk;
my %dset = ($dk, $k);
print "# http://oeis.org/A1313$a1313/b1313$a1313.txt: table n,a(n),n=1..$n\n";
print "$k " . (($a1313 =~ m{88|93}) ? $ak : $dk) . "\n";
$k ++;
while ($k <= $n) {
    my $busy = 1;
    $dk = -1;
    if (($a1313 =~ m{93|94}) && $dkm1 < 0) {
    	$dk = $dkm1 - 1;
    }
    while ($busy == 1 and $dk > 1 - $akm1) { # negative
        $ak = $akm1 + $dk;
        if ($ak > 0 and ! defined($aset{$ak}) and ! defined($dset{$dk})) {
            $busy = 0;            $aset{$ak} = $k;          $dset{$dk} = $k;          
        } else {
        	$dk --;
        }
    } # while negative
    if ($busy == 1) {
    	$dk = +1;
    }
    while ($busy == 1                    ) { # positive
        $ak = $akm1 + $dk;
        if ($ak > 0 and ! defined($aset{$ak}) and ! defined($dset{$dk})) {
            $busy = 0;            $aset{$ak} = $k;          $dset{$dk} = $k;          
        } else {
	        $dk ++;
	    }
    } # while positive
    if ($busy == 1) {
        print "n=$k, assertion: still busy\n";
        exit(1);
    }
    print "$k " . (($a1313 =~ m{88|93}) ? $ak : $dk);
    # print "\t# ak = $ak, dk = $dk, akm1 = $akm1, dkm1 = $dkm1";
    print "\n";
    $akm1 = $ak;
    $dkm1 = $dk;
    $k ++; # iterate
} # while $k
