#!perl

# Build the Kimberling expulsion array in a triangle in HTML
# @(#) $Id$
# 2018-05-07, Georg Fischer
#------------------------------------------------------
# usage:
#   perl kea_html.pl maxrow
#--------------------------------------------------------
use strict;
use integer;

my @k;
$k[0][0] = 0;
$k[1][0] = 0;
$k[1][1] = 1;
my @c; # assembled class attribute for K[i,j]
my $maxrow = shift(@ARGV); # number of rows to be printed
my $maxcol;
my $irow = 1;   # index for K's rows
my $jcol;       # index for K's columns
my @orow = (0, 1); # old row of  triangle
my @nrow;       # new row for triangle
my $bk = 0;      # b-file index
my $elem;       # current element
my $tail;       # element at the end of the row
my $debug = 0;

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
.frame 
	{ font-size:smaller; background-color: white}
.arr
	{ background-color: lightyellow;}
.m1 /* diagonal */
	{ background-color: tomato; color: white; font-weight: bold }
.k0 /* known value - outside */
	{ background-color: white; color: black; font-weight: bold; font-style: italic; }
.k1 /* known value */
	{ background-color: yellow; color: black; font-weight: bold; font-style: italic; }
.d1 /* 1st derivative */
	{ background-color: lightblue; color: black; }
.d2 /* 2nd derivative */
	{ background-color: lightgreen; color: black; }
.bord
	{ border-style: solid; border-width: thin; }
</style>
</head>
<body>
<table border="0">
GFis
$irow = 1;
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
&line(1, 1, 1, 1, "m1"); # main diagonal

# last 3 are known
$start = 2;
for ($i3 = 1; $i3 <= 3; $i3 ++) { # last 3
	&line($start, $i3, 1, 2, "k0");
} # last 3

# known lanes
$start = 3;
$delta = 1;
while ($start <= $maxrow) {
	for ($i3 = 1; $i3 <= 3; $i3 ++) { # 
		&line($start, 1, 1, 2, "k1");
		$start += $delta;
	} # last 3
	$start -= $delta;
	$delta *= 2;
	$start += $delta;
} # while $start

&line(3, 1, 2, 1, "d1"); # 1st derivative left
&line(4, 7, 2, 3, "d1"); # 1st derivative right
&line(4, 3, 4, 3, "d2"); # 2nd derivative left
&line(2, 3, 4, 5, "d2"); # 2nd derivative right
#--------
# print the whole array
&print_head();
&print_ruler();
$irow = 1;
while ($irow <= $maxrow) {
    &print_row();
    $irow ++;
} # while $irow
# &print_ruler();
# &print_head();
print <<"GFis";
<tr><td class="frame"><strong>i</strong></td></tr>
</table>
</body>
</html>
GFis
#----------------
sub line { # draw the styles for a line
	my ($i1, $j1, $idelta, $jdelta, $style) = @_;
	my $i = $i1;
	my $j = $j1;
	while ($i <= $maxrow) {
		$c[$i][$j] .= " $style";
		$i += $idelta;
		$j += $jdelta;
	} # while
} # line
#----------------
sub advance { # compute next row
    # $orow[$irow] is the element to be expelled
    my $busy = 1; # whether there is a left element
    my $iofs = 1; # offset to the right and to the left
    @nrow = (0);
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
    for ($jcol = 0; $jcol < scalar(@nrow) - 1; $jcol ++) {
        $orow[$jcol] = $nrow[$jcol];
        print STDERR sprintf("%4d", $orow[$jcol]) if $debug > 0;
        $k[$irow + 1][$jcol] = $orow[$jcol];
        $c[$irow + 1][$jcol] = ($jcol < 2 * $irow - 1 ?  " arr" : " "); # initially
    }
    print STDERR "\n" if $debug > 0;
    print STDERR sprintf("#     |\n") if $debug > 0;
} # advance
#----------------
sub print_head {
    $maxcol = $maxrow * 2 - 1;
    $jcol = 1;
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

sub print_ruler {
    $jcol = 1;
    print STDERR sprintf("#-----+") if $debug > 0;
    while ($jcol < $maxcol) {
        print STDERR sprintf("----") if $debug > 0;
        $jcol ++;
    } # while $jcol
    print STDERR "\n" if $debug > 0;
} # print_ruler
#-----------------
sub print_row {
    $jcol = 1;
    print <<"GFis";
    <tr><td class=\"frame\">$irow</td>
GFis
    while ($jcol < $irow * 2 ) {
    	$c[$irow][$jcol] =~ s{\A\s+}{}; #  remove leading spaces
    	if (($c[$irow][$jcol] =~ s{(\d)}{\1}g) >= 2) { # more than 1 attribute
    		$c[$irow][$jcol] .= " bord";
    	} # more than 1
        print "<td class=\"$c[$irow][$jcol]\">$k[$irow][$jcol]</td>";
        $jcol ++;
    } # while $jcol
    print <<"GFis";
<td>..</td></tr>
GFis
} # sub print_row
#----------------
sub bfile {
    my ($elem) = @_;
    print "$bk $elem\n";
    $bk ++;
} # bfile

__DATA__