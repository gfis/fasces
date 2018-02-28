#!perl

# Count results of interlace.pl
# @(#) $Id$
# 2018-02-28, Georg Fischer
#------------------------------------------------------
# usage:
#   java -cp ... org.teherba.ramath.util.Permutator 10 \
#   | perl interlace.pl 10 1\
#   | perl ilcount.pl
#--------------------------------------------------------
use strict;

my %mems;
my %plas;
my $count = 0;
while (<>) {
    # print "$_";
    s/\r?\n//; # chompr
	$count ++;
    my @pm = split(/ /);
    my $cind = 0; # index in current row
    while ($cind < scalar(@pm)) {
    	my $elem = $pm[$cind];
    	$plas{$elem . $cind} = 1;
    	$mems{$cind . $elem} = 1;
    	$cind ++;
    } # while $cind
} # while <>
my $key;
my $val;
my $opla = "?";
foreach my $key (sort(keys(%plas))) {
	if (substr($key, 0, 1) ne $opla) {
		$opla = substr($key, 0, 1);
		print "\nplaces ($opla): ";
	}
	print " " . substr($key, 1);
} # foreach plas
print "\n";
my $omem = "?";
foreach my $key (sort(keys(%mems))) {
	if (substr($key, 0, 1) ne $omem) {
		$omem = substr($key, 0, 1);
		print "\nmembers($omem): ";
	}
	print " " . substr($key, 1);
} # foreach mems
print "\n";
print "$count triangles with interlacing rows\n";
# https://oeis.org/wiki/User:Georg_Fischer Feb. 27, 2018
__DATA__
perl ilcount.pl < inter6.1.tmp

places (0):  3 4 5
places (1):  1 2 3 5
places (2):  0 1 2 3 4 5
places (3):  0 1 2 3 4 5
places (4):  1 2 3 5
places (5):  3 4 5

members(0):  2 3
members(1):  1 2 3 4
members(2):  1 2 3 4
members(3):  0 1 2 3 4 5
members(4):  0 2 3 5
members(5):  0 1 2 3 4 5
20 triangles with interlacing rows

perl interlace.pl 10 1 < perm10.tmp > inter10.1.tmp
# arrange 10 numbers in a triangle with 4 interlaced "between: " rows
1744 triangles with interlacing rows
perl ilcount.pl < inter10.1.tmp

places (0):  6 7 8 9
places (1):  3 4 5 6 7 8 9
places (2):  1 2 3 4 5 6 7 8 9
places (3):  0 1 2 3 4 5 6 7 8 9
places (4):  0 1 2 3 4 5 6 7 8 9
places (5):  0 1 2 3 4 5 6 7 8 9
places (6):  0 1 2 3 4 5 6 7 8 9
places (7):  1 2 3 4 5 6 7 8 9
places (8):  3 4 5 6 7 8 9
places (9):  6 7 8 9

members(0):  3 4 5 6
members(1):  2 3 4 5 6 7
members(2):  2 3 4 5 6 7
members(3):  1 2 3 4 5 6 7 8
members(4):  1 2 3 4 5 6 7 8
members(5):  1 2 3 4 5 6 7 8
members(6):  0 1 2 3 4 5 6 7 8 9
members(7):  0 1 2 3 4 5 6 7 8 9
members(8):  0 1 2 3 4 5 6 7 8 9
members(9):  0 1 2 3 4 5 6 7 8 9
1744 triangles with interlacing rows
