#!perl

# Truncate a b-file at the first non-increasing index
# 2020-10-16, Georg Fischer
#
use strict;
use integer;
use warnings;
my $nm1 = 0; # n - 1
while (<>) {
    if (m{\A\s*\#}) {
        print;
    } else { # no comment
        m{\A\s*(\-?\d+)\s*(\-?\d+)};
        my ($n, $an) = ($1, $2);
        if ($n <= 2) {
            $nm1 = $n;
            print;
        } elsif ($n != $nm1 + 1) {
            exit();
        } else {
            print;
            $nm1 = $n;
        }
    } # no comment
} # while <>
