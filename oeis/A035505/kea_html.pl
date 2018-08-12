#!perl

# Build the Kimberling expulsion array in a triangle in HTML
# and show lines of known values
# @(#) $Id$
# 2018-08-07: 1st and 2nd level known values (delta 3)
# 2018-05-07, Georg Fischer
#--------------------------------------------------------
# usage:
#   perl kea_html.pl [maxrow [center]]
#--------------------------------------------------------
use strict;
use integer;

my $maxrow = 100;
my $center = 0;
if (scalar(@ARGV) > 0) {
    $maxrow = shift(@ARGV); # number of rows to be printed
}
if (scalar(@ARGV) > 0) {
    $center = shift(@ARGV); # 0 = left aligned, 1 = centered
}
my @k;
$k[0][0]  = 0;
$k[1][0]  = 0;
$k[1][1]  = 1;
my @c;              # assembled class attribute for K[i,j]
my $debug =  0;
my @orow = (0, 1);  # old row of  triangle

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
.d3     { background-color: orange;    color: white; }
.d4     { background-color: yellow;    color: black; }
.meet /* several lines/colors meet in this point */
        { background-color: limegreen; color: white; }
</style>
</head>
<body>
<h3>Kimberling Expulsion Array</h3>
<table border="0">
<tr>
<td class="d0">   &nbsp; &nbsp; &nbsp; </td><td style="text-align:left;">main diagonal (A035505)</td>
<td class="k0">   &nbsp; &nbsp; &nbsp; </td><td style="text-align:left;">known values</td>
</tr>
<tr>
<td class="d1">   &nbsp; &nbsp; &nbsp; </td><td>1st level derived diagonals</td>
<td class="k1">   &nbsp; &nbsp; &nbsp; </td><td style="text-align:left;">1st level known delta 3</td>
</tr>
<tr>
<td class="d2">   &nbsp; &nbsp; &nbsp; </td><td>2nd level derived diagonals</td>
<td class="k2">   &nbsp; &nbsp; &nbsp; </td><td style="text-align:left;">2nd level known delta 3</td>
</tr>
<tr>
<td class="d3">   &nbsp; &nbsp; &nbsp; </td><td>3rd level derived diagonals</td>
<td class="k3">   &nbsp; &nbsp; &nbsp; </td><td style="text-align:left;">3rd level known delta 3</td>
</tr>
<tr>
<td class="d4">   &nbsp; &nbsp; &nbsp; </td><td>4th level derived diagonals</td>
<td class="k4">   &nbsp; &nbsp; &nbsp; </td><td style="text-align:left;">4th level known delta 3</td>
</tr>
<tr>
<td class="meet"> &nbsp; &nbsp; &nbsp; </td><td style="text-align:left;">crossing with known value</td>
<td             > &nbsp; &nbsp; &nbsp; </td><td>&nbsp;</td>
</tr>
</table>
<p>&nbsp;</p>
<table border="0">
GFis
my $irow  = 1; # index for K's rows
while ($irow <= $maxrow) {
    &advance();
    $irow ++;
} # while advancing
#--------
# set special attributes
my $i;
my $i3;
my $start;
my $delta;

if (0) { # known values (delta = 3)
	# last 3 are known
    $start = 2;
    for ($i3 = 1; $i3 <= 3; $i3 ++) { # last 3
        &line($start, $i3, 1, 2, "k0"); # was k0
        #     row     col dr dc
    } # last 3
    # known lanes: 3 x {2, 5, 11, 23, 47 ...} starting at delta i = 2^n
    $start = 3;
    $delta = 1;
    while ($start <= $maxrow) {
        for ($i3 = 1; $i3 <= 3; $i3 ++) { # 
            &line($start    ,              1, 1,  2, "k1"); # right, down
            &line($start + 1, $start * 2 - 2, 1, -2, "k2"); # left, down
            &line($start + 2, $start * 2 - 7, 1, -6, "k3"); # left, down
            $start += $delta;
        } # last 3
        $start -= $delta;
        $delta *= 2;
        $start += $delta;
    } # while $start
} # known values
# |-> means: position in next row 
# last interesting element is K[i][2*i-1] 
# main diagonal,   darkred
&line( 1, 1, 1, 1, "d0"); 
# 1st derivatives, crimson                  
&line( 3, 1, 2, 1, "d1"); # d1,1  |->od0,1  left  4,7,8,9,24,14 ...
&line( 4, 7, 2, 3, "d1"); # d1,3  |->ed0,1  right 10,15,20,18,31 ...
# 2nd derivatives, orangered                
&line( 9, 1, 4, 1, "d2"); # d2,1  |->od1,3  18,28,33,36,62...   
&line( 4, 3, 4, 3, "d2"); # d2,3  |->ed1,1  7,9,14,35,6
&line( 2, 3, 4, 5, "d2"); # d2,5  |->od1,1  8,24,22,46
&line(11,21, 4, 7, "d2"); # d2,7  |->ed1,3  31,42,53,2,76
# 3rd derivatives, orange
&line(22, 1, 8, 1, "d3"); # d3,1  |->ed2,7  2,34,58
&line( 5, 1, 8, 3, "d3"); # d3,3  |->od2,5  8,22,23
&line( 7, 4, 8, 5, "d3"); # d3,5  |->od2,3  9,35,55,48
&line( 4, 4, 8, 7, "d3"); # d3,7  |->ed2,1  4,28,36,54
&line( 8, 9, 8, 9, "d3"); # d3,9  |->ed2,1  18,33,62
&line(11,16, 8,11, "d3"); # d3,11 |->od2,3  14,6
&line( 9,16, 8,13, "d3"); # d3,13 |->od2,5  24,46,59
&line(26,51, 8,15, "d3"); # d3,15 |->ed2,7  76,99
if (1) {
# 4th derivatives, yellow
#&line(22, 1,16, 1, "d4"); # d4,1  |-> d3,15  
#&line(17, 1,16, 3, "d4"); # d4,3  |-> d3,13  
#&line( 7, 4,16, 5, "d4"); # d4,5  |-> d3,11  
#&line( 4, 4,16, 7, "d4"); # d4,7  |-> d3,9   
#&line( 8, 9,16, 9, "d4"); # d4,9  |-> d3,7   
#&line(11,16,16,11, "d4"); # d4,11 |-> d3,5   
#&line( 9,16,16,13, "d4"); # d4,13 |-> d3,3   
#&line(26,51,16,15, "d4"); # d4,15 |-> d3,1   
&line(21,22,16,17, "d4"); # d4,17 |-> d3,1  2,58
&line(20,24,16,19, "d4"); # d4,19 |-> d3,3  23,97
&line( 4, 5,16,21, "d4"); # d4,21 |-> d3,5  8,23
#&line( 4, 4,16,23, "d4"); # d4,23 |-> d3,7   
#&line( 8, 9,16,25, "d4"); # d4,25 |-> d3,9   
#&line(11,16,16,27, "d4"); # d4,27 |-> d3,11  
#&line( 9,16,16,29, "d4"); # d4,29 |-> d3,13  
#&line(26,51,16,31, "d4"); # d4,31 |-> d3,15  
}

