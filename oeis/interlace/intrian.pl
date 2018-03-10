#!perl

# Fill triangles with interlaced rows 
# defined by Clark Kimberling
# @(#) $Id$
# 2018-03-06, Georg Fischer: 3rd attempt
#------------------------------------------------------
# usage:
#   perl intrian.pl [max_row [between]]
#--------------------------------------------------------
use strict;
use Time::HiRes qw(time); # yields microseconds

my $debug = 0; # 0 = none, 1 = some, 2 = more
my $max_row = shift(@ARGV); # rowno runs from 0 to max_row - 1
my $between = 0; # whether strictly less than (0) or between (1)
if (scalar(@ARGV) > 0) {
    $between = shift(@ARGV);
}
my $FREE = -1; # indicates that a  position in the triangle is not filled by an element
my $NALL = -1; # indicates that no position in the triangle is allocated to the element
my $FAIL = 0; 
my $SUCC = 1; 
my $TRUE    = 1;
my $FALSE   = 0;
my $UNKNOWN = -1;
my @srow; # start of row
my @erow; # end   of row + 1
my @nrow; # row number for a position in the triangle
my @trel; # element which fills the position in the triangle, or $FREE
my @elpo; # position in the triangle for an element

# positions of the neighbours for the focus element
my @polarm;
my @porarm;
my @polhip;
my @porhip;
my @polleg;
my @porleg;
# Naming of the neighbours of element $focus:
#
#       larm   rarm
#      /   \   /   \
#   lhip   FOCUS   rhip
#      \   /   \   /
#       lleg   rleg
my $cind = 0; # current index 
my $rowno = 0; # current row
while ($rowno < $max_row) {
    my $nind = $cind + $rowno + 1; # index of the start of the next row 
    $srow[$rowno] = $cind;
    $erow[$rowno] = $nind;
    while ($cind < $nind) {
        $nrow[$cind]   = $rowno;
        $trel[$cind]   = $FREE;
        $elpo[$cind]   = $NALL;
        $polarm[$cind] = $FREE; 
        $porarm[$cind] = $FREE;
        $polhip[$cind] = $FREE;
        $porhip[$cind] = $FREE;
        if ($cind > $srow[$rowno]    ) {
            $polhip[$cind] = $cind - 1;
            $polarm[$cind] = $srow[$rowno - 1] + $polhip[$cind] - $srow[$rowno];
        }
        if ($cind < $erow[$rowno] - 1) {
            $porhip[$cind] = $cind + 1;
            $porarm[$cind] = $srow[$rowno - 1] + $cind          - $srow[$rowno];
        }
        # arms of row 0 remain free be conditions above
        # legs always exist
        $polleg[$cind] = $erow[$rowno] + $cind - $srow[$rowno];
        $porleg[$cind] = $polleg[$cind] + 1;
        $cind ++;
    } # while $cind
    $rowno ++;
} # while rowno ++
my $last_row = $rowno - 1; # last row, lowest row
my $size = $cind; # number of elements in the triangle
my $width = $size;

if (1) { # repair legs of last row - they do not exist
    $cind = $srow[$last_row];
    while ($cind < $erow[$last_row]) {
        $polleg[$cind] = $FREE;
        $porleg[$cind] = $FREE;
        $cind ++;
    } # while $cind
} # repair last row     

my $filled = 0;
print "# arrange $size numbers in a triangle with $rowno rows, with "
        . ($between == 0 ? "child1 < father < child2" : "father between child1 and child2") ."\n";
