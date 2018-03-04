#!perl

# Test for interlaced rows in triangles
# as defined by Clark Kimberling
# @(#) $Id$
# 2018-03-03, Georg Fischer
#------------------------------------------------------
# usage:
#   perl stackinter.pl [max_row [between]]
#--------------------------------------------------------
use strict;

my $max_row = shift(@ARGV); # rowno runs from 0 to max_row - 1
my $between = 0; # whether strictly less than (0) or between (1)
if (scalar(@ARGV) > 0) {
    $between = shift(@ARGV);
}
my $count;
my $cind = 0;
my $rowno = 0;
my $nind = $cind + $rowno + 1;
my @rows; # start of row
while ($rowno < $max_row) {
    @rows[$rowno] = $cind;
    $cind = $nind;
    $rowno ++;
    $nind += $rowno + 1;
} # while rowno ++
$rows[$rowno] = $cind; # additional stopper for last row
my $len = $cind;
my $width = $cind;

print STDERR "# arrange $len numbers in a triangle with $rowno interlaced \""
        . ($between == 0 ? "less than" : "between") . "\" rows\n";

my @stack; # contains elements which are still to be evaluated
my @nelem; # next element positions to be tried
my @trian; # free positions in the triangle (-1) or element in the position (>= 0)

# positions of elements
my @min;
my @max;
my @cur;

my $FREE = -1;
my $IN_ROW = -1;

my $debug = 1;
my @segs; # segment starts = 1, 0 otherwise
if (1) { # stack evaluation
    $cind = 0;
    while ($cind < $len) { # preset arrays
        $trian[$cind] = $FREE;
        $segs[$cind] = $IN_ROW;
        $min[$cind] = 0;
        $cur[$cind] = $min[$cind];
        $max[$cind] = $len;
        $cind ++;
    } # preset
    my $irow = 0;
    while ($irow < scalar(@rows)) {
        $segs[$rows[$irow]] = irow;
        $irow ++;
    }

    my $elem = 0;
    my $pos;
    push(@stack, $elem);
    while (scalar(@stack) > 0) {
        $elem = pop(@stack); # where in the triangle can $elem be placed
        $pos  = $cur[$elem]; # that was the old position?
        print "popped $elem; stack=" . join(",", @stack) . "; pos=$pos\n" if $debug > 0;
        my $nonfit = &is_nonfit($elem, $pos);
        while ($nonfit == 1 and $pos < $max[$elem]) {
            if ($trian[$pos] == $elem) {
                $trian[$pos] = $FREE;
            }
            $pos ++;
            $nonfit = &is_nonfit($elem, $pos);
        } # while nonfit
        if ($nonfit == 1) { # loop broke because $pos >= $max: range is exhausted

            # range exhausted
        } else { # $pos did fit
            print "placed $elem at $pos\n" if $debug > 0;
            $trian[$pos] = $elem;
            push(@stack, $elem);
            $elem ++;
            if ($elem < $len) { # there is another element to be placed
                $cur[$elem] = $min[$elem];
                push(@stack, $elem); # try it
                print "pushed $elem; " . join(",", @stack) . "\n" if $debug > 0;
            } else { # all elements are placed
                print "" . join(" ", @trian) . "\n";
            }
        } # pos did fit
    } # while stack not empty
} # stack evaluation
print "segs: " . join(",", @segs) . "\n";
#---------------------------
sub is_nonfit {
    my ($elem, $pos) = @_;
    my $result = 0; # assume that it fits
    print "triangle " . join("/", @trian) . "\n" if $debug > 0;
    if (0) {
    } elsif ($trian[$pos] != $FREE) {
        $result = 1; # not free
    } else {
        if ($segs[$pos] != $IN_ROW) {
            if (0) {
            } elsif ($trian[$pos - 1] != $FREE and $trian[$pos - 1] >= $elem) {
                $result = 1;
            } elsif ($segs[$pos + 1] != $IN_ROW and $trian[$pos + 1] != $FREE and $trian[$pos - 1] >= $elem) {
                $result = 1;
            }
        } else { # == IN_ROW


                if (if trian[$pos] != $FREE) {
        $result = 1; # not free

    if ($trian[$pos] == $FREE) { # condition (1): position is free
        if ($segs[$pos] == IN_ROW) {
            $result = ($trian[$pos - 1] < $elem) ? 0 : 1;
            print "is_nonfit($elem, $pos) = $result for <\n" if $debug > 0;
        } else {
            $result = 0;
            print "is_nonfit($elem, $pos) = $result at row start\n" if $debug > 0;
        }
    }
    return $result;
} # is_nonfit
#---------------------------
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
