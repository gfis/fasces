#!perl

# Generate OEIS A030707, A055187, A217760 and related
# "cumulative counting" sequences as defined by Clark Kimberling.
# http://faculty.evansville.edu/ck6/integer/unsolved.html, Problem 4
# @(#) $Id$
# 2018-04-20, Georg Fischer (previosu version in cumulcount2.pl)
#------------------------------------------------------
# Comment from A217760:
#   Write 0 followed by segments defined inductively as follows: each segment
#   tells how many times each previously written integer occurs, in the order
#   of first occurrence.  This is Method A (adjective-before-noun pairs); for
#   Method B (noun-before-adjective), see A055168.
# Example:
#   Start with 0, followed by the adjective-noun pair 1,0; followed by
#   adjective-noun pairs 2,0 then 1,1; etc. Writing the pairs vertically,
#   the initial segments are
#   0.|.1.|.2 1.|.3 3 1.|.4 5 2 2.|.5 6 5 3 1 1.|.6 9 6 5 2 4 1.|.7 11 8 6 4 6 4 1
#   ..|.0.|.0 1.|.0 1 2.|.0 1 2 3.|.0 1 2 3 4 5.|.0 1 2 3 4 5 6.|.0 1  2 3 4 5 6 9
#
# Usage:
#   perl cumulcount.pl -m method -r row -n noeis -l len -a appear -o offset -s start -p parm -d debug
#       All parameters are optional and have a default value:
#       method = "A" (attribute over noun; default)
#                "B" (noun over attribute)
#                "C" (noun behind attribute)
#                "D" (new, distinct elements)
#                "I" (inverse, first occurrence of a number)
#                "J" (next term which is greater than all previous)
#                "K" (next position where term is greater than all previous)
#                "N" (number of new elements in segment)
#                "P" (positions of small numbers (p2))
#                "S" (sum of terms in segment n)
#                "T" (number of terms in segment n)
#       row    =  0 (count in both rows,    output both; default)
#                 1 (count in both rows,    output 1st)
#                 2 (count in both rows,    output 2nd)
#                 5 (count in 1st row only, output 1st)
#                 6 (count in 1st row only, output 2nd)
#       noeis  = "030707|055187|217760 ..." (OEIS number without "A", default "030707")
#       len    = length of sequence to be generated (default: 256)
#       appear = "io" (increasing order; default)
#                "do" (decreasing order)
#                "iz" (increasing order, complete with zero counts)
#                "dz" (decreasing order, complete with zero counts)
#                "fa" (order of first appearance)
#       offset = 0, 1 (index f 1st b-file entry, default: 1)
#       start  = starting value for a(1): 0, 1 (default), 3, 4, 5
#       parm   = 2nd parameter (for rule "P"): 1, 2, 3, 4
#       debug  = 0 (none; default)
#                1 (with segments)
#--------------------------------------------------------
use strict;

my $debug  = 0;
my $len    = 256;
my $method = "A";
my $noeis  = "030707";
my $appear = "io";
my $parm   = 0;
my $row    = 0;
my $start  = 1;
my $with_zero = 0; # ignore nouns with zero attribute
my $offset = 1;

while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt eq "-a") { $appear  = shift(@ARGV);
    } elsif ($opt eq "-d") { $debug   = shift(@ARGV);
    } elsif ($opt eq "-l") { $len     = shift(@ARGV);
    } elsif ($opt eq "-m") { $method  = shift(@ARGV);
    } elsif ($opt eq "-n") { $noeis   = shift(@ARGV);
    } elsif ($opt eq "-o") { $offset  = shift(@ARGV);
    } elsif ($opt eq "-p") { $parm    = shift(@ARGV);
    } elsif ($opt eq "-r") { $row     = shift(@ARGV);
    } elsif ($opt eq "-s") { $start   = shift(@ARGV);
    } else { die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $incpre = 0; # 1 would count in nouns only
my $incpst = 0; # 1 would count in attrs only

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
    = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d"
    , $year + 1900, $mon + 1, $mday, $hour, $min);
print <<"GFis";
# http://oeis.org/A$noeis/b$noeis.txt: table n,a(n)
# Generated by cumulcount.pl on $timestamp
GFis

my @seqlen = (1); # cumulative length of sequence so far, indexed with $segno
my %occrs  = ();
my $curmax = $start - 1;
my $segno = 1;
my @segment = ();
# $segment[i+0] = attribute, how often (i = 1, 3, 5 ..)
# $segment[i+1] = noun, which number is counted,
#               always increasing, always complete with zero attributes
my @count; # temporary copy of the attributes
my $attr;  # attribute, count of nouns
my $noun;  # the numbers to be counted
my $iseg;  # index in @segment

