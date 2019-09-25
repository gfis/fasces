#!perl

# powertrain.pl -
# @(#) $Id$
# c.f. <https://www.spektrum.de/magazin/powertrain/1669402>
# 2019-09-24, Georg Fischer
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
my $nmax    = 3000;
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

if ($nmin eq $nmax) { # with -s
        my $fix = &train($nmin);
        my $fixb = $fix->to_base($base); # &to_base($fix);
        if ($debug >= 1 or length($fixb) > 1) {
            print "$nmin(10) ->\tfixpoint $fix(10)=$fixb($base)\n";
        }
} else { # range 1..$nmax
    my $n = $nmin;
    while ($n <= $nmax) {
        my $fix = &train($n);
        my $fixb = $fix->to_base($base); # &to_base($fix);
        if ($debug >= 1 or length($fixb) > 1) {
            print "$n(10) ->\tfixpoint $fix(10)=$fixb($base)\n";
        }
        $n ++;
    } # while $n
}
#--------
sub train {
    my ($n) = @_;
    my $nb = Math::BigInt->new($n);
    $nb = $nb->to_base($base); # &to_base($n);
    if ($debug >= 2) {
        print "powertrain($n(10)=$nb($base))\n";
    }
    my $oldnb = 0;
    my $prod = 1;
    while (length($nb) != 1 and $nb ne $oldnb) {
        $oldnb = $nb;
        if (length($nb) % 2 == 1) { # odd
            $nb .= "1";
        }
        my $inb = 0;
        $prod = Math::BigInt->new(1);
        while ($inb < length($nb)) {
            $prod = $prod->bmul(&pow(&to_dec(substr($nb, $inb, 1)), &to_dec(substr($nb, $inb + 1, 1))));
            $inb += 2;
        } # while $inb
        my $prodb = $prod->to_base($base); # &to_base($prod);
        if ($debug >= 2) {
            print "$nb($base) -> $prod(10)=$prodb($base)\n";
        }
        $nb = $prodb;
    } # while $n
    return $prod;
} # train

# compute a**b - up to 15**14
sub pow { my ($a, $b) = @_;
    my $result = 1;
    if ($b == 0) {
        # already ok
    } elsif ($b == 1) {
        $result = $a;
    } else {
        $result = $a ** $b;
    }
    if ($debug >= 3) {
        print "$a ** $b = $result\n";
    }
    return $result;
} # pow

sub pow2 { my ($a, $b) = @_;
    my $result = Math::BigInt->new(1);
    if ($b == 0) {
        # already ok
    } elsif ($b == 1) {
        $result = Math::BigInt->new($a);
    } else {
        $result = Math::BigInt->new($a)->bpow($b);
    }
    if ($debug >= 3) {
        print "$a ** $b = $result\n";
    }
    return $result;
} # pow2

# convert from decimal to base, without leading zeroes
sub to_base { my ($pnum) = @_;
    my $num = Math::BigInt->new($pnum);
    my $result = "";
    while ($num->is_positive()) {
        my ($quo, $digit) = $num->bdiv($base);
        $result =  substr($digits, $digit, 1) . $result;
        # $num = $num->bdiv($base);
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


2960(10) ->     fixpoint 16(10)=24(6)

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 9

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 9 -m 20000
5344(10) ->     fixpoint 24586240(10)=51232874(9)
6464(10) ->     fixpoint 24586240(10)=51232874(9)

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 7 -m 20000

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 9 -m 20000

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 9 -m 20000
5344(10) ->     fixpoint 24586240(10)=51232874(9)
6464(10) ->     fixpoint 24586240(10)=51232874(9)

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 11 -m 20000
258(10) ->      fixpoint 10(10)=A(11)
556(10) ->      fixpoint 10(10)=A(11)
618(10) ->      fixpoint 10(10)=A(11)
1018(10) ->     fixpoint 10(10)=A(11)
2839(10) ->     fixpoint 10(10)=A(11)
6117(10) ->     fixpoint 10(10)=A(11)

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 12 -m 20000
305(10) ->      fixpoint 10(10)=A(12)
486(10) ->      fixpoint 486(10)=346(12)
494(10) ->      fixpoint 486(10)=346(12)
509(10) ->      fixpoint 39366(10)=1A946(12)
534(10) ->      fixpoint 39366(10)=1A946(12)
542(10) ->      fixpoint 39366(10)=1A946(12)
734(10) ->      fixpoint 10(10)=A(12)
1326(10) ->     fixpoint 486(10)=346(12)
1337(10) ->     fixpoint 39366(10)=1A946(12)
1350(10) ->     fixpoint 39366(10)=1A946(12)
1517(10) ->     fixpoint 39366(10)=1A946(12)
3641(10) ->     fixpoint 486(10)=346(12)
3645(10) ->     fixpoint 39366(10)=1A946(12)
3661(10) ->     fixpoint 10(10)=A(12)
5833(10) ->     fixpoint 486(10)=346(12)
5929(10) ->     fixpoint 486(10)=346(12)
6109(10) ->     fixpoint 39366(10)=1A946(12)
6279(10) ->     fixpoint 39366(10)=1A946(12)
6409(10) ->     fixpoint 39366(10)=1A946(12)
6505(10) ->     fixpoint 39366(10)=1A946(12)

C:\Users\User\work\gits\fasces\oeis\powertrain>perl powertrain.pl -b 19 -m 20000
1604(10) ->     fixpoint 524288(10)=40862(19)
1617(10) ->     fixpoint 524288(10)=40862(19)
3004(10) ->     fixpoint 524288(10)=40862(19)
