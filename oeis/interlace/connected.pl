#!perl

# Fill triangles with interlaced rows
# defined by Clark Kimberling
# @(#) $Id$
# 2018-03-10, Georg Fischer: 6th attempt, copied from inbetween.pl
#------------------------------------------------------
# usage:
#   perl connected.pl [max_row]
#--------------------------------------------------------
use strict;
use Time::HiRes qw(time); # yields microseconds

my $max_row = shift(@ARGV); # rowno runs from 0 to max_row - 1
my $size = ($max_row * ($max_row + 1)) / 2; # number of elements in the triangle
my $debug = 0; # 0 = none, 1 = some, 2 = more
if (scalar(@ARGV) > 0) {
    $debug = shift(@ARGV);
}
my $FAIL = 0;
my $SUCC = 1;

my @srow; # start index of a row
my @erow; # end   index of a row + 1
my @nrow; # row number for a position in the triangle
my @trel; # element which fills the position in the triangle, or $FREE
my @elpo; # position in the triangle where an element was allocated, or $NOEX
my $NOEX = $size;     # indicates that a position does not exist
my $FREE = $size + 1; # indicates that a position in the triangle is not filled by an element
$trel[$NOEX] = $NOEX;
$trel[$FREE] = $NOEX;

# positions of the neighbours of the focus element
my @polarm;
my @porarm;
my @polsib;
my @porsib;
my @polleg;
my @porleg;
#
# Naming of the neighbours of element $focus:
#
#       larm   rarm
#      /   \   /   \
#   lsib   FOCUS   rsib
#      \   /   \   /
#       lleg   rleg
#
my $cind = 0; # current index
my $last_row = $max_row - 1; # last row, lowest row
my $rowno = 0; # current row
while ($rowno <= $last_row) { # all rows except for the last
    my $nind = $cind + $rowno + 1; # index of the start of the next row
    $srow[$rowno] = $cind;
    $erow[$rowno] = $nind;
    while ($cind < $nind) {
        $nrow  [$cind] = $rowno;
        $trel  [$cind] = $FREE;
        $elpo  [$cind] = $NOEX;
        $polarm[$cind] = $FREE;
        $porarm[$cind] = $FREE;
        $polsib[$cind] = $FREE;
        $porsib[$cind] = $FREE;
        if ($cind > $srow[$rowno]    ) { # does not apply for row 0
            $polsib[$cind] = $cind - 1;
            $polarm[$cind] = $srow[$rowno - 1] + $polsib[$cind] - $srow[$rowno];
        } else { # no arm and sibling
            $polsib[$cind] = $NOEX;
            $polarm[$cind] = $NOEX;
        }
        if ($cind < $erow[$rowno] - 1) { # does not apply for row 0
            $porsib[$cind] = $cind + 1;
            $porarm[$cind] = $srow[$rowno - 1] + $cind          - $srow[$rowno];
        } else { # no arm and sibling
            $porsib[$cind] = $NOEX;
            $porarm[$cind] = $NOEX;
        }
        if ($rowno < $last_row) { # legs exist
            $polleg[$cind] = $erow[$rowno] + $cind - $srow[$rowno];
            $porleg[$cind] = $polleg[$cind] + 1;
        } else { # no legs for last row
            $polleg[$cind] = $NOEX;
            $porleg[$cind] = $NOEX;
        } # no legs for last row
        $cind ++;
    } # while $cind
    $rowno ++;
} # while rowno ++