if ($debug >= 2) {
    print "# srow:   " . join(",", @srow  ) . "\n";
    print "# erow:   " . join(",", @erow  ) . "\n";
    print "# nrow:   " . join(",", @nrow  ) . "\n";
    print "# polarm: " . join(",", @polarm) . "\n";
    print "# porarm: " . join(",", @porarm) . "\n";
    print "# polhip: " . join(",", @polhip) . "\n";
    print "# porhip: " . join(",", @porhip) . "\n";
    print "# polleg: " . join(",", @polleg) . "\n";
    print "# porleg: " . join(",", @porleg) . "\n";                                  
    print "#\n";
}
#----
my $count = 0; # number of triangles which fulfill the interlacing condition
my $level = 0; # nesting level
my $start_time = time();
if ($between == 0) { # 
    &alloc(0,         $srow[$last_row    ]    );
    &alloc(1,         $srow[$last_row - 1]    );
    &alloc($size - 1, $erow[$last_row    ] - 1);
    &alloc($size - 2, $erow[$last_row - 1] - 1);
    &test(2);
} else {
    &test(0);
}
my $duration = (time() - $start_time);
$duration =~ s{(\d+)\.(\d{3})\d*}{$1.$2};
print        "# $count triangles found in $duration s\n";
print STDERR "# $count triangles found in $duration s\n";
exit;

# test where an element can be allocated, and try the conjugate thereafter
sub test { 
    my ($elem) = @_; 
    $level ++;
    my $result = $FAIL;
    my $range0 = 0;
    my $range9 = $size - 1;
    if ($elem == $range0 or $elem == $range9) { # restrict to last row
        # this brings max_row=4 down from 36 s to 3.3 s
        $range0 = $srow[$last_row];
        $range9 = $erow[$last_row] - 1;
    } # restrict
    my $fpos = $range9; # position where $elem should be allocated
    while ($fpos >= $range0) {
        $result = $FAIL;
        if ($trel[$fpos] == $FREE) {
            $result = $SUCC;
            # allocate $elem here
            $filled ++;
            $trel[$fpos] = $elem;
            $elpo[$elem] = $fpos;
            print "# $level alloc $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;

            # check other conditions and refine $result
            if (&possible(2, $fpos) == $FALSE) {
                $result = $FAIL;
            }
            if ($result == $SUCC) 
            { # other conditions true
                my $conj = $size - 1 - $elem; # conjugate element, 0 -> 9, 9 -> 1, 1 -> 8 ...
                if ($conj < $elem) { # $elem in right half
                    $conj ++; # adjust it
                    if ($elem < $size - 2) {
                        $result = &check_right_connection($elem, $fpos);
                    }
                    # right half
                } else { # $elem in left half
                    if ($elem > 1) {
                        $result = &check_left_connection ($elem, $fpos);
                    }
                    # left half
                } 
                if ($result == $SUCC) { # connectivity
                    if ($filled < $size) {
                        print "# $level next = $conj, " . join(" ", @trel) . "\n" if $debug >= 2;
                        &test($conj);
                    } else { # all elements exhausted, check, count and maybe print
                        # check whole triangle again
                        $result = &check_all();
                        if ($result == $SUCC) {
                            print join(" ", @trel) . "\n" if $debug >= 1;
                            $count ++;
                        }
                    } # all exhausted
                } # with connectivity
            } # other conditions
            # deallocate $elem
            $elpo[$elem] = $NALL; 
            $trel[$fpos] = $FREE;
            $filled --;
            print "# $level free  $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
        } # if SUCC
        $fpos --;
    } # while $fpos 
    $level --;
    return $result;
} # test

# allocate an element
sub alloc {
    my ($elem, $fpos) = @_;
    $filled ++;
    $trel[$fpos] = $elem;
    $elpo[$elem] = $fpos;
    print "# $level alloc $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
} # alloc
    
# neighbourhood access, connectivity and test methods

sub check_left_connection { # whether the element has a connection to any member of the "left" set
    my ($elem, $fpos) = @_;
    my $memb;
    my $pos;
    my $result = $FAIL;
    if ($between == 1 and $fpos >= $srow[$last_row]) {
        return $SUCC;
    } else {
    	{ $pos = $polarm[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb < $elem) { return $SUCC; }}}
    	{ $pos = $polleg[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb < $elem) { return $SUCC; }}}