$noun = 0;
while ($noun < $start) { # fill before $start
    push(@segment, 0, $noun);
    $noun ++;
} # while filling
push(@segment, 1, $start);

my $k = 1;
my $k2 = $k; # copy of k, running as if it were rule A
    if (0) {
    } elsif ($method =~ m{[ABIJKP]}i) {
        if ($row <= 1 or $row == 5) {
            &bfile($start);
        }
    } elsif ($method =~ m{C}i) {
        &bfile(1, $start);
    } elsif ($method =~ m{D}i) {
        print "$k $start\n"; $k ++;
    } elsif ($method =~ m{N}i) {
        print "$k 1\n"  ; $k ++;
    } elsif ($method =~ m{[ST]}i) {
    } else {
        die "invalid rule \"$method\" at bf(1)\n";
    }
$segno ++;

while ($k <= $len and $segno <= $len) { # compute new segment from current
    &advance();
    $segno ++;
} # while b-file

if ($method =~ m{I}i) { # special treatment of the inverse
    $k = 1;
    foreach my $attr (sort {$a <=> $b} (keys(%occrs))) {
        last if $attr > $k; # must be monotone
        print "$k $occrs{$attr}\n"; $k ++;
    } # foreach
} # method I
#----------------
sub advance { # count between 0 and $nmax, and store in @counts
    my $amax = -1; # $nmax is the current segment length / 2
if ($debug >= 1) {
    print "seg#$segno:";
    $iseg = 0;
    while ($iseg < scalar(@segment)) { # print the elements of this segment
        $attr = $segment[$iseg + 0];
        $noun = $segment[$iseg + 1];
        print " $attr.$noun";
        $iseg += 2;
    } # while copying
    print "\n";
} # debug

    # now the b-file entries
    if (0) {
    } elsif ($method =~ m{[ABIJKP]}i) { # first or second row or both
        $iseg = 0;
        while ($iseg < scalar(@segment)) { # print the elements of this segment
            $attr = $segment[$iseg + 0];
            $noun = $segment[$iseg + 1];
            if ($attr != 0 or $with_zero == 1) {
                &bfile($attr, $noun); # for method I: store ion %occrs only
            }
            $iseg += 2;
        } # while copying
#    } elsif ($rule =~ m{D}i) { # new terms
#        $inoun = $start_new;
#        while ($inoun < scalar(@seql)) {
#            my $attr = $seql[$inoun + 0];
#            my $noun = $seql[$inoun + 1];
#            &bfile($noun);
#            $inoun += 2;
#        } # while $inoun
#    } elsif ($rule =~ m{N}i) { # no. of new terms in segment
#        my $no_new = (scalar(@segment) - $start_new) >> 1;
#        &bfile($no_new);
    } elsif ($method =~ m{T}i) { # no. of terms in segment
        my $nelem = 0; # nubmer of elements in segment, depends on $with_zero
        $iseg = 0;
        while ($iseg < scalar(@segment)) { # print the elements of this segment
            $attr = $segment[$iseg + 0];
            $noun = $segment[$iseg + 1];
            if ($attr != 0 or $with_zero == 1) {
                $nelem ++;
            }
            $iseg += 2;
        } # while copying
        &bfile($nelem);
        $seqlen[$segno] = $seqlen[$segno - 1] + $nelem;
    }
	#--------
	# compute following segment 
    $iseg = 0;
    while ($iseg < scalar(@segment)) { # copy attr and determine maximums
        $attr = $segment[$iseg + 0];
        $noun = $segment[$iseg + 1];
        $count[$noun] = $attr; # copy old attr
        if ($attr > $amax) {
            $amax = $attr;
        }
        $iseg += 2;
    } # while copying
    my $last_noun = $noun;

    $noun = $last_noun + 1;
    while ($noun <= $amax) { # fill with zeroes
        $count[$noun ++] = 0;
    } # while filling
    my $ff_count = $noun;

    # now add all (or row1, row2) to @count
    $iseg = 0;
    while ($iseg < scalar(@segment)) { # add
        $attr = $segment[$iseg + 0];
        $noun = $segment[$iseg + 1];
        if ($incpre == 0 and ($attr != 0 or $with_zero == 1)) {
            $count[$attr] ++;
        }
        if ($incpst == 0 and (($noun != 0 and $attr != 0) or $with_zero == 1)) {
            $count[$noun] ++;
        }
        $iseg += 2;
    } # while adding

    # copy it back to the segment
    $iseg = 0;
    $noun = 0;
    while ($noun < $ff_count) { # add
        $segment[$iseg + 0] = $count[$noun];
        $segment[$iseg + 1] = $noun;
        $iseg += 2;
        $noun ++;
    } # while copying back

} # sub advance
#----------------
sub bfile {
    if ($k > $len) {
        return;
    }
    my ($attr, $noun) = @_;
    if (0) {
    } elsif ($method =~ m{P}i) {
        if ($attr == $parm) {
            print "$k $k2\n"; $k ++;
        }
        $k2 ++;
    } elsif ($method =~ m{I}i) {
        if (! defined($occrs{$attr})) {
            # assume that rule "I" is called with row=1 only !
            $occrs{$attr} = $k;
            if ($debug >= 1) {
                print "# stored $k in occrs{$attr}\n";
            }
        }
        $k ++;
    } elsif ($method =~ m{J}i) {
        if ($attr > $curmax) {
            print "$k $attr\n"; $k ++;
            $curmax = $attr;
        }
        $k2 ++;
    } elsif ($method =~ m{K}i) {
        if ($attr > $curmax) {
            print "$k $k2\n"; $k ++;
            $curmax = $attr;
        }
        $k2 ++;
    } elsif (scalar(@_) == 1) {
            print "$k $attr\n"; $k ++;
    } elsif ($method =~ m{C}i) {
            print "$k $attr\n"; $k ++;
            print "$k $noun\n"; $k ++;
    } elsif ($method =~ m{[DNT]}i) {
        # c.f. above
    } elsif ($method =~ m{[A]}i) { # attribute before noun
        if (0) {
        } elsif ($row == 0) {
            print "$k $attr\n"; $k ++;
            print "$k $noun\n"; $k ++;
        } elsif ($row == 1) {
            print "$k $attr\n"; $k ++;
        } elsif ($row == 2) {
            print "$k $noun\n"; $k ++;
        } elsif ($row == 5) {
            print "$k $attr\n"; $k ++;
        } elsif ($row == 6) {
            print "$k $noun\n"; $k ++;
        }
    } elsif ($method =~ m{B}i) { # noun before attribute
        if (0) {
        } elsif ($row == 0) {
            print "$k $noun\n"; $k ++;
            print "$k $attr\n"; $k ++;
        } elsif ($row == 1) {
            print "$k $noun\n"; $k ++;
        } elsif ($row == 2) {
            print "$k $attr\n"; $k ++;
        } elsif ($row == 5) {
            print "$k $noun\n"; $k ++;
        } elsif ($row == 6) {
            print "$k $attr\n"; $k ++;
        }
    } else {
        die "invalid rule \"$method\" in sub bfile\n";
    }
} # bfile
__DATA__
Rule A, A055187:
1 | 1 | 3 | 4  1 |  6  2  1 |  8  1  3  2  1 |
  | 1 | 1 | 1  3 |  1  3  4 |  1  2  3  4  6 |

  | 11  3  5  3  2  1  | 13  5  8  4  1  3  2  1 |
  |  1  2  3  4  6  8  |  1  2  3  4  5  6  8 11 |

  | 16  7 10  6  3  4  4  2  1 |
  |  1  2  3  4  5  6  8 11 13 |

  | 18  9 12  9  4  6  1  5  1  3  2  1 |
  |  1  2  3  4  5  6  7  8 10 11 13 16 |

  | 22 11 14 11  6  8  2  6  2  2  4  1  3  2  1 |
  |  1  2  3  4  5  6  7  8  9 10 11 12 13 16 18 |

  | 25 16 16 14 ...
  |  1  2  3  4 ...

