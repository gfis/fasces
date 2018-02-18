#!/usr/bin/perl
# convert the number base of a b-file, and clean it
# 2017-08-30: Georg Fischer. I place this program in the public domain.
#
# usage : 
#     perl [-f num] [-t num] [-z] [infile] > outfile
#       -f  source base (if omitted, guess it from the digits in the values)
#       -t  target base (10 if omitted)
#       -z  fill target representation with leading zeroes
#       infile defaults to STDIN
# 2 <= base <= 36
# For base > 10, a notation with letters is used in both directions,
# for example a-f = digts 10-15 for base = 16 = hexadecimal.
# If the is no comment starting with "n, a(n)", the program inserts one.
# Caution, works for values >= 0 and <= int_size only!
#-----------------------------------------------
use strict;
use integer; # avoid division problems with reals

my $fbase = -1;
my $tbase = 10;
my $pad_zero = 0;
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
my $min_comment = 0; # minimal comment not yet seen
# shoutd be #n, a(n) [for n = 1..20001]
my $max_digit = "0";
my $min_ind = -1;
my $max_ind = -1;
my $dig_chars = "0123456789abcdefghijklmnopqrstuvwxyz";
my $max_val = -1;

# while (<DATA>) {
while (<>) {
	s{\s+\Z}{}; # chompr
	s{\A\s+}{}; # remove leading spaces
	my $line = $_;
	# print "# line: \"$line\"\n";
	if ($line =~ m{\A\#}) {
		if ($line =~m{\A\#\s*n\,\s*a\(n\)\s*((for)\s+n\s*\=\s*(\d+)\.\.\.?(\d+))?}i) { # min. comment was present
			$min_comment = 1; 
			if ($2 eq "for") {
				$min_ind = $3;
				$max_ind = $4;
			}
		}
		print "$line\n";
	} else { # no comment
		my ($ind, $val) = split(/\s+/, $line);
		my @digits = reverse(sort(split(//, $val)));
		if ($digits[0] gt $max_digit) {
			$max_digit = $digits[0];
		}
		if ($fbase != 10) {
			$val = &from_base($val);
		}
		if ($val > $max_val) {
			$max_val = $val;
		}
		$inds[$ival] = $ind;
		$vals[$ival] = $val;
		$ival ++;
	} # no comment
} # while <>

if ($fbase < 0) {
	$fbase = index($dig_chars, "$max_digit") + 1;
	if ($fbase < 2) {
		print STDERR "could not guess base from maximum digit \"$max_digit\"\n";
		exit(1);
	} else {
		print STDERR "guessed source base $fbase(10)\n";
	}
}

# output comments
my $real_min = $inds[0];
my $real_max = $inds[scalar(@inds) - 1];
if (($min_ind >= 0 and $min_ind != $real_min) or 
	($max_ind >= 0 and $max_ind != $real_max)) {
		print STDERR "b-file_rebase: warning, claimed range ($min_ind..$max_ind)"
				. " differs from real range ($real_min..$real_max)\n";
}
if ($min_comment == 0) { # generate our range
	print "# n, a(n) for n = $real_min..$real_max\n";
}
my $width = -1;
if ($pad_zero > 0) {
	$width = length(&to_base($max_val));
}
# output the table
my $nval = $ival; # number of values
$ival = 0;
while ($ival < $nval) {
	print "$inds[$ival] " . &to_base($vals[$ival]) . "\n";
	$ival ++;
} # while output
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
__DATA__
0 00
1 01
2 02
3 03
4 04
5 05
6 06
7 07
8 08
9 09
10 a
11 b
12 c
13 d
14 e
15 f
16 10
17 11
18 12
