#!/usr/bin/perl
# 2017-08-23, Georg Fischer: I place this program in the public domain
# Generate a sequence of numbers starting at 0
# usage:
#    perl count.pl num > number.txt
#---------------
use strict;
use integer; # avoid division problems with reals

my $len = shift(@ARGV);;
my $ind = 0;
while ($ind <= $len) {
	print "$ind\n";
	$ind ++;
} # while $ind
