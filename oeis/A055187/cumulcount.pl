#!perl

# Generate OEIS Sequence A055187 and its companions
# as defined by Clark Kimberling
# http://faculty.evansville.edu/ck6/integer/unsolved.html, Problem 4
# @(#) $Id$
# 2018-04-20, Georg Fischer
#------------------------------------------------------
# usage:
#   perl cumulcount.pl rule row noeis n op a1 [debug]
#       rule  = "A"  (attribute before noun) 
#               "B"  (noun before attribute)
#               "D"  (new, distinct elements)
#               "I"  (inverse, first occurrence of a number)
#               "J"  (next term which is greater than all previous)
#               "K"  (next position where term is greater than all previous)
#               "N"  (number of new elements)
#               "Pi" (positions of small numbers i)
#               "T"  (number of [new] terms in segment n)
#       row   = 0 (both), 1 (first), 2 (second)
#       noeis = "030707|055187|217760 ..." (without "A")
#       n     = length of sequence to be generated
#       op    = "io" (increasing order), 
#               "do" (decreasing order), 
#               "ic" (increasing order, complete with zero counts), 
#               "fa" (first appearance) 
#       p1    = starting value for a(1): 0,1, ... 5
#       p2    = 2nd parameter (for rule "P")
#       debug = 0 (none), 1 (with segments)
#------------------------------------------------------
# Formula:
#--------------------------------------------------------
use strict;

my $rule = "A"; if (scalar(@ARGV) > 0) { $rule  = shift(@ARGV); }
my $row = 0;    if (scalar(@ARGV) > 0) { $row   = shift(@ARGV); }
my $noeis = ""; if (scalar(@ARGV) > 0) { $noeis = shift(@ARGV); }
my $n = 256;    if (scalar(@ARGV) > 0) { $n     = shift(@ARGV); }
my $op = "io";  if (scalar(@ARGV) > 0) { $op    = shift(@ARGV); }
my $p1 = 1;     if (scalar(@ARGV) > 0) { $p1    = shift(@ARGV); }
my $p2 = 0;     if (scalar(@ARGV) > 0) { $p2    = shift(@ARGV); }
my $debug = 0;  if (scalar(@ARGV) > 0) { $debug = shift(@ARGV); }

# segment have 2 rows:
# row 1 = attrs
# row 2 = nouns
my $attr;
my $noun;
my %nouns;
my %occrs = (); # first occurrences of attributes
my @seql = (); # sequence list 
push(@seql, $p1, 1, $p1);
#            0   1   2  3
my $segno = 1;
my $sseg  = 1;             # index of 1st element in segment
my $eseg  = scalar(@seql); # index of 1st element behind segment
my $inoun;
my $sum;
my $search = $p2; # for $rule =~ m{P}
my $curmax = 0;
print <<"GFis";
# http://oeis.org/A$noeis/b$noeis.txt: table n,a(n),n=1..$n
GFis
my $k = 1;
my $k2 = $k; # copy of k, running as if it were the A rule
    if (0) {
    } elsif ($rule =~ m{[ABPIJK]}i) {
        if ($row <= 1) {
            &bfile($p1);
        }
        &bfile(1, $p1);
    } elsif ($rule =~ m{D}i) {
        print "$k $p1\n"; $k ++;
    } elsif ($rule =~ m{N}i) {
        print "$k 1\n"  ; $k ++;
    } elsif ($rule =~ m{T}i) {
        print "$k $p1\n"; $k ++;
    } else {
        die "invalid rule \"$rule\"\n";
    }
