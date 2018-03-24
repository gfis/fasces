#!perl

# Build b-file of OEIS A291939 from tabular A070165
# @(#) $Id$
# 2018-03-23, Georg Fischer
#------------------------------------------------------
# Usage:
#	wget https://oeis.org/A070165/a070165.txt
#	perl a291939.pl 0 a070165.txt | tee b291939.txt
# Sequence:
#     1, 12, 19, 27, 37, 43, 51, 55, 75, 79, ... 9997
# Explanation:
# Build a 3-dimensional structure representing all Collatz
# sequences (CSs) up to some start element (the sequences are taken
# from A070165). 
# In that structure, the y direction is downwards, x is to the right, 
# and the "layer" z is upwards.
# The elements e(i) of the CSs starting with 1, 2, 3 ... 
# are positioned beginning at the end (4 2 1), and proceeding up to
# the starting number. Name them e(1) = 1, # e(2) = 2, e(3) = 4 etc.
# Start positioning the trailing element e(1) = 1 of a particular 
# CS at (x,y,z) = (1,1,1). For all i running up to the 
# starting element:
# If e(i+1) is even, store it at (e(i).x, e(i).(y+1), e(i).z), and
# if e(i+1) is odd,  store it at (e(i).(x+1), e(i).y, e(i).z),
# if that position is not occupied by a different number, 
# otherwise increase the layer z by one for all new elements
# to be stored.
# The target sequence A291939 = a(n) consists of all starting 
# values of all CSs which reach the z coordinate n for the first 
# time.
#--------------------------------------------------------
use strict;
my $debug = 1; # 0 = none, 1 = some, 2 = more
if (scalar(@ARGV) > 0) {
    $debug = shift(@ARGV);
}
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
    next if ! m{\A\d}; # no digit in column 1 -> skip initial comment lines
	# 9/20: [9, 28, 14, 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
	s/\s+//g; # remove all spaces
    my ($pair,$cs) = split(/\:/);
    my ($coln, $count) = split(/\//, $pair); # CS starts at $coln and has $count elements
    $cs =~ s{[\[\]]}{}; # remove square brackets
    @colseq = split(/\,/, $cs);
    if ($debug >= 2) {
        print "# evaluate CS($coln) = " . join(" ", @colseq) . "\n";
    }
    my ($x, $y, $z) = (1,1,1);
    my $ind = scalar(@colseq) - 1; 
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
This file has 10000 rows showing the following for each row:
  a) Starting number for Collatz sequence ending with 1 (a.k.a. 3x+1 sequence).
  b) Number of terms in sequence (a.k.a. number of halving and tripling steps to reach 1).
  c) Actual sequence as a vector.

1/4: [1, 4, 2, 1]
2/2: [2, 1]
3/8: [3, 10, 5, 16, 8, 4, 2, 1]
4/3: [4, 2, 1]
5/6: [5, 16, 8, 4, 2, 1]
6/9: [6, 3, 10, 5, 16, 8, 4, 2, 1]
7/17: [7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
8/4: [8, 4, 2, 1]
9/20: [9, 28, 14, 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
10/7: [10, 5, 16, 8, 4, 2, 1]
11/15: [11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
12/10: [12, 6, 3, 10, 5, 16, 8, 4, 2, 1]
13/10: [13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
14/18: [14, 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
15/18: [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
16/5: [16, 8, 4, 2, 1]
17/13: [17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
18/21: [18, 9, 28, 14, 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
19/21: [19, 58, 29, 88, 44, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
20/8: [20, 10, 5, 16, 8, 4, 2, 1]
21/8: [21, 64, 32, 16, 8, 4, 2, 1]
22/16: [22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
23/16: [23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
24/11: [24, 12, 6, 3, 10, 5, 16, 8, 4, 2, 1]
25/24: [25, 76, 38, 19, 58, 29, 88, 44, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
26/11: [26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
27/112: [27, 82, 41, 124, 62, 31, 94, 47, 142, 71, 214, 107, 322, 161, 484, 242, 121, 364, 182, 91, 274, 137, 412, 206, 103, 310, 155, 466, 233, 700, 350, 175, 526, 263, 790, 395, 1186, 593, 1780, 890, 445, 1336, 668, 334, 167, 502, 251, 754, 377, 1132, 566, 283, 850, 425, 1276, 638, 319, 958, 479, 1438, 719, 2158, 1079, 3238, 1619, 4858, 2429, 7288, 3644, 1822, 911, 2734, 1367, 4102, 2051, 6154, 3077, 9232, 4616, 2308, 1154, 577, 1732, 866, 433, 1300, 650, 325, 976, 488, 244, 122, 61, 184, 92, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
28/19: [28, 14, 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
29/19: [29, 88, 44, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
30/19: [30, 15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
31/107: [31, 94, 47, 142, 71, 214, 107, 322, 161, 484, 242, 121, 364, 182, 91, 274, 137, 412, 206, 103, 310, 155, 466, 233, 700, 350, 175, 526, 263, 790, 395, 1186, 593, 1780, 890, 445, 1336, 668, 334, 167, 502, 251, 754, 377, 1132, 566, 283, 850, 425, 1276, 638, 319, 958, 479, 1438, 719, 2158, 1079, 3238, 1619, 4858, 2429, 7288, 3644, 1822, 911, 2734, 1367, 4102, 2051, 6154, 3077, 9232, 4616, 2308, 1154, 577, 1732, 866, 433, 1300, 650, 325, 976, 488, 244, 122, 61, 184, 92, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
32/6: [32, 16, 8, 4, 2, 1]
33/27: [33, 100, 50, 25, 76, 38, 19, 58, 29, 88, 44, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
34/14: [34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
35/14: [35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]
36/22: [36, 18, 9, 28, 14, 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
37/22: [37, 112, 56, 28, 14, 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
38/22: [38, 19, 58, 29, 88, 44, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]
...