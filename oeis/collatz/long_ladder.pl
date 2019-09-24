#!perl

# Evaluate ladders of long segments
# @(#) $Id$
# 2019-09-10: suffix "*" (divisible) or "#" (indivisible) by 3
# 2019-08-19: -e
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
my $VERSION = "V2.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min);
#----------------
# get commandline options
my $debug     = 0;
my $maxnum    = 65536;
my $maxrule   = 16;
my $expanding = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt =~ m{e}) {
        $expanding = 1;
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

if ($debug >= 1) {
    print "Maps:\n";
}
for ($ir = 0; $ir < $maxrule; $ir ++) { # set dependant fields
    if ($ir % 2 == 0) {
        $rind += 2;
    }
    $rules[$ir]  = "r$rind";
    $rind ++;
    $srcmod[$ir] = $srcadd[$ir] % $srcmul[$ir];
    $tarmod[$ir] = $taradd[$ir] % $tarmul[$ir];
    if ($debug >= 1) {
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
if ($debug >= 1) {
    print "Chains:\n";
}
my $n = 1; 
my $src;
my $tar;
my $ksrc;
my $ktar;
while ($n <= $maxnum) {
    my $nchain = $n;
    my @chain = ();
    my $busy = 1;
    while ($busy == 1) { # as long as chaining is possible
        $busy = 0; # assume no successor
        $ir = 0; # skip rule 9 - start with rule 10
        while ($ir < $maxrule) { # search for applicable rule
            if ($expanding == 0 or ($ir != 0 and $ir != 2 and $ir != 4)) {
                # 10, rule 9: 3*k + 1 -> 8*k + 2
            #   if ($nchain % $srcmul[$ir] == $srcmod[$ir]) { # rule is applicable
                if ($nchain % $tarmul[$ir] == $tarmod[$ir]) { # rule is applicable
                    # $ksrc = $nchain / $srcmul[$ir]; # 10 / 3 = 3
                    $ktar = $nchain / $tarmul[$ir]; # 10 / 8 = 1
                    $src  = $srcmul[$ir] * $ktar + $srcmod[$ir];
                    # $tar  = $tarmul[$ir] * $ksrc + $tarmod[$ir];
                    if (scalar(@chain) == 0) {
                        push(@chain, &nodetext($nchain));
                    }
                    # push(@chain, &ruletext($ir, $ksrc), &nodetext($tar));
                    push(@chain, &ruletext($ir, $ktar), &nodetext($src));
                    $busy = 1; # there is a successor - continue
                    # $nchain = $tar;
                    $nchain = $src;
                    $ir = $maxrule; # break while rule
                } # rule is applicable
            } # if expanding ...
            $ir ++;
        } # while $ir
    } # while busy
    if (scalar(@chain) > 3) {
        # print join("", reverse @chain) . "\n";
        print join("\t", scalar(@chain), @chain) . "\n";
    }
    $n ++;
} # while $n
#----
sub ruletext {
    my ($ir, $k) = @_;
    return "($rules[$ir],k$k)";
    # return "($rules[$ir])";
}
#----
sub nodetext {
    my ($node) = @_;
    my $suffix = $node % 3 == 0 ? "*" : "";
    return "$node$suffix"; #. ($node*6 -2);
}
#---------------------------------------
__DATA__
Maps:
 r10:      9*k +      9 ->      8*k +    8
 r14:     27*k +     15 ->     16*k +    9
 r18:     81*k +     78 ->     32*k +   31
 r21:     81*k +     24 ->     64*k +   19
 r22:    243*k +    132 ->     64*k +   35
 r25:    243*k +     51 ->    128*k +   27
 r26:    729*k +    699 ->    128*k +  123
 r29:    729*k +    213 ->    256*k +   75
 r30:   2187*k +   1185 ->    256*k +  139
 r33:   2187*k +    456 ->    512*k +  107
 r34:   6561*k +   6288 ->    512*k +  491
 r37:   6561*k +   1914 ->   1024*k +  299
 r38:  19683*k +  10662 ->   1024*k +  555

Chains:
15*-(r14)>9*-(r10)>8#
27*-(r10)>24*-(r21)>19#
51*-(r25)>27*-(r10)>24*-(r21)>19#
81*-(r10)>72*-(r10)>64#
108*-(r10)>96*-(r14)>57*
159*-(r18)>63*-(r10)>56#
162*-(r10)>144*-(r10)>128#
177*-(r14)>105*-(r21)>83#
243*-(r10)>216*-(r10)>192*
258*-(r14)>153*-(r10)>136#
270*-(r10)>240*-(r18)>95#
324*-(r10)>288*-(r10)>256#
351*-(r10)>312*-(r14)>185#
375*-(r22)>99*-(r10)>88#
402*-(r18)>159*-(r18)>63*-(r10)>56#
405*-(r10)>360*-(r10)>320#
429*-(r21)>339*-(r14)>201*
486*-(r10)>432*-(r10)>384*
501*-(r14)>297*-(r10)>264*