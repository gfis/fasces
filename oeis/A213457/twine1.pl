#!perl

# OEIS A213457 Intertwined numbers
# @(#) $Id$
# 2018-03-19, Georg Fischer, copied from interlace/connected.pl
#
# a(n, n=1..6) = 1, 1, 2, 10, 148, 7384, 1380960
#------------------------------------------------------
# usage:
#   perl twine1.pl n [debug]
#--------------------------------------------------------
use strict;
use Time::HiRes qw(time); # yields microseconds

my $n = shift(@ARGV); 
my $debug = 1; # 0 = none, 1 = some, 2 = more
if (scalar(@ARGV) > 0) {
    $debug = shift(@ARGV);
}
my $SUCC = 1;
my $FAIL = 0;
my $DIGITS = "0123456789";
&check_all(split(//, "54354523452345"));
print join("\n", &combinom("0123", 2)) . "\n";

sub check_all { # check all conditions
    my $str = join("", @_);
    if ($debug >= 2) {
        print "$str\n";
    }
    my $result = $SUCC;
    my $k = $n;
    while ($k >= 2) {
        my @conts = grep { length($_) > 0 } split(/$k/, $str);
        if ($debug >= 2) {
            print "between $k\'s: " . join(",", @conts);
        }
        # test (1)
        my $j = $k + 1;
        while ($j <= $n) {
            map { if (! m/$j/) { $result = $FAIL; } $_ } @conts;
            $j ++;
        }
        if ($debug >= 2) {
            print ", test1=$result";
        }
        $j = $k - 1;
        while ($j > 0) {
            map { if ((s/$j/$j/g) > 1)  { $result = $FAIL; } $_ } @conts;
            $j --;
        }
        if ($debug >= 2) {
            print ", test2=$result";
            print "\n";
        }
        $k --;
    } # while $k
    if ($debug >= 1) {
        print "$str " . ($result == $SUCC ? " ok" : " bad") . "\n";
    }
    return $result;
} # check_all

sub combinom { # get all combinations of k elements out of n (= length($str))
    # from https://stackoverflow.com/questions/12991758/creating-all-possible-k-combinations-of-n-items-in-c
    my  @result = ();
    my ($str, $k) = @_;
    my $n = length($str);
    my $n2 = 1 << $n;
    my $combo = (1 << $k) - 1; # k bit sets
    while ($combo < $n2) {
        my $line = "";
        for (my $i = 0; $i < $n; $i++) {
            if ((($combo >> $i) & 1) != 0) {
                $line .= substr($str, $i, 1);
            }
        } # for $i
        push(@result, $line);
        my $x = $combo & -$combo;
        my $y = $combo + $x;
        my $z = ($combo & ~$y);
        $combo = $z / $x;
        $combo >>= 1;
        $combo |= $y;
    } # while 
    return @result;
} # combinom

__DATA__
 1, 1, 2, 10, 148, 7384, 1380960

{}
 0
--------------------------------------
 a
 1
--------------------------------------
 b a b
 1
--------------------------------------
(2 1) = 2 positions for c
2   1   2
=1
--------------------------------------
3   2   3   2   3

3   2 1 3   2   3
3   2   3 1 2   3
c   b a c   b   c  A3
c   b   c a b   c  /A3
=2
--------------------------------------
(5 2) = 10 positions for 2 d times 2*A3
d cba d cb  d c   d  A4 A3
d cba d c   d bc  d  B4 A3
d cb  d acb d c   d  C4 A3
d cb  d ac  d bc  d  D4 A3
d c   d bac d bc  d  /E4    A3

d cb  d cab d c   d  E4 /A3
d cb  d ca  d bc  d  /D4    /A3
d cb  d c   d abc d  /B4    /A3
d c   d bca d bc  d  /C4    /A3
d c   d bc  d abc d  /A4    /A3    

4   3   4   3   4   3   4    Z
 
4   3 2 4   3 2 4   3   4    A
4   3 2 4   3   4 2 3   4    B
4   3   4 2 3   4 2 3   4    C

4   3   2 1 4   3   2   4   3   4    A1
4   3   2   4 1 3   2   4   3   4    A2
4   3   2   4   3 1 2   4   3   4    A3

4   3   2 1 4   3   4   2   3   4    B1
4   3   2   4 1 3   4   2   3   4    B2
4   3   2   4   3 1 4   2   3   4    B3
4   3   2   4   3   4 1 2   3   4    B4

4   3   4   2 1 3   4   2   3   4    C1
4   3   4   2   3 1 4   2   3   4    C2
4   3   4   2   3   4 1 2   3   4    C3
=10
--------------------------------------
5   4   5   4   5   4   5   4   5

5   4 3 5   4 3 5   4 3 5   4   5   A
5   4 3 5   4 3 5   4   5 3 4   5   B
5   4 3 5   4   5 3 4   5 3 4   5   D
5   4   5 3 4   5 3 4   5 3 4   5   H

5   4   3 2 5   4   3 2 5   4   3   5   4   5   A 4 positions for 1 between 2s
5   4   3 2 5   4   3   5 2 4   3   5   4   5   A 5
5   4   3 2 5   4   3   5   4 2 3   5   4   5   A 6
5   4   3   5 2 4   3   5 2 4   3   5   4   5   A 4
5   4   3   5 2 4   3   5   4 2 3   5   4   5   A 5
5   4   3   5   4 2 3   5   4 2 3   5   4   5   A 4
                                               = 28
5   4   3 2 5   4   3 2 5   4   5   3   4   5   B 4
5   4   3 2 5   4   3   5 2 4   5   3   4   5   B 5
5   4   3 2 5   4   3   5   4 2 5   3   4   5   B 6
5   4   3 2 5   4   3   5   4   5 2 3   4   5   B 7
5   4   3   5 2 4   3   5 2 4   5   3   4   5   B 4
5   4   3   5 2 4   3   5   4 2 5   3   4   5   B 5
5   4   3   5 2 4   3   5   4   5 2 3   4   5   B 6
5   4   3   5   4 2 3   5   4 2 5   3   4   5   B 4
5   4   3   5   4 2 3   5   4   5 2 3   4   5   B 5
                                               = 46
5   4   3 2 5   4   5   3 2 4   5   3   4   5   D 5
5   4   3 2 5   4   5   3   4 2 5   3   4   5   D 6
5   4   3 2 5   4   5   3   4   5 2 3   4   5   D 7
5   4   3   5 2 4   5   3 2 4   5   3   4   5   D 4
5   4   3   5 2 4   5   3   4 2 5   3   4   5   D 5
5   4   3   5 2 4   5   3   4   5 2 3   4   5   D 6
5   4   3   5   4 2 5   3   4 2 5   3   4   5   D 4
5   4   3   5   4 2 5   3   4   5 2 3   4   5   D 5
5   4   3   5   4   5 2 3   4   5 2 3   4   5   D 4
                                               = 46
5   4   5   3 2 4   5   3 2 4   5   3   4   5   H 4
5   4   5   3 2 4   5   3   4 2 5   3   4   5   H 5
5   4   5   3 2 4   5   3   4   5 2 3   4   5   H 6
5   4   5   3   4 2 5   3   4 2 5   3   4   5   H 4
5   4   5   3   4 2 5   3   4   5 2 3   4   5   H 5
5   4   5   3   4   5 2 3   4   5 2 3   4   5   H 4
                                               = 28
                                      A+B+D+H = 148 !
--------------------------------------                          
6   5   6   5   6   5   6   5   6   5   6 

6   5 4 6   5 4 6   5 4 6   5 4 6   5   6 
6   5 4 6   5 4 6   5 4 6   5   6 4 5   6 
6   5 4 6   5 4 6   5   6 4 5   6 4 5   6 
6   5 4 6   5 4 6   5 4 6   5 4 6   5   6 
6   5 4 6   5   6   5 4 6   5 4 6   5   6 
6   5   6 4 5   6 4 5   6 4 5   6 4 5   6 
70 possiblities to place the 4

(9 3) = 84 positions for 3 e times 10*A4 
--------------------------------------
(14 4) = 1001
--------------------------------------
