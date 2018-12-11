#!perl

# @(#) $Id$
# 2018-12-09, Georg Fischer
#
# usage:
#	perl a32connect.pl [limit] 
#-------------------------------
use integer; 
use strict;
my $n = 1; 
my $an; 
my $i = 1; 
my $limit = 1000;
if (scalar(@ARGV) > 0) {
	$limit = shift(@ARGV); 
}
#     index  0  1   2   3 
my @segms = (1, 1, -1, -1); # segment index of the node,
	# positive if it already expanded     
	# negative if it should still be expanded
my $unconnected = scalar(@segms);

while ($i < $limit) { # compute segment with index i
    $an = 4 * $i - 1; 
    &append();
    while ($an % 3 == 0) { 
        $an /= 3; &append();
        $an *= 2; &append();
    } # while subseq
    $i ++; 
} # while start values
#------------
sub append {
    $segms[$an] = $i;
    if ($an == $unconnected) { # increase
        print "cover $an in segment $i\n";
        while (defined($segms[$unconnected])) {
            $unconnected ++;
        } # while increasing  
    } # if connected
} # append
__DATA__
