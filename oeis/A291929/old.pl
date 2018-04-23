#!perl

# Build b-file of OEIS A291939 from tabular A070165
# @(#) $Id$
# 2018-03-23, Georg Fischer
#------------------------------------------------------
# Usage:
#     wget https://oeis.org/A070165/b070165.txt
#     perl a291939.pl b070165.txt > b291939.txt
# Sequence:
#     1, 12, 19, 27, 37
# Explanation:
# Build a 3-dimensional structure representing all Collatz
# sequences (CSs) up to some start element (the sequences are taken
# from A070165). 
# In that structure, the y direction is downwards, x is to the right, 
# and the "layer" z is forward.
# The elements e(i) of the CSs starting with 1, 2, 3 ... 
# are positioned beginning at the end (4 2 1), and proceeding up to
# the starting number (index n of A070165). Name them e(1) = 1,
# e(2) = 2, e(3) = 4 etc.
# Start positioning the trailing element e(1) = 1 of a particular 
# CS at (x,y,z) = (1,1,1). For all i running up to the
# starting element:
# If e(i+1) = 2 * e(i), position the e(i+1) at (e(i).x, e(i).(y+1), e(i).z)
# if that position is still free or if the CS value is the same as e(i+1), 
# otherwise increase the z # coordinate of e(i+1) until the position is free.
# The target sequence A291939 = a(n) consists of all e(i) which reach
# the z coordinate n for the first time.
#--------------------------------------------------------
use strict;
my $debug = 1; # 0 = none, 1 = some, 2 = more
if (scalar(@ARGV) > 0) {
    $debug = shift(@ARGV);
}
my $num = 1;
my $bfn = 1; # index for target b-file
my $layer = 1;
my %chains; # maps (x,y,layer=z) -> elements of a CS
$chains{"1,1,1"} = 1;
my @elems; # maps elements of a CS to their coordinates (x,y,z)
$elems[1] = "1,1,1";
print <<"GFis";
# b-file for A291939
1 1
GFis
my @colseq = ();
my $curr_layer = 1;
while (<>) {
    s/\s+\Z//; # chompr
    my ($n, $an) = split(/\s+/);
    push(@colseq, $an);
    if ($an == 1) { # end: evaluate this one and start a new sequence
        if ($debug >= 2) {
            print "# evaluate CS($num) = " . join(" ", @colseq) . "\n";
        }
        my $ind = scalar(@colseq) - 1; 
        my ($x, $y, $z) = (1,1,1);
        my $coln = $colseq[0]; # we currently process the single CS starting with $coln 
        $ind --; # element's indexes run backwards in contradiction to the explanation above
        while ($ind >= 0) {
            my $elcurr = $colseq[$ind];
            if (defined($elems[$elcurr])) {
                ($x, $y, $z) = split(/\,/, $elems[$elcurr]); 
            } else { # undefined - append to chain
                if (($elcurr & 1) == 0) { # even -> go down
                    $y ++;
                    &investigate($coln, $elcurr, $x, $y, $curr_layer);
                } else { # odd -> go right
                    $x ++;
                    &investigate($coln, $elcurr, $x, $y, $curr_layer);
                }
            } # undefined
            $ind --;
        } # while $ind
        
        # start next CS
        $num ++;
        @colseq = (); 
    } # end of one cs
} # while <>

sub investigate {
    my ($coln, $elcurr, $x, $y, $z) = @_;
    if (defined($chains{"$x,$y,$z"})) { 
        my $stelem = $chains{"$x,$y,$z"};
        if ($stelem ne $elcurr) { # collision
            $curr_layer ++;
            if ($debug >= 2) {
                print "# collision for $elcurr at ($x,$y,$z), layer -> $curr_layer\n";
            }
            $z = $curr_layer;
            $bfn ++; 
            print "$bfn $coln\n";
            &allocate($elcurr, $x, $y,$z);
        } # else same element - ignore
    } else { # undefined
        &allocate($elcurr, $x, $y,$z);
    } # undefined
} # investigate

sub allocate {
    my ($elcurr, $x, $y, $z) = @_;
    $chains{"$x,$y,$z"} = $elcurr;
    $elems[$elcurr] = "$x,$y,$z";
    if ($debug >= 2) {
        print "# allocate $elcurr at ($x,$y,$z)\n";
    }
} # allocate
__DATA__
1 1
2 2
3 1
4 3
5 10
6 5
7 16
8 8
9 4
10 2
11 1
...