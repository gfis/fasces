#!perl
#
# Generate proof data for OEIS A136nnn sequences
# @(#) $Id$
# 2018-10-25, Georg Fischer
#
# Usage:
#   perl a136859.pl -c digits -w width -d debug 
#--------------------------------------------
use strict;
use integer;
use Math::BigInt;
use Math::BigInt':constant'; # $a[$n] = Math::BigInt->new(1);
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $base   = 10;
my $digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzäö";
#             0123456789012345678901234567890123456789012345678901234567890123
#                       1         2         3         4         5         6
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $code   = "0146"; # digits which may occur
my $maxind = 100000000; # generate so many terms
my $bseqno = "b136808";
my $proof  = 0;
my $maxwidth  = 25; # very wide
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{b}) {
        $base   = shift(@ARGV);
    } elsif ($opt =~ m{f}) {
        $bseqno = shift(@ARGV);
    } elsif ($opt =~ m{c}) {
        $code   = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $maxind = shift(@ARGV);
    } elsif ($opt =~ m{p}) {
        $proof  = shift(@ARGV);
    } elsif ($opt =~ m{w}) {
        $maxwidth  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

my $rest = "0123456789";
my @digs = split(//, $code);
$rest =~ s{[$code]}{}g;
print "digs=$code, rest=$rest\n";
my @olds = map { $_ } @digs;
my $pdig  = qr("\A[$code]+\Z");

my $width = 1;
while ($width <= $maxwidth) {
    my @news = ();
    my $ind = 1;
    foreach my $old(@olds) { # all allowed so far
        my $old2  = Math::BigInt->new($old);
        $old2->bmul($old);
        my $old2w = substr($old2, - $width);
        if ($old2w !~ m{[$rest]}o) { # last block of square is allowed
        	if ($old !~ m{^0}) {
		        my $result = sprintf("%d\t%20s", $ind, $old);
        	    print $result; #  +";
            	print " " . (($old2 !~ m{[$rest]}o) ? " + " : "   "); 
            	$old2 =~ s{$old2w\Z}{ $old2w};
            	print sprintf("%40s", $old2);
            	# print sprintf(" %10s %20s ", &to_base($old), &to_base($old2));
            	my $occur = join("", sort(split(//, $old2)));
            	# print " $occur ";
            	$occur =~ s{((\d)\2+)}{\2}g;
	            print " $occur\n";
		        $ind ++;
            }
            if ($old2w != 0) {
                push(@news, $old);
            }
        } else {
        } # last block of square
    } # foreach @olds
    @olds = ();
    foreach my $dig(@digs) {
        foreach my $new(@news) {
            push(@olds, "$dig$new");
        } # foreach @news
    } # foreach @digs
    $width ++;
} # while
#--------
# convert from decimal to base, without leading zeroes
sub to_base { my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $base;
        $result =  substr($digits, $digit, 1) . $result;
        $num /= $base;
    } # while > 0
    return $result eq "" ? "0" : $result;
} # to_base
#--------
__DATA__
