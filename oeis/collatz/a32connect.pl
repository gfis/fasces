#!perl

# @(#) $Id$
# 2018-12-09, Georg Fischer
#
# usage:
#   perl a32connect.pl [limit] 
#-------------------------------
use integer; 
use strict;
my $n = 1;    # b-file count (not used)
my $node;     # current node
my $cind = 1; # current segment index
my $limit = 20000;
my $debug = 2;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $limit  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#     $cind  0  1  2  3 
my @segms = (0, 1, 1, 1); # index of the segment containing this node,
    # positive if the segment is already expanded     
    # negative if the segment should still be expanded
my @dones = (0, 1);
my $unattached = 4;
my $imin = 2;

while ($unattached < $limit) { # compute segment with index i
    $cind  = $imin;
    if (! defined($dones[$cind])) {
    	&enqueue();
    } # ! defined or planned
    if ($imin < $cind) {
    } else { # increment
        $imin = $cind + 1;
        while ($imin < scalar(@segms) and ! defined($segms[$imin])) {
            $imin ++;
        }
        if ($imin >= scalar(@segms)) {
            print "exhausted - quit\n";
            exit(1);
        }
    } # increment
} # while start values
#----
sub enqueue { # expand segment $cind, returns $imin = minimum node in row
    	print "enqueue cind=$cind\tunattached=$unattached\n" if $debug >= 1;
        $node = 4 * $cind - 1; 
        $imin = $node;
        &attach();
        while ($node % 3 == 0) { 
            $node /= 3; &attach();
            $node *= 2; &attach();
        } # while subseq
        $dones[$cind] = $cind;
} # enqueue
#----
sub attach {
    print "attach  cind=$cind\tnode=$node\tunattached=$unattached\n"  if $debug >= 2;
    $segms[$node] = $cind;
    if ($node < $imin) {
        $imin = $node;
    } 
    if ($node == $unattached) { #  and defined($segms[$unattached])) { # now connected
        while (defined($segms[$unattached])) {
            $unattached ++;
        } # while increasing  
        print sprintf("increased in segment %d (0x%x), now %d (0x%x) unattached\n", 
        	$cind, $cind, $unattached, $unattached);
    } # if connected
} # attach
__DATA__
increased in segment 7 (0x7), now 5 (0x5) unattached
increased in segment 4 (0x4), now 10 (0xa) unattached
increased in segment 4 (0x4), now 13 (0xd) unattached
increased in segment 10 (0xa), now 14 (0xe) unattached
increased in segment 16 (0x10), now 28 (0x1c) unattached
increased in segment 16 (0x10), now 37 (0x25) unattached
increased in segment 28 (0x1c), now 49 (0x31) unattached
increased in segment 37 (0x25), now 64 (0x40) unattached
increased in segment 547 (0x223), now 85 (0x55) unattached
increased in segment 64 (0x40), now 113 (0x71) unattached
increased in segment 85 (0x55), now 164 (0xa4) unattached
increased in segment 277 (0x115), now 224 (0xe0) unattached
increased in segment 1276 (0x4fc), now 320 (0x140) unattached
increased in segment 2734 (0xaae), now 352 (0x160) unattached
increased in segment 2005 (0x7d5), now 436 (0x1b4) unattached
increased in segment 736 (0x2e0), now 581 (0x245) unattached
increased in segment 436 (0x1b4), now 910 (0x38e) unattached
increased in segment 1024 (0x400), now 958 (0x3be) unattached
increased in segment 1078 (0x436), now 1277 (0x4fd) unattached
increased in segment 958 (0x3be), now 2128 (0x850) unattached
increased in segment 8080 (0x1f90), now 2296 (0x8f8) unattached
increased in segment 5812 (0x16b4), now 3061 (0xbf5) unattached
increased in segment 2296 (0x8f8), now 4081 (0xff1) unattached
increased in segment 3061 (0xbf5), now 4832 (0x12e0) unattached
increased in segment 27520 (0x6b80), now 8590 (0x218e) unattached
increased in segment 9664 (0x25c0), now 10448 (0x28d0) unattached
