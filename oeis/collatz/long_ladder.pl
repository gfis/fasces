#!perl

# Evaluate ladders of long segments
# @(#) $Id$
# 2019-09-19: -e
# 2019-08-14, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl long_ladder.pl [-d debug] [-n maxnum] [-r maxrule] [-e]
#       -d  debug level: 0 (none), 1 (some), 2 (more)
#       -e  only expanding rules (default: all)
#--------------------------------------------------------
use strict;
use integer;
#----------------
# global constants
my $VERSION = "V2.0";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min);
#----------------
# get commandline options
my $debug     = 0;
my $maxnum    = 16384;
my $maxrule   = 16;
my $expanding = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt =~ m{e}) {
        $expanding = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxnum    = shift(@ARGV);
    } elsif ($opt =~ m{r}) {
        $maxrule   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $ir;    #   0   1   2   3   4
my @srcmul = ( 3,  9,  9, 27, 27); # 81, 81, 243, 243
my @srcadd = ( 1,  9,  3, 15,  6); # 78, 24, 132, 51, 699, 213, 1185, 456, 6288, 1914
my @tarmul = ( 8,  8, 16, 16, 32); # 32, 64, 64, 128
my @taradd = ( 2,  8,  5,  9,  7); # 31, 19, 35, 27, 123, 75, 139, 107, 491, 299, 555, 427
# LinearRecurrence[{0,3},{3,9},20]
# LinearRecurrence[{1,0,0,9,-9},{1,9,3,15,6},20]
# LinearRecurrence[{0,2},{8,8},20]
# LinearRecurrence[{1,0,0,4,-4},{2,8,5,9,7,31},20]
$ir = 0;
for ($ir = scalar(@srcmul); $ir < $maxrule; $ir ++) { # lin.rec.
    $srcmul[$ir] =                    3 * $srcmul[$ir - 2];
    $srcadd[$ir] = $srcadd[$ir - 1] + 9 * $srcadd[$ir - 4] - 9 * $srcadd[$ir - 5];
    $tarmul[$ir] =                    2 * $tarmul[$ir - 2];
    $taradd[$ir] = $taradd[$ir - 1] + 4 * $taradd[$ir - 4] - 4 * $taradd[$ir - 5];
} # while reading rules
my @rules;
my @srcmod;
my @tarmod;
my $rind = 7;
print "Maps:\n";
for ($ir = 0; $ir < $maxrule; $ir ++) { # set dependant fields
    if ($ir % 2 == 0) {
        $rind += 2;
    }
    $rules[$ir]  = "r$rind";
    $rind ++;
    $srcmod[$ir] = $srcadd[$ir] % $srcmul[$ir];
    $tarmod[$ir] = $taradd[$ir] % $tarmul[$ir];
    if ($debug >= 0) {
            if ($expanding == 0 or ($ir != 0 and $ir != 2 and $ir != 4)) {
                print sprintf("%4s: %6d*k + %6d -> %6d*k + %4d\n", $rules[$ir]
                    , $srcmul[$ir], $srcadd[$ir]
                    , $tarmul[$ir], $taradd[$ir]
                #   , $srcmod[$ir], $tarmod[$ir] 
                    );
            }
    } # debug
} # for ir set dependant
print "\n";
# exit;
#----
print "Chains:\n";
for (my $n = 1; $n <= $maxnum; $n ++) {
    my $nchain = $n;
    my @chain = ();
    my $src;
    my $tar;
    my $ksrc;
    my $ktar;
    my $busy = 1;
    while ($busy == 1) { # as long as chaining is possible
        $busy = 0; # assume no successor
        $ir = 0; # skip rule 9 - start with rule 10 
        while ($ir < $maxrule) { # search for applicable rule
            if ($expanding == 0 or ($ir != 0 and $ir != 2 and $ir != 4)) {
                # 10, rule 9: 3*k + 1 -> 8*k + 2
                if ($nchain % $srcmul[$ir] == $srcmod[$ir]) 
                { # rule is applicable
                    $ksrc = $nchain / $srcmul[$ir]; # 10 / 3 = 3
                    # $ktar = $nchain / $tarmul[$ir]; # 10 / 8 = 1
                    # $src  = $srcmul[$ir] * $ktar + $srcmod[$ir];
                    $tar  = $tarmul[$ir] * $ksrc + $tarmod[$ir];
                    if (scalar(@chain) == 0) {
                        push(@chain, &nodetext($nchain));
                    }
                    push(@chain, &ruletext($ir, $ksrc), &nodetext($tar));
                    if ($debug >= 2) {
                        print "$nchain: applicable $rules[$ir]: ksrc=$ksrc, ktar=$ktar, src=$src, tar=$tar\n";
                    }
                    $busy = 1; # there is a successor - continue
                    $nchain = $tar;
                    $ir = $maxrule; # break while rule
                } # rule is applicable
                if ($debug >= 2) {
                    print "$nchain: rule[$ir]=$rules[$ir], ksrc=$ksrc, ktar=$ktar, src=$src, tar=$tar\n";
                }
            } # if expanding ...
            $ir ++;
        } # while $ir
    } # while busy
    if (scalar(@chain) > 3) {
        # push(@chain, $tar);
        print join("", @chain) . "\n";
    }
} # for $n
#----
sub ruletext {
    my ($ir, $k) = @_;
    # return "\t($rules[$ir],k$k)\t";
    return "-($rules[$ir])>";
}
#----
sub nodetext {
    my ($node) = @_;
    return "$node"; #. ($node*6 -2);
}
#---------------------------------------
__DATA__
# R9  3   1   8   2
R10 9   9   8   8
R13 9   3   16  5
R14 27  15  16  9
R17 27  6   32  7
R18 81  78  32  31
R21 81  24  64  19
R22 243 132 64  35
R25 243 51  128 27
R26 729 699 128 123
R29 729 213 256 75
R30 2187    1185    256 139
