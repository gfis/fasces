#!perl

# Build the Kimberling expulsion array in a triangle in HTML
# @(#) $Id$
# 2018-05-07, Georg Fischer
#------------------------------------------------------
# usage:
#   perl A006852.pl maxrow
#--------------------------------------------------------
use strict;
use integer;

my $n = shift(@ARGV);
my ($i, $j);
$i= ($n + 4) / 3;
$j= (2 * $n + 1) / 3;
my $oj = 0;
while ($i != $j) {
#	$j = &max(($i - $j) << 1, (($j - $i) << 1) - 1); 
	print "i=$i\t j=$j\t diff=" . "\t" . ($oj - $j) . "\t" . ($i > $j ? " L": " R") . "\t" .  ($i - $j) ."\n";
	$oj = $j;
	$j = ($i > $j) ? ($i - $j) << 1 : (($j - $i) << 1) - 1; 
	$ i++;
} # while
print "A006852($n) = $i\n";
#--------------
sub max {
	my ($a, $b) = @_;
	return $a > $b ? $a : $b;
} # max
__DATA__

C:\Users\gfis\work\gits\fasces\oeis\A035505>perl A006852.pl 2
A006852(2) = 25

C:\Users\gfis\work\gits\fasces\oeis\A035505>perl A006852.pl 19
A006852(19) = 49595

C:\Users\gfis\work\gits\fasces\oeis\A035505>perl A006852.pl 242
A006852(242) = 16509502
