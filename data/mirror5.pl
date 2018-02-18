#!/usr/bin/perl
# 2017-08-24, Georg Fischer
# mirror a partial b-file
# usage:
#    perl mirror5.pl partial > complete   

use strict;
use integer; # avoid division problems with reals
my $base = 5;
my @ent = ();
my $ind = 0;
my $val = 0;
my $val5 = 0;

while (<>) {
	s{\s+\Z}{}; # chompr
	($ind, $val5) = split(/\s+/);
	$ent[$ind] = &normal($val5);
	#print "# ent[$ind]=" . &based($ent[$ind]) . "\n";
} # while $ind 
my $pbl = $ind * 2 + 1;

my $half = $ind;
$ind ++;
print STDERR "ind=$ind, pbl=$pbl, half=$half\n";
while ($ind < $pbl) {
	$ent[$ind] = $pbl -1 - $ent[$pbl - 1 - $ind]; 
    $ind ++;
} # while $ind
$ent[$ind] = $pbl + $pbl - 1;

$ind = 0;
while ($ind <= $pbl) {
	print "$ind\t" . &based($ent[$ind]) . "\n";
	$ind ++;
} # while $ind

#--------
sub based {
    # return a number in base $base
    my ($num) = @_;
    my $bpow = 1;
    my $result = "";
    if ($num <= 0) {
        $result = $num;
    } else {
        while ($num > 0) {
            $result = ($num % $base) . $result;
            $num    /= $base;
            $bpow   *= $base;
        } # while $idig
    }
    return $result; 
} # based
#--------
sub normal {
    # return a based number (string) as normal integer
    my ($bnum) = @_;
    my $bpow = 1;
    my $result = 0;
    if ($bnum < 0) {
        $result = $bnum;
    } else { # positive
        my $pos = length($bnum) - 1;
        while ($pos >= 0) { # from backwards
            my $digit = substr($bnum, $pos, 1);
            $result += $digit * $bpow;
            $bpow   *= $base;
            $pos --;
        } # while $pos
    } # positive
    return $result; 
} # normal
