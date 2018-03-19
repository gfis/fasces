#!perl

# @(#) $Id$
# Generate all combinations of length k from a string of length n
# 2018-03-19, Georg Fischer
# from https://stackoverflow.com/questions/12991758/creating-all-possible-k-combinations-of-n-items-in-c
# 2nd last example

use strict;
use integer;

my $str = shift(@ARGV);
my $k = shift(@ARGV);
&generate($str, $k);
exit(0);

sub generate {
    my ($str, $k) = @_;
    my $n = length($str);
    my $n2 = 1 << $n;
    my $combo = (1 << $k) - 1; # k bit sets
    while ($combo < $n2) {
        for (my $i = 0; $i < $n; $i++) {
            if ((($combo >> $i) & 1) != 0) {
                print substr($str, $i, 1) . " ";
            }
        } # for $i
        print "\n";
        my $x = $combo & -$combo;
        my $y = $combo + $x;
        my $z = ($combo & ~$y);
        $combo = $z / $x;
        $combo >>= 1;
        $combo |= $y;
    } # while 
} # generate
