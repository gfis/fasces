#!perl

# List length of lines
# @(#) $Id$
# 2019-01-12, Georg Fischer
#
# usage:
#   perl a048200.pl 
#---------------------------------
use strict;
use integer;


# get options
my $with_anum = 0;
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-a}) {
        $with_anum = 1;
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
my $letters  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
my $rletters = "ZYXWVUTSRQPONMLKJIHGFEDCBA";
my $num = 3;
my $hit;
while ($num < 20) {
    my $rword = substr($rletters, - $num);
    my $min = 0b10;
    my $max = $min * 2;
    my $busy  = 1;
    while ($busy == 1) { # increase $width
        my $patt = $min; 
        while ($busy == 1 and $patt < $max) {
            my $word  = substr($letters, 0, $num);
            my $bpatt = sprintf("%0b", $patt);
            my $ibp = 1;
            while ($busy == 1 and $ibp < length($bpatt)) {
                my $act = substr($bpatt, $ibp, 1);
                if ($act == 0) { # rotate
                    $word = substr($word, 1   ) . substr($word, 0, 1);
                } else {         # exchange
                    $word = substr($word, 1, 1) . substr($word, 0, 1) . substr($word, 2);
                }
                if ($word eq $rword) { # hit
                    $busy = 0;
                    print "hit num=$num, bpatt=$bpatt, len=" . (length($bpatt) - 1) . "\n";
                }   
                $ibp ++;
            } # while $ibp
            $patt ++;
        } # for $patt
        $min = $max;
        $max = $min * 2;
    } # while width
    $num ++;
} # while $num
exit(0);
#----------------------
__DATA__
A048200     Minimal length pair-exchange / set-rotate sequence to reverse n distinct ordered elements.      3
%I
%S 0,1,2,4,10,15,23,32,42,55,67
%N Minimal length pair-exchange / set-rotate sequence to reverse n distinct ordered elements.
%C "Rotate" is always a left-rotate (moves leftmost element to the right end) and "Exchange" is always a pair-exchange of the two leftmost elements.
%H Sai Satwik Kuppili, <a href="/A048200/a048200_1.cpp.txt">C++ program for generating the moves for a given n</a>
%e a(4) = 4 since "xrrx" is the shortest sequence reversing "ABCD". Explicitly, (begin) ABCD, (x)-> BACD, (r)-> ACDB, (r) -> CDBA, (x)-> DCBA.
%K nonn,nice,more,changed
%O 1,3
%A _Tony Bartoletti_
%E a(11) added by _Sai Satwik Kuppili_, Srinath T, _Bhadrachalam Chitturi_, Jan 02 2019

C:\Users\User\work\gits\OEIS-mat\bfcheck>perl a048200.pl
hit num=3, bpatt=101, len=2
hit num=4, bpatt=11001, len=4
hit num=5, bpatt=11001001010, len=10
hit num=6, bpatt=1010010100101001, len=15
hit num=7, bpatt=110001000101001010010101, len=23
               
                01
               1001
            1001001010
         010010100101001
     10001000101001010010101

                   01
               1001
            1001001010
    010010100101001
10001000101001010010101
     