$segno ++;
while ($k <= $n) { # fill b-file
    my %nouns = ();
    $inoun = $sseg;
    while ($inoun < $eseg) { # count the present nouns
        my $attr = $seql[$inoun + 0];
        my $noun = $seql[$inoun + 1];
        if (1) {
            $sum = $attr + &count($noun, $sseg, $eseg);
            $nouns{$noun} = $sum;
            push(@seql, $sum, $noun);
        }
        $inoun += 2;
    } # while $inoun
    $inoun = $sseg;
    my $start_new = scalar(@seql);
    while ($inoun < $eseg) { # count the new attributes
        my $attr = $seql[$inoun + 0];
        if (! defined($nouns{$attr})) {
            $sum = &count($attr, $sseg, $eseg);
            $nouns{$attr} = $sum;
            push(@seql, $sum, $attr);
        }
        $inoun += 2;
    } # while $inoun
    
    if (0) {
    } elsif ($op eq "fa") {
        # already stored in @seql
    } elsif ($op eq "do") {
        $inoun = $eseg;
        foreach $noun (reverse(sort {$a <=> $b} (keys(%nouns)))) {
            $seql[$inoun + 0] = $nouns{$noun};
            $seql[$inoun + 1] = $noun;
            $inoun += 2;
        } # foreach
    } elsif ($op eq "io") {
        $inoun = $eseg;
        foreach $noun (sort {$a <=> $b} (keys(%nouns))) {
            $seql[$inoun + 0] = $nouns{$noun};
            $seql[$inoun + 1] = $noun;
            $inoun += 2;
        } # foreach
    } elsif ($op eq "ic") { # increasing order (complete) - insert 0 counts
        my $cnoun = $seql[$sseg + 1];
        $inoun = $eseg;
        foreach $noun (sort {$a <=> $b} (keys(%nouns))) {
            while ($cnoun < $noun) {
                $seql[$inoun + 0] = 0;
                $seql[$inoun + 1] = $cnoun;
                $cnoun ++;
                $inoun += 2;
            } # while $cnoun
            $seql[$inoun + 0] = $nouns{$noun};
            $seql[$inoun + 1] = $noun;
            $inoun += 2;
            $cnoun = $noun + 1;
        } # foreach
    } else {
        die "invalid paramter op=\"$op\"\n";
    }

    if ($debug >= 1) {
        print "# segment $segno:";
        $inoun = $eseg;
        while ($inoun < scalar(@seql)) { # 
            my $attr = $seql[$inoun + 0];
            my $noun = $seql[$inoun + 1];
            print " $attr.$noun"; 
            $inoun += 2;
        } # while $inoun
        print "\n";
    } # debug
    
    if (0) {
    } elsif ($rule =~ m{[ABPIJK]}i) { # first or second row or both
        $inoun = $eseg;
        while ($inoun < scalar(@seql)) { 
            my $attr = $seql[$inoun + 0];
            my $noun = $seql[$inoun + 1];
            &bfile($attr, $noun);
            $inoun += 2;
        } # while $inoun
    } elsif ($rule =~ m{D}i) { # new terms
        $inoun = $start_new;
        while ($inoun < scalar(@seql)) { 
            my $attr = $seql[$inoun + 0];
            my $noun = $seql[$inoun + 1];
            &bfile($noun);
            $inoun += 2;
        } # while $inoun
    } elsif ($rule =~ m{N}i) { # no. of new terms
        my $no_new = (scalar(@seql) - $start_new) >> 1;
        &bfile($no_new);
    } elsif ($rule =~ m{T}i) { # no. of terms in segemnt
        my $no_new = (scalar(@seql) - $eseg) >> 1;
        &bfile($no_new);
    }
    $sseg = $eseg;
    $eseg = scalar(@seql);  
    $segno ++;
} # while b-file

if ($rule =~ m{I}i) { 
	$k = 1;
	foreach $attr (sort {$a <=> $b} (keys(%occrs))) {
		# last if $attr > $k; # must be monotone
        print "$k $occrs{$attr}\n"; $k ++;
	} # foreach
} # rule I

sub bfile {
    my ($attr, $noun) = @_;
    if (0) {
    } elsif ($rule =~ m{P}i) {
    	if ($attr == $search) {
	        print "$k $k2\n"; $k ++;
    	}
    	$k2 ++;
    } elsif ($rule =~ m{I}i) { 
    	if (! defined($occrs{$attr})) { 
    		# assume that rule "I" is called with row=1 only !
    		$occrs{$attr} = $k;
    		if ($debug >= 1) {
    			print "# stored $k in occrs{$attr}\n";
    		}
    	}
    	$k ++;
    } elsif ($rule =~ m{J}i) { 
    	if ($attr > $curmax) {
	        print "$k $attr\n"; $k ++;
	        $curmax = $attr;
    	}
    	$k2 ++;
    } elsif ($rule =~ m{k}i) { 
    	if ($attr > $curmax) {
	        print "$k $k2\n"; $k ++;
	        $curmax = $attr;
    	}
    	$k2 ++;
    } elsif (scalar(@_) == 1) {
        print "$k $attr\n"; $k ++;
    } elsif ($rule =~ m{[DNT]}i) {
    	# c.f. above
    } elsif ($rule =~ m{A}i) {
        if (0) {
        } elsif ($row == 0) {
            print "$k $attr\n"; $k ++; 
            print "$k $noun\n"; $k ++;
        } elsif ($row == 1) {
            print "$k $attr\n"; $k ++;
        } elsif ($row == 2) {
            print "$k $noun\n"; $k ++;
        }
    } elsif ($rule =~ m{B}i) {
        print "$k $noun\n"; $k ++;
        print "$k $attr\n"; $k ++;
    } else {
        die "invalid rule \"$rule\"\n";
    }
} # bfile

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