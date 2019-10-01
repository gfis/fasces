#!perl

# powertrain.pl -
# @(#) $Id$
# 2019-10-01: with hashes
# 2019-09-24, Georg Fischer
# c.f. <https://www.spektrum.de/magazin/powertrain/1669402>
# All variables ending with "b" are in $base representation.
#:# usage:
#:#   perl powertrain.pl [-b base] [-m nmax] [-s single] [-d debug]
#:#       -b base    (default 10)
#:#       -m nmax    range to be checked (default 3000)
#:#       -s single  single number to be checked
#:#       -d debug   level n (default: 0 = none)
#-----------------------------------------------
use strict;
use integer;
use Math::BigInt;
use Math::BigInt':constant';

my $digits = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZäöü"; # for counting in base 11, 13, ...
#                       012345678901234567890123456789012345678901234567890123456789
#                       1         2         3         4         5         6
my $base    = 10;
my $debug   = 0;
my $nsingle = 0;
my $nmin    = 0;
my $nmax    = 30000;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-b}) {
        $base   = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-m}) {
        $nmax   = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $nsingle  = shift(@ARGV);
        $nmin = $nsingle;
        $nmax = $nsingle;
    }
} # while opt

my %pmap = (); # powertrain map
my %pfix = (); # numbers participating in a fixpoint (cycle)
# range 1..$nmax
my $n = $nmin;
while ($n <= $nmax) {
    my $fix  = &train($n);
    my $fixb = &to_base($fix); # $fix->to_base($base); # 
    if ($debug >= 1 or length($fixb) > 1) {
        print "$n(10) ->\tfixpoint $fix(10)=$fixb($base)\n";
    }
    $n ++;
} # while $n
#--------
sub train {
    my ($n) = @_;
    my $nb = Math::BigInt->new($n);
    $nb = &to_base($nb); # $nb->to_base($base); # 
    if ($debug >= 2 or $n % 1000 == 0) {
        print "powertrain($n(10)=$nb($base))\n";
    }
    my $oldnb = 0;
    my $prod = 1;
    while (length($nb) != 1 and $nb ne $oldnb) {
        $oldnb = $nb;
        if (length($nb) % 2 == 1) { # odd - exponent is missing
            $nb .= "1"; # assume exponent 1
        }
        my $inb = 0;
        $prod = &compute($nb);
        my $prodb = &to_base($prod); # $prod->to_base($base); # 
        if ($debug >= 2) {
            print "$nb($base) -> $prod(10)=$prodb($base)\n";
        }
        $nb = $prodb;
    } # while $n
    return $prod;
} # train

# compute the product
sub compute { my ($nb) = @_;
    my $prod = Math::BigInt->new(1);
    my $inb = 0;
    while ($inb < length($nb) and ! $prod->is_zero()) {
        my $a = &to_dec(substr($nb, $inb    , 1));
        my $b = &to_dec(substr($nb, $inb + 1, 1));
        $prod = $prod->bmul(&pow($a, $b));
        $inb += 2;
    } # while $inb
    return $prod;
} # compute 

# compute a**b - up to 15**14
sub pow { my ($a, $b) = @_;
    my $result = Math::BigInt->new(1);
    if ($b == 0) {
        # 0^0 = 1, already ok
    } elsif ($b == 1) {
        $result = Math::BigInt->new($a);
    } else {
        $result = Math::BigInt->new($a)->bpow($b);
    }
    if ($debug >= 3) {
        print "$a ** $b = $result\n";
    }
    return $result;
} # pow

# convert from decimal to base, without leading zeroes
sub to_base { my ($pnum) = @_;
    my $num = Math::BigInt->new($pnum);
    my $result = "";
    while ($num->is_positive()) {
        my ($quo, $digit) = $num->bdiv($base);
        $result = substr($digits, $digit, 1) . $result;
        # $num = $num->bdiv($base);
    } # while > 0
    return $result eq "" ? "0" : $result;
} # to_base

# convert 1 $base digit back to decimal
sub to_dec { my ($bdig) = @_;
    return index($digits, $bdig);
} # to_dec
#------------------------------------------
__DATA__
2592 keinen anderen Fixpunkt.
Sein Kollege Neil Sloane stellte allerdings fest, dass
24 547 284 284 866 560 000 000 000

odd number of digits => append 1
0^0 = 1

2 - none <= 30000
3 - none <= 40000
4 - none <= 30000
5 - none <= 30000

2960(10) ->     fixpoint 16(10)=24(6)

7 - none <= 30000

5344(10) ->     fixpoint 24586240(10)=51232874(9)
6464(10) ->     fixpoint 24586240(10)=51232874(9)

642(10) ->      fixpoint 2592(10)=2592(10)
2164(10) ->     fixpoint 2592(10)=2592(10)
2534(10) ->     fixpoint 2592(10)=2592(10)
2592(10) ->     fixpoint 2592(10)=2592(10)

11 - none <= 3000

3661(10) ->     fixpoint 10(10)=A(12)
5833(10) ->     fixpoint 486(10)=346(12)
6505(10) ->     fixpoint 39366(10)=1A946(12)

13 - none <= 30000
14 - none <= 30000
15 - none <= 30000

25143(10) ->    fixpoint 78732(10)=1338c(16)

29652(10) ->    fixpoint 10000(10)=20a4(17)

24679(10) ->    fixpoint 768(10)=26c(18)

1604(10) ->     fixpoint 524288(10)=40862(19)
1617(10) ->     fixpoint 524288(10)=40862(19)
3004(10) ->     fixpoint 524288(10)=40862(19)

124(10) ->      fixpoint 1296(10)=34g(20)

937(10) ->      fixpoint 1024(10)=26g(21)

27082(10) ->    fixpoint 2048(10)=452(22)

23 -none <= 30000

4116(10) ->     fixpoint 4116(10)=73c(24)
8133(10) ->     fixpoint 4116(10)=73c(24)

25 -none <= 30000

85(10) ->       fixpoint 2187(10)=363(26)

27 -none <= 30000
28 -none <= 10000