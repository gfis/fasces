#!perl

# Which chains of long segments?
# @(#) $Id$
# 2019-08-14, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl long_chain.pl [-d debug] 
#       -d  debug level: 0 (none), 1 (some), 2 (more)
#--------------------------------------------------------
use strict;
use integer;
#----------------
# global constants
my $VERSION = "V1.0";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min);
my $MAX_RULE  = 64; # rule 7 has 4 mod 16, rule 11 has 16 mod 64
my @RULENS    = (0, 1, 7, 61, 547, 4921, 44287, 398581, 3587227, 32285041, 290565367, 2615088301); # OEIS A066443
#----------------
# get commandline options
my $debug  = 0;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my @ress = ();
my $ind;
my $max2 = 64;
my $max3 = 81;
my $high = $max2 * $max3 - 1;
foreach $ind (0..$high) {
    if (0) {
    } elsif ($ind %  4 ==  3) { $ress[$ind] = -1; # rule  5
    } elsif ($ind %  4 ==  1) { $ress[$ind] = -1; # rule  6
    } elsif ($ind %  8 ==  2) { $ress[$ind] = -1; # rule  9
    } elsif ($ind %  8 ==  6) { $ress[$ind] = 10; # rule 10
    } elsif ($ind % 16 == 12) { $ress[$ind] = -1; # rule 13
    } elsif ($ind % 16 ==  4) { $ress[$ind] = 14; # rule 14
    } elsif ($ind % 32 ==  8) { $ress[$ind] = -1; # rule 17
    } elsif ($ind % 32 == 24) { $ress[$ind] = 18; # rule 18
    } elsif ($ind % 64 == 48) { $ress[$ind] = 21; # rule 21
    } elsif ($ind % 64 == 16) { $ress[$ind] = 22; # rule 22
#   } elsif ($ind %128    32) { $ress[$ind] = 25; # rule 25
#   } elsif ($ind %128 == 96) { $ress[$ind] = 26; # rule 26
    } else                    { $ress[$ind] = 99; # rule > 21
    }
} # foreach
foreach $ind (0..$high) {
    if ($ress[$ind] > 0) {
        my $mod3 = 0;
        if (0) {
        } elsif ($ind % 81 == 61) { $mod3 = 81;
        } elsif ($ind % 27 ==  7) { $mod3 = 27;
        } elsif ($ind %  9 ==  7) { $mod3 = 9;
    #   } elsif ($ind %  3 ==  1) { $mod3 = 3;
        }
        if ($mod3 > 0) {
            print "$ind (rule $ress[$ind]) -> mod $mod3\n";
        }
    }
} # foreach
#---------------------------------------
__DATA__
my @mods = (4, 6, 14, 16, 20, 22, 24, 30); # mod 32
my @ress = ();
my $ind = 0; 
while ($ind < 9) {
    push(@ress, @mods);
    @mods = map { $_ + 32 } @mods;
    $ind ++;
} # while $ind
foreach my $res (@ress) {
    if ($res % 9 == 7) {
        print "$res, mod 27 = " . ($res % 27) . ", mod 64 = " . ($res % 64) . "\n";
    }
} # foreach


