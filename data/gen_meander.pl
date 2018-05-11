#!/usr/bin/perl

# Generate a meander sequence
# 2017-08-31, Georg Fischer
# Program in the public domain
# c.f. <http://www.teherba.org/index.php/OEIS/A220952>

use strict;
use integer; # avoid division problems with reals
my $even   = 0; # experimental conditions for even base
my $debug  = 0;
my $ansi   = 0; # whether to use ANSI colors on console output
my $bfile  = 0; # whether to print b-file
my $graph  = 0; # whether to plot y,x behind the b-file entries
my $fail   = 0;
my $sep    = "/";
my $base   = 5; 
my $fbase  = 10;
my $ident  = "xx";
my $limit  = 125;
my @path   = (0,1,2,3,4,9,14,19,18,17,16,11,12,13,8,7,6,5,10,15,20,21,22,23,24);
# $bpath =   "00/01/02/03/04/14/24/34/33/32/31/21/22/23/13/12/11/10/20/30/40/41/42/43/44/"; # defines the meander sequence
# print "     0  3  6  9  12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 72\n" if $debug >= 1;
#<meander id="xx" path="0,1,2,3,4,9,14,19,18,17,16,11,12,13,8,7,6,5,10,15,20,21,22,23,24"
# Kn:  bpath="00/01/02/03/04/14/24/34/33/32/31/21/22/23/13/12/11/10/20/30/40/41/42/43/44/"
#<meander id="xx" path="0,1,2,3,4,9,14,19,18,13,8,7,12,17,16,11,6,5,10,15,20,21,22,23,24"
# Fs:  bpath="00/01/02/03/04/14/24/34/33/23/13/12/22/32/31/21/11/10/20/30/40/41/42/43/44/"


while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # start with hyphen
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt eq "\-a") {
        $ansi   = 1;
    } elsif ($opt eq "\-b") {
        $base   = shift(@ARGV);
    } elsif ($opt eq "\-d") {
        $debug  = shift(@ARGV);
    } elsif ($opt eq "\-e") {
        $even   = shift(@ARGV);
    } elsif ($opt eq "\-f") {
        $bfile  = 1;
    } elsif ($opt eq "\-g") {
        $graph  = 1;
    } elsif ($opt eq "\-i") {
        $ident  = shift(@ARGV);
    } elsif ($opt eq "\-l") {
        $limit  = shift(@ARGV);
    } elsif ($opt eq "\-p") {
        @path   = split(/\,/, shift(@ARGV));
    }
} # while opt
my $tbase  = $base;

print "<!-================================-_>\n";
my $bpath  = join("", map { my $bnum = &to_base($_); (length($bnum) < 2 ? "0$bnum" : $bnum) . $sep} @path);
print "<meander id=\"$ident\" path=\"" . join(",", @path) . "\"\n"
    . "    bpath=\"$bpath\"\n"
    . "    >\n";
my $ind = 1;

&draw_path(@path);
if (1) { # generate b-file
    print "<b$base-file>\n";
    $ind = 1;
    my $ind_1 = $ind - 1;
    my $bprev = "9";
    my $bcurr = "0";
    print "0 0\n";
    while ($fail == 0 and $ind <= $limit) {
        my $bnext = &get_successor($bprev, $bcurr);
        if (length($bnext) > 8) {
            $fail = 1;
        } else { # not yet_failed
            if ($bfile > 0) {
                print "$ind $bnext\n";
            } else {
                if (length($bcurr) != length($bnext)) {
                    $ind_1 = $ind - 1;
                    print "$ind_1 $bcurr\n$ind $bnext\n"; 
                }
            }
        } # not yet failed
        $bprev = $bcurr;
        $bcurr = $bnext;
        $ind ++;
    } # while $ind
    print "</b$base-file>\n";
} # b-file