--------------------
A030717 (row 1), A030718 (row2) - zeroes are inconsistent
1 | 1 | 2 | 2, 1 | 3, 2 | 3, 3, 1 | 4, 3, 3 | 4, 3, 5, 1 | 5, 3, 6, 2, 1
  | 1 | 1 | 1, 2 | 1, 2 | 1, 2, 3 | 1, 2, 3 | 1, 2, 3, 4 | 1, 2, 3, 4, 5

  | 6, 4, 7, 2, 2, 1 | 7, 6, 7, 3, 2, 2, 1| 8, 8, 8, 3, 2, 3, 3
  | 1, 2, 3, 4, 5, 6 | 1, 2, 3, 4, 5, 6, 7| 1, 2, 3, 4, 5, 6, 7

  | 8, 9, 11, 3, 2, 3, 3, 3 | 8, 10, 15, 3, 2, 3, 3, 4, 1,  0,  1
  | 1, 2,  3, 4, 5, 6, 7, 8 | 1,  2,  3, 4, 5, 6, 7, 8, 9,     11

  | 10, 11, 18, 4, 2, 3, 3, 5, 1,  1,  1, 0, 0, 0,  1
  |  1,  2,  3, 4, 5, 6, 7, 8, 9, 10, 11,          15

  | 14, 12, 20, 5, 3, 3, 3, 5, 1,  2,  2, 0, 0, 0,  1, 0, 0,  1
  |  1,  2,  3, 4, 5, 6, 7, 8, 9, 10, 11,          15,       18

  | 17, 14, 23, 5, 5
  |  1,  2,  3  ...
