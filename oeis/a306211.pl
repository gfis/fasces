#!perl

# Repair indexes in b-files
# @(#) $Id$
# 2019-01-24, Georg Fischer
#
# usage:
#   perl bfclean.pl [[+|-]increment] [-s seqno|-f infile] [outfile]
#       -s  A-number, b-number or number
#       outfile is "bnnnnnn.txt" by default, or "-" for STDOUT
#       default increment 0
#---------------------------------
use strict;
use integer;
use warnings;

my $maxgen = shift(@ARGV);
my @seq = (1);
my $gen = 0;
my $iseq;
my @runls;
my @rlens = (0); # length of @runls
while ($gen < $maxgen) {
    @runls = ();
    my $len = scalar(@seq);
    $iseq = 0;
    my $runl = 1;
    my $old = $seq[$iseq ++];
    while ($iseq < $len) {
        my $new = $seq[$iseq ++];
        if ($new == $old) {
            $runl ++;
        } else {
            push(@runls, $runl);
            $old = $new;
            $runl = 1;
        }
    }
    push(@runls, $runl);
    push(@seq, @runls);
    $gen ++;
    $rlens[$gen] = scalar(@runls);
 	if ($gen > 4) {
	    # print sprintf("%3d ", $gen) . join("", @runls) . "\n";
	    my $offset = $rlens[$gen - 1] + $rlens[$gen - 1] - $rlens[$gen - 2];
	    my $len    = scalar(@runls) - $offset;
	    print 
	    	# sprintf("%3d ", $gen) . 
	    	join("", splice(@runls, $offset, $len)) . "\n";
	}
} # while 1
if (0) {
	for ($iseq = 0; $iseq < scalar(@seq); $iseq ++) {
    	print sprintf("%d %d\n", $iseq + 1, $seq[$iseq]);
	} # for
}
