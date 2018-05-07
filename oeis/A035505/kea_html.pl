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
my $debug = 1;

print <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style>
body,table,p,td,th 
	{ font-family: Courier; }
tr,td,th,p
	{ text-align: right; }
.frame 
	{ font-size:smaller; background-color: white}
.arr
	{ background-color: lightyellow;}
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
        print "<td class=\"" . substr($c[$irow][$jcol], 1) . "\">$k[$irow][$jcol]</td>";
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