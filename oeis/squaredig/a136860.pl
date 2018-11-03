#!perl
#
# Generate proof data for OEIS A136nnn sequences
# @(#) $Id$
# 2018-10-25, Georg Fischer
#
# Usage:
#   perl a136860.pl -c digits -w width -d debug
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
my $code   = "01467"; # digits which may occur
my $maxind = 100000000; # generate so many terms
my $bseqno = "b136860";
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

my $rest  = "0123456789";
my @digs  = split(//, $code);
$rest =~ s{[$code]}{}g;
print "digs=$code, rest=$rest\n";
my $pdig  = qr("\A[$code]+\Z");
my @digs2 = ();
my @olds  = ();
for (my $i = 0; $i < scalar(@digs); $i ++) {
	for (my $j = 0; $j < scalar(@digs); $j ++) {
    	push(@digs2, $digs[$i] . $digs[$j]);
    	push(@olds , $digs[$i] . $digs[$j]);
	} # for j
} # for i

my $width = 1;
while ($width <= $maxwidth) {
    my @news = ();
    my $ind = 1;
    foreach my $old(@olds) { # allowed so far
        my $squold  = Math::BigInt->new($old);
        my $bold    = Math::BigInt->copy($squold);
        $squold->bsqrt();
   		if ($debug >= 1) {
    		print "sqrt($old) = $squold";
    	}
    	if ($squold !~ m{[$rest]}o) { # sqrt contains allowed digits
   			if ($debug >= 1) {
	    		print " ! ";
	    	}
    		my $powold = Math::BigInt->new($squold);
    		$powold->bmul($squold);
    		if (($bold->bcmp($powold)) == 0) { # sqrt of a square
    			print "sqrt($old) = $squold" if $debug == 0;
    			print " + ";
    			print "\n"  if $debug == 0;
	   		} # if sqrt of a square
			foreach my $dig2 (@digs2) {
				my $new = "$old$dig2";
				push(@news, $new);
    			if ($debug >= 2) {
    				print " $new";
    			}
			} # foreach $dig2
     	} # if sqrt contains allowed digits
   		if ($debug >= 1) {
    		print "\n";
    	}
    	@olds = ();
        foreach my $new(@news) {
            push(@olds, $new);
        } # foreach @news
    } # foreach @olds
    if (1) { # yet
        # $width = $maxwidth;
    } 
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
