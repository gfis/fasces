#!perl

# show iterative differences of a sequence
# @(#) $Id$
# 2018-03-27, Georg Fischer
#------------------------------------------------------
# usage:
#	./armleg $(N) 1 | grep -vE "^#" | cut -d " " -f $$(($(N)+2)) \
#	| perl diffs.pl
#--------------------------------------------------------
use strict;

my $count = 0;
my @arr = ();
while (<>) {
    s/\s//g; # chompr
	push(@arr, $_);
} # while <>
print join(" ", @arr) . "\n";
while (scalar(@arr) > 1) { # compute diffs
	my $a0 = shift(@arr);
	my $ia = 0;
	while ($ia < scalar(@arr)) {
		my $ai = $arr[$ia];
		$arr[$ia] = abs($ai - $a0);
		$a0 = $ai;
		$ia ++;
	} # while $ia
	print join(" ", @arr) . "\n";
} # while computing
__DATA__
./armleg 4 1 | grep -vE "^#" | cut -d " " -f $((4+2))
160
110
68
160
264
110
110
264
160
68
110
160
