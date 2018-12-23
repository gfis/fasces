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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $jtree  = shift(@ARGV);
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

    print "# check coverage     of tree $jtree up to $limit[$jtree]\n";
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
            print "## $icov in tree $jtree occurs $cover[$icov] times\n";
        }
        $icov ++;
    } # while covered

    print "# check connectivity of tree $jtree up to $limit[$jtree]\n";
    @cover = ();
    &enqueue(1); # enqueue row[1] = (3, 1, 2);
    while (scalar(@queue) > 0) { # expand tree
        my $node = shift(@queue);
        &enqueue($node);
    } # while expanding tree

    $icov = 2;
    $busy = 1;
    while ($busy >= 1) { # look whether all counts are 1
        if (! defined($cover[$icov])) {
            $cover[$icov] = 0;
        }
        if ($cover[$icov] != 1) {
            $busy = 0;
            print "## $icov in tree $jtree occurs $cover[$icov] times\n";
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
    my $an = 4 * $irow - 1; &append($irow, ++ $icol, $an);
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
        if ($node > 1 and $node <= $max) {
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
#----
sub attach {
} # attach
__DATA__
# check coverage     of tree 1 up to 8 in 18 nodes
# check connectivity of tree 1 up to 8
# check coverage     of tree 2 up to 32 in 128 nodes
# check connectivity of tree 2 up to 32
# check coverage     of tree 3 up to 128 in 1102 nodes
# check connectivity of tree 3 up to 128
# check coverage     of tree 4 up to 512 in 9852 nodes
# check connectivity of tree 4 up to 512
# check coverage     of tree 5 up to 2048 in 88586 nodes
# check connectivity of tree 5 up to 2048
# check coverage     of tree 6 up to 8192 in 797176 nodes
# check connectivity of tree 6 up to 8192
# check coverage     of tree 7 up to 32768 in 7174470 nodes
# check connectivity of tree 7 up to 32768