#!/usr/bin/perl

# Compress gear notation
# 2018-06-04, Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl compress_gear.pl [-d n]
#       -d debug level n (default: 0 = none)
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $debug  = 0;
my $base   = 5;
my $unit   = 1;  # dual to $base
my $digits = "0123456789abcdefghijklmnopqrstuvwxyz"; # for counting in base 11, 13, ...
my $id;
my $gear;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-b}) {
        $base   = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    }
} # while opt

my %hash = ();
    print <<"GFis";
<?xml version="1.0" encoding="UTF-8" ?>
<paths>
GFis
foreach my $fbase (3,5,7) {
    &evaluate("paths.$fbase.tmp");
}
print "</paths>\n";
#---------------------------------
# read a path file and compress all gear attributes
sub evaluate { my ($filename) = @_;
    my $line;
    open(PIN, "<", $filename) || die "cannot read \"$filename\"\n";
    while (<PIN>) {
        $line = $_;
        if (0) {
        } elsif ($line =~ m{\<(meander|path)\s}) { # start tag
            $line =~ m{base\=\"(\d+)\"};
            $base   = $1;
            $line =~ m{id\=\"(\d+)\"};
            $id  = $1;
        } elsif ($line =~ m{gear\=\"([^\"]*)\"}) { 
            $gear   = $1;
        } elsif ($line =~ m{\<\/(meander|path)\>}) { # end tag
            &compress($id, $gear, $base);
        }
    } # while PIN
    close(PIN);
} # evaluate
#----------------------
sub compress { my ($id, $gear, $base) = @_;
    foreach my $key (sort(keys(%hash))) {
        $gear =~ s{\Q$key\E}{$hash{$key}}g;
    } # foreach
    print <<"GFis";
<path base="$base" id="$id"\tgear="$gear" />
GFis
    $hash{$gear} = "($base.$id)";
} # compress
#--------
__DATA__