#   	{ $pos = $polhip[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb < $elem) { return $SUCC; }}}
    	{ $pos = $porarm[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb < $elem) { return $SUCC; }}}
    	{ $pos = $porleg[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb < $elem) { return $SUCC; }}}
#   	{ $pos = $porhip[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb < $elem) { return $SUCC; }}}
    }
    # print "check_left_connection  elem=$elem, fpos=$fpos, memb=$memb, result=$result; \n" if $debug >= 2;
    return $result;
} # check_left_connection

sub check_right_connection { # whether the element has a connection to any member of the "right" set 
    my ($elem, $fpos) = @_;
    my $memb;
    my $pos;
    my $result = $FAIL;
    if ($between == 1 and $fpos >= $srow[$last_row]) {
        return $SUCC;
    } else {
    	{ $pos = $polarm[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb > $elem) { return $SUCC; }}}
    	{ $pos = $polleg[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb > $elem) { return $SUCC; }}}
#   	{ $pos = $polhip[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb > $elem) { return $SUCC; }}}
    	{ $pos = $porarm[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb > $elem) { return $SUCC; }}}
    	{ $pos = $porleg[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb > $elem) { return $SUCC; }}}
#   	{ $pos = $porhip[$fpos]; if ($pos != $FREE) { $memb = $trel[$pos]; if ($memb != $FREE and $memb > $elem) { return $SUCC; }}}
    }
    # print "check_right_connection elem=$elem, fpos=$fpos, memb=$memb, result=$result; \n" if $debug >= 2;
    return $result;
} # check_right_connection

sub check_all { # check all positions
    my $cpos = 0;
    my $result = $SUCC;
    while ($cpos < $srow[$last_row]) {
        if (&possible(1, $cpos) == $FALSE) {
            $result = $FAIL;
        }
        $cpos ++;
    } # while $cpos
    return $result;
} # check_all

# Naming of the neighbours of element $focus:
#
#       larm   rarm
#      /   \   /   \
#   lhip   FOCUS   rhip
#      \   /   \   /
#       lleg   rleg
#
# conditions for (a) between = 0, (b) for between = 1
# (1a) not last and lleg < focus < rleg    
# (2a) 0,1,8,9 in lower corners
# (1b) not last and lleg < focus < rleg or lleg > focus > rleg
# (2b) 0,9 in last row
# (3) abs(lhip-focus) > 1, abs(rhip-focus) > 1 (is implied by (4,5)
# (4a) lhip  < larm < focus
# (4b) lhip  < larm < focus or lhip  > larm > focus
# (5a) focus < rarm < rhip
# (5b) focus < rarm < rhip  or focus > rarm > rhip

