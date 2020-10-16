#!perl

# Run linhrec.jar through stripped
# 2019-02-18, Georg Fischer

use strict;
use integer; 

while (<>) {
	s{\s+\Z}{}; # chompr;
	my ($aseqno, $list) = split(/\s+\,/, $_);
	print "$aseqno: " . `java -jar linhrec.jar \"$list\"`);
} # while <>
