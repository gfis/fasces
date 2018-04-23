#!perl

# Generate OEIS Sequence A055187 and its companions
# as defined by Clark Kimberling
# http://faculty.evansville.edu/ck6/integer/unsolved.html, Problem 4
# @(#) $Id$
# 2018-04-20, Georg Fischer
#------------------------------------------------------
# usage:
#   perl cumulcount.pl rule s noeis n op a1 [debug]
#       rule  = "A" | "B"
#       s     = 1
#       noeis = "131388|131389|1313393|131394..." (without "A")
#       n     = length of sequence to be generated
#       op    = "io" (increasing order), "fa" (first appearance) 
#       a1    = starting value for a(1): 0,1, ... 5
#       debug = 0 (none), 1 (with segments)
#------------------------------------------------------
# Formula:
#--------------------------------------------------------
use strict;

my $rule = "A"; if (scalar(@ARGV) > 0) { $rule  = shift(@ARGV); }
my $s = 1;      if (scalar(@ARGV) > 0) { $s     = shift(@ARGV); }
my $noeis = ""; if (scalar(@ARGV) > 0) { $noeis = shift(@ARGV); }
my $n = 256;    if (scalar(@ARGV) > 0) { $n     = shift(@ARGV); }
my $op = "io";  if (scalar(@ARGV) > 0) { $op    = shift(@ARGV); }
my $a1 = 1;     if (scalar(@ARGV) > 0) { $a1    = shift(@ARGV); }
my $debug = 0;  if (scalar(@ARGV) > 0) { $debug = shift(@ARGV); }

# segment have 2 rows:
# row 1 = attrs
# row 2 = nouns
my $attr;
my $noun;
my %nouns; # the nouns 
my @seql = (); # sequence list 
push(@seql, $a1, 1, $a1);
#            0   1   2  3
my $segno = 1;
my $sseg  = 1;             # index of 1st element in segment
my $eseg  = scalar(@seql); # index of 1st element behind segment
my $k  = $eseg;
my $inoun;
print <<"GFis";
# http://oeis.org/A$noeis/b$noeis.txt: table n,a(n),n=1..$n
1 $a1
# segment 1: 1.$a1
2 1
3 $a1
GFis
$segno ++;
$k ++;
while ($k <= $n) { # fill b-file
    my %nouns = ();
    $inoun = $sseg;
    while ($inoun < $eseg) { # count the present nouns
        my $attr = $seql[$inoun + 0];
        my $noun = $seql[$inoun + 1];
        if (1) {
            my $sum = $attr + &count($noun, $sseg, $eseg);
            $nouns{$noun} = $sum;
            push(@seql, $sum, $noun);
        }
        $inoun += 2;
    } # while $inoun
    $inoun = $sseg;
    while ($inoun < $eseg) { # count the new attributes
        my $attr = $seql[$inoun + 0];
        if (! defined($nouns{$attr})) {
            my $sum = &count($attr, $sseg, $eseg);
            $nouns{$attr} = $sum;
            push(@seql, $sum, $attr);
        }
        $inoun += 2;
    } # while $inoun
    if ($debug >= 1) {
        print "# segment $segno:";
        $inoun = $eseg;
        while ($inoun < scalar(@seql)) { # count the present nouns
            my $attr = $seql[$inoun + 0];
            my $noun = $seql[$inoun + 1];
            print " $attr.$noun"; 
            $inoun += 2;
        } # while $inoun
        print "\n";
    } # debug
    
    if (0) {
    } elsif ($op eq "fa") { # first appearance
        $inoun = $eseg;
        while ($inoun < scalar(@seql)) { # count the present nouns
            my $attr = $seql[$inoun + 0];
            my $noun = $seql[$inoun + 1];
            print "$k $attr\n"; $k ++;
            print "$k $noun\n"; $k ++;
            $inoun += 2;
        } # while $inoun
    } elsif ($op eq "io") { # increasing order
        foreach $noun (sort {$a <=> $b} (keys(%nouns))) {
            $attr = $nouns{$noun};
            print "$k $attr\n"; $k ++;
            print "$k $noun\n"; $k ++;
        } # foreach
    } else {
        die "invalid paramter op=\"$op\"\n";
    }
    $sseg = $eseg;
    $eseg = scalar(@seql);  
    $segno ++;
} # while b-file

sub count {
    my ($noun, $sseg, $eseg) = @_;
    my $sum = 0;
    my $iseg = $sseg;
    while ($iseg < $eseg) {
        if ($seql[$iseg] == $noun) {
            $sum ++;
        }
        $iseg ++;
    } # while $iseg
    return $sum;
} # sub count
__DATA__
#--------
60 4
61 6
62 1
63 9
# Attr   7  11   8   6   4   6   4   1 |
# Noun   0   1   2   3   4   5   6   9 |
# Appr   0   1   2   3   4   5   6   7 |
64 8
65 0
66 13
67 1
68 9
69 2
70 7
71 3
72 7
73 4
74 7
75 5
76 7
77 6
78 1
79 7
80 1
81 8
82 2
83 9
84 1
85 11
# Attr   8  13   9   7   7   7   7   1   1   2   1 |
# Noun   0   1   2   3   4   5   6   7   8   9  11 |
# Appr   0   1   2   3   4   5   6   8  10   7   9 |
86 9
87 0
88 17
89 1
90 11
# https://oeis.org/wiki/User:Georg_Fischer Apr. 20, 2018


1  1 | 3 | 4  1 |  6  2  1 |  8  1  3  2  1 |
   1 | 1 | 1  3 |  1  3  4 |  1  2  3  4  6 |
                  +1    +1   +1 +1       +1

 | 11  3  5  3  2  1  | 13  5  8  4  1  3  2  1 |
 |  1  2  3  4  6  8  |  1  2  3  4  5  6  8 11 |
   +2 +1 +1       +1    +1 +1 +2    +1       +1

 | 16  7 10  6  3  4  4  2  1 |
 |  1  2  3  4  5  6  8 11 13 |
   +2 +1 +1 +1 +1    +1    +1

 | 18  9 12  9  4  6  1  5  1  3  2  1 |
 |  1  2  3  4  5  6  7  8 10 11 13 16 |
   +1 +1 +1 +2    +1 +1    +1       +1

 | 22 11 14 11  6  8  2  6  2  2  4  1  3  2  1 |
 |  1  2  3  4  5  6  7  8  9 10 11 12 13 16 18 |
   +3 +1 +1 +1 +1 +1       +2       +1       +1

 | 25 16 16 14
 |  1  2  3  4
   +2 +4 +1 +1