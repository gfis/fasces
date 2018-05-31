#!/usr/bin/perl

# Evaluate turncodes
# 2018-05-31, Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl eval_turncode.pl [-b base] [-d n]
#       -b base  (default 5)
#       -d debug level n (default: 0 = none)
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $debug  = 0;
my $base   = 5;
my $unit   = 1;  # dual to $base
my $digits = "0123456789abcdefghijklmnopqrstuvwxyz"; # for counting in base 11, 13, ...

# while (scalar(@ARGV) > 0) {
#     my $opt = shift(@ARGV);
#     if (0) {
#     } elsif ($opt =~ m{\-b}) {
#         $base   = shift(@ARGV);
#     } elsif ($opt =~ m{\-d}) {
#         $debug  = shift(@ARGV);
#     }
# } # while opt
my %hooks = (); # collect turncode components here
my %port4 = ();
my %port6 = ();
#----
while (<>) {
	if (m{notexp\=\"(\d+)\"\s+turncode\=\"([\d\-]*)\"}) {
		my $notexp   = $1 + 1; # 1 = bit 0 = success, 2 = bit 1 = failure
		my $turncode = $2;
		my $tc2 = $turncode;
		$tc2 =~ s{(\d)}{\+\1}g;
		$tc2 =~ s{\-\+}{\-}g;
		$tc2 = substr($tc2, 1);
		my $ind2 = 0;
		while ($ind2 < length($tc2)) {
			my 
			$port = substr($tc2, $ind2, 4);
			if (length($port) == 4) {
				if ($notexp == 1) {
					$port4{$port}  = -1;
				} else {
					if (defined($port4{$port})) {
						if ($port4{$port} > 0) {
							$port4{$port} ++;
						}
					} else {
						$port4{$port} = 1;
					}
				}
			}
			$port = substr($tc2, $ind2, 6);
			if (length($port) == 6) {
				if ($notexp == 1) {
					$port6{$port}  = -1;
				} else {
					if (defined($port6{$port})) {
						if ($port6{$port} > 0) {
							$port6{$port} ++;
						}
					} else {
						$port6{$port} = 1;
					}
				}
			}
			$ind2 += 2;
		} # while $ind2
		foreach my $comp (split(/\-/, $turncode)) {
			if (! defined($hooks{$comp})) {
				$hooks{$comp}  = $notexp;
			} else {
				$hooks{$comp} |= $notexp;
			}
		} # foreach $comp
	} # proper attribute line
} # while <>
print "--hooks---------------\n";
my $key;
foreach $key (sort(keys(%hooks))) {
	print sprintf("%s %s\n", $hooks{$key}, $key);
} # foreach $key
print "--port4	--------------\n";
foreach $key (sort(keys(%port4))) {
	if (1 or $port4{$key} >= 0) {
		print sprintf("%6d %s\n", $port4{$key}, $key);
	}
} # foreach $key
print "--port6---------------\n";
foreach $key (sort(keys(%port6))) {
	if (1 or $port6{$key} >= 0) {
		print sprintf("%6d %s\n", $port6{$key}, $key);
	}
} # foreach $key
__DATA__
