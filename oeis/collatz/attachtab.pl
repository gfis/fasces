#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/attachtab.pl
# Generate and check attachment table
# @(#) $Id$
# 2018-11-19, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl attachtab.pl [-n maxn] [-d debug]
#-----------------------------------------------
# get commandline options
my $debug  = 0;
my $maxn   = 4; # max. value for k
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#---------------
while (<DATA>) {
    s/\s+\Z//; # chompr
    s/\A\s+//; # trim leading whitespace
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\A\#\Z}) { 
    	print "#---------------------------------------------\n";
    } elsif ($line =~ m{\#}) { # ignore comment
    	print "$line\n";
    } else { # statement line
	    print "$line\t|| ";
        $line =~ s{\A(\w+)\s*\=\s*}{}; # remove "S = "
        $line =~ s{k}{\$k}g;
        for my $k (0..$maxn) {
            print " " . (eval $line); # errors in $@
        } # for $k
	    print "\n";
    } # statement line
} # while DATA
__DATA__
# k = 0,1,2,3 ... old rule - new rule
#
# R2    16,40,64,88        =>  4,10,16,22
# r2
s = 6*(1*(4*k + 3)) - 2
t = 6*(1*(k           ) -2
#  0 mod 8, 2 / 4 6 mod 8
#
# R3    4,28,52,76         =>  4,22,40,58    R6
# r3
s = 6*(1*(4*k + 1)) - 2
t = 3*6*k+4
t = 6*(1*(3*k + 1)     ) - 2
t = 1*(6*(3*k + 1)     ) - 2
#  4 mod 8, 2 6 / 10 14 mod 16
#
# R4    10,58,106,154      =>  4,22,40,58    R9
# r4
s = 6*(2*(4*k + 1)) - 2
t = 6*(1*(3*k + 1)    ) - 2
t = 1*(6*(3*k + 1)    ) - 2
#  10 mod 16, 2 6 / 14 mod 16
#
# R5    34,82,130,178      =>  40,94,148,202 R10
# r5
s = 6*(2*(4*k + 3)) - 2
t = 6*(3*(3*k + 2) - 2) - 2
t = 6*(9*k + 7) - 2
t = 3*(6*(3*k + 1) - 8) - 2
#  2 mod 16, 6 14 / 22 30 mod 32
#
# R6    70,166,262,358     =>  40,94,148,202 R13
# r7
s = 6*(4*(4*k + 3)) - 2
t = 6*(3*(3*k + 3) - 2) - 2
#  6 mod 32, 14 / 22 30 mod 32
#
# R7    22,118,214,310     =>  40,202,364,526 R14
# r7
s = 6*(4*(4*k + 1)) - 2
t = 6*(9*(3*k + 1) - 2) - 2
#  22 mod 32, 14 30 / 46 62 mod 64
#
# R8    46,238,430,622    =>  40,202,364,526  R17
# r8    8,40,72,104             7,34,61,88
s = 6*(8*(4*k + 1)) - 2
t = 6*(9*(3*k + 1) - 2) - 2
#  46 mod 64, 14 30 / 62 mod 64
#
# R9    142,334,526,718    =>  364,850,1336,1822 R18
# r9    24,56,88,120        61,142,223,304
s = 6*(8*(4*k + 3)) - 2
t = 6*27*k+40
t = 6*(27*(3*k + 1) - 2) - 2
#  14 mod 64, 30 62 / 94 126 mod 128
#
# R10   286,670,1054,1438 =>  364,850,1336,1822 R21
# r10   48,112,176,240            61,142,223,304
s = 6*(16*(4*k + 3)) - 2
t = 6*27*k+40
t = 6*(27*(3*k + 1) - 2) - 2
#  30 mod 128, 62 / 94 126 mod 128
#
# R11   94,478,862,1246 =>  364,1822,3280,4738  R22
# r11   80,144,208            61,304,547,790
s = 6*(16*(4*k + 3)) - 2
t = 6*27*k+40
t = 6*(27*(3*k + 1) - 2) - 2
#  94 mod 128,  62 126 / 190 254 mod 256
