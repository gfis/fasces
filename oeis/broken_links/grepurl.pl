#!/usr/bin/perl

# grep (seqno, URL) from %H entries OEIS DB files
# 2018-10-16: without internal links
# 2009-01-07, Georg Fischer <punctum (at) punctum.com> 

use strict;

    while (<>) {
        next if ! m[^\%H];
        s/\r?\n//; # chompr
        while (s[\<a\s+href\=\"(http\:\/\/[^\"]+)\"][]i > 0) { # external link found
            my $url = $1;
            m[^\%H\s*(A\d{6})];
            my $seqno = $1;
            print "$seqno\t$url\n";
        } # while external link href="http://..." found
    } # while <>
__DATA__