sub possible { # whether the focus fits in its neighbourhood
    my ($rule, $fpos) = @_; # position of focus
    my $result = $TRUE; # -1: UNKNOWN, 0 = FALSE, 1 = TRUE
    my $focus  = $trel[$fpos]; # focus element
    my $frow   = $nrow[$fpos]; # row of focus
    
    if ($frow < $last_row) { # not last
        # rule 1, legs, condition (1)
        my $poll = $polleg[$fpos];
        if ($poll != $FREE) {
            my $lleg     = $trel[$poll]; # left  leg element
            if ($lleg != $FREE) {
                my $porl = $porleg[$fpos];
                if ($porl != $FREE) {
                    my $rleg = $trel[$porl]; # right leg element
                    if ($rleg != $FREE) {
                        if  ( ($lleg < $focus and $focus < $rleg) 
                              or ($between == 1 and
                              ($lleg > $focus and $focus > $rleg))
                            ) {
                            # $result = $TRUE;
                        } else {
                            $result = $FALSE;
                        }   
                    } # rleg allocated
                } # rleg exists
            } # lleg allocated
        } # lleg exists
    } else { # last row - hips may not have distance 1
        # $result = $TRUE;
    } # last row
    
    if ($rule > 1 and $frow > 0) { # check arms
        # left arm, condition (4)
        my $polh = $polhip[$fpos];
        if ($polh != $FREE) {
            my $lhip = $trel[$polh];
            if ($lhip != $FREE) { # lhip allocated
                my $dist = $lhip - $focus;
                if ($dist == -1 or $dist == 1) {
                    $result = $FALSE;
                }
                my $pola  = $polarm[$fpos];
                if ($pola != $FREE) {
                    my $larm  = $trel[$pola]; # left  arm element
                    if ($larm != $FREE and $result == $TRUE) { # larm allocated
                        if  ( ($lhip < $larm and $larm < $focus) 
                               or ($between == 1 and
                              ($lhip > $larm and $larm > $focus))
                            ) {
                            # $result = $TRUE;
                        } else {
                            $result = $FALSE;
                        }  
                    } # larm allocated
                } # larm exists
            } # lhip allocated
        } # lhip exists

        # right arm, condition (5)
        my $porh = $porhip[$fpos];
        if ($porh != $FREE) {
            my $rhip = $trel[$porh];
            if ($rhip != $FREE) { # rhip allocated
                my $dist = $rhip - $focus;
                if ($dist == -1 or $dist == 1) {
                    $result = $FALSE;
                }
                my $pora  = $porarm[$fpos];
                if ($pora != $FREE) {
                    my $rarm  = $trel[$pora]; # right arm element
                    if ($rarm != $FREE and $result == $TRUE) { # rarm allocated
                        if  ( ($focus < $rarm and $rarm < $rhip) 
                               or ($between == 1 and
                              ($focus > $rarm and $rarm > $rhip) )
                            ) {
                            # $result = $TRUE;
                        } else {
                            $result = $FALSE;
                        }  
                    } # rarm allocated
                } # rarm exists
            } # rhip allocated
        } # rhip exists
    } # arms, rule > 1
    return $result;
} # possible
#------------------------------------------
# permutation algorithm, not used
my $rollOver;
my @swaps;
my @meter;
if (0) {
    &permute();
}
exit;

sub permute {
    &reset();
    while ($rollOver == 0) {
        my @result = &next();
        print join(" ", @result) . "\n";
    } # while ! $rollOver
} # permute

sub reset() {
    @swaps = ();
    my $im = 0;
    while ($im < $width) {
        $meter[$im] = $im;
        $swaps[$im] = $im;
        $im ++;
    } # while $im
    $rollOver = 0;
} # reset

# Determines the next permutation by swapping 2 elements.
# Pleasant, efficient, non-recursive implementation derived from the stackoverflow answer.
# @return an array with the <em>original</em> digits tuple <em>before</em> rolling

sub next() {
    my @result = @meter; # first copy current tuple to the result
    my $i = $width - 1;
    while ($i >= 0 and $swaps[$i] == $width - 1) {
        &swap($i, $swaps[$i]); # Undo the swap represented by swaps[i]
        $swaps[$i] = $i;
        $i --;
    } # while i

    if ($i < 0) {
        $rollOver = 1;
    } else {
        my $prev = $swaps[$i];
        &swap($i, $prev);
        my $next = $prev + 1;
        $swaps[$i] = $next;
        &swap($i, $next);
    }
    return @result;
} # next

# Exchange to elements of the array to be permuted
# @param i index of 1st element
# @param j index of 2nd element
sub swap() {
    my ($i, $j) = @_;
    my $tmp = $meter[$i];
    $meter[$i] = $meter[$j];
    $meter[$j] = $tmp;
} #swap