#----------------------------------------------
A051120 ,1|1,1|3,1|1,3,4,1|1,4,2,3,6,1|1,6,2,4,3,3,1,2,8,1|1,8,2,6,3,4,5,3,3,2,11,1|1,11,2,8,3,6,1,5,4,4,8,3,5,2,13,1|1,13,2,11,4,8,4,6,3,5,6,4,10,3,7,2,16,1,1,16,2,13,3,11,1,10,5,8,1,7,6,6,4,5,9,4,12,3,9,2,18,1,
A055187 ,1|1,1|3,1|4,1,1,3|6,1,2,3,1,4|8,1,1,2,3,3,2,4,1,6|11,1,3,2,5,3,3,4,2,6,1,8|13,1,5,2,8,3,4,4,1,5,3,6,2,8,1,11|16,1,7,2,10,3,6,4,3,5,4,6,4,8,2,11,1,13,18,1,9,2,12,3,9,4,4,5,6,6,1,7,5,8,1,10,3,11,2,13,1,16,22,1,


#    if (0) {
#    } elsif ($appear eq "fa") { # order of first appearance
#        # already stored in @segment
#    } elsif ($appear eq "do") { # decreasing order
#        $inoun = $eseg;
#        foreach $noun (sort {$b <=> $a} (keys(%nouns))) { # reverse sort
#            $segment[$inoun + 0] = $nouns{$noun};
#            $segment[$inoun + 1] = $noun;
#            $inoun += 2;
#        } # foreach
#    } elsif ($appear eq "io") { # increasing order
#        $inoun = $eseg;
#        foreach $noun (sort {$a <=> $b} (keys(%nouns))) {
#            $segment[$inoun + 0] = $nouns{$noun};
#            $segment[$inoun + 1] = $noun;
#            $inoun += 2;
#        } # foreach
#    } elsif ($appear eq "dz") { # decreasing order (complete) - insert 0 counts
#        my $cnoun = 0; # avoids "while" in first "foreach"
#        $inoun = $eseg;
#        foreach $noun (sort {$b <=> $a} (keys(%nouns))) { # reverse sort
#            while ($cnoun > $noun) {
#                $segment[$inoun + 0] = 0;
#                $segment[$inoun + 1] = $cnoun;
#                $cnoun --;
#                $inoun += 2;
#            } # while $cnoun
#            $segment[$inoun + 0] = $nouns{$noun};
#            $segment[$inoun + 1] = $noun;
#            $inoun += 2;
#            $cnoun = $noun - 1;
#        } # foreach
#    } elsif ($appear eq "iz") { # increasing order (complete) - insert 0 counts
#        my $cnoun = $segment[$sseg + 1];
#        $inoun = $eseg;
#        foreach $noun (sort {$a <=> $b} (keys(%nouns))) {
#            while ($cnoun < $noun) {
#                $segment[$inoun + 0] = 0;
#                $segment[$inoun + 1] = $cnoun;
#                $cnoun ++;
#                $inoun += 2;
#            } # while $cnoun
#            $segment[$inoun + 0] = $nouns{$noun};
#            $segment[$inoun + 1] = $noun;
#            $inoun += 2;
#            $cnoun = $noun + 1;
#        } # foreach
#    } else {
#        die "invalid paramter op=\"$appear\"\n";
#    }
#
#    if (0) {
#    } elsif ($method =~ m{[ABIJKP]}i) { # first or second row or both
#        $inoun = $eseg;
#        while ($inoun < scalar(@segment)) {
#            my $attr = $segment[$inoun + 0];
#            my $noun = $segment[$inoun + 1];
#            &bfile($attr, $noun);
#            $inoun += 2;
#        } # while $inoun
#    } elsif ($method =~ m{D}i) { # new terms
#        $inoun = $start_new;
#        while ($inoun < scalar(@segment)) {
#            my $attr = $segment[$inoun + 0];
#            my $noun = $segment[$inoun + 1];
#            &bfile($noun);
#            $inoun += 2;
#        } # while $inoun
#    } elsif ($method =~ m{N}i) { # no. of new terms in segment
#        my $no_new = (scalar(@segment) - $start_new) >> 1;
#        &bfile($no_new);
#    } elsif ($method =~ m{T}i) { # no. of terms in segemnt
#        my $no_new = (scalar(@segment) - $eseg) >> 1;
#        &bfile($no_new);
#    }
