#!perl

# @(#) $Id$
# 2018-12-21, Georg Fischer: copied from a32connect.pl
#
# usage:
#   perl a32tree.pl [-n jtree] [-d debug] [-s start]
#	  jtree = 1..9
#	  debug = 0 (none), 1 (some), 2 (more) debugging output
#     start = 1 | 3 for 3x+1 | 3x-1
#-------------------------------
use strict;
use integer;

# get options
my $jtree = 0;
my $debug = 1;
my $start = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $jtree  = shift(@ARGV);
    } elsif ($opt =~ m{s}) {
        $start  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#--------------------------------------------------
#  jtree:       0    1   2    3     4      5       6        7         8          9
my @maxseg =   (1,   7, 61, 547, 4921, 44287, 398581, 3587227, 32285041, 290565367); #, 2615088301, 23535794707, 211822152361, 1906399371247, 17157594341221, 154418349070987, 1389765141638881, 12507886274749927, 112570976472749341); # OEIS A066443(j >= 0)
my @limit  =   (1,   8, 32, 128,  512,  2048,   8192,   32768,   131072,    524288); # 2^(2*j + 1)
# column of T:  3    7  11   15    19     23      27       31
my @queue;
my @cover;
my @tab;
my @tlen;

if ($jtree > 0) { # one single only
    &tree1($jtree);
} else { # all
    $jtree = 1 ;
    while ($jtree < scalar(@maxseg)) { # compute and evaluate 1 complete tree
        &tree1($jtree);
        $jtree ++;
    } # while all
} # all
#--------------------------
sub tree1 {
    # generate the rows for this partial tree
    my ($jtree) = @_;
    @cover = ();
    @tab   = ();
    @tlen  = ();
    my $irow = 1;
    while ($irow <= $maxseg[$jtree]) { # populate @tab
        &row1($irow);
        $irow ++;
    } # while $irow

    print "# check coverage     of tree $jtree up to node $limit[$jtree] in $maxseg[$jtree] segments\n";
    my
    $icov = 1;
    my
    $busy = 1;
    while ($busy >= 1) { # look whether all counts are 1
        if (! defined($cover[$icov])) {
            $cover[$icov] = 0;
        }
        if ($cover[$icov] != 1) {
            $busy = 0;
            print "## node $icov in tree $jtree occurs $cover[$icov] times\n";
        }
        $icov ++;
    } # while covered

    print "# check connectivity of tree $jtree up to node $limit[$jtree] in $maxseg[$jtree] segments\n";
    @cover = ();
    &enqueue($start); # enqueue row[1] = (3, 1, 2);
    while (scalar(@queue) > 0) { # expand tree
        my $node = shift(@queue);
        &enqueue($node);
    } # while expanding tree

    $icov = $start + 1;
    $busy = 1;
    while ($icov <= $limit[$jtree]) { # look whether all counts are 1
        if (! defined($cover[$icov])) {
            $cover[$icov] = 0;
        }
        if ($cover[$icov] != 1) {
            $busy = 0;
            print "## node $icov in tree $jtree occurs $cover[$icov] times\n";
        }
        $icov ++;
    } # while covered

    if ($debug >= 1) {
        print "----------------\n";
    }
} # tree1
#--------------------------
sub row1 { # generate 1 row
    my ($irow) = @_;
    if ($debug >= 2) {
        print sprintf("%4d:", $irow);
    }
    my $icol = 0;
    my $an = 4 * $irow - $start; &append($irow, ++ $icol, $an);
    while ($an % 3 == 0) {
        $an /= 3; &append($irow, ++ $icol, $an);
        $an *= 2; &append($irow, ++ $icol, $an);
    } # while subseq
    $tlen[$irow] = $icol;
    if ($debug >= 2) {
        print "\n";
    }
} # row1
#------------
sub enqueue { # queue all nodes in a row
    my ($irow) = @_;
    my
    $max = $limit [$jtree];
    $max = $maxseg[$jtree];
    if ($debug >= 2) {
        print sprintf("# enqueue row %d ", $irow);
    }
    my $icol = 1;
    while ($icol <= $tlen[$irow]) {
        my $node = $tab[$irow][$icol];
        if ($node != $start and $node <= $max) {
            if (! defined($cover[$node])) {
                $cover[$node] = 1;
            } else {
                $cover[$node] ++;
            }
            push(@queue, $node);
        } else {
            if ($debug >= 2) {
                print sprintf("ignore %d ", $node);
            }
        }
        $icol ++;
    } # while in row
    if ($debug >= 2) {
        print "; queue = (" . join(",", @queue) . ")\n";
    }
} # enqueue
#------------
sub append {
    my ($irow, $icol, $node) = @_;
    $tab[$irow][$icol] = $node;
    if (! defined($cover[$node])) {
        $cover[$node] = 1;
    } else {
        $cover[$node] ++;
    }
    if ($debug >= 2) {
        print sprintf(" %d", $tab[$irow][$icol]);
    }
} # append
#-----------------------------------
__DATA__
# check coverage     of tree 1 up to node 8 in 7 segments
## node 13 in tree 1 occurs 0 times
# check connectivity of tree 1 up to no 8 in 7 segments
## node 8 in tree 1 occurs 0 times
----------------
# check coverage     of tree 2 up to node 32 in 61 segments
## node 52 in tree 2 occurs 0 times
# check connectivity of tree 2 up to no 32 in 61 segments
## node 14 in tree 2 occurs 0 times
## node 16 in tree 2 occurs 0 times
## node 21 in tree 2 occurs 0 times
## node 24 in tree 2 occurs 0 times
## node 28 in tree 2 occurs 0 times
## node 32 in tree 2 occurs 0 times
----------------
# check coverage     of tree 3 up to node 128 in 547 segments
## node 208 in tree 3 occurs 0 times
# check connectivity of tree 3 up to node 128 in 547 segments
----------------
# check coverage     of tree 4 up to node 512 in 4921 segments
## node 832 in tree 4 occurs 0 times
# check connectivity of tree 4 up to node 512 in 4921 segments
## node 320 in tree 4 occurs 0 times
## node 352 in tree 4 occurs 0 times
## node 436 in tree 4 occurs 0 times
## node 469 in tree 4 occurs 0 times
## node 480 in tree 4 occurs 0 times
----------------
# check coverage     of tree 5 up to node 2048 in 44287 segments
## node 3328 in tree 5 occurs 0 times
# check connectivity of tree 5 up to node 2048 in 44287 segments
## node 910 in tree 5 occurs 0 times
## node 958 in tree 5 occurs 0 times
## node 1024 in tree 5 occurs 0 times
## node 1078 in tree 5 occurs 0 times
## node 1213 in tree 5 occurs 0 times
## node 1277 in tree 5 occurs 0 times
## node 1280 in tree 5 occurs 0 times
## node 1365 in tree 5 occurs 0 times
## node 1437 in tree 5 occurs 0 times
## node 1536 in tree 5 occurs 0 times
## node 1617 in tree 5 occurs 0 times
## node 1820 in tree 5 occurs 0 times
## node 1916 in tree 5 occurs 0 times
## node 1920 in tree 5 occurs 0 times
## node 1972 in tree 5 occurs 0 times
## node 2048 in tree 5 occurs 0 times
----------------
C:\Users\User\work\gits\fasces\oeis\collatz>perl a32tree.pl -n 6
# check coverage     of tree 6 up to node 8192 in 398581 segments
## node 13312 in tree 6 occurs 0 times
# check connectivity of tree 6 up to node 8192 in 398581 segments
## node 2128 in tree 6 occurs 0 times
## node 2296 in tree 6 occurs 0 times
## node 2837 in tree 6 occurs 0 times
## node 3061 in tree 6 occurs 0 times
## node 3192 in tree 6 occurs 0 times
## node 3236 in tree 6 occurs 0 times
## node 3444 in tree 6 occurs 0 times
## node 4081 in tree 6 occurs 0 times
## node 4096 in tree 6 occurs 0 times
## node 4256 in tree 6 occurs 0 times
## node 4592 in tree 6 occurs 0 times
## node 4788 in tree 6 occurs 0 times
## node 4832 in tree 6 occurs 0 times
## node 4854 in tree 6 occurs 0 times
## node 5166 in tree 6 occurs 0 times
## node 5441 in tree 6 occurs 0 times
## node 5461 in tree 6 occurs 0 times
## node 5674 in tree 6 occurs 0 times
## node 5812 in tree 6 occurs 0 times
## node 6122 in tree 6 occurs 0 times
## node 6144 in tree 6 occurs 0 times
## node 6296 in tree 6 occurs 0 times
## node 6384 in tree 6 occurs 0 times
## node 6472 in tree 6 occurs 0 times
## node 6724 in tree 6 occurs 0 times
## node 6776 in tree 6 occurs 0 times
## node 6888 in tree 6 occurs 0 times
## node 6992 in tree 6 occurs 0 times
## node 7182 in tree 6 occurs 0 times
## node 7248 in tree 6 occurs 0 times
## node 7256 in tree 6 occurs 0 times
## node 7281 in tree 6 occurs 0 times
## node 7520 in tree 6 occurs 0 times
## node 7565 in tree 6 occurs 0 times
## node 7670 in tree 6 occurs 0 times
## node 7749 in tree 6 occurs 0 times
## node 7760 in tree 6 occurs 0 times
## node 8080 in tree 6 occurs 0 times
## node 8162 in tree 6 occurs 0 times
## node 8192 in tree 6 occurs 0 times
----------------

C:\Users\User\work\gits\fasces\oeis\collatz>perl a32tree.pl -n 7
# check coverage     of tree 7 up to node 32768 in 3587227 segments
## node 53248 in tree 7 occurs 0 times
# check connectivity of tree 7 up to node 32768 in 3587227 segments
## node 10448 in tree 7 occurs 0 times
## node 13312 in tree 7 occurs 0 times
## node 14144 in tree 7 occurs 0 times
## node 15672 in tree 7 occurs 0 times
## node 15956 in tree 7 occurs 0 times
## node 16510 in tree 7 occurs 0 times
## node 16736 in tree 7 occurs 0 times
## node 17749 in tree 7 occurs 0 times
## node 18574 in tree 7 occurs 0 times
## node 19968 in tree 7 occurs 0 times
## node 20896 in tree 7 occurs 0 times
## node 21216 in tree 7 occurs 0 times
## node 22013 in tree 7 occurs 0 times
## node 23508 in tree 7 occurs 0 times
## node 23665 in tree 7 occurs 0 times
## node 23934 in tree 7 occurs 0 times
## node 24765 in tree 7 occurs 0 times
## node 25104 in tree 7 occurs 0 times
## node 25214 in tree 7 occurs 0 times
## node 26264 in tree 7 occurs 0 times
## node 26624 in tree 7 occurs 0 times
## node 26926 in tree 7 occurs 0 times
## node 27256 in tree 7 occurs 0 times
## node 27861 in tree 7 occurs 0 times
## node 28048 in tree 7 occurs 0 times
## node 28288 in tree 7 occurs 0 times
## node 28366 in tree 7 occurs 0 times
## node 29952 in tree 7 occurs 0 times
## node 30292 in tree 7 occurs 0 times
## node 30488 in tree 7 occurs 0 times
## node 31040 in tree 7 occurs 0 times
## node 31344 in tree 7 occurs 0 times
## node 31352 in tree 7 occurs 0 times
## node 31553 in tree 7 occurs 0 times
## node 31824 in tree 7 occurs 0 times
## node 31912 in tree 7 occurs 0 times
## node 32654 in tree 7 occurs 0 times
----------------
# check coverage     of tree 8 up to node 131072 in 32285041 segments
## node 212992 in tree 8 occurs 0 times
# check connectivity of tree 8 up to node 131072 in 32285041 segments
## node 30488 in tree 8 occurs 0 times
## node 34768 in tree 8 occurs 0 times
## node 38836 in tree 8 occurs 0 times
## node 41206 in tree 8 occurs 0 times
## node 45732 in tree 8 occurs 0 times
## node 46357 in tree 8 occurs 0 times
## node 47480 in tree 8 occurs 0 times
## node 49504 in tree 8 occurs 0 times
## node 51781 in tree 8 occurs 0 times
## node 52152 in tree 8 occurs 0 times
## node 54941 in tree 8 occurs 0 times
## node 56692 in tree 8 occurs 0 times
## node 57880 in tree 8 occurs 0 times
## node 58254 in tree 8 occurs 0 times
## node 60976 in tree 8 occurs 0 times
## node 61809 in tree 8 occurs 0 times
## node 64592 in tree 8 occurs 0 times
## node 65536 in tree 8 occurs 0 times
## node 66005 in tree 8 occurs 0 times
## node 67124 in tree 8 occurs 0 times
## node 67190 in tree 8 occurs 0 times
## node 68598 in tree 8 occurs 0 times
## node 69041 in tree 8 occurs 0 times
## node 69184 in tree 8 occurs 0 times
## node 69536 in tree 8 occurs 0 times
## node 71220 in tree 8 occurs 0 times
## node 71294 in tree 8 occurs 0 times
## node 74256 in tree 8 occurs 0 times
## node 75488 in tree 8 occurs 0 times
## node 75589 in tree 8 occurs 0 times
## node 77173 in tree 8 occurs 0 times
## node 77672 in tree 8 occurs 0 times
## node 78228 in tree 8 occurs 0 times
## node 78848 in tree 8 occurs 0 times
## node 79744 in tree 8 occurs 0 times
## node 80206 in tree 8 occurs 0 times
## node 80720 in tree 8 occurs 0 times
## node 80768 in tree 8 occurs 0 times
## node 81301 in tree 8 occurs 0 times
## node 82412 in tree 8 occurs 0 times
## node 85038 in tree 8 occurs 0 times
## node 85504 in tree 8 occurs 0 times
## node 85888 in tree 8 occurs 0 times
## node 86820 in tree 8 occurs 0 times
## node 87381 in tree 8 occurs 0 times
## node 90232 in tree 8 occurs 0 times
## node 91360 in tree 8 occurs 0 times
## node 91464 in tree 8 occurs 0 times
## node 91556 in tree 8 occurs 0 times
## node 92245 in tree 8 occurs 0 times
## node 92714 in tree 8 occurs 0 times
## node 94286 in tree 8 occurs 0 times
## node 94960 in tree 8 occurs 0 times
## node 95668 in tree 8 occurs 0 times
## node 96256 in tree 8 occurs 0 times
## node 96356 in tree 8 occurs 0 times
## node 96888 in tree 8 occurs 0 times
## node 98304 in tree 8 occurs 0 times
## node 99008 in tree 8 occurs 0 times
## node 99040 in tree 8 occurs 0 times
## node 100686 in tree 8 occurs 0 times
## node 100785 in tree 8 occurs 0 times
## node 102008 in tree 8 occurs 0 times
## node 102897 in tree 8 occurs 0 times
## node 103424 in tree 8 occurs 0 times
## node 103562 in tree 8 occurs 0 times
## node 103776 in tree 8 occurs 0 times
## node 104304 in tree 8 occurs 0 times
## node 105728 in tree 8 occurs 0 times
## node 106072 in tree 8 occurs 0 times
## node 106325 in tree 8 occurs 0 times
## node 106552 in tree 8 occurs 0 times
## node 106830 in tree 8 occurs 0 times
## node 106941 in tree 8 occurs 0 times
## node 108278 in tree 8 occurs 0 times
## node 108401 in tree 8 occurs 0 times
## node 109882 in tree 8 occurs 0 times
## node 111384 in tree 8 occurs 0 times
## node 113232 in tree 8 occurs 0 times
## node 113272 in tree 8 occurs 0 times
## node 113384 in tree 8 occurs 0 times
## node 114005 in tree 8 occurs 0 times
## node 114200 in tree 8 occurs 0 times
## node 114517 in tree 8 occurs 0 times
## node 114830 in tree 8 occurs 0 times
## node 115760 in tree 8 occurs 0 times
## node 115876 in tree 8 occurs 0 times
## node 116366 in tree 8 occurs 0 times
## node 116508 in tree 8 occurs 0 times
## node 117342 in tree 8 occurs 0 times
## node 118272 in tree 8 occurs 0 times
## node 119616 in tree 8 occurs 0 times
## node 120184 in tree 8 occurs 0 times
## node 120309 in tree 8 occurs 0 times
## node 121080 in tree 8 occurs 0 times
## node 121152 in tree 8 occurs 0 times
## node 121813 in tree 8 occurs 0 times
## node 121951 in tree 8 occurs 0 times
## node 122993 in tree 8 occurs 0 times
## node 123618 in tree 8 occurs 0 times
## node 126613 in tree 8 occurs 0 times
## node 127557 in tree 8 occurs 0 times
## node 128256 in tree 8 occurs 0 times
## node 128341 in tree 8 occurs 0 times
## node 128832 in tree 8 occurs 0 times
## node 129104 in tree 8 occurs 0 times
## node 129184 in tree 8 occurs 0 times
## node 130230 in tree 8 occurs 0 times
## node 130304 in tree 8 occurs 0 times
## node 130912 in tree 8 occurs 0 times
## node 131072 in tree 8 occurs 0 times
----------------
