#!perl

# Fill triangles with interlaced rows
# defined by Clark Kimberling
# @(#) $Id$
# 2018-03-10, Georg Fischer: 4th attempt, copied from intrian.pl
#------------------------------------------------------
# usage:
#   perl inlace.pl [max_row [between]]
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
my $FAIL = 0;
my $SUCC = 1;
my @srow; # start of row
my @erow; # end   of row + 1
my @nrow; # row number for a position in the triangle
my @trel; # element which fills the position in the triangle, or $FREE

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
my $count  = 0; # number of triangles which fulfill the interlacing condition
my $missed = 0; # number of triangles which were constructed, but failed the final test
my $level = 0; # nesting level
my $start_time = time();
if ($between == 0) { # strict less than: 0,1,8, 9 have fixed positions
    &alloc(0,         $srow[$last_row    ]    );
    &alloc(1,         $srow[$last_row - 1]    );
    &alloc($size - 1, $erow[$last_row    ] - 1);
    &alloc($size - 2, $erow[$last_row - 1] - 1);
    &test(2); # start with $elem = 2
} else { # between
    &test(0); # start with $elem = 0
}
my $duration = (time() - $start_time);
$duration =~ s{(\d+)\.(\d{3})\d*}{$1.$2};
print        "# $count triangles found in $duration s\n";
print STDERR "# $count triangles found in $duration s\n";
print STDERR "# $missed failed the final test\n";
exit;
#-----------------------
# unconditionally allocate an element
sub alloc {
    my ($elem, $fpos) = @_;
    $filled ++;
    $trel[$fpos] = $elem;
    print "# $level alloc $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
} # alloc
#----
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
            print "# $level alloc $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;

            # check other conditions and refine $result
            if (&possible(2, $fpos) == $FAIL) {
                $result = $FAIL;
            }
            if ($result == $SUCC)
            { # other conditions true
                my $conj = $size - 1 - $elem; # conjugate element, 0 -> 9, 9 -> 1, 1 -> 8 ...
                if ($conj < $elem) { # $elem in right half
                    $conj ++; # adjust it
                    if ($elem < $size - 2) {
                        $result = &check_legs($elem, $fpos, $conj);
                    }
                    # right half
                } else { # $elem in left half
                    if ($elem > 1) {
                        $result = &check_legs($elem, $fpos, $conj);
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
                        } else { # constructed, but still not possible
                            $missed ++;
                        }
                    } # all exhausted
                } # with connectivity
            } # other conditions
            # deallocate $elem
            $trel[$fpos] = $FREE;
            $filled --;
            print "# $level free  $elem at $fpos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
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
    if ($between == 1 and $fpos >= $srow[$last_row]) {
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
        if (&possible(1, $cind) == $FAIL) {
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
    my $result = $SUCC; # 0 = FALSE, 1 = TRUE
    my $focus  = $trel[$fpos]; # focus element
    my $frow   = $nrow[$fpos]; # row of focus

    if ($frow < $last_row) { # not last
        # rule 1, legs, condition (1)
        my $poll = $polleg[$fpos];
        # if ($poll != $FREE) {
            my $lleg     = $trel[$poll]; # left  leg element
            if ($lleg != $FREE) {
                my $porl = $porleg[$fpos];
                # if ($porl != $FREE) {
                    my $rleg = $trel[$porl]; # right leg element
                    if ($rleg != $FREE) {
                        if  ( ($lleg < $focus and $focus < $rleg)
                              or ($between == 1 and
                              ($lleg > $focus and $focus > $rleg))
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
        # hips may not have distance 1
        # but that is implied by the above conditions for the legs
        # $result = $SUCC;
    } # last row

    if ($rule > 1 and $frow > 0) { # check arms
        # left arm, condition (4)
        my $polh = $polhip[$fpos];
        if ($polh != $FREE) {
            my $lhip = $trel[$polh];
            if ($lhip != $FREE) { # lhip allocated
                my $dist = $lhip - $focus;
                if ($dist == -1 or $dist == 1) {
                    $result = $FAIL;
                }
                my $pola  = $polarm[$fpos];
                if ($pola != $FREE) {
                    my $larm  = $trel[$pola]; # left  arm element
                    if ($larm != $FREE and $result == $SUCC) { # larm allocated
                        if  ( ($lhip < $larm and $larm < $focus)
                               or ($between == 1 and
                              ($lhip > $larm and $larm > $focus))
                            ) {
                            # $result = $SUCC;
                        } else {
                            $result = $FAIL;
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
                    $result = $FAIL;
                }
                my $pora  = $porarm[$fpos];
                if ($pora != $FREE) {
                    my $rarm  = $trel[$pora]; # right arm element
                    if ($rarm != $FREE and $result == $SUCC) { # rarm allocated
                        if  ( ($focus < $rarm and $rarm < $rhip)
                               or ($between == 1 and
                              ($focus > $rarm and $rarm > $rhip) )
                            ) {
                            # $result = $SUCC;
                        } else {
                            $result = $FAIL;
                        }
                    } # rarm allocated
                } # rarm exists
            } # rhip allocated
        } # rhip exists
    } # arms, rule > 1
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
