#!/usr/bin/perl

# grep (seqno, URL) from %H entries OEIS DB files
# 2018-12-11: -t
# 2018-10-16: without internal links
# 2009-01-07, Georg Fischer <punctum (at) punctum.com>
#
# Usage:
#	perl grepurl.pl [-t] H-lines.text 
#		-t cut behind tilde part
#------------------------------------
use strict;

my $tilde_only = 0;
my $opt = "";
if (0) {
} elsif ($ARGV[0] =~ m{^-t}) {
	$opt = shift(@ARGV);
	$tilde_only = 1;
}
while (<>) {
    next if ! m[^\%H];
    s/\r?\n//; # chompr
    while (s[\<a\s+href\=\"(http\:\/\/[^\"]+)\"][]i > 0) { # external link found
        my $url = $1;
        m[^\%H\s*(A\d{6})];
        my $seqno = $1;
        if (0) {
        } elsif ($tilde_only == 1) {
        	if (($url =~ s{((\~|\%E7)[^\/]*\/).*}{$1}) >= 1) {
	        	print "$seqno\t$url\n";
	        }
        } else {
        	print "$seqno\t$url\n";
        }
    } # while external link href="http://..." found
} # while <>
__DATA__
