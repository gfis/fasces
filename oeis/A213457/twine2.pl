#!perl

# OEIS A213457 Intertwined numbers
# @(#) $Id$
# 2018-03-19, Georg Fischer, 2nd attempt: with array of numbers
#
# a(n, n=1..6) = 1, 1, 2, 10, 148, 7384, 1380960,
# 1058349286 tuples found in 4478.587 s
#------------------------------------------------------
# usage:
#   perl twine2.pl n [visible [debug]]
#--------------------------------------------------------
use strict;
use Time::HiRes qw(time); # yields microseconds

my $max_n = shift(@ARGV); 
my $count = 0; # the overall counter for tuples
my @counters; # for each digit
my $visible = 0; # show outmost partial sums only; 1 : next level, 2: 3 levels ...
if (scalar(@ARGV) > 0) {
    $visible = shift(@ARGV);
}
my $debug = 0; # 0 = none, 1 = some, 2 = more
if (scalar(@ARGV) > 0) {
    $debug = shift(@ARGV);
}
my $SUCC = 1;
my $FAIL = 0;
# my $DIGITS = "0123456789";
# &check_all(split(//, "54354523452345"));
# print join("\n", &combinom("0123", 2)) . "\n";
my @arr;
my $i;
for ($i = 0; $i < $max_n; $i ++) {
    push(@arr, $max_n);
    push(@arr, $max_n - 1);
} # for $i
pop(@arr); # remove the trailing $max_n-1
#[0]1 2 3 4 5 6
# 4 3 4 3 4 3 4
#     x x x x   <- may insert 2 2s before these positions

my $start_time = time();
my $high_digit = $max_n - 2;
&insert($max_n - 2);

my $duration = (time() - $start_time);
$duration =~ s{(\d+)\.(\d{3})\d*}{$1.$2};
print        "# $count tuples found in $duration s\n";
# print STDERR "# $count tuples found in $duration s\n";

