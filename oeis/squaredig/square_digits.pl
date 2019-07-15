#!perl

# Evaluate - for a selection of decimal digits - which
#   numbers and their squares use only those digits.
# @(#) $Id$
# 2019-07-09: new attempt
# 2018-10-17, Georg Fischer
# For Jonathan Wellon's sequences A136808-A137147
#
#:# Usage:
#:#   perl square_digits.pl [-d debug] [-n max_ind] [-s digits] [-w max_width] [-q initial queue element]
#------------------------------
use strict;
use Math::BigInt;
use Math::BigInt':constant';

my $debug     = 0;
my $max_ind   = 1000;
my $subset    = "0146"; # A136859
my $max_width = 16;
my $que0 = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{\-n}) {
        $max_ind   = shift(@ARGV);
    } elsif ($opt  =~ m{\-q}) {
        $que0      = shift(@ARGV);
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
my @queue = ($que0); # all possible endings of numbers still to be investigated
my $width = length($queue[0]) + 1; # number of digits in $num
my $minbl = 0; # start of block in @queue
my $maybl = scalar(@queue); # asserted, 1 behind end of block
my $num;   # BigInt
my $npow2; # $num**2
my $snum;  # $num as string
my $start = time();
while ($width <= $max_width && $index <= $max_ind) {
    foreach my $dig (@digs) {
        my $ibl = $minbl;
        while ($ibl < $maybl) {
            $snum = "$dig$queue[$ibl]";
            my $num0 = $snum;
            $num0 =~ s{0+\Z}{};
            my $lendiff = length($snum) - length($num0);
            $num   = Math::BigInt->new($num0); # contains proper digits by construction
            $npow2 = $num->copy()->bmul($num); # ->bstr();
            # $npow2 =~ s{(00)+
            if ($npow2 !~ m{[$rest]}o) { # leading part of square has proper digits
                &enqueue("full");
                if ($dig != 0 || $width == 1) { # no leading zero
                    my $time_diff = time() - $start;
                    print "$index $snum # $minbl:$maybl, $time_diff s\n";
                    $index ++;
                } # no leading zero
                # square ok
            } else {
                if (substr($npow2, - $width + $lendiff) !~ m{[$rest]}o) { # tail of square has proper digits
                    &enqueue("tail");
                } else {
                    &output("drop");
                }
            }       
            $ibl ++;
        } # while $ibl
    } # foreach $dig
    $minbl = $maybl;
    $maybl = scalar(@queue);
    $width ++; # enter next level
    if ($debug >= 1) {
        print "----------------\n";
        print "push 9 9999999999999999999999999999999999\n";
    }
} # while $width

sub enqueue {
    my ($text) = @_;
    push(@queue, $snum);
    &output($text);
} # enqueue

sub output {
    if ($debug >= 1) {
        my ($text) = @_;
        print sprintf("%s %10d %s: %${width}s.%${width}s %d\n", $text, scalar(@queue), $snum
            , substr($npow2, 0, length($npow2) - $width)
            , substr($npow2, - $width) , $width
            );
    }
} # output
__DATA__
            if ($dig == 0 && $width > 1) { # leading zero
                if (substr($npow2, - $width)  !~ m{[$rest]}o) { # leading part of square has proper digits, too
                    push(@queue, $snum);
                    # &enqueue();
                } # square ok
            } elsif (substr($npow2, - $width) !~ m{[$rest]}o) { # tail of square has proper digits
                if ($npow2 !~ m{[$rest]}o) { # leading part of square has proper digits, too
                    push(@queue, $snum);
                    # &enqueue();
                    if ($dig != 0 || $width == 1) { # no leading zero
                        my $time_diff = time() - $start;
                        print "$index $num # $minbl:$maybl, $time_diff s\n";
                        $index ++;
                    } # no leading zero
                    # square ok
                } else { 
                    push(@queue, $snum);
                    # &enqueue() ;
                }
            }
            $ibl ++;                my $nzero = 0;
                my $pos2 = length($npow2);
                while (0 and $pos2 >= 4 && substr($snum, $pos2 - 4, 4) eq "0000") {
                    $nzero += 2;
                    $pos2 -= 4;
                } # cut trailing 00 pairs
                my $pos1 = $pos2 - $width;
                if ($pos1 < 0) {
                    $pos1 = 0;
                }



gits\fasces\oeis\squaredig>perl square_digits.pl -s 0146 -w 15
1 1 # 0:1, 0 s
2 4 # 0:1, 0 s
3 10 # 1:5, 0 s
4 40 # 1:5, 0 s
5 100 # 5:12, 0 s
6 400 # 5:12, 0 s
7 1000 # 12:29, 0 s
8 4000 # 12:29, 0 s
9 10000 # 29:57, 0 s
10 40000 # 29:57, 0 s
11 100000 # 57:117, 0 s
12 400000 # 57:117, 0 s
13 1000000 # 117:212, 0 s
14 4000000 # 117:212, 0 s
15 10000000 # 212:405, 0 s
16 40000000 # 212:405, 0 s
17 100000000 # 405:705, 0 s
18 400000000 # 405:705, 0 s
19 1000000000 # 705:1301, 1 s
20 4000000000 # 705:1301, 1 s
21 10000000000 # 1301:2220, 1 s
22 40000000000 # 1301:2220, 1 s
23 100000000000 # 2220:4029, 2 s
24 400000000000 # 2220:4029, 3 s
25 1000000000000 # 4029:6809, 4 s
26 4000000000000 # 4029:6809, 4 s
27 10000000000000 # 6809:12261, 7 s
28 40000000000000 # 6809:12261, 8 s
29 100000000000000 # 12261:20628, 12 s
30 400000000000000 # 12261:20628, 14 s
31 1000000000000000 # 20628:37013, 22 s
32 4000000000000000 # 20628:37013, 25 s
33 10000000000000000 # 37013:62145, 40 s
34 40000000000000000 # 37013:62145, 45 s
35 100000000000000000 # 62145:111333, 67 s
36 400000000000000000 # 62145:111333, 78 s
37 1000000000000000000 # 111333:186764, 118 s
38 4000000000000000000 # 111333:186764, 135 s
39 10000000000000000000 # 186764:334365, 204 s
40 40000000000000000000 # 186764:334365, 236 s
41 100000000000000000000 # 334365:560697, 360 s