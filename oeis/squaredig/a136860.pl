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
my @digs1 = split(//, $code);
$rest =~ s{[$code]}{}g;
print "# digs1=$code, rest=$rest\n";
my $pdig  = qr("\A[$code]+\Z");
my @digs2 = ();
my @olds  = ();
for (my $i = 0; $i < scalar(@digs1); $i ++) {
    for (my $j = 0; $j < scalar(@digs1); $j ++) {
        push(@digs2, $digs1[$i] . $digs1[$j]);
        push(@olds , $digs1[$i] . $digs1[$j]);
    } # for j
} # for i
if ($debug >= 1) {
	print "# olds = (" . join(",", @olds) . ")\n";
}
my $ind = 0;
my $width = 1;
while ($width <= $maxwidth) {
    my @news = ();
    foreach my $old (@olds) { # allowed so far
    	my $bold   = Math::BigInt->new($old); # = $old as BigInt
        my $squold = Math::BigInt->copy($bold)->bsqrt($bold);
        if ($squold !~ m{[$rest]}o) { # sqrt contains allowed digits
            my $powold = Math::BigInt->new($squold);
            $powold->bmul($squold);
            my $bdiff = $bold->copy();
            $bdiff->bsub($powold);
            if ($debug >= 1) {
                print "# sqrt($old) = $squold rest $bdiff ! ";
            }
            if ($bdiff->is_zero()) { # sqrt of a square
                if ($debug >= 1){
                	print " +\n";
                }
            	$ind ++;
                print "$ind $squold $bold\n"; # b-file line
                # if sqrt of a square
            } else {
	            if ($debug >= 1) {
    	            print "\n";
        	    }
            }
            foreach my $dig2 (@digs2) {
            	if ($old !~ m{\A0+\Z}) { # not all zeroes
                	push(@news, $old . $dig2);
            	}
            } # foreach $dig2
            # if sqrt contains allowed digits
        } else {
	        if ($debug >= 2) {
    	        print "# sqrt($old) = $squold\n";
        	}
		}
    } # foreach @olds
    @olds = @news;
    @news = ();
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
C:\Users\User\work\gits\fasces\oeis\squaredig>perl a136860.pl
# digs1=01467, rest=23589
# sqrt(00) = 0 +
# sqrt(01) = 1 +
# sqrt(16) = 4 +
# sqrt(0100) = 10 +
# sqrt(1600) = 40 +
# sqrt(010000) = 100 +
# sqrt(160000) = 400 +
# sqrt(01000000) = 1000 +
# sqrt(01147041) = 1071 +
# sqrt(16000000) = 4000 +
# sqrt(60466176) = 7776 +
# sqrt(0100000000) = 10000 +
# sqrt(0114704100) = 10710 +
# sqrt(0116014441) = 10771 +
# sqrt(1600000000) = 40000 +
# sqrt(6046617600) = 77760 +
# sqrt(010000000000) = 100000 +
# sqrt(011400046441) = 106771 +
# sqrt(011401114176) = 106776 +
# sqrt(011470410000) = 107100 +
# sqrt(011601444100) = 107710 +
# sqrt(160000000000) = 400000 +
# sqrt(604661760000) = 777600 +
# sqrt(01000000000000) = 1000000 +
# sqrt(01014141646116) = 1007046 +
# sqrt(01140004644100) = 1067710 +
# sqrt(01140111417600) = 1067760 +
# sqrt(01147041000000) = 1071000 +
# sqrt(01160144410000) = 1077100 +
# sqrt(01161601106176) = 1077776 +
# sqrt(16000000000000) = 4000000 +
