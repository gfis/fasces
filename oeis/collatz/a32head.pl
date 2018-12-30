#!perl

# @(#) $Id$
# 2018-12-27, Georg Fischer
# Usage:
#   perl a32head.pl [limit]
#-------------------------------------------
use strict;
use integer;

my $n = 1; # b-file count
my $an;
my $i = 1;
my $limit = shift(@ARGV);
my $okern = 0;
my $od1 = 0;
my $nd1;
my $od2 = 0;
my $nd2;
my $icol;
while ($i <= $limit) { # compute segment with index i
    $an = 4 * $i - 1;
    $icol = 1;
    while ($an % 3 == 0) {
        $an /= 3; &append();
        $an *= 2; &append();
        $icol ++;
    } # while subseq
    $i ++;
} # while start values
#------------
sub append {
    if ($an % 6 == 4) { # is kern
        my $nkern = ($an + 2) / 6;
        if ($i % 27 == 7) {
        	print "\n";
        }
        $nd1 = $nkern - $okern;
        $nd2 = abs(abs($nd1) - abs($od1));
        print sprintf("%4d,%2d:%6d %6d %6d\n", $i, $icol, $nkern, $nd1, $nd2);
        $okern = $nkern;
        $od1 = $nd1;
        $od2 = $nd2;
        $n ++;
    } # if 4 mod 6
} # append
__DATA__