if ($fail == 0) { # success
    if ($graph > 0) {
        &draw_graph();
    }
    # success
} else {
	print "<failed />\n";
}
print "</meander>\n";
#--------
sub get_successor {
    # get the successor node $bnext of a pair ($bprev, $bcurr)
    our @cands  = (); # candidates
    #----
    sub add_candidate {
        # add a candidate
        #----
        sub adjust {
            # make sure that both arguments start with "0" and have the same length
            my ($bnum1, $bnum2) = @_;
            while (length($bnum1) < length($bnum2)) {
                $bnum1 = "0$bnum1";
            } 
            while (length($bnum2) < length($bnum1)) {
                $bnum2 = "0$bnum2";
            } 
            if (substr($bnum1, 0, 1) != "0"  or 
                substr($bnum2, 0, 1) != "0") {
                $bnum1 = "0$bnum1";
                $bnum2 = "0$bnum2";
            }
            return ($bnum1, $bnum2);
        } # adjust
        #----
        sub is_adjacent {
            # check whether 2 nodes are adjacent
            my ($bprev, $bcurr) = @_;
            ($bprev, $bcurr) = &adjust($bprev, $bcurr);
            # print "#     is_adjacent(bprev=$bprev, bcurr=$bcurr) \n" if ($debug >= 2);
            my $adjacent = 1;
            my $width = length($bcurr);
            my $j = $width - 1;
            while ($adjacent == 1 and $j > 0) {
                my $i = $j - 1;
                while ($adjacent == 1 and $i >= 0) {
                    my  $ppair = substr($bprev, $i, 1) . substr($bprev, $j, 1);
                    my  $cpair = substr($bcurr, $i, 1) . substr($bcurr, $j, 1);
                    if (0 and $base % 2 == 0) {
                        $ppair = substr($bprev, $j, 1) . substr($bprev, $i, 1);
                        $cpair = substr($bcurr, $j, 1) . substr($bcurr, $i, 1);
                    }
                    my  $ppos  = index($bpath, $ppair);
                    my  $cpos  = index($bpath, $cpair);
                    if ($ppair != $cpair and abs($cpos - $ppos) != 3) {
                        print "\n#   is_adjacent($bprev,$bcurr): ppair=$ppair, cpair=$cpair, ppos=$ppos, cpos=$cpos\n" if $debug >= 2;
                        $adjacent = 0;
                    }
                    $i --;
                } # while $i
                $j --;
            } # while $j
            return $adjacent;
        } # is_adjacent
        #----
        my ($npair, $bprev, $bcurr, $i, $j) = @_;
        my $width = length($bcurr);
        print "#   add_candidate(npair=$npair, i=$i, j=$j)" if ($debug >= 1);
        my $bcand = substr($bcurr, 0, $i)                   # before i
                  . substr($npair, 0, 1)                    # 1st digit -> [$i]
                  . substr($bcurr, $i + 1, $j - $i - 1)     # between i and j
                  . substr($npair, 1, 1)                    # 2nd digit -> [$j]
                  . substr($bcurr, $j + 1, $width - 1 - $j) # behind j
                  ;
        if (0) {
        } elsif (&is_adjacent($bcurr, $bcand) == 0) {
            print "#   $bcurr not adjacent to $bcand" if $debug >= 1;
        } elsif ($bcand eq $bprev) {
            print "    $bcand=bprev" if $debug >= 1;
        } else {
            my $cpos = substr($bcurr, $i, 1) ne substr($bcand, $i, 1) ? $i : $j; # else change must be at j
            my $icand = 0;
            my $busy = 1;
            while ($busy == 1 and $icand < scalar(@cands)) {
                $busy = $cands[$icand] ne $bcand ? 1 : 0;
                $icand ++;
            } # while icand
            if ($busy == 1) { # not yet stored
                # $bcand =~ s{\A0}{};
                push(@cands, $bcand); 
            } # not yet stored
            print " -> bcand=$bcand" if $debug >= 1;
        }
        print "\n" if ($debug >= 1);
    } # add_candidate
    #----
    my ($bprev, $bcurr) = @_;
    ($bprev, $bcurr) = &adjust($bprev, $bcurr);
    print "# get_successor(bcurr=$bcurr)\n" if ($debug >= 1);
    @cands = ();
    my $width = length($bcurr);
    my $j = $width - 1;
    while ($j > 0) {
        my $i = $j - 1;
        while ($i >= 0) {
            my $cpair = substr($bcurr, $i, 1) . substr($bcurr, $j, 1);
            my $cpos  = index($bpath, $cpair);
            print "#   cpair=$cpair -> cpos=$cpos\n" if ($debug >= 1);
            if ($cpos >= 3) { # the node before, if it exists
                &add_candidate(substr($bpath, $cpos - 3, 2), $bprev, $bcurr, $i, $j);
            } # before
            if ($cpos <  length($bpath) - 3) { # the node behind, if it exists
                &add_candidate(substr($bpath, $cpos + 3, 2), $bprev, $bcurr, $i, $j);
            } # behind
            if ($even > 0 and $cpos == length($bpath) - 3) { # the node in the next dimension
            	my $bcand = $bcurr;
            	$bcand =~ s{0}{1};
                push(@cands, $bcand);
            } # behind
            
            $i --;
        } # while $i
        $j --;
    } # while $j
    my $cand = "";
    print "# get_successor: " if ($debug >= 1);
    my $lcand = scalar(@cands);
    if (0) {
    } elsif ($lcand >  1) {
        print "# more than 1 candidate for $bcurr @ $ind" . ", cands=" . join(",", @cands) . "\n";
        if ($even > 0) { 
        	$cand = $cands[0];
        } else {
        	$fail = 1;
        }
    } elsif ($lcand <  1) {
        print "# no candidate for $bcurr at $ind\n";
        $fail = 1;
    } else { # $lcand == 1
        $cand = $cands[0];
        $cand =~ s{\A0+}{};
        if (length($cand) > 16) {
            print "# $cand exploding @ $ind\n";
            $fail = 1;
        }
    }
    print "\n" if $debug >= 1;
    return $cand;
} # get_successor
#--------
sub to_base {
    # return a normal integer as number in base $tbase
    my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $tbase;
        $result =  $digit . $result;
        $num /= $tbase;
    } # while > 0
    return $result eq "" ? "0" : $result; 
} # to_base
#--------
sub from_base {
    # return a number in base $fbase (string, maybe with letters) as normal integer
    my ($num)  = @_;
    my $bpow   = 1;
    my $result = 0;
    my $pos    = length($num) - 1;
    while ($pos >= 0) { # from backwards
        my $digit = substr($num, $pos, 1);
        if ($digit < 0) {
            print STDERR "invalid digit in number $num\n";
        }
        $result += $digit * $bpow;
        $bpow   *= $fbase;
        $pos --;
    } # positive
    return $result; 
} # from_base
#--------
sub draw_graph {
    print "<draw-graph>\n";
    $ind = 1;
    my $ind_1 = $ind - 1;
    my $bprev = "9";
    my $bcurr = "0";
    print "0 0\n";
    while ($fail == 0 and $ind <= $limit) {
        my $bnext = &get_successor($bprev, $bcurr);
        print sprintf("%-10s", "$ind $bnext") 
                    . ($graph > 0 ? "|" . " " x (&from_base($bnext) + 1) . "@" : "") 
                    . "\n"; 
        $bprev = $bcurr;
        $bcurr = $bnext;
        $ind ++;
    } # while $ind
    print "</draw-graph>\n";
} # draw_graph  
#--------
sub draw_path {
    our $vert   = "||"; if ($ansi == 1) { $vert = "\x1b[103m$vert\x1b[0m"; }
    our $hori   = "=="; if ($ansi == 1) { $hori = "\x1b[103m$hori\x1b[0m"; }
    our @matrix = ();
    our $blan   = "  ";
    #----
    sub get_matrix_pos {
        my ($x, $y) = @_;
        my $base2_1 = $base * 2 - 1; # 9  for base=5
        return $x * 2 + ($base2_1 - 1) * $base2_1 - $y * 2 *$base2_1; 
    } # get_matrix_pos
    #----
    sub get_digit {
        # return the value of a digit from a string in $base representation
        # $base <= 10 for the moment, but hex is prepared
        my ($num, $pos) = @_; # pos is 0 for last character
        my $bum = &based0($num);
        return substr($bum, length($bum) - 1 - $pos, 1);
    } # get_digit
    #----
    sub based0 {
        # return a number in base $base, 
        # filled to $maxexp - 1 with leading zeroes
        my $maxexp = 2; # for drawing the start path only!
        my ($num) = @_;
        my $result = "";
        my $ind = 0;
        while ($ind < $maxexp) {
           $result = ($num % $base) . $result;
           $num    /= $base;
           $ind ++;
        } # while $idig
        return $result; 
    } # based0
    #----
    sub connect {
        my ($pa0, $pa1) = @_;
        if ($pa0 > $pa1) { # exchange, make p1 smaller
            my $temp = $pa0;
            $pa0 = $pa1;
            $pa1 = $temp;
        } # pa0 <= pa1
        my $ba0 = &based0($pa0);
        my $ba1 = &based0($pa1);
        print "ba0=$ba0, ba1=$ba1" if $debug >= 2;
        my $x0 = &get_digit($pa0, 1);
        my $y0 = &get_digit($pa0, 0);
        my $x1 = &get_digit($pa1, 1);
        my $y1 = &get_digit($pa1, 0);
        print ", x0=$x0, y0=$y0, x1=$x1, y1=$y1" if $debug >= 2;
        my $mp0 = &get_matrix_pos($x0, $y0);
        if ($x0 eq $x1) { # up
            $matrix[$mp0 - ($base * 2 - 1)] = $vert; # up
            print " $vert\n" if $debug >= 2;
        } else {
            $matrix[$mp0 + 1]               = $hori; # right
            print " $hori\n" if $debug >= 2;
        }
    } # connect
    #----
    # initialize the matrix
    my $x = 0;
    my $y = 0;
    while ($x < $base) {
        $y = 0;
        while ($y < $base) {
            my $mp = &get_matrix_pos($x, $y);
            $matrix[$mp] = $ansi == 1 ? "\x1b[102m$x$y\x1b[0m" : "$x$y";
            if ($x < $base - 1) {
                $matrix[$mp + 1] = $blan; # " "; # right
            }
            if ($y > 0) {
                $matrix[$mp + $base * 2 - 1] = $blan; # "  "; # down
                if ($x < $base - 1) {
                    $matrix[$mp + $base * 2 - 1 + 1] = $blan; # " "; # down
                }                   
            }
            $y ++;
        } # while y
        $x ++;
    } # while $x

    my $ipa = 1;
    while ($ipa < scalar(@path)) {
        &connect($path[$ipa - 1], $path[$ipa]);
        $ipa ++;
    } # while $ipa 
    print "<draw-path>\n\n";
    my $imp = 0;
    while ($imp < scalar(@matrix)) { # print
        print "$matrix[$imp]";
        $imp ++;
        if ($imp % ($base * 2 - 1) == 0) {
            print "\n";
        }
    } # printing
    print "\n</draw-path>\n";
} # draw_path
#--------
__DATA__
