#!perl

# Build the Kimberling expulsion array in a triangle
# @(#) $Id$
# 2018-05-03, Georg Fischer
#------------------------------------------------------
# usage:
#   perl expell0.pl maxrow
#--------------------------------------------------------
use strict;
use integer; # avoid division problems with reals

my $maxrow = shift(@ARGV); # number of rows to be printed
my $maxcol;
my $irow = 0;   # index in rows
my $icol;       # index for columns
my @nrow;       # new row for triangle
my $k = 0;      # b-file index
my $elem;       # current element
my $ifeed;      # index for new elements: 0, 1, 2
my $tail = 1;   # last new element, increased by &feed()
my @kimb; # elements of the Kimberling expulsion array
my $ikimb = 0;
open(KIM, "<b007063.txt") || die "cannot read b007063.txt";
while (<KIM>) {
	last if $ikimb >= 2000;
	s/\s+\Z//;
	my ($n, $an) = split;
	push(@kimb, $an);
	$ikimb ++;
} # while KIM
close(KIM);
$ikimb = 1;

my @orow = ($tail); # old row of  triangle
my $width =  5; # width of an element to be printed
my $tbase =  10; # target base
&print_head();
&print_ruler();
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
	        push(@nrow, $elem);
        } elsif ($irow + $iofs >= scalar(@orow)) {
        	$ifeed = 0;
            $busy = 0;
        }
        # to the left
        if ($irow - $iofs >= 0) {
            $elem = $orow[$irow - $iofs];
            push(@nrow, $elem);
        }
        $iofs ++;
    } # while busy
   	push(@nrow, &feed($irow)); 
   	push(@nrow, &feed($irow)); 
   	push(@nrow, &feed($irow)); 
	for ($icol = 0; $icol < scalar(@nrow); $icol ++) {
		$orow[$icol] = $nrow[$icol];
	}
    $irow ++;
} # advance
#----------------
sub feed { # return the 3 new elements in succession
	my ($irow) = @_;
	&grow();
	my $result = $tail;
	$ifeed ++;
	return $result;
} # feed
#----------------
sub grow_3 { # run $tail through all natural numbers
	if (0) {
	} elsif ($tail % 3 == 0) {
		$tail += 2;
	} elsif ($tail % 3 == 1) {
		$tail += 2;
	} elsif ($tail % 3 == 2) {
		$tail += -1;
	}		
} # grow
#----------------
sub grow_kimb { # run $tail through all elements of the Kimberling expulsion array
	$tail = $kimb[$ikimb ++];
} # grow_kimb
#----------------
sub grow { # run $tail through all natural numbers
	$tail ++;
} # grow
#----------------
sub grow_natural { # run $tail through all natural numbers
	$tail ++;
} # grow
#----------------
sub grow_integer_neg { # run $tail through all integer numbers - start -
	if ($tail >= 0) {
		$tail = - $tail - 1;
	} else {
		$tail = - $tail;
	}
} # grow
#----------------
sub grow_integer_pos { # run $tail through all integer numbers - start +
	if ($tail <= 0) {
		$tail = - $tail + 1;
	} else {
		$tail = - $tail;
	}
} # grow
#----------------
sub print_head {
	$maxcol = $maxrow * 2 - 1;
    $icol = 0;
    print sprintf("# %3s |", "");
    while ($icol < $maxcol) {
        print sprintf("%${width}d", $icol);
        $icol ++;
    } # while $icol
    print "\n";
} # print_head

sub print_ruler {
    $icol = 0;
    print sprintf("#-----+");
    while ($icol < $maxcol) {
        print sprintf("-" x $width);
        $icol ++;
    } # while $icol
    print "\n";
} # print_ruler
#-----------------
sub print_row {
    $icol = 0;
    print sprintf("# %3d |", $irow);
    print " " x ($width * ($maxrow - $irow - 1));
    while ($icol < scalar(@orow)) {
        print sprintf("%${width}s", &to_base($orow[$icol]));
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
#--------
sub to_base {
    # return a normal integer as number in base $tbase
    my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $tbase;
        $result =  $digit . $result;
        $num /= $tbase;
    } # while > 0
    return $result eq "" ? "0" : $result; 
} # to_base

__DATA__