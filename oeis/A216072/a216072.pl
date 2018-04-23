#!perl

# OEIS A216072 tough aliquot start values
# @(#) $Id$
# 2018-04-15, Georg Fischer
#------------------------------------------------------
# Usage:
#	wget https://oeis.org/A216072/b216072.txt
#	perl a216072.pl b216072.txt
#--------------------------------------------------------
use strict;
while (<>) {
    next if ! m{\A\d}; # no digit in column 1 -> skip initial comment lines
    s/\s+\Z//; # chompr
    my ($n, $an) = split(/\s+/);
    print sprintf("%d %d\t# %16x %32b\n", $n, $an, $an, $an);
} # while <>