#--------
# print the whole array
# &print_head();
$irow = 1;
while ($irow <= $maxrow) {
    &print_row();
    $irow ++;
} # while $irow
# print "<tr><td class=\"frame\"><strong>i</strong></td></tr>\n";
print <<"GFis";
</table>
</body>
</html>
GFis
#----------------
sub line { # draw the styles for a line
    my ($i1, $j1, $idelta, $jdelta, $style) = @_;
    my $i = $i1;
    my $j = $j1;
    while ($i <= $maxrow and $j >= 1) {
        $c[$i][$j] .= " $style";
        if ($c[$i][$j]  =~ m{k|meet}) {
            # $c[$i][$j] .= " meet";
            my $jn = ($i > $j) ? ($i - $j) << 1 : (($j - $i) << 1) - 1; 
            my $in = $i + 1;
            # $c[$in][$jn] .= " k1";
        }
        $i += $idelta;
        $j += $jdelta;
    } # while
} # line
#----------------
sub advance { # compute next row
    # $orow[$irow] is the element to be expelled
    my $busy = 1; # whether there is a left element
    my $iofs = 1; # offset to the right and to the left
    my $elem;     # current element
    my $tail;     # element at the end of the row
    my @nrow = (0);
    while ($busy != 0) {
        # to the right
        if (0) {
        } elsif ($irow + $iofs <  scalar(@orow)) {
            $elem = $orow[$irow + $iofs];
        } elsif ($irow + $iofs >= scalar(@orow)) {
            $elem = $orow[scalar(@orow) - 1] + 1;
            $tail = $elem;
            $busy = 0;
        }
        push(@nrow, $elem);
        # to the left
        if ($irow - $iofs >= 1) {
            $elem = $orow[$irow - $iofs];
            push(@nrow, $elem);
        }
        $iofs ++;
    } # while busy
    while (scalar(@nrow) < $irow * 2 + 3) {
        $tail ++;
        push(@nrow, $tail);
    } # while $tail
    for (my $jcol = 0; $jcol < scalar(@nrow) - 1; $jcol ++) {
        $orow[$jcol] = $nrow[$jcol];
        print STDERR sprintf("%4d", $orow[$jcol]) if $debug > 0;
        $k[$irow + 1][$jcol] = $orow[$jcol];
        $c[$irow + 1][$jcol] = ($jcol < 2 * $irow - 1 ?  " arr" : " "); # initially
    }
    if ($debug > 0) {
        print STDERR "\n" . sprintf("#     |\n");
    }
} # advance
#----------------
sub print_head {
    my $maxcol = $maxrow * 2 - 1;
    my $jcol = 1;
    print <<"GFis";
    <tr><td class=\"frame\"><strong>K</strong></td>
GFis
    print STDERR sprintf("# %3s |", "") if $debug > 0;
    while ($jcol < $maxcol) {
        print "<td class=\"frame\">$jcol</td>";
        print STDERR sprintf("%4d", $jcol) if $debug > 0;
        $jcol ++;
    } # while $jcol
    print STDERR "\n" if $debug > 0;
    print <<"GFis";
    <td class="frame"><strong>j</strong></td></tr>
GFis
} # print_head
#-----------------
sub print_row {
    print "<tr>";
    print "<td class=\"frame\">$irow</td>\n";
    my $jcol = 1;
    if ($center == 1) { # shows rows centered, otherwise they are left aligned
        while ($jcol < $maxrow - $irow + 1) {
            print "<td>\&nbsp;</td>\n";
            $jcol ++;
        } # while $jcol
    } # center
    $jcol = 1;
    while ($jcol < $irow * 2) {
        $c[$irow][$jcol] =~ s{\A\s+}{}; #  remove leading spaces
        if (($c[$irow][$jcol] =~ s{(\d)}{\1}g) >= 2) { # more than 1 attribute
           $c[$irow][$jcol] .= " meet";
        } # more than 1
        print "<td class=\"$c[$irow][$jcol]\" title=\"$irow,$jcol\">" 
            . $k[$irow][$jcol]
            . "</td>";
        $jcol ++;
    } # while $jcol
    print <<"GFis";
<td>...</td></tr>
GFis
} # sub print_row
#--------
__DATA__