#---------------------------------
sub insert {
    my ($digit) = @_;
    my $beflo = 1; 
    while ($arr[$beflo] > $digit + 1) {
        $beflo ++;
    } 
    $beflo ++;
    # now $arr[$beflo] == $digit
    my $befhi = scalar(@arr) - 2; 
    while ($arr[$befhi] > $digit + 1) {
        $befhi --;
    } 
    # now $arr[$befhi] == $digit + 1
    my $fillno = $befhi - $beflo + 1; # 4
    if ($debug >= 2) {
        print "# " . join(" ", (0,1,2,3,4,5,6,7,8,9)) . " digit=$digit\n";
        print "# " . join(" ", @arr) . " beflo=$beflo, befhi=$befhi, fillno=$fillno\n";
    }
    #[0]1 2 3 4 5 6
    # 4 3 4 3 4 3 4
    #     x x x x   <- may insert 2 2s before these positions
    #
    # now insert $digit occurrences of $digit 
    # into the $fillno positions before $arr[$beflo..$befhi]
    if ($digit == 1) { # anywhere possible - simply count the possible positions
        $count += $fillno;
        if ($debug >= 1) {
            print "# + $fillno ones\n";
        }
    } else { # $digit > 1 - check, and maybe insert, recurse and remove again
        my $target = (((1 << $max_n) - 1) - ((1 << $digit) - 1)) << 1;
        my $k = $digit;
        my $n = $fillno;
        my $n2 = 1 << $n;
        my $bitmap = (1 << $k) - 1; # k bit sets
        while ($bitmap < $n2) { # evaluate binomial possibilities
            my @combin = (); # pick k out of n
            for (my $i = 0; $i < $n; $i++) {
                if ((($bitmap >> $i) & 1) != 0) {
                    push(@combin, $i);
                }
            } # for $i
            
            my $result = $SUCC;
            # check rule 1: between any pair of $digit all higher digits must occur
            if ($debug >= 2 and $digit >= $high_digit or $debug >= 3) {
                print "# combination " . join(" ", @combin) . "\n";
            }
            my $ipair = scalar(@combin) - 2;
            while ($result == $SUCC and $ipair >= 0) {
                my $start = $combin[$ipair];
                my $end   = $combin[$ipair + 1];
                if ($end - $start >= $max_n - $digit) {
                    my $source = 0;
                    for (my $jpos = $start; $jpos < $end; $jpos ++) {
                        $source |= 1 << $arr[$befhi - 1 - $jpos];
                        if ($debug >= 3) {
                            print "# source |= digit at " . ($befhi - 1 - $jpos) 
                                . " = " . $arr[$befhi - $combin[$jpos]] . "\n";
                        }
                    } # for jpos
                    if ($source != $target) { # not all higher digits did occur
                        if ($debug >= 3) {
                            print "# source " . sprintf("%b", $source) . " failed\n"; 
                        }
                        $result = $FAIL;
                    } else {
                        if ($debug >= 3) {
                            print "# source " . sprintf("%b", $source) . " succeeded\n"; 
                        }
                    }
                } else {
                    $result = $FAIL;
                }
                $ipair --;
            } # while ipair
            if ($result == $SUCC) { # valid combination
                $counters[$digit] = $count;
                if ($debug >= 1 and $digit >= $high_digit || $debug >= 3) {
                    print "# insert($digit) -> " . join(" ", @combin) . " result=$result\n";
                }
                my $cind;
                #-----------------
                # insert
                for ($cind = 0; $cind < scalar(@combin); $cind ++) { 
                    # important: splice downwards
                    splice(@arr, $befhi - $combin[$cind], 0, $digit); # insert 1 element before
                } # for cind backwards
                if ($debug >= 2) {
                    print "# inserted: " . join(" ", @arr) . "\n";
                }
                #-----------------
                # recurse
                &insert($digit - 1);
                #-----------------
                # remove
                for ($cind = scalar(@combin) - 1; $cind >= 0; $cind --) { 
                    # important: splice upwards
                    splice(@arr, $befhi - $combin[$cind], 1); # remove 1 element
                } # for cind backwards
                if ($debug >= 2) {
                    print "# removed:  " . join(" ", @arr) . "\n";
                }
                #-----------------
                my $diff = $count - $counters[$digit];
                if ($digit >= $high_digit - $visible) {
                    print "# " . ("  " x $digit) . "$digit: +$diff\n";
                }
            } # valid combination
            
            # next combination
            my $x = $bitmap & -$bitmap;
            my $y = $bitmap + $x;
            my $z = ($bitmap & ~$y);
            $bitmap = $z / $x;
            $bitmap >>= 1;
            $bitmap |= $y;
        } # while 
    } # $digit > 1
} # insert
__DATA__
# 1, 1, 2, 10, 148, 7384, 1380960,
# 1058349286 tuples found in 3818.873 s
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
# perl twine2.pl 5 2
#     2: +4
#     2: +5
#     2: +4
#     2: +6
#     2: +5
#     2: +4
#       3: +28
#     2: +4
#     2: +5
#     2: +4
#     2: +6
#     2: +5
#     2: +4
#     2: +7
#     2: +6
#     2: +5
#       3: +46
#     2: +5
#     2: +4
#     2: +6
#     2: +5
#     2: +4
#     2: +7
#     2: +6
#     2: +5
#     2: +4
#       3: +46
#     2: +4
#     2: +5
#     2: +4
#     2: +6
#     2: +5
#     2: +4
#       3: +28
# 148 tuples found in 0.001 s
# perl twine2.pl 7
#         4: +3684
#         4: +6426
#         4: +7058
#         4: +6426
#         4: +3684
#         4: +9858
#         4: +11656
#         4: +10878
#         4: +6426
#         4: +11824
#         4: +11656
#         4: +7058
#         4: +9858
#         4: +6426
#         4: +3684
#           5: +116602
#         4: +3684
#         4: +6426
#         4: +7058
#         4: +6426
#         4: +3684
#         4: +9858
#         4: +11656
#         4: +10878
#         4: +6426
#         4: +11824
#         4: +11656
#         4: +7058
#         4: +9858
#         4: +6426
#         4: +3684
#         4: +14040
#         4: +17344
#         4: +16400
#         4: +9858
#         4: +18822
#         4: +18814
#         4: +11656
#         4: +16400
#         4: +10878
#         4: +6426
#           5: +257240
#         4: +5672
#         4: +6304
#         4: +5642
#         4: +3172
#         4: +9080
#         4: +10854
#         4: +10040
#         4: +5872
#         4: +11050
#         4: +10812
#         4: +6498
#         4: +8984
#         4: +5842
#         4: +3335
#         4: +13238
#         4: +16494
#         4: +15508
#         4: +9262
#         4: +17976
#         4: +17886
#         4: +11030
#         4: +15436
#         4: +10222
#         4: +6023
#         4: +17278
#         4: +17916
#         4: +11213
#         4: +16368
#         4: +10988
#         4: +6643
#           5: +316638
#         4: +6643
#         4: +6023
#         4: +3335
#         4: +10988
#         4: +10222
#         4: +5842
#         4: +11213
#         4: +11030
#         4: +6498
#         4: +9262
#         4: +5872
#         4: +3172
#         4: +16368
#         4: +15436
#         4: +8984
#         4: +17916
#         4: +17886
#         4: +10812
#         4: +15508
#         4: +10040
#         4: +5642
#         4: +17278
#         4: +17976
#         4: +11050
#         4: +16494
#         4: +10854
#         4: +6304
#         4: +13238
#         4: +9080
#         4: +5672
#           5: +316638
#         4: +6426
#         4: +3684
#         4: +10878
#         4: +6426
#         4: +11656
#         4: +7058
#         4: +9858
#         4: +6426
#         4: +3684
#         4: +16400
#         4: +9858
#         4: +18814
#         4: +11656
#         4: +16400
#         4: +10878
#         4: +6426
#         4: +18822
#         4: +11824
#         4: +17344
#         4: +11656
#         4: +7058
#         4: +14040
#         4: +9858
#         4: +6426
#         4: +3684
#           5: +257240
#         4: +3684
#         4: +6426
#         4: +7058
#         4: +6426
#         4: +3684
#         4: +9858
#         4: +11656
#         4: +10878
#         4: +6426
#         4: +11824
#         4: +11656
#         4: +7058
#         4: +9858
#         4: +6426
#         4: +3684
#           5: +116602
# 1380960 tuples found in 5.797 s
# perl twine2.pl 7
#           5: +116602
#           5: +257240
#           5: +316638
#           5: +316638
#           5: +257240
#           5: +116602
# 1380960 tuples found in 5.693 s
# perl twine2.pl 8
#             6: +62425636
#             6: +153912067
#             6: +203960729
#             6: +217752422
#             6: +203960729
#             6: +153912067
#             6: +62425636
# 1058349286 tuples found in 3818.873 s
# 
