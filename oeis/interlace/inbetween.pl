#!perl

# Fill triangles with interlaced rows
# defined by Clark Kimberling
# @(#) $Id$
# 2018-03-10, Georg Fischer: 5th attempt, copied from inlace.pl
#------------------------------------------------------
# usage:
#   perl inbetween.pl [max_row]
#--------------------------------------------------------
use strict;
use Time::HiRes qw(time); # yields microseconds

my $debug = 0; # 0 = none, 1 = some, 2 = more
my $max_row = shift(@ARGV); # rowno runs from 0 to max_row - 1
my $FREE = -1; # indicates that a  position in the triangle is not filled by an element
my $FAIL = 0;
my $SUCC = 1;
my $LSET = 0; # indicator that 0 <= $elem <= 4 (for size=10)
my $RSET = 1; # indicator that 5 <= $elem <= 9
my @srow; # start of row
my @erow; # end   of row + 1
my @nrow; # row number for a position in the triangle
my @trel; # element which fills the position in the triangle, or $FREE

# positions of the neighbours for the focus element
my @polarm;
my @porarm;
my @polsib;
my @porsib;
my @polleg;
my @porleg;
# Naming of the neighbours of element $focus:
#
#       larm   rarm
#      /   \   /   \
#   lsib   FOCUS   rsib
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
        $polarm[$cind] = $FREE;
        $porarm[$cind] = $FREE;
        $polsib[$cind] = $FREE;
        $porsib[$cind] = $FREE;
        if ($cind > $srow[$rowno]    ) {
            $polsib[$cind] = $cind - 1;
            $polarm[$cind] = $srow[$rowno - 1] + $polsib[$cind] - $srow[$rowno];
        }
        if ($cind < $erow[$rowno] - 1) {
            $porsib[$cind] = $cind + 1;
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
        .  "father between child1 and child2" ."\n";
if ($debug >= 2) {
    print "# srow:   " . join(",", @srow  ) . "\n";
    print "# erow:   " . join(",", @erow  ) . "\n";
    print "# nrow:   " . join(",", @nrow  ) . "\n";
    print "# polarm: " . join(",", @polarm) . "\n";
    print "# porarm: " . join(",", @porarm) . "\n";
    print "# polsib: " . join(",", @polsib) . "\n";
    print "# porsib: " . join(",", @porsib) . "\n";
    print "# polleg: " . join(",", @polleg) . "\n";
    print "# porleg: " . join(",", @porleg) . "\n";
    print "#\n";
}
#----
# main program
my $count  = 0; # number of triangles which fulfill the interlacing condition
my $missed = 0; # number of triangles which were constructed, but failed the final test
my $level = 0; # nesting level
my $start_time = time();
my $range9 = $size - 1;

&test(0, $LSET); # start with $elem = 0 in lset

my $duration = (time() - $start_time);
$duration =~ s{(\d+)\.(\d{3})\d*}{$1.$2};
print        "# $count triangles found in $duration s\n";
print STDERR "# $count triangles found in $duration s\n";
print STDERR "# $missed failed the final test\n";
exit; # main
#-----------------------
# test where an element can be allocated, and try the conjugate thereafter
sub test {
    my ($elem, $eset) = @_;
    $level ++;
    my $result = $FAIL;
    my $range0 = 0;
    if ($elem == 0 or $elem == $range9) { # restrict to last row
        $range0 = $srow[$last_row];
    } # restrict
    my $fpos = $range9; # position where $elem should be allocated
    while ($fpos >= $range0) {
        $result = $FAIL;
        if ($trel[$fpos] == $FREE) {
            $result = $SUCC;
            # allocate $elem here
            $filled ++;
            $trel[$fpos] = $elem;
            # print "# $level alloc $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;

            # check other conditions and refine $result
            if (&possible(2, $fpos, $eset) == $FAIL) {
                $result = $FAIL;
            }
            if ($result == $SUCC)
            { # other conditions true
                my $conj = $size - 1 - $elem + ($eset == $RSET ? 1 : 0); # conjugate element, 0 -> 9, 9 -> 1, 1 -> 8 ...
            #   if ($eset == $RSET) { # $elem in right set
            #       if ($elem < $size - 2) {
            #           $result = &check_legs($elem, $fpos, $conj);
            #       }
            #       # right set
            #   } else { # $elem in left set
            #       if ($elem > 1) {
            #           $result = &check_legs($elem, $fpos, $conj);
            #       }
            #       # left set
            #   }
                if ($result == $SUCC) { # connectivity
                    if ($filled < $size) {
                        # print "# $level next = $conj, " . join(" ", @trel) . "\n" if $debug >= 2;
                        &test($conj, $RSET - $eset);
                    } else { # all elements exhausted, check, count and maybe print
                        # check whole triangle again
                        $result = &check_all();
                        if ($result == $SUCC) {
                            print join(" ", @trel) . "\n" if $debug >= 1;
                            $count ++;
                        } else { # constructed, but still not possible
                            $missed ++;
                        }
                    } # all exhausted
                } # with connectivity
            } # other conditions
            # deallocate $elem
            $trel[$fpos] = $FREE;
            $filled --;
            # print "# $level free  $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
        } # if SUCC
        $fpos --;
    } # while $fpos
    $level --;
    return $result;
} # test

# neighbourhood access, connectivity and test methods

sub check_legs { # whether the element has any leg to a member of the adjacent set
    my ($elem, $fpos, $conj) = @_; # "left" set if $elem < $conj, otherwise "right" set
    my $memb;
    my $mpos; # position of $memb
    my $spos; # position of sibling of $memb
    my $sibl; # sibling of $memb
    my $result = $FAIL;
    if ($fpos >= $srow[$last_row]) {
        return $SUCC;
    } 
    $mpos = $polleg[$fpos];
    if ($mpos != $FREE) { # exists
        $memb = $trel[$mpos];
        if ($memb != $FREE and ($elem < $conj and $memb < $elem or $elem >= $conj and $memb > $elem)) {
            return $SUCC;
        } # lleg allocated
    } # exists
    $mpos = $porleg[$fpos];
    if ($mpos != $FREE) { # exists
        $memb = $trel[$mpos];
        if ($memb != $FREE and ($elem < $conj and $memb < $elem or $elem >= $conj and $memb > $elem)) {
            return $SUCC;
        } # rleg allocated
    } # exists
    $mpos = $polarm[$fpos];
    if ($mpos != $FREE) { # exists
        $memb = $trel[$mpos];
        if ($memb != $FREE and ($elem < $conj and $memb < $elem or $elem >= $conj and $memb > $elem)) {
            return $SUCC;
        } # larm allocated
    } # exists
    $mpos = $porarm[$fpos];
    if ($mpos != $FREE) { # exists
        $memb = $trel[$mpos];
        if ($memb != $FREE and ($elem < $conj and $memb < $elem or $elem >= $conj and $memb > $elem)) {
            return $SUCC;
        } # rarm allocated
    } # exists
    # print "check_legs elem=$elem, fpos=$fpos, $conj=$conj, memb=$memb, result=$result; \n" if $debug >= 2;
    return $result;
} # check_legs

sub check_all { # check all positions
    my $cind = 0;
    my $result = $SUCC;
    while ($cind < $srow[$last_row]) {
        if (&possible(1, $cind, ($cind < $size - $cind ? $LSET : $RSET) ) == $FAIL) {
            $result = $FAIL;
        }
        $cind ++;
    } # while $cind
    return $result;
} # check_all

# Naming of the neighbours of element $focus:
#
#       larm   rarm
#      /   \   /   \
#   lsib   FOCUS   rsib
#      \   /   \   /
#       lleg   rleg
#
# conditions for (a) between = 0, (b) for between = 1
# (1a) not last and lleg < focus < rleg
# (2a) 0,1,8,9 in lower corners
# (1b) not last and lleg < focus < rleg or lleg > focus > rleg
# (2b) 0,9 in last row
# (3) abs(lsib-focus) > 1, abs(rsib-focus) > 1 (is implied by (4,5)
# (4a) lsib  < larm < focus
# (4b) lsib  < larm < focus or lsib  > larm > focus
# (5a) focus < rarm < rsib
# (5b) focus < rarm < rsib  or focus > rarm > rsib

sub possible { # whether the focus fits in its neighbourhood
    my ($rule, $fpos, $eset) = @_; # position of focus, set of $focus
    my $result = $SUCC; # 0 = FALSE, 1 = TRUE
    my $focus  = $trel[$fpos]; # focus element
    my $frow   = $nrow[$fpos]; # row of focus
    my $connected = ($frow == $last_row) ? $SUCC : $FAIL; # not connected so far

    if ($frow < $last_row) { # not last
        # rule 1, legs, condition (1)
        my $poll = $polleg[$fpos];
        # if ($poll != $FREE) {
            my $lleg     = $trel[$poll]; # left  leg element
            if ($lleg != $FREE) {
                if ($eset == $LSET) {
                    if ($lleg < $focus) {
                        $connected = $SUCC;
                    }
                } else {
                    if ($lleg > $focus) {
                        $connected = $SUCC;
                    }
                }
                my $porl = $porleg[$fpos];
                # if ($porl != $FREE) {
                    my $rleg = $trel[$porl]; # right leg element
                    if ($rleg != $FREE) {
                        if ($eset == $LSET) {
                            if ($rleg < $focus) {
                                $connected = $SUCC;
                            }
                        } else {
                            if ($rleg > $focus) {
                                $connected = $SUCC;
                            }
                        }
                        if  ( ($lleg < $focus and $focus < $rleg) or
                              ($lleg > $focus and $focus > $rleg)
                            ) {
                            # $result = $SUCC;
                        } else {
                            $result = $FAIL;
                        }
                    } # rleg allocated
                # } # rleg exists
            } # lleg allocated
        # } # lleg exists
    } else { # last row
        # siblings may not have distance 1
        # but that is implied by the above conditions for the legs
        # $result = $SUCC;
    } # last row

    if ($rule > 1 and $frow > 0) { # check arms
        # left arm, condition (4)
        my $polh = $polsib[$fpos];
        if ($result == $SUCC and $polh != $FREE) {
            my $lsib = $trel[$polh];
            if ($lsib != $FREE) { # lsib allocated
                my $dist = $lsib - $focus;
                if ($dist == -1 or $dist == 1) {
                    $result = $FAIL;
                }
                my $pola  = $polarm[$fpos];
                if ($pola != $FREE and $result == $SUCC) {
                    my $larm  = $trel[$pola]; # left  arm element
                    if ($larm != $FREE) { # larm allocated
                        if ($eset == $LSET) {
                            if ($larm < $focus) {
                                $connected = $SUCC;
                            }
                        } else {
                            if ($larm > $focus) {
                                $connected = $SUCC;
                            }
                        }
                        if  ( ($lsib < $larm and $larm < $focus) or
                              ($lsib > $larm and $larm > $focus)
                            ) {
                            # $result = $SUCC;
                        } else {
                            $result = $FAIL;
                        }
                    } # larm allocated
                } # larm exists
            } # lsib allocated
        } # lsib exists

        # right arm, condition (5)
        my $porh = $porsib[$fpos];
        if ($result == $SUCC and $porh != $FREE) {
            my $rsib = $trel[$porh];
            if ($rsib != $FREE) { # rsib allocated
                my $dist = $rsib - $focus;
                if ($dist == -1 or $dist == 1) {
                    $result = $FAIL;
                }
                my $pora  = $porarm[$fpos];
                if ($pora != $FREE and $result == $SUCC) {
                    my $rarm  = $trel[$pora]; # right arm element
                    if ($rarm != $FREE) { # rarm allocated
                        if ($eset == $LSET) {
                            if ($rarm < $focus) {
                                $connected = $SUCC;
                            }
                        } else {
                            if ($rarm > $focus) {
                                $connected = $SUCC;
                            }
                        }
                        if  ( ($focus < $rarm and $rarm < $rsib) or
                              ($focus > $rarm and $rarm > $rsib) 
                            ) {
                            # $result = $SUCC;
                        } else {
                            $result = $FAIL;
                        }
                    } # rarm allocated
                } # rarm exists
            } # rsib allocated
        } # rsib exists
    } # arms, rule > 1
    if ($connected = $FAIL) {
    	$result = $FAIL;
    }
    return $result;
} # possible
# https://oeis.org/wiki/User:Georg_Fischer Feb. 27, 2018
__DATA__
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl -w inlace.pl 4 1
# arrange 10 numbers in a triangle with 4 rows, with father between child1 and child2
# 1744 triangles found in 0.760 s
# 1744 triangles found in 0.760 s
# 0 failed the final test
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl -w inlace.pl 5 0
# arrange 15 numbers in a triangle with 5 rows, with child1 < father < child2
# 286 triangles found in 0.100 s
# 286 triangles found in 0.100 s
# 0 failed the final test
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl -w inlace.pl 6 0
# arrange 21 numbers in a triangle with 6 rows, with child1 < father < child2
# 33592 triangles found in 50.232 s
# 33592 triangles found in 50.232 s
# 0 failed the final test
georg@nunki:~/work/gits/fasces/oeis/interlace$ 
