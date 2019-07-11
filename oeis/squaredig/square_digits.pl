#!perl

# Evaluate - for a selection of decimal digits - which
#   numbers and their squares use only those digits.
# @(#) $Id$
# 2019-07-09: new attempt
# 2018-10-17, Georg Fischer
# For Jonathan Wellon's sequences A136808-A137147
#
# Usage:
#   perl square_digits.pl [-d debug] [-n max_ind] [-s digits] [-w max_width]
#------------------------------
use strict;
use Math::BigInt;
use Math::BigInt':constant';

my $debug     = 0;
my $max_ind   = 1000;
my $subset    = "23467"; # A137071
my $max_width = 16;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{\-n}) {
        $max_ind   = shift(@ARGV);
    } elsif ($opt  =~ m{\-s}) {
        $subset    = shift(@ARGV);
    } elsif ($opt  =~ m{\-w}) {
        $max_width = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
my @digs = split(//, $subset); # single digits
my $diglen = length($subset);
my $index = 1;

my $rest  = "0123456789";
$rest =~ s{[$subset]}{}og;

my @pairPoss; # whether index pair 00..99 is possible as a tail
my @tailPoss; # whether index pair 00..99 is possible as a tail
my @headPoss; # whether index pair 00..99 is possible as a head

# determine the possible digit pairs
my $ind;
for ($ind = 0; $ind < 100; $ind ++) {
    my $ind2 = $ind * $ind;
    my $isPoss = ((sprintf("%02d", $ind)   !~ m{[$rest]}o) ) ? 1 : 0;
    $pairPoss[$ind] = $isPoss;
    $tailPoss[$ind] = ($isPoss == 1 and (sprintf("%02d", $ind2 % 100) !~ m{[$rest]}o) ) ? 1 : 0;
    my $head2 = $ind2;
    my $next2 = ($ind + 1) * ($ind + 1);
    my $kind = $ind2;
    $isPoss = 0; # assume pair to be not possible as head
    # now check whether there is any possible in the range $ind**2 <= $kind < ($ind + 1)**2
    while ($isPoss == 0 and $kind < $next2) {
        $isPoss = ($kind !~ m{[$rest]}o) ? 1 : 0;
        $kind ++;
    } # while $kind
    $headPoss[$ind] = ($isPoss == 1 and $pairPoss[$ind] == 1) ? 1 : 0;
    if ($debug >= 2) {
        print sprintf("%4d %6d =~ %s: pair %d   head %d   tail %d\n"
            , $ind, $ind2, $subset, $pairPoss[$ind], $headPoss[$ind], $tailPoss[$ind]);
    }
} # for $ind

my $width = 1; # number of digits in $num
my @queue = ("");
my @queub = ("");
my $minbl = 0; # start of block in queue
my $maybl = scalar(@queue); # asserted, 1 behind end of block
my $num;   # BigInt
my $npow2; # $num ** 2
my $snum;  # $num as string
my $bmod;  # digit before mod part in square
my $start = time();
while ($width <= $max_width && $index <= $max_ind) {
    foreach my $dig (@digs) {
        my $ibl = $minbl;
        while ($ibl < $maybl) {
            $snum = "$dig$queue[$ibl]";
        #   my $squb = $queub[$ibl];
        #   my $bmod1 = substr($squb, 0, length($squb) - $width + 1) || 0;
        #   $bmod = ($width > 1) ? ($bmod1 + 2 * $dig * ($queue[$ibl] || 0)) % 10 : ($dig * $dig) % 10;
        #   if ($debug >= 2) {
        #       print "snum=$snum, dig=$dig bmod1=\"$bmod1\" -> bmod=\"$bmod\"\n";
        #   }
        #   if (0 and ($bmod =~ m{[$rest]}o)) {
        #       if ($debug >= 1) {
        #           print "skip $snum\n";
        #       }
        #   } else 
            { # test mod
                $num   = Math::BigInt->new($snum); # contains proper digits by construction
                $npow2 = $num->copy()->bmul($num);
        #       my $bmod9 = substr($npow2, - $width, 1) || 0;
        #       if ($bmod ne $bmod9) {
        #           if ($debug >= 1) {
        #               print "\t\t\tassertion failed: \"$bmod\" ne \"$bmod9\", npow2=$npow2\n";
        #           }
        #           $bmod = $bmod9;
        #       } else 
        #       {
        #       #   if ($debug >= 1) {
        #       #       print "\t\t\tassertion passed: \"$bmod\" eq \"$bmod9\", npow2=$npow2\n";
        #       #   }
        #       }
                if (substr($npow2, - $width) !~ m{[$rest]}o) { # tail of square has proper digits
				    push(@queue, $snum);
				#   push(@queub, $npow2);
				#   if ($debug >= 1) {
				#       &output("push");
				#   }
                    # &enqueue();
                    if ($npow2 !~ m{[$rest]}o) { # leading part of square has proper digits, too
                        if ($dig != 0) { # no leading zero
                            my $time_diff = time() - $start;
                            print "$index $num # $minbl:$maybl, $time_diff s\n";
                            $index ++;
                        } # no leading zero
                    } # square ok
                } # square mod ok
            } # test mod
            $ibl ++;
        } # while $ibl
    } # foreach $dig
    $minbl = $maybl;
    $maybl = scalar(@queue);
    $width ++; # enter next level
    if ($debug >= 1) {
        print "----------------\n";
    }
} # while $width

sub enqueue {
} # enqueue

sub output {
    my ($text) = @_;
    print sprintf("%s: %s %${width}s.%${width}s:%s\n", $text, $snum
        , substr($npow2, 0, length($npow2) - $width)
        , substr($npow2, - $width)
        , $queub[$#queub]);
} # output
__DATA__
C:\Users\User\work\gits\fasces\oeis\squaredig>perl square_digits.pl -s 0146 -w 15
1 1 # 0:1, 0 s
2 4 # 0:1, 0 s
3 10 # 1:5, 0 s
4 40 # 1:5, 0 s
5 100 # 5:12, 0 s
6 400 # 5:12, 0 s
7 1000 # 12:31, 0 s
8 4000 # 12:31, 0 s
9 10000 # 31:64, 0 s
10 40000 # 31:64, 0 s
11 100000 # 64:144, 0 s
12 400000 # 64:144, 0 s
13 1000000 # 144:281, 0 s
14 4000000 # 144:281, 0 s
15 10000000 # 281:609, 0 s
16 40000000 # 281:609, 0 s
17 100000000 # 609:1168, 0 s
18 400000000 # 609:1168, 0 s
19 1000000000 # 1168:2502, 1 s
20 4000000000 # 1168:2502, 1 s
21 10000000000 # 2502:4779, 2 s
22 40000000000 # 2502:4779, 2 s
23 100000000000 # 4779:10172, 3 s
24 400000000000 # 4779:10172, 4 s
25 1000000000000 # 10172:19369, 8 s
26 4000000000000 # 10172:19369, 9 s
27 10000000000000 # 19369:41074, 16 s
28 40000000000000 # 19369:41074, 19 s
29 100000000000000 # 41074:78070, 33 s
30 400000000000000 # 41074:78070, 38 s

