#!perl

# @(#) $Id$
# 2018-12-09, Georg Fischer
use integer; 
use strict;

my $n = 1;    # b-file count (not used)
my $an; 
my $i = 1; 
my $limit = shift(@ARGV); 
my @segms = (0, 1, 1, 1); # segment index if the segment is computed
my $uncovered = scalar(@segms);
while ($i < $limit) { # compute segment with index i
    $an = 4 * $i - 1; &append();
    while ($an % 3 == 0) { 
        $an /= 3; &append();
        $an *= 2; &append();
    } # while subseq
    $i ++; 
} # while start values
#------------
sub append {
    $segms[$an] = $i;
    if ($an == $uncovered) { # increase
        print "cover $an in segment $i\n";
        while (defined($segms[$uncovered])) {
            $uncovered ++;
        } # while increasing  
    } # if covered
} # append
__DATA__
perl a32cover.pl 100000000
cover 4 in segment 7
cover 8 in segment 7
cover 	13 in segment 10
cover 	14 in segment 16
cover 16 in segment 61
cover 32 in segment 61
cover 	52 in segment 88
cover 	56 in segment 142
cover 64 in segment 547
cover 128 in segment 547
cover 	208 in segment 790
cover 	224 in segment 1276
cover 256 in segment 4921
cover 512 in segment 4921
cover 	832 in segment 7108
cover 	896 in segment 11482
cover 1024 in segment 44287
cover 2048 in segment 44287
cover 	3328 in segment 63970
cover 	3584 in segment 103336
cover 4096 in segment 398581
cover 8192 in segment 398581
cover 	13312 in segment 575728
cover 	14336 in segment 930022
cover 16384 in segment 3587227
cover 32768 in segment 3587227
cover 	53248 in segment 5181550
cover 	57344 in segment 8370196
cover 65536 in segment 32285041
cover 131072 in segment 32285041
cover 	212992 in segment 46633948
cover 	229376 in segment 75331762
