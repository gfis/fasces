#!perl

# Build the Kimberling expulsion array in a triangle in HTML
# and show lines of known values
# @(#) $Id$
# 2019-01-09: var. renamed
# 2018-08-07: 1st and 2nd level known values (delta 3)
# 2018-05-07, Georg Fischer
#--------------------------------------------------------
# usage:
#   perl kea_html.pl [maxrow] [-c] [-k]
#       -c center
#       -k known values
#       -p known places
#--------------------------------------------------------
use strict;
use integer;

my $maxrow = 100;
my $center = 0;
my $known  = 0;
my $maind  = 0;
my $places = 0;
my $debug  = 0;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\A\d+\Z}) {
        $maxrow = $opt;
    } elsif ($opt =~ m{c}) {
        $center = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{k}) {
        $known  = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $maind  = shift(@ARGV);
    } elsif ($opt =~ m{p}) {
        $places = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my @kear; # left lower triangle of Kimberling's expulsion array
my @clar; # assembled class attribute for $kear[i,j]
my @kfol; # whether the cell was visited when +3 chains are followed
$kear[0][0]  = 0;
$kear[1][0]  = 0;
$kear[1][1]  = 1;
my @orow = (0, 1);  # old row of  triangle
my 
$irow  = 1; # index for rows in @kear
while ($irow <= $maxrow) { # fill with Kimberling's rule
    &advance(); # computes [$irow + 1]
    $irow ++;
} # while advancing

$irow  = 1; # index for rows in @kear
while ($irow <= $maxrow) { # fill with Kimberling's rule
    &follow_chains($irow);
    $irow ++;
} # while advancing

&attributes();

# print the whole array
&print_html_head();
$irow = 1;
while ($irow <= $maxrow) {
    &print_row();
    $irow ++;
} # while $irow

&print_html_tail();
# end main
#***********************************************
#----------------
sub advance { # compute next row [$irow + 1]
    # $orow[$irow] is the element to be expelled
    my $busy = 1; # whether there is a left element
    my $iofs = 1; # offset to the right and to the left
    my $elem;     # current element
    my @nrow = (0); # element [0] is not used
    while ($busy != 0) {
        # to the right
        if (0) {
        } elsif ($irow + $iofs <  scalar(@orow)) {
            $elem = $orow[$irow + $iofs];
            push(@nrow, $elem);
        } elsif ($irow + $iofs >= scalar(@orow)) {
            $busy = 0;
            $elem = $orow[scalar(@orow) - 1] + 1;
            push(@nrow, $elem);
            while (scalar(@nrow) < $irow * 2 + 3) {
                $elem ++;
                push(@nrow, $elem);
            } # while last 3
        }
        # to the left
        if ($irow - $iofs >= 1) {
            $elem = $orow[$irow - $iofs];
            push(@nrow, $elem);
        }
        $iofs ++;
    } # while busy
    for (my $jcol = 0; $jcol < scalar(@nrow) - 1; $jcol ++) {
        $orow[$jcol] = $nrow[$jcol];
        print STDERR sprintf("%4d", $orow[$jcol]) if $debug >= 2;
        $kear[$irow + 1][$jcol] = $orow[$jcol];
        $clar[$irow + 1][$jcol] = " ";
        $kfol[$irow + 1][$jcol] = 0; # not visited yet
    }
    if ($debug >= 2) {
        print STDERR "\n" . sprintf("#     |\n");
    }
} # advance
#--------
sub follow_chains {
    my ($irow) = @_;
    if ($debug >= 1) {
        print STDERR "follow irow=$irow\n";
    }
    my @in_diags = (); # 
    my $jcol = 1;
    while ($jcol < $irow * 2) {
        if ($kfol[$irow][$jcol] == 0) { # not yet followed
            my $elem = $kear[$irow][$jcol];
            if ($debug >= 2) {
                print STDERR "follow? $elem = kear[$irow][$jcol]\n";
            }
            my $busy = 1;
            my $kcol = 1; 
            while ($busy == 1 and $kcol < $irow * 2) {
                if ($elem + 3 <= $kear[$kcol][$kcol]) { # found in diagonal
                    push(@in_diags, $elem);
                    $busy = 0;
                } # found in diagonal
                $kcol ++;
            } # while $kcol
            if (0 and $busy == 0) {
                $kfol[$irow][$jcol] = 1;
            } else { # not in diag
                print STDERR "# chain " . join("", &follow_1_chain($irow, $jcol)) . "\n";
            } # not in diag
        } # not yet followed
        $jcol ++;
    } # while $jcol
    print STDERR "# row $irow - in diag - " . join(",", sort { $a <=> $b } @in_diags) . "\n";
    print STDERR "#----------------\n"
} # follow_chains

sub follow_1_chain {
    my ($irow, $jcol) = @_;
    my $elem = $kear[$irow][$jcol];
    my @result = ("($elem)");
    $kfol[$irow][$jcol] = 1;
    $irow ++;
    my $busyr = 1;
    while ($busyr == 1 and $irow <= $maxrow) { # determine possible chain element in next row
		if ($debug >= 2) {
			print STDERR "follow_1_chain [$irow,$jcol]\n";
		}
        my $kcol = 1;
        my $busyc = 1;
        while ($busyc == 1 and $kcol < $irow * 2) { # search for $elem + 3
            if ($elem + 3 == $kear[$irow][$kcol]) { # found
                $busyc = 0;
                $elem = $kear[$irow][$kcol];
                push(@result
                	, ($kcol - $jcol >= 0 ? "+" : "") . ($kcol - $jcol)
                	, ($kcol == $irow ? "[$elem]" : "($elem)")
                	);
                $jcol = $kcol;
                # push(@result, $elem);
                $kfol[$irow][$kcol] = 1;
            } # found
            $kcol ++;
        } # while $kcol
        if ($busyc == 1) { # not found - end of chain
            $busyr = 0;
        }
        $irow ++;
    } # while
    if ($elem + 3 == $kear[$irow][$irow]) {
    	push(@result, " +3 on diag");
    }
    return @result;
} # follow_1_chain
#--------
sub attributes { # set special attributes
    if ($known > 0) { # known values (delta = 3)
        # last 3 are known
        my $start = 2;
        for (my $i3 = 1; $i3 <= 3; $i3 ++) { # last 3
            #     row     col dr dc
            &line($start, $i3, 1, 2, "k0"); # was k0
        } # last 3
        # known lanes: 3 x {2, 5, 11, 23, 47 ...} starting at delta i = 2^n
        $start = 3;
        my $delta = 1;
        while ($start <= $maxrow) {
            for (my $i3 = 1; $i3 <= 3; $i3 ++) { # last 3
                #     row         col            dr  dc
                &line($start    ,              1, 1,  2, "k1"); # right, down
                &line($start + 1, $start * 2 - 2, 1, -2, "k2"); # left, down
                &line($start + 2, $start * 2 - 7, 1, -6, "k3"); # left, down
                &line($start + 3, $start * 2 -19, 1,-14, "k4"); # left, down
                $start += $delta;
            } # last 3
            $start -= $delta;
            $delta *= 2;
            $start += $delta;
        } # while $start <= $maxrow
    } # known values
    if ($maind  > 0) {
        # main diagonal,   darkred
        &line(  1,  1, 1, 1, "d0");
    }
    if ($places > 0) { # |-> means: position in next row; last interesting element is $kear[i][2*i-1]
        # 1st derivatives, crimson
        &line(  3,  1, 2, 1, "d1"); # d1,1  |->od0,1  left  4,7,8,9,24,14 ...
        &line(  4,  7, 2, 3, "d1"); # d1,3  |->ed0,1  right 10,15,20,18,31 ...
        # 2nd derivatives, orangered
        &line(  9,  1, 4, 1, "d2"); # d2,1  |->od1,3  18,28,33,36,62...
        &line(  4,  3, 4, 3, "d2"); # d2,3  |->ed1,1  7,9,14,35,6
        &line(  2,  3, 4, 5, "d2"); # d2,5  |->od1,1  8,24,22,46
        &line( 11, 21, 4, 7, "d2"); # d2,7  |->ed1,3  31,42,53,2,76
        # 3rd derivatives, orange
        &line( 22,  1, 8, 1, "d3"); # d3,1  |->ed2,7  2,34,58,82
        &line(  5,  1, 8, 3, "d3"); # d3,3  |->od2,5  8,22,23
        &line(  7,  4, 8, 5, "d3"); # d3,5  |->od2,3  9,35,55,48
        &line(  4,  4, 8, 7, "d3"); # d3,7  |->ed2,1  4,28,36,54
        &line(  8,  9, 8, 9, "d3"); # d3,9  |->ed2,1  18,33,62,70
        &line( 11, 16, 8,11, "d3"); # d3,11 |->od2,3  14,6
        &line(  9, 16, 8,13, "d3"); # d3,13 |->od2,5  24,46,59
        &line( 26, 51, 8,15, "d3"); # d3,15 |->ed2,7  76,99
        # 4th derivatives, yellow
        &line( 49,  1,16, 1, "d4"); # d4,1  |-> d3,15 67,21
        &line( 24,  3,16, 3, "d4"); # d4,3  |-> d3,13 59,13
        &line( 10,  2,16, 5, "d4"); # d4,5  |-> d3,11 14,65
        &line( 15,  6,16, 7, "d4"); # d4,7  |-> d3,9  33,70
        &line(  3,  1,16, 9, "d4"); # d4,9  |-> d3,7  4,36,44
        &line(  6,  4,16,11, "d4"); # d4,11 |-> d3,5  9,55
        &line( 12, 10,16,13, "d4"); # d4,13 |-> d3,3  22,11,115
        &line( 29, 28,16,15, "d4"); # d4,15 |-> d3,1  34.82
        &line( 21, 22,16,17, "d4"); # d4,17 |-> d3,1  2,58
        &line(  4,  5,16,19, "d4"); # d4,19 |-> d3,3  8,23,97
        &line( 14, 19,16,21, "d4"); # d4,21 |-> d3,5  35,48
        &line( 11, 17,16,23, "d4"); # d4,23 |-> d3,7  28,54
        &line(  7, 12,16,25, "d4"); # d4,25 |-> d3,9  18,62
        &line( 18, 32,16,27, "d4"); # d4,27 |-> d3,11 6,95
        &line( 16, 31,16,29, "d4"); # d4,29 |-> d3,13 46,79
        &line( 57,113,16,31, "d4"); # d4,31 |-> d3,15 169.216
    } # places
}  # attributes
#--------
sub line { # draw the styles for a line
    my ($i1, $j1, $idelta, $jdelta, $style) = @_;
    my $i = $i1;
    my $j = $j1;
    while ($i <= $maxrow and $j >= 1) {
        $clar[$i][$j] .= " $style";
        if ($clar[$i][$j]  =~ m{k|meet}) {
            # $clar[$i][$j] .= " meet";
            my $jn = ($i > $j) ? ($i - $j) << 1 : (($j - $i) << 1) - 1;
            my $in = $i + 1;
            # $clar[$in][$jn] .= " k1";
        }
        $i += $idelta;
        $j += $jdelta;
    } # while
} # line
#----------------
sub print_head {
    my $maxcol = $maxrow * 2 - 1;
    my $jcol = 1;
    print <<"GFis";
    <tr><td class=\"frame\"><strong>K</strong></td>
GFis
    print STDERR sprintf("# %3s |", "") if $debug >= 2;
    while ($jcol < $maxcol) {
        print "<td class=\"frame\">$jcol</td>";
        print STDERR sprintf("%4d", $jcol) if $debug >= 2;
        $jcol ++;
    } # while $jcol
    print STDERR "\n" if $debug >= 2;
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
        $clar[$irow][$jcol] =~ s{\A\s+}{}; #  remove leading spaces
        if (($clar[$irow][$jcol] =~ s{(\d)}{$1}g) >= 2) { # more than 1 attribute
           $clar[$irow][$jcol] .= " meet";
        } # more than 1
        print "<td class=\"$clar[$irow][$jcol]\" title=\"$irow,$jcol\">"
            . $kear[$irow][$jcol]
            . "</td>";
        $jcol ++;
    } # while $jcol
    print <<"GFis";
<td>...</td></tr>
GFis
} # sub print_row
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
.k0     { background-color:    black;  color: white; font-weight: bold; font-style: italic; }
.k1     { background-color: darkblue;  color: white; font-weight: bold; font-style: italic; }
.k2     { background-color:     blue;  color: white; font-weight: bold; font-style: italic; }
.k3     { background-color: lightblue; color: black; font-weight: bold; font-style: italic; }
.k4     { background-color: lavender;  color: black; font-weight: bold; font-style: italic; }
.k5     { background-color: lavender;  color: black; font-weight: bold; font-style: italic; }
/* main diagonal and its derivatives */
.d0     { background-color: darkred;   color: white; font-weight: bold; }
.d1     { background-color: crimson;   color: white; }
.d2     { background-color: orangered; color: white; }
.d3     { background-color: orange;    color: black; }
.d4     { background-color: yellow;    color: black; }
.meet /* several lines/colors meet in this element */
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
} # print_html_head
#-----------------
sub print_html_tail {
    # print "<tr><td class=\"frame\"><strong>i</strong></td></tr>\n";
    print <<"GFis";
</table>
</body>
</html>
GFis
} # print_html_tail
#--------
__DATA__
from A035505.txt,active part of Kimberling's expulsion (shuffle) array
K(i,j)=i+j-1; (j>=2*i-3)
K(i,j)=K(i-1,i-(j+2)/2); If j is Even and (j<2*i-3)
K(i,j)=K(i-1,i+(j-1)/2); If j is Odd and (j<2*i-3) (End)
4 2; 6 2 7 4; 8 7 9 2 10 6; ...

k[i   ,2j  ]    = k[i-1,i-(2j+2)/2]     
k[i   ,2j+1]    = k[i-1,i+(2j+1-1)/2]   

k[i   ,2j  ]    = k[i-1 ,i-j-1 ] xe 
k[i   ,2j+1]    = k[i-1 ,i+j   ] xo
#-----------------------------------
k[2i  ,2j  ]    = k[2i-1,2i-j-1] ee
k[2i  ,2j+1]    = k[2i-1,2i+j  ] eo
k[2i+1,2j  ]    = k[2i  ,2i-j  ] oe
k[2i+1,2j+1]    = k[2i  ,2i+j+1] oo
#-----------------------------------
main diagonal
d0[2i  ,2i  ]   = d1[2i-1,i-1  ] eeA2,1
d0[2i+1,2i+1]   = d1[2i  ,3i+1 ] A2,3

d1[4j-1,2j-1] A4,1 oo = d2[4j-2,
d1[4j  ,6j+1] A4,3 eo
d1[4j+1,2j  ] A4,1 oe
d1[4j+2,6j+4] A2,3 ee
