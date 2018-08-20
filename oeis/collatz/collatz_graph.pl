#!perl

# Build the tree of inverse Collatz sequences
# @(#) $Id$
# 2018-08-17, Georg Fischer
#------------------------------------------------------
# usage:
#   perl icoll.pl maxrow maxn
#
# Algorithm:
# Start with 1,2,4,8.
# For each element n: 
# If n mod 3 = 0 then terminate the row and take next element from the queue.
# If n mod 3 = 1 then queue 2*n and continue with k such that 3*k+1=n,
# otherwise continue with 2*n.
#--------------------------------------------------------
use strict;
use integer;

my $debug  = 0;
my $maxn   = 100000;
my $maxrow = 8192;
# my $maxrow = shift(@ARGV); # number of rows to be printed

my @orow;        # old row 
my @queue = ();  # rows which must still be processed
my @occur = (0); # whether an element did occur, and in which row

my $irow = 0;    # index in rows
push(@orow, 1, 2, 4);
push(@queue, 8);
my $ncomplete = 2;
my $jcol = 0;
while ($jcol < scalar(@orow)) { # these did occur
    $occur[$orow[$jcol]] = $irow;
    $jcol ++;
} # while $jcol

&print_header();
while ($irow < $maxrow) {
    &advance($irow);
    $irow ++;
} # while $irow
&print_trailer();
# end main
#----------------
sub advance { # compute next row
    my ($irow) = @_;
    my $elem = shift(@queue);
    my $busy = 1;
    while ($busy > 0) {
        push(@orow, $elem); $occur[$elem] = $irow;
        my $mod3 = $elem % 3;
        if ($debug > 0) {
            print "[$irow] elem=$elem, mod3=$mod3\n";
        }
        if ($mod3 == 0) { # divisible by 3
            &fill3($irow, $elem);
            $busy = 0; # end of row
            &print_row($irow, $elem / 3);
        } elsif ($mod3 == 1 and $elem % 2 == 0) { # odd: divide
            push(@queue, $elem * 2); # process that later
            $elem = ($elem - 1 ) / 3;
        } else { # duplicate
            $elem *= 2;
        } # duplicate
    } # while $busy 
    @orow = ();
} # advance
#----------------
sub fill3 { # fill @occur for elements divisible by 3
    my ($irow, $last) = @_;
    while ($last < $maxn) {
        $occur[$last] = $irow;
        $last *= 2;
    } # while $last
} # fill3
#-----------------
sub print_row { # parameter: 1/3 of last element
    my ($irow, $third) = @_;
    my $len = scalar(@orow);
    print "<tr>";
    my $jcol = 0;
    while ($jcol < $len) { # include the last
        print "<td class=\"\" title=\"\">"
                . $orow[$jcol] . "</td>";
        $jcol ++;
    } # while $jcol
    my $complete = &get_complete();
    print <<"GFis";
    <td colspan="4" style="text-align:left"> ... 3*${third}*2^n
    \&nbsp;<strong>$complete</strong></td></tr>
GFis
} # sub print_row
#----------------
sub get_complete {
	while ($ncomplete < $maxn and defined($occur[$ncomplete + 1])) {
		$ncomplete ++;
	} # while complete
	return $ncomplete;
} # get_complete
#----------------
sub print_ruler {
    my $icol = 0;
    print sprintf("# %3d |", $irow);
    while ($icol < scalar(@orow)) {
        print sprintf("%4d", $orow[$icol]);
        $icol ++;
    } # while $icol
} # sub print_ruler
#-----------------
sub print_header {
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
<h3>Collatz Graph</h3>
<table>
GFis
} # print_header
#-----------------
sub print_trailer {
    print <<"GFis";
</table>
</body>
</html>
GFis
} # print_trailer
#-----------------
__DATA__
      1-----v
      2     0
      4-------v
      8       1^
     16-----------------------------v
     32                             5
     64-------------------------v  10---------------v
    128                        21  20               3
    256---------------v   3*7*2^n  40---------v     3*2^n
    512              85            80        13    
   1024----v        170           160----v   26
   2048  341        340----v      320   53   52 
   4096  682---v    680  113      640
   8192 1364 227   1360  226

#----------------
1 2 4 8 16 5 10 3 6 12... 3*2^n (6)
#******** 
32 64 21 ... 3*7*2^n
20 40 13 26 52 17 34 11 22 7 14 28 9 18 ... 3^2*2^n (14)
#******** 14
128 256 85 170 340 113 226 75 150 ... 3*5^2*2^n
#----
80 160 53 106 35 70 23 46 15 30 ... 3*5*2^n (18)
104 208 69 ... 3*13*2^n
68 136 45 ... 3^2*5*2^n
44 88 176 352 114 ... 3*19*2^n
56 112 37 75 148 49 98 196 65 130 43 86 172 57 114! ... 3*19*2^n
#******** 
512
680
452
#----
320
212
140
92
#----
416
#----
272
#----
704
#----
224
296
392
260
344
#********
A070165:
142/104: [142m  71d 214m 107d 322m 161d 484m  242m 121d | 364m 182m 91, ... 10, 5, 16, 8, 4, 2, 1]
143/104: [143d 430m 215d 646m 323d 970m 485d 1456m 728m | 364m 182m 91, ... 10, 5, 16, 8, 4, 2, 1]
           +1 *6+4   +1 *6+4   +1 *6+4   +1  *6+4 *6+2    =    = ...

124m 62m  31d 94m  47d 142m
126m 63d 190m 95d 286m 143d