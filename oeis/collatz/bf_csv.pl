#!perl

# Print the terms of a b-file as comma-separated list
# 2020-10-16, Georg Fischer
#
use strict;
use integer;
use warnings;
while (<>) {
    if (m{\A\s*\#}) {
    } else { # no comment
        m{\A\s*(\-?\d+)\s*(\-?\d+)};
        my ($n, $an) = ($1, $2);
        print "$2, ";
    } # no comment
} # while <>
print "\n";
