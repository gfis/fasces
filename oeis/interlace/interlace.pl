#!perl

# Test for interlaced rows in triangles
# as defined by Clark Kimberling
# @(#) $Id$
# 2018-02-27, Georg Fischer
#------------------------------------------------------
# usage:
#   java -cp ... org.teherba.ramath.util.Permutator 10 \
#   | perl interlace.pl 10
#--------------------------------------------------------
use strict;

my $len = shift(@ARGV);
my $between = 0; # whether strictly less than (0) or between (1)
if (scalar(@ARGV) > 0) {
    $between = shift(@ARGV);
}
my $rowno = 1;
while ($rowno * ($rowno - 1) / 2 < $len) {
    $rowno ++;
} # while rowno ++
$rowno --;
print STDERR "# arrange $len numbers in a triangle with $rowno interlaced \""
        . ($between == 0 ? "less than" : "between") . "\" rows\n";
my $count = 0;
while (<>) {
    # print "$_";
    s/\r?\n//; # chompr
    my @pm = split(/ /);
    my $irow = 0; # index for current row
    my $crow = 0; # start of current row
    my $nrow = 0; # start of next row
    my $cind = 0; # index in current row
    my $nind = 0; # index in next row
    my $busy = 1;
    while ($irow < $rowno - 1 and $busy == 1) {
        $nrow = $crow + $irow + 1;
        $cind = $crow;
        $nind = $nrow;
        # print "check row $irow = pm[$cind..${nrow}-1] against pm[$nrow..]\n";
        while ($cind < $nrow and $busy == 1) {
            # print "irow=$irow, crow=$crow, nrow=$nrow, cind=$cind, nind=$nind\n";
            if  ( $pm[$cind] > $pm[$nind] and $pm[$cind] < $pm[$nind + 1] or
                  $between == 1 and
                  $pm[$cind] < $pm[$nind] and $pm[$cind] > $pm[$nind + 1]
                ) { # ok
                $cind ++;
                $nind ++;
            } else { # violation
                $busy = 0;
            } # violation
            # print "irow=$irow, crow=$crow, nrow=$nrow, cind=$cind, nind=$nind, busy=$busy\n";
        } # while $crow
        $crow = $nrow;
        $irow ++;
    } # while $irow
    if ($busy == 1) { # success
        $count ++;
        print "" . join(" ", @pm) . "\n";
    } # success
} # while <>
print STDERR "$count triangles with interlacing rows\n";
# https://oeis.org/wiki/User:Georg_Fischer Feb. 27, 2018
__DATA__
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

with swapping Permutator:
	0 1 2 3 4 5
	-----------
a	2 1 3 4 0 5
b	2 1 3 5 0 4		a35
c	2 1 4 3 0 5		a23
d	2 1 4 0 3 5		c34
e	2 1 4 0 5 3		d45
f	2 3 1 4 0 5		a12
g	2 3 1 5 0 4		b12
h	2 4 1 3 5 0		r04
i	2 4 1 5 0 3		h34
j	2 4 1 5 3 0		i45
k	3 1 4 0 2 5		d04
l	3 1 4 0 5 2		k45
m	3 1 4 2 0 5		k34
n	3 2 4 0 5 1		l15
o	3 2 4 1 5 0		n34
p	3 4 2 0 5 1		n12
q	3 4 2 1 5 0		o12
r	3 4 1 2 5 0		q23
s	3 4 1 5 2 0		r34
t	3 4 1 5 0 2		s45

with swapping Permutator:
	0 1 2 3 4 5
	-----------
a	2 1 3 4 0 5		f12
b	2 1 3 5 0 4		a35
g	2 3 1 5 0 4		b12
f	2 3 1 4 0 5		g35

h	2 4 1 3 5 0		r04
i	2 4 1 5 0 3		h34
j	2 4 1 5 3 0		i45


e	2 1 4 0 5 3		
d	2 1 4 0 3 5		e45
c	2 1 4 3 0 5		d34
m	3 1 4 2 0 5		c03
k	3 1 4 0 2 5		m34
l	3 1 4 0 5 2		k45
n	3 2 4 0 5 1		l15
o	3 2 4 1 5 0		n34
q	3 4 2 1 5 0		o12
r	3 4 1 2 5 0		q23
s	3 4 1 5 2 0		r34
t	3 4 1 5 0 2		s45
p	3 4 2 0 5 1		n12




time perl interlace.pl 10 0 < perm10.tmp
# arrange 10 numbers in a triangle with 4 interlaced rows
less than: 6 3 7 1 4 8 0 2 5 9
less than: 6 2 7 1 4 8 0 3 5 9
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