if (0) { # repair legs of last row - they do not exist
    $cind = $srow[$last_row];
    while ($cind < $erow[$last_row]) {
        $polleg[$cind] = $NOEX;
        $porleg[$cind] = $NOEX;
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
    print "# trel:   " . join(",", @trel  ) . "\n";
    print "# elpo:   " . join(",", @elpo  ) . "\n";
    print "#\n";
}
# exit;
#----
# main program
my $count  = 0; # number of triangles which fulfill the interlacing condition
my $missed = 0; # number of triangles which were constructed, but failed the final test
my $investigated = 0; # number of free positions which were tried
my $level  = 0; # nesting level
my $start_time = time();

&test_lset(0); # start with $elem = 0 in lset

my $duration = (time() - $start_time);
$duration =~ s{(\d+)\.(\d{3})\d*}{$1.$2};
print        "# $count triangles found in $duration s\n";
print STDERR "# $count triangles found in $duration s\n";
print STDERR "# $investigated investigated, $missed triangles failed the final test\n";
exit; # main
#-----------------------
sub test_lset { my ($elem) = @_;
    $level ++;
    my $result = $FAIL;
    my $fpos;
    my $lelem = $elem - 1; # element of lset
    while ($lelem >= 0) { # try all arms of the lset
        $fpos = $elpo[$lelem]; # must be allocated (by construction)
        &evaluate($elem, $fpos, -1); # look at left  arm
        &evaluate($elem, $fpos, +1); # look at right arm
        $lelem --;
    } # while $lelem
    $fpos = $srow[$last_row];
    while ($fpos < $erow[$last_row]) { # look at some FREE in the last row
        &evaluate($elem, $fpos,  0);
        $fpos ++;
    } # while last
} # test_lset

sub test_rset { my ($elem) = @_;
    $level ++;
    my $result = $FAIL;
    my $fpos;
    my $relem = $elem + 1; # element of rset
    while ($relem < $size) { # try all arms of the rset
        $fpos = $elpo[$relem]; # must be allocated (by construction)
        &evaluate($elem, $fpos, -1); # look at left  arm
        &evaluate($elem, $fpos, +1); # look at right arm
        $relem ++;
    } # while $relem
    $fpos = $erow[$last_row] - 1;
    while ($fpos >= $srow[$last_row]) { # look at some FREE in the last row
        &evaluate($elem, $fpos,  0);
        $fpos --;
    } # while last
} # test_rset

sub evaluate { my ($elem, $fpos, $arm) = @_;
    my $epos; # where to allocate $elem
    if ($arm == 0) { # in last row
        $epos = $fpos;
    } elsif ($arm < 0) { # take left arm
        $epos = $polarm[$fpos];
    } else { # if ($arm > 0) { # take right arm
        $epos = $porarm[$fpos];
    }
    my $result = $SUCC;
    if ($trel[$epos] == $FREE) { # and therefore != $NOEX
        if ($arm == 0) { # last row
            my $lsib = $trel[$polsib[$epos]];
            if ($lsib < $size) { # != NOEX and != FREE
                if (abs($lsib - $elem) <= 1) {
                    $result = $FAIL;
                }
                my $larm = $trel[$polarm[$epos]];
                if (0 and $larm < $size) {
                    if ($lsib < $larm and $larm < $elem or
                        $lsib > $larm and $larm > $elem) {
                    } else {
                        $result = $FAIL;
                    }
                } # larm exists
            }
            if ($result == $SUCC) {
                my $rsib = $trel[$porsib[$epos]];
                if ($rsib < $size) { # != NOEX and != FREE
                    if (abs($rsib - $elem) <= 1) {
                        $result = $FAIL;
                    }
                    my $rarm = $trel[$porarm[$epos]];
                    if (0 and $rarm < $size) {
                        if ($elem < $rarm and $rarm < $rsib or
                            $elem > $rarm and $rarm > $rsib) {
                        } else {
                            $result = $FAIL;
                        }
                    } # rarm exists
                } # rsib exists
            }
        } else { # not last row
            my $leg1 = $trel[$fpos]; # != $NOEX, were we came from, == $lelem
            my $leg2 = $trel[$arm < 0 ? $polleg[$epos] : $porleg[$epos]];
            if ($leg2 < $size) { # != NOEX and != FREE
                if ($leg1 < $elem and $elem < $leg2 or
                    $leg1 > $elem and $elem > $leg2) {
                    # ok
                } else {
                    $result = $FAIL;
                }
            }
        } # not last
        if ($result == $SUCC) { # is possible
            # &allocate($elem, $epos);
            $investigated ++;
            $filled ++;
            $trel[$epos] = $elem;
            $elpo[$elem] = $epos;
            # print "# $level allocate $elem at $epos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
            if ($filled < $size) {
                my $conj = $size - 1 - $elem;
                if ($elem < $conj) {
                    &test_rset($conj    );
                } else {
                    &test_lset($conj + 1);
                }
            } else { # all elements exhausted, check, count and maybe print
                # check whole triangle again
                $result = &check_all();
                if ($result == $SUCC) {
                    my $ind = 0;
                    if ($debug >= 1) {
                        print join(" ", grep { $ind ++; $ind <= $size } @trel) . "\n";
                    }
                    $count ++;
                } else { # constructed, but still not possible
                    $missed ++;
                }
            } # all exhausted
            # &remove($elem, $epos);
            $filled --;
            $trel[$epos] = $FREE;
            $elpo[$elem] = $NOEX;
            # print "# $level remove   $elem at $epos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
        } # was possible
    } # was FREE
    return $result;
} # evaluate

sub allocate { my ($elem, $epos) = @_;
	# allocate $elem at $epos
    $filled ++;
    $trel[$epos] = $elem;
    $elpo[$elem] = $epos;
    # print "# $level allocate $elem at $epos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
} # allocate

sub remove { my ($elem, $epos) = @_;
	# undo the allocation of $elem at $epos
    $filled --;
    $trel[$epos] = $FREE;
    $elpo[$elem] = $NOEX;
    # print "# $level remove   $elem at $epos, filled=$filled, trel="  . join(" ", @trel) . "\n" if $debug >= 2;
} # remove

# neighbourhood access, connectivity and test methods
sub check_all { 
	# check all positions
    my $result = $SUCC;
    my $focus = 0;
    while ($result == $SUCC and $focus < $srow[$last_row]) {
        my $elem = $trel[$focus];
        my $larm = $trel[$polleg[$focus]];
        my $rarm = $trel[$porleg[$focus]];
        if ($larm < $elem and $elem < $rarm or
            $larm > $elem and $elem > $rarm) {
                # ok
        } else {
            $result = $FAIL;
        }
        $focus ++;
    } # while $focus
    return $result;
} # check_all

__DATA__
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl connected.pl 3
# arrange 6 numbers in a triangle with 3 rows, with father between child1 and child2
# 20 triangles found in 0.001 s
# 20 triangles found in 0.001 s
# 0 failed the final test
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl connected.pl 4
# arrange 10 numbers in a triangle with 4 rows, with father between child1 and child2
# 1744 triangles found in 0.180 s
# 1744 triangles found in 0.180 s
# 0 failed the final test
georg@nunki:~/work/gits/fasces/oeis/interlace$ perl connected.pl 5
# arrange 15 numbers in a triangle with 5 rows, with father between child1 and child2
# 2002568 triangles found in 314.388 s
# 2002568 triangles found in 314.388 s
# 0 failed the final test
georg@nunki:~/work/gits/fasces/oeis/interlace$