exit;
print STDERR "$count triangles with interlacing rows\n";
# https://oeis.org/wiki/User:Georg_Fischer Feb. 27, 2018
__DATA__
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl -w intrian.pl 4 0
# arrange 10 numbers in a triangle with 4 rows, with child1 < father < child2
# 12 triangles found in 0.004 s
# 12 triangles found in 0.004 s
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl -w intrian.pl 5 0
# arrange 15 numbers in a triangle with 5 rows, with child1 < father < child2
# 286 triangles found in 12.475 s
# 286 triangles found in 12.475 s
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl -w intrian.pl 4 1
# arrange 10 numbers in a triangle with 4 rows, with father between child1 and child2
# 1744 triangles found in 1.337 s
# 1744 triangles found in 1.337 s
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl -w intrian.pl 5 1
# arrange 15 numbers in a triangle with 5 rows, with father between child1 and child2
# 2002568 triangles found in 22308.002 s
# 2002568 triangles found in 22308.002 s
georg@nunki:~/work/gits/fasces/oeis/interlace$ 

georg@nunki:~/work/gits/fasces/oeis/interlace$ perl intrian.pl 4 
# arrange 10 numbers in a triangle with 4 rows, with child1 < father < child2
# srow: 0,1,3,6
# erow: 1,3,6,10
# nrow: 0,1,1,2,2,2,3,3,3,3
#
# 3628800 triangles found
georg@nunki:~/work/gits/fasces/oeis/interlace$ 





                       3
                      2 .
                     1 . 8
                    0 . . 9
                                                        6
                                      3                 7
                                     2
                                    1 5 8               7
                                   0 4   9              6

             .
            2 .
           1 . 8
          0 . . 9

                                      4
                                     2 .
                                    1 . 8
                                   0 3 . 9
                                                        6
                                                 4      7
                                                2 .
                                               1 5 8    7
                                              0 3 . 9   6
                       .
                      2 .
                     1 . 8
                    0 3 . 9
                                                        6
                                                 5      7
                                                2 .
                                               1 4 8    7
                                              0 3 . 9   6
                                      .
                                     2 .
                                    1 4 8
                                   0 3 . 9
                                                .      6
                                               2 .     7
                                              1 4 8
                                             0 3 5 9

   .
  . .
 1 . 8
0 . . 9

                                                       6
                                          4            7
                                         3 .
                                        1 5 8          7
                                       0 2 . 9         6
                        4
                       3 .
                      1 . 8
                     0 2 . 9

             .
            3 .
           1 . 8
          0 2 . 9

                                          6
                                         3 7
                                        1 4 8
                                       0 2 5 9
                        .
                       3 .
                      1 4 8
                     0 2 . 9
                                                       6
                                          5            7
                                         3 .
                                        1 4 8          7
                                       0 2 . 9         6




(b)oth = up and down interlaced, only (u)pper,
all (l)ess, all (g)reater,
si = mirror of ri
3 4 1 5 2 0 b g0
2 4 1 5 3 0 b g1
3 4 2 1 5 0 u s1
3 2 4 1 5 0 u s2
3 4 1 2 5 0 u s3
2 4 1 3 5 0 u s4
3 4 2 0 5 1 u r2
3 2 4 0 5 1 u r1
3 4 1 5 0 2 b s5
3 1 4 0 5 2 b r3
2 4 1 5 0 3 b s6
2 1 4 0 5 3 b r4
2 3 1 5 0 4 u s7
2 1 3 5 0 4 u s8
3 1 4 2 0 5 u r5
2 1 4 3 0 5 u r6
2 3 1 4 0 5 u r8
2 1 3 4 0 5 u r7
3 1 4 0 2 5 u l0
2 1 4 0 3 5 u l1
6*b, 14*u, 2*l, 2*g

time perl interlace.pl 10 0 < perm10.tmp
# arrange 10 numbers in a triangle with 4 interlaced rows
less than: 6
          3 7
         1 4 8
        0 2 5 9
less than: 6
          2 7
         1 4 8
        0 3 5 9
