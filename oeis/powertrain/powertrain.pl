#!perl

# powertrain.pl - 
# c.f. <https://www.spektrum.de/magazin/powertrain/1669402>
# 2019-09-24, Georg Fischer
use strict;
use integer;

my $digits = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZäöü"; # for counting in base 11, 13, ...
#                       012345678901234567890123456789012345678901234567890123456789
#                       1         2         3         4         5         6
my $base = 10;
my $nmax = 3000;
if (scalar(@ARGV) > 0) {
	$base = shift(@ARGV);
}
if (scalar(@ARGV) > 0) {
	$nmax = shift(@ARGV);
}

my $n = 0;
while ($n <= $nmax) {
    $n ++;
    my $fix = &train(&to_base($n));
    if (1 or length($fix) > 1) {
    	print "fix($n) = $fix\n";
    }
} # while $n

sub train {
    my ($n) = @_;
    my $oldn = 0;
    while (length($n) != 1 and $n != $oldn) {
        $oldn = $n;
        if (length($n) % 2 == 1) { # odd
            $n .= "1";
        }
        my $in = 0;
        my $prod = 1;
        while ($in < length($n)) {
            $prod = $prod * (&to_dec(substr($n, $in, 1)) ** &to_dec(substr($n, $in + 1, 1)));
            $in += 2;
        } # while $in
        print "$n -> $prod\n";
        $n = &to_base($prod);
    } # while $n
    return $n;
} # train

# convert from decimal to base, without leading zeroes
sub to_base { my ($num) = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $base;
        $result =  substr($digits, $digit, 1) . $result;
        $num /= $base;
    } # while > 0
    return $result eq "" ? "0" : $result;
} # to_base

sub to_dec { my ($bdig) = @_;
    return index($digits, $bdig);
} # to_dec
__DATA__
2592 keinen anderen Fixpunkt. 
Sein Kollege Neil Sloane stellte allerdings fest, dass
24 547 284 284 866 560 000 000 000

odd number of digits => append 1
0^0 = 1