#!perl

# put lower values from stripped.gz at the end
# @(#) $Id$
# 2018-10-01, Georg Fischer 
#---------------------------------
use strict;
use integer;
my $higher = 8;
my $debug = 0;
my $minlen = 6;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{h}) {
        $higher = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $minlen = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

while (<>) {
    next if m{\A\s*\#};
    s/\s+\Z//; # chompr
    my ($seqno, $list) = split(/\s+\,/);
    my @sequence = split(/\,/, $list);
    my $ind = 0;
    while ($ind < scalar(@sequence) and $sequence[$ind] < $higher) {
        $ind ++;
    } # while $ind
    if (scalar(@sequence) - $ind >= $minlen) {
        print join(" ", splice(@sequence, $ind)) 
            . "\t" . join(" ", splice(@sequence, 0, $ind)) 
            . "\t$seqno\n";
    }
} # while <>
