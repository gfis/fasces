#!perl

# @(#) $Id$
# 2018-12-21, Georg Fischer: copied from a32connect.pl
#
# usage:
#   perl a32tree.pl [-n jtree]
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
# check coverage     of tree 6 up to 8192
## 13312 in tree 6 occurs 0 times
# check connectivity of tree 6 up to 8192
## 2128 in tree 6 occurs 0 times
----------------
# check coverage     of tree 7 up to 32768
## 53248 in tree 7 occurs 0 times
# check connectivity of tree 7 up to 32768
## 10448 in tree 7 occurs 0 times
----------------
# check coverage     of tree 8 up to 131072
## 212992 in tree 8 occurs 0 times
# check connectivity of tree 8 up to 131072
