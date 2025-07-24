#!perl

# b-file for http://oeis.org/A173388
# @(#) $Id$
# 2018-10-01, Georg Fischer 
#---------------------------------
use strict;
use Math::BigInt;
use Math::BigInt':constant';
my @a;
for (my $n = 0; $n <= 1000; $n++) {
    if ($n < 4)           { $a[$n] = Math::BigInt->new(1);
    } elsif ($n % 2 == 0) { $a[$n] = $a[$n - 3] + $a[$n - 4];
    } else                { $a[$n] = $a[$n - 2] + $a[$n - 3];
    }
    print "$n $a[$n]\n";
} # for n