less than: 5 3 7 1 4 8 0 2 6 9
less than: 4 3 7 1 5 8 0 2 6 9
less than: 5 2 7 1 4 8 0 3 6 9
less than: 4 2 7 1 5 8 0 3 6 9
less than: 3 2 7 1 5 8 0 4 6 9
less than: 5 3 6 1 4 8 0 2 7 9
less than: 4 3 6 1 5 8 0 2 7 9
less than: 5 2 6 1 4 8 0 3 7 9
less than: 4 2 6 1 5 8 0 3 7 9
less than: 3 2 6 1 5 8 0 4 7 9
12 triangles with interlacing rows
29.62user 0.11system 0:29.94elapsed 99%CPU (0avgtext+0avgdata 4088maxresident)k
8784inputs+0outputs (1major+180minor)pagefaults 0swaps

012345678901234
ABCDEFGHIJKLMNO <- instead of digits

Strict "less" interlacing
------------------------------
lower left  corner: AAA/BBB
lower right corner: III\JJJ (last)
min left  edge: A,B,C,D,...
max right edge: J,I,H.G,...
all -- must be strict <
all /  must be strict <
all \  must be strict >

start with:
                       D-G

                    C-x   x-H

                 BBB   x-x   III

              AAA   x-x   x-x   JJJ

Step 1: x < or >
                       D-G

                    C-F   E-H

                 BBB   D-G   III

              AAA   C-F   E-H   JJJ

Step 2: shrink center of vertically duplicated arms

                       D-G

                    C-F   E-H

                 BBB   E!F   III

              AAA   C-F   E-H   JJJ

Step 3: re-evaluate < >

                       D-G

                    C-E   F-H

                 BBB   E!F   III

              AAA   C-E   F-H   JJJ

Step 4:
E in row 2 would leave FGH for 4 positions right to it
F in row 2 would leave CDE for 4 positions left  to it

4                      D-G

4                   C-D   G-H

2                BBB   E!F   III

6             AAA   C-E   F-H   JJJ

select out of 4 * 2 * 2 * 2 * 3 * 3 = 288

try C in [7] (1 of 3)
try E in [4] (1 of 2)
try G in [2] (1 of 2)
4                      F=F

4                   D=D   G=G

2                BBB   E=E   III

6             AAA   C=C   H=H   JJJ

------------------------------------------------

/\ ascending/descending

                       E-K

                    D-J   F-L

                 C-I   E-K   G-M

              BBB   D-J   F-L   NNN

           AAA   C-I   E-K   G-M   OOO

how many must fit to the right or to the left

                       E+K

                    D+H   H+L

                 C+G   G+I   I+M

              BBB   E+G   I+L   NNN

           AAA   C+F   F+K   J+M   OOO

re-adjust lines

                       E+K

                    D+H   H+L

                 C+F   G+I   J*M

              BBB   E+G   I+L   NNN

           AAA   C+F   F+K   J+M   OOO



7                              04-10

6                         03-05     09-11

7                    02-03     06-08     11-12

6               01-01     04-06     08-10     13-13

13         00-00     02-05     05-09     09-12     14-14
= 180222 possibilities

try 02 in [10] (1 of 4)
try 04 in [7]  (1 of 3)
try 06 in [4]  (1 of 3)
try 07 in [0]  (1 of 4)
try 08 in 12   (1 of 2)
try 09 in 8    (1 of 2)
try 10 in 2    (1 of 2)
try 11 in 13   (1 of 2)
2304 possibilities
7                              07=07

6                         05=05     10=10

7                    03=03     06=06     12=12

6               01-01     04=04     09=09     13-13

13         00-00     02=02     08=08     11=11     14-14
------------------------------------------
differently
7                              08-08

6                         05-05     10-10

7                    02-02     07-07     12-12

6               01-01     04-04     09-09     13-13

13         00-00     03-03     06-06     11-11     14-14

try 02 in 3    (1 of 2)
try 03 in 11   (1 of 3)
try 04 in 7    (1 of 3)
try 06 in 12   (1 of 4)
try 07 in 4    (1 of 2)
try 08 in 8    (1 of 3)
try 09 in 9    (1 of 2)
try 10 in 2    (1 of 2)
try 11 in 13   (1 of 2)
3456 possibilities

