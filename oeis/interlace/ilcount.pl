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

my %members;
my %positns;
my $count = 0;
while (<>) {
    # print "$_";
    s/\r?\n//; # chompr
	$count ++;
    my @pm = split(/ /);
    my $cind = 0; # index in current row
    while ($cind < scalar(@pm)) {
    	my $elem = $pm[$cind];
    	$positns{$elem . $cind} = 1;
    	$members{$cind . $elem} = 1;
    	$cind ++;
    } # while $cind
} # while <>
my $key;
my $val;
my 
$okey = "?";
print "Positions of members";
foreach my $key (sort(keys(%positns))) {
	if (substr($key, 0, 1) ne $okey) {
		$okey = substr($key, 0, 1);
		print "\nmem = $okey: ";
	}
	print " " . substr($key, 1);
} # foreach positns
print "\n";
print "Members at positions";
$okey = "?";
foreach my $key (sort(keys(%members))) {
	if (substr($key, 0, 1) ne $okey) {
		$okey = substr($key, 0, 1);
		print "\npos = $okey: ";
	}
	print " " . substr($key, 1);
} # foreach members
print "\n";
print "$count triangles with interlacing rows\n";
# https://oeis.org/wiki/User:Georg_Fischer Feb. 27, 2018
__DATA__
        0
       1 2
      3 4 5
perl ilcount.pl < inter6.1.tmp
Positions of members
mem = 0:  3 4 5
mem = 1:  1 2 3 5
mem = 2:  0 1 2 3 4 5
mem = 3:  0 1 2 3 4 5
mem = 4:  1 2 3 5
mem = 5:  3 4 5
Members at positions
pos = 0:  2 3
pos = 1:  1 2 3 4
pos = 2:  1 2 3 4
pos = 3:  0 1 2 3 4 5
pos = 4:  0 2 3 5
pos = 5:  0 1 2 3 4 5
20 triangles with interlacing rows

perl interlace.pl 10 1 < perm10.tmp > inter10.1.tmp
# arrange 10 numbers in a triangle with 4 interlaced "between: " rows
1744 triangles with interlacing rows
        0
       1 2
      3 4 5
     6 7 8 9
perl ilcount.pl < inter10.1.tmp
Positions of members
mem = 0:  6 7 8 9
mem = 1:  3 4 5 6 7 8 9
mem = 2:  1 2 3 4 5 6 7 8 9
mem = 3:  0 1 2 3 4 5 6 7 8 9
mem = 4:  0 1 2 3 4 5 6 7 8 9
mem = 5:  0 1 2 3 4 5 6 7 8 9
mem = 6:  0 1 2 3 4 5 6 7 8 9
mem = 7:  1 2 3 4 5 6 7 8 9
mem = 8:  3 4 5 6 7 8 9
mem = 9:  6 7 8 9
Members at positions
pos = 0:  3 4 5 6
pos = 1:  2 3 4 5 6 7
pos = 2:  2 3 4 5 6 7
pos = 3:  1 2 3 4 5 6 7 8
pos = 4:  1 2 3 4 5 6 7 8
pos = 5:  1 2 3 4 5 6 7 8
pos = 6:  0 1 2 3 4 5 6 7 8 9
pos = 7:  0 1 2 3 4 5 6 7 8 9
pos = 8:  0 1 2 3 4 5 6 7 8 9
pos = 9:  0 1 2 3 4 5 6 7 8 9
1744 triangles with interlacing rows
