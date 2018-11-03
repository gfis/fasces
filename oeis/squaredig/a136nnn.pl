#!perl
#
# Generate proof data for OEIS A136nnn sequences
# @(#) $Id$
# 2018-10-25
# 2018-10-11, Georg Fischer
#
# Usage:
#   perl a136nnn.pl -c digits -m max -w width -b seqno -d debug -p proof
#--------------------------------------------
use strict;
use integer;
use Math::BigInt;
use Math::BigInt':constant'; # $a[$n] = Math::BigInt->new(1);
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $code   = "0146"; # digits which may occur
my $maxind = 1000; # generate so many terms
my $bseqno = "b136808";
my $proof  = 0;
my $width  = 2048; # very wide
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{b}) {
        $bseqno  = shift(@ARGV);
    } elsif ($opt =~ m{c}) {
        $code   = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $maxind = shift(@ARGV);
    } elsif ($opt =~ m{p}) {
        $proof  = shift(@ARGV);
    } elsif ($opt =~ m{w}) {
        $width  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

my $rest = "0123456789";
my $digs = $code;
$rest =~ s{[$digs]}{}g;
print "rest=$rest\n";

my $pdig  = qr("[^$digs]");
my %hash = ();
for (my $i = 0; $i < length($digs); $i ++) {
for (my $j = 0; $j < length($digs); $j ++) {
for (my $k = 0; $k < length($digs); $k ++) {
for (my $l = 0; $l < length($digs); $l ++) {
    $hash{substr($digs, $i, 1) 
        . substr($digs, $j, 1)
        . substr($digs, $k, 1)
        . substr($digs, $l, 1)
        } = 1;
} # for l
} # for k
} # for j
} # for i
#----
print "Overview:\n" .join("\n", 
    grep { $_ !~ m{[$rest]} }
    map { sprintf("%04d %8d", $_, ($_ * $_)) } 
    sort(keys(%hash))
    ) . "\n";
#----
# proofs    
if (0) {
} elsif ($proof == 1) {
	print sprintf("x y %11s + %8s + %4s = %4s, d1\n"
                , "100*x^2", "20*x*y", "y^2", "a^2");
    for (my $i = 0; $i < length($digs); $i ++) {
    for (my $j = 0; $j < length($digs); $j ++) {
        if ($i != 0 and $j != 0) {
            my $x = substr($digs, $i, 1);
            my $y = substr($digs, $j, 1);
            my $sq = 100*$x*$x + 20*$x*$y + $y*$y; 
            my $sq2 = ($sq % 100) / 10;
            print sprintf("%1d %1d %6d[00*] + %4d[0*] + %4d = %4d, %1d\n"
                , $x, $y, 100*$x*$x, 20*$x*$y, $y*$y, $sq, $sq2);
        } # != 0
    } # for j
    } # for i
    # proof 1
} elsif ($proof == 6) {
	print sprintf("x y %11s + %8s + %4s = %4s, d1\n"
                , "100*x^2", "20*x*y", "y^2", "a^2");
    for (my $i = 0; $i < length($digs); $i ++) {
    for (my $j = 0; $j < length($digs); $j ++) {
        if (1) {
            my $x = substr($digs, $i, 1);
            my $y = substr($digs, $j, 1);
            my $sq = 100*$x*$x + 20*$x*$y + $y*$y; 
            my $sq2 = ($sq % 100) / 10;
            print sprintf("%1d %1d %6d[00*] + %4d[0*] + %4d = %4d, %1d\n"
                , $x, $y, 100*$x*$x, 20*$x*$y, $y*$y, $sq, $sq2);
        } # != 0
    } # for j
    } # for i
    # proof 6
}
#----
# now counting for b-file
my $an = Math::BigInt->new(1);
my $ind = 1;
my $loopcheck = 1000000;
my $busy = 1;
while ($busy == 1 and $loopcheck > 0) {
    if ($an !~ m{[$rest]}o) {
        my $an2 = $an->copy();
        $an2->bmul($an);
        if ($an2 !~ m{[$rest]}o) {
            print "$ind $an\n";
            $ind ++;
            if ($ind > $maxind) {
                $busy = 0;
            }
        }
        if (length($an) > $width) {
            $busy = 0;
        }
    }
    $an += 1;
    $loopcheck --;
} # while $ind
if ($loopcheck <= 0) {
    print "loop exhausted\n";
}
__DATA__