======================================================
2018-03-07
intrian.pl 2 1 ->
   1           1
  2 0  symm.  0 2
  
=> *2 + 1

            3
        5       1
a   0:4     =6      =0          
    2:4     =6      =0            
3 5 1 2 6 0 ->  3 4 1 2 5 0
3 5 1 4 6 0 ->  2 4 1 3 5 0
            3
        5       1
b   =6      2:6     =0          
    =6      2:4     =0          
3 5 1 6 2 0 ->  3 4 1 5 2 0
3 5 1 6 4 0 ->  2 4 1 5 3 0 = c2

            3
        5       1
c   =6      =0      2:6         
    =6      =0      2:4           
3 5 1 6 0 2 ->  3 4 1 5 0 2
3 5 1 6 0 4 ->  2 4 1 5 0 3 = b2

intrian.pl 3 1 ->
a   3 4 1 5 2 0     /s
b   2 4 1 5 3 0     /t
c   3 4 2 1 5 0     /h
d   3 2 4 1 5 0     /g
e   3 4 1 2 5 0     /j
f   2 4 1 3 5 0     /l
i   3 4 1 5 0 2     /o
k   2 4 1 5 0 3     /p
m   2 3 1 5 0 4     /r
n   2 1 3 5 0 4     /q
following counts *=2 because of  symmetry:

o   3 1 4 2 0 5         5       1       11
                  2:4     6:10     =0      =12      2*3
                  6:10    2:4      =0      =12      3*2
                  6:10    =0       2:10    =12      3*4
                  6:10    =0       =12     2:10     3*4 -> 36

p   2 1 4 3 0 5         7       1       11
                  2:6     8:10     =0      =12      3*2
                  8:10    2:6      =0      =12      2*3
                  8:10    =0       2:10    =12      2*4
                  8:10    =0       =12     2:10     2*4 -> 28

q   2 3 1 4 0 5         9       1       11
                  2:8     =10      =0      =12      4  
                  =10     2:8      =0      =12      4  
                  =10     =0       2:8     =12      5  
                  =10     =0       =12     2:8      5   -> 16

r   2 1 3 4 0 5         9       1       11
                  2:8     =10      =0      =12      4  
                  =10     2:8      =0      =12      4  
                  =10     =0       2:8     =12      4  
                  =10     =0       =12     2:8      4   -> 16

s   3 1 4 0 2 5         1       5       11
                  =0       2:4     6:10    =12      2*3
                  =0       2:4     =12     2:10     2*4
                  =0       6:10    2:4     =12      3*2
                  2:10      =0     6:10    =12      3*4
                  2:10      =0     =12     2:10     5*4 -> 52

t   2 1 4 0 3 5         1       7       11
                  =0       2:6     8:10    =12      3*2
                  =0       2:6     =12     2:10     3*4
                  =0       8:10    2:6     =12      2*3
                  2:10      =0     8:10    =12      2*4
                  2:10      =0     =12     2:10     5*4 -> 52

g   3 4 2 0 5 1         1       11      3
                  =0       4:10    =12     =2       4  
                  =0       =12     4:10    =2       4  
                  =0       =12     =2      4:10     4  
                  4:10      =0     =12     =2       4   -> 16

h   3 2 4 0 5 1         1       11      3
                  =0       4:10    =12     =2       4  
                  =0       =12     4:10    =2       4  
                  =0       =12     =2      4:10     4  
                  4:10      =0     =12     =2       4   -> 16

j   3 1 4 0 5 2         1       11      5
                  =0       2:10    =12     2:4      2*4
                  =0       =12     6:10    2:4      2*3
                  =0       =12     2:4     6:10     2*3
                  2:10      =0     =12     2:4      2*4 -> 28

l   2 1 4 0 5 3         1       11      7
                  =0       2:10    =12     2:6      3*4
                  =0       =12     8:10    2:6      2*3
                  =0       =12     2:6     8:10     2*3
                  2:10      =0     =12     2:6      3*4 -> 36
