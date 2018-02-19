#!/usr/bin/perl

# Convert a vector to a b-file
# @(#) $Id$
# 2018-02-19, Georg Fischer
# usage:
#     perl gen_expr.pl 4 | perl expand_expr.pl | tail -2 \
#     | perl vector_b-file.pl > b-file.txt
#---------------------------------------
use strict;

my $count = 0;
print "# generated by vector_b-file.pl\n";
$_ = <>; # first line only
s{[^\d\,]}{}g; # remove all but digits and commas

foreach my $elem (split(/\,/)) {
    $elem =~ s{\A0+}{}; # remove leading zeroes
    if (length($elem) == 0) {
        $elem = "0";
    }
    print "$count $elem\n";
    $count ++;
} # foreach 
__DATA__
   = [00,01,02,03,04,14,24,34,33,32,31,21,22,23,13,12,11,10,20,30,40,41,42,43,44];
#--------
