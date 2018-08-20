#!perl

# Follow patterns in the Collatz graph
# @(#) $Id$
# 2018-08-20, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl collatz_pattern.pl start
#
# c.f. example behind __DATA__ below
# The lengths of the ropes show a fractal structure 
# when indexes are incremented by 2*3=6, 2*3*9=54, 2*3*9*9=486. 2*3*9*9*9=4374
#--------------------------------------------------------
use strict;
use integer;

my $debug  = 0;
my $maxn   = 8192; # max. start value
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-n}) {
        $maxn   = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

&print_html_head();
my $elem0  = 3280; # 364; 40;
while ($elem0 < $maxn) {
    &rope2($elem0);
    if (0) {
        my $mod6 = $elem0 % 6;
        if (0) {
        } elsif ($mod6 == 0) {
        } elsif ($mod6 == 2) {
        } elsif ($mod6 == 4) {
        }
    }
    $elem0 += 54*9 * 9;
} # while incrementing
&print_html_tail();
# end main
#**************************************************
sub rope2 {
    my ($start) = @_;
    my $elem0 = $start;
    my $count = 0;
    my $buffer = "<td>dm</td>";
    my $elem1  = $elem0; # 2 parallel threads: $elem0 (upper, left), $elem1 (lowe, right)
    my $state  = "st"; # both resulted from mult.
    my $busy   = 1; # as long as loop should continue
    while ($busy == 1) {
        if (0) {
        } elsif ($state eq "st") {
            $elem0 = ($elem0 - 1) / 3; # possible because of preparation above
            $elem1 = $elem1 * 2;
            $state = "mm";
        } elsif ($state eq "mm") {
            $elem0 = $elem0 * 2; # always possible
            $elem1 = $elem1 * 2;
            $state = "md";
        } elsif ($state eq "md") {
            if (($elem1 - 1) % 3 == 0) {
                $elem1 = ($elem1 - 1) / 3;
                $elem0 = $elem0 * 2; # always possible
                $state = "dm";
                if ($elem0 % 3 == 0) {
                    $busy  = 0;
                    $state = " 0/3";
                } elsif ($elem1 % 3 == 0) {
                    $busy  = 0;
                    $state = " 1/3";
                }
            } else {
                $busy  = 0;
                $state = " 1n3";
            }
        } elsif ($state eq "dm") {
            if (($elem0 - 1) % 3 == 0) {
                $elem0 = ($elem0 - 1) / 3;
                $elem1 = $elem1 * 2; # always possible
                $state = "md";
                if ($elem0 % 3 == 0) {
                    $busy  = 0;
                    $state = " 0/3";
                } elsif ($elem1 % 3 == 0) {
                    $busy  = 0;
                    $state = " 1/3";
                }
            } else {
                $state = " 0n3";
                $busy  = 0;
            }
        } else {
            die "invalid state \"$state\"\n";
        }
        $buffer .= "<td>$elem0,$elem1</td><td>$state</td>";
        $count ++;
    } # while busy
    print "<tr><td>$count</td><td>$start</td>$buffer</tr>\n";
} # rope2
#-----------------
#----------------
sub print_ruler {
} # sub print_ruler
#-----------------
sub print_html_head {
    print <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style>
body,table,p,td,th
        { font-family: Arial; }
tr,td,th,p
        { text-align: right; }
.frame  { font-size:smaller; background-color: lightgray;}
.arr    { background-color: lightyellow;}
/* known values and their derivatives (delta=3) */
.k0     { background-color: darkblue;  color: white; font-weight: bold; font-style: italic; }
.k1     { background-color:     blue;  color: white; font-weight: bold; font-style: italic; }
.k2     { background-color: lightblue; color: black; font-weight: bold; font-style: italic; }
.k3     { background-color: lavender;  color: black; font-weight: bold; font-style: italic; }
.k4     { background-color: lavender;  color: black; font-weight: bold; font-style: italic; }
/* main diagonal and its derivatives */
.d0     { background-color: darkred;   color: white; font-weight: bold; }
.d1     { background-color: crimson;   color: white; }
.d2     { background-color: orangered; color: white; }
.d3     { background-color: orange;    color: black; }
.d4     { background-color: yellow;    color: black; }
.meet /* several lines/colors meet in this point */
        { background-color: limegreen; color: white; }
</style>
</head>
<body>
<h3>Patterns in Collatz Graph</h3>
<table>
GFis
} # print_html_head
#-----------------
sub print_html_tail {
    print <<"GFis";
</table>
</body>
</html>
GFis
} # print_html_tail
#-----------------
__DATA__
A070165:
142/104: [142 m  71 d 214 m 107 d 322 m 161 d 484 m  242 m 121 d | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
           +1  *6+4    +1  *6+4    +1  *6+4    +1   *6+4  *6+2     =     =   ...
143/104: [143 d 430 m 215 d 646 m 323 d 970 m 485 d 1456 m 728 m | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
              i     i     i     i     i     i     i      1     1       0
124 m 62 m  31 d 94 m  47 d 142 m
 +2   +1  *6+4    +1 *6+4    +1
126 m 63 d 190 m 95 d 286 m 143 d
         i     i    i     i     i