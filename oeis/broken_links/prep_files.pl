#!/usr/bin/perl

# grep (seqno, URL) from %H entries OEIS DB files
# 2009-01-07, Georg Fischer <punctum (at) punctum.com> 
#	http://www.research.att.com/~njas/sequences/eisBTfry00000.txt

use strict;

	for my $no (0..160) {
		print "http://www.research.att.com/~njas/sequences/eisBTfry" . sprintf("%05d.txt\n", $no);
	}

