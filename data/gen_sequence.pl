#!/usr/bin/perl

# Generate a meander sequence
# 2017-08-31, Georg Fischer
# Program in the public domain
# c.f. <http://www.teherba.org/index.php/OEIS/A220952>

use strict;
use integer; # avoid division problems with reals

my $debug = 1;
my $base   = 5; 
my $maxexp = 3;  # compute b-file up to $base**$maxexp
my $width  = $maxexp;
my $fbase = 10;
my $tbase =  5;
my $pad_zero = 1;
my $dig_chars = "0123456789abcdefghijklmnopqrstuvwxyz";

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # start with hyphen
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt eq "\-f") {
        $fbase  = shift(@ARGV);
    } elsif ($opt eq "\-t") {
        $tbase  = shift(@ARGV);
    } elsif ($opt eq "\-z") {
        $pad_zero = 1;
    }
} # while opt

my $ival = 0;
my @inds = ();
my @vals = ();
while (<>) {
    s{\s+\Z}{}; # chompr
    s{\A\s+}{}; # remove leading spaces
    next if m{\A\#};
    my $line = $_;
    # print "# line: \"$line\"\n";
    my ($ind, $val) = split(/\s+/, $line);
    my $val = &to_base($val); # coordinates are wxy for 341
    if (length($val) == $maxexp) { # no longer
        $inds[$ival] = $ind;
        $vals[$ival] = $val;
        $ival ++;
    }
} # while <>

my $ind = 1; # $vals[0] is always fixed
while ($ind < scalar(@vals)) {
    my $change = &get_change_pos($vals[$ind - 1], $vals[$ind]);
    $ind ++;
} # while $ind
#--------
sub draw {
    
} # draw
#--------
sub get_digit {
    # gets the digit for base**n
    my ($bnum, $bexp) = @_;
    return substr($bnum, length($bnum) - 1 - $bexp, 1);
} # get_digit
#--------
sub get_change_pos {
    # determine the position which changed between 2 nodes
    # assume that only one position changes
    my ($prev, $curr) = @_;
    while (length($prev) < length($curr)) { # adjust length
        $prev = "0$prev"; # prefix with 0
    } # while adjusting
    my $result = -1;
    my $bexp = 0;
    while ($result < 0 and $bexp < $maxexp) {
        if (&get_digit($prev, $bexp) ne 
            &get_digit($curr, $bexp)) {
            $result = $bexp;
        }
        $bexp ++;
    } # while $bexp
    print "change $prev,$curr: $result " . substr("       ", 0, $result) . "*\n";
    return $result;
} # get_change_pos
#--------
sub to_base {
    # return a normal integer as number in base $tbase
    my ($num)  = @_;
    my $result = "";
    my $iw = 0;
    while ($num > 0 or $iw < $width) {
        my $digit = substr($dig_chars, $num % $tbase, 1);
        $result =  $digit . $result;
        $num /= $tbase;
        $iw ++;
    } # while $iw
    return $result eq "" ? "0" : $result; 
} # to_base
#--------
sub from_base {
    # return a number in base $fbase (string, maybe with letters) as normal integer
    my ($num)  = @_;
    my $bpow   = 1;
    my $result = 0;
    my $pos    = length($num) - 1;
    while ($pos >= 0) { # from backwards
        my $digit = index($dig_chars, substr($num, $pos, 1));
        if ($digit < 0) {
            print STDERR "invalid digit in number $num\n";
        }
        $result += $digit * $bpow;
        $bpow   *= $fbase;
        $pos --;
    } # positive
    return $result; 
} # from_base
#--------
#--------
__DATA__
