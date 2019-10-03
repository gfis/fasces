#!perl

# powertrain.pl -
# @(#) $Id$
# 2019-10-02: with hashes
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
        $nmax  = shift(@ARGV);
        $nmin = $nmax;
    }
} # while opt

my %pmap = (); # powertrain map
my %pend = ();
my %pfix = (); # numbers participating in a fixpoint (cycle)

my $n = $nmin;
while ($n <= $nmax) {
    my $oldn  = $n;
    my $oldnb = &to_base($oldn);
    if (length($oldnb) % 2 == 1) { # odd - exponent is missing
        $oldnb .= "1"; # assume exponent 1
    }
    if ($debug >= 2 or $n % 1000 == 0) {
        print "powertrain($oldn(10)=$oldnb($base))\n";
    }
    my $newn  = 1;
    my $newnb = 1;
    while (! defined($pmap{$oldn})) { # until we find a chain member which is already known
        $newn  = &compute($oldnb);
        $newnb = &to_base($newn);
        $pmap{$oldn} = $newn;
        if ($debug >= 2) {
            print "$oldnb($base) -> $newn(10)=$newnb($base)\n";
        }
        $oldn  = $newn;
        $oldnb = $newnb;
        if (length($oldnb) % 2 == 1) { # odd - exponent is missing
            $oldnb .= "1"; # assume exponent 1
        }
    } # while $oldn
    # now we have a chain from $n to $oldn
    
    # check whether we know the end point of $oldn
    if (defined($pend{$oldn})) {
        $pend{$n} = $pend{$oldn}; # propagate it to $n
    } else { # determine it, but with loop check
        my %pvis = (); 
        my $busy = 1;
        my $chain = "$oldn(10)=" . &to_base($oldn) . "($base)";
        while ($busy == 1 and defined($pmap{$oldn})) { 
            # follow the chain until we get into a loop
            $newn = $pmap{$oldn};
            $pvis{$oldn} = $newn;
            $oldn = $newn;
            $chain .= "->$oldn(10)=" . &to_base($oldn) . "($base)";
            if (defined($pvis{$oldn})) {
                $busy = 0;
            }
        } # while $busy
        $pend{$n} = $pend{$oldn}; # propagate it to $n
        if (defined($pfix{$oldn})) { # fixpoint was already known
        } else { # new fixpoint
            my $fix  = $oldn;
            my $fixb = &to_base($fix); # without ".= 1";
            $pfix{$fix} = 1; # make it known for the future
            print "$n(10) -> ... $chain\n";
        } # new fixpoint
    } # determine it
    $n ++;
} # while $n
#--------
# compute the product
sub compute { my ($nb) = @_;
    my $prod = Math::BigInt->new(1);
    my $inb = 0;
    while ($inb < length($nb) and ! $prod->is_zero()) {
        # consider a decimal pair (digit, exponent)
        my $digit = &to_dec(substr($nb, $inb    , 1));
        my $expon = &to_dec(substr($nb, $inb + 1, 1));
        $prod = $prod->bmul(&pow($digit, $expon));
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
#   if ($debug >= 3) {
#       print "$a ** $b = $result\n";
#   }
    return $result;
} # pow

# convert from decimal to base, without leading zeroes
sub to_base { my ($pnum) = @_;
    my $result = "";
    if ($base == 10) {
        $result= $pnum;
    } else {
        my $num = Math::BigInt->new($pnum);
        while ($num->is_positive()) {
            my ($quo, $digit) = $num->bdiv($base);
            $result = substr($digits, $digit, 1) . $result;
            # $num = $num->bdiv($base);
        } # while > 0
    }
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
#---------------------------------------
Results for different bases:

2 - none <= 30000
3 - none <= 40000
4 - none <= 30000
5 - none <= 30000

0(10) ->        fixpoint 0(6)->0(6)
1(10) ->        fixpoint 1(6)->1(6)
2(10) ->        fixpoint 2(6)->2(6)
3(10) ->        fixpoint 3(6)->3(6)
4(10) ->        fixpoint 4(6)->4(6)
5(10) ->        fixpoint 5(6)->5(6)
16(10) ->       fixpoint 24(6)->24(6)
powertrain(1000(10)=4344(6))

7 - none <= 30000

powertrain(0(10)=01(8))
0(10) ->        fixpoint 0(8)->0(8)
1(10) ->        fixpoint 1(8)->1(8)
2(10) ->        fixpoint 2(8)->2(8)
3(10) ->        fixpoint 3(8)->3(8)
4(10) ->        fixpoint 4(8)->4(8)
5(10) ->        fixpoint 5(8)->5(8)
6(10) ->        fixpoint 6(8)->6(8)
7(10) ->        fixpoint 7(8)->7(8)
27(10) ->       fixpoint 33(8)->33(8)
230(10) ->      fixpoint 746(8)->34106(8)->746(8)
3196(10) ->     fixpoint 34106(8)->746(8)->34106(8)
powertrain(5000(10)=116101(8))

0(10) ->        fixpoint 0(9)->0(9)
1(10) ->        fixpoint 1(9)->1(9)
2(10) ->        fixpoint 2(9)->2(9)
3(10) ->        fixpoint 3(9)->3(9)
4(10) ->        fixpoint 4(9)->4(9)
5(10) ->        fixpoint 5(9)->5(9)
6(10) ->        fixpoint 6(9)->6(9)
7(10) ->        fixpoint 7(9)->7(9)
8(10) ->        fixpoint 8(9)->8(9)
5344(10) ->     fixpoint 51232874(9)->51232874(9)

0(10) ->        fixpoint 0(10)->0(10)
1(10) ->        fixpoint 1(10)->1(10)
2(10) ->        fixpoint 2(10)->2(10)
3(10) ->        fixpoint 3(10)->3(10)
4(10) ->        fixpoint 4(10)->4(10)
5(10) ->        fixpoint 5(10)->5(10)
6(10) ->        fixpoint 6(10)->6(10)
7(10) ->        fixpoint 7(10)->7(10)
8(10) ->        fixpoint 8(10)->8(10)
9(10) ->        fixpoint 9(10)->9(10)
642(10) ->      fixpoint 2592(10)->2592(10)
powertrain(2000(10)=2000(10))

11 - none <= 3000

powertrain(0(10)=01(12))
0(10) ->        fixpoint 0(12)->0(12)
1(10) ->        fixpoint 1(12)->1(12)
2(10) ->        fixpoint 2(12)->2(12)
3(10) ->        fixpoint 3(12)->3(12)
4(10) ->        fixpoint 4(12)->4(12)
5(10) ->        fixpoint 5(12)->5(12)
6(10) ->        fixpoint 6(12)->6(12)
7(10) ->        fixpoint 7(12)->7(12)
8(10) ->        fixpoint 8(12)->8(12)
9(10) ->        fixpoint 9(12)->9(12)
10(10) ->       fixpoint a(12)->a(12)
11(10) ->       fixpoint b(12)->b(12)
129(10) ->      fixpoint 372b9a830000000000(12)->372b9a830000000000(12)
486(10) ->      fixpoint 346(12)->346(12)
509(10) ->      fixpoint 1a946(12)->1a946(12)
1082(10) ->     fixpoint 14b42(12)->14b42(12)
9895(10) ->     fixpoint 11292450a0a8(12)->11292450a0a8(12)
powertrain(25000(10)=125741(12))

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
