#!perl

# Build the Kimberling expulsion array in a triangle
# @(#) $Id$
# 2018-05-03, Georg Fischer
#------------------------------------------------------
# usage:
#   perl expell.pl maxrow
#--------------------------------------------------------
use strict;

my $maxrow = shift(@ARGV); # number of rows to be printed
my $maxcol;
my $irow = 0;   # index in rows
my $icol;       # index for columns
my @orow = (1); # old row of  triangle
my @nrow;       # new row for triangle
my $k = 0;      # b-file index
my $elem;       # current element
my $tail;       # element at the end of the row

&print_head();
&print_ruler();
&print_row();
$irow ++;
@orow = (2, 3, 4);
while ($irow < $maxrow) {
	&print_row();
	&advance();
} # while $irow
&print_ruler();
&print_head();
#----------------
sub advance { # compute next row
	# $orow[$irow] is the element to be expelled
    my $busy = 1; # whether there is a left element
    my $iofs = 1; # offset to the right and to the left
    @nrow = ();
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
        if ($irow - $iofs >= 0) {
            $elem = $orow[$irow - $iofs];
            push(@nrow, $elem);
        }
        $iofs ++;
    } # while busy
    while (scalar(@nrow) < $irow * 2 + 3) {
    	$tail ++;
    	push(@nrow, $tail);
	} # while $tail
	for ($icol = 0; $icol < scalar(@nrow); $icol ++) {
		$orow[$icol] = $nrow[$icol];
	}
    $irow ++;
} # advance
#----------------
sub print_head {
	$maxcol = $maxrow * 2 - 1;
    $icol = 0;
    print sprintf("# %3s |", "");
    while ($icol < $maxcol) {
        print sprintf("%4d", $icol);
        $icol ++;
    } # while $icol
    print "\n";
} # print_head

sub print_ruler {
    $icol = 0;
    print sprintf("#-----+");
    while ($icol < $maxcol) {
        print sprintf("----");
        $icol ++;
    } # while $icol
    print "\n";
} # print_ruler
#-----------------
sub print_row {
    $icol = 0;
    print sprintf("# %3d |", $irow);
    while ($icol < scalar(@orow)) {
        print sprintf("%4d", $orow[$icol]);
        $icol ++;
    } # while $icol
    print "\n";
    print sprintf("#     |\n");
} # sub print_row
#----------------
sub bfile {
    my ($elem) = @_;
    print "$k $elem\n";
    $k ++;
} # bfile

__DATA__