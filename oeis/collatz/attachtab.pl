#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/attachtab.pl
# Generate and check attachment table
# @(#) $Id$
# 2019-08-09: -c for compressed; V.S.W.F. = 38
# 2018-11-27: comment "Generated at ..." before
# 2018-11-19, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl attachtab.pl [-n maxn] [-c] [-d debug]
#-----------------------------------------------
use strict;
use integer;
#----------------
# global constants
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get commandline options
my $debug  = 0;
my $maxn   = 4; # max. value for k
my $compr  = 0; # 1 = compressed 
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{c}) {
        $compr  = 1;
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#---------------
print <<"GFis"; # table header
<!--Generated with
<a href="https://github.com/gfis/fasces/blob/master/oeis/collatz/attachtab.pl" target="_blank">segment.pl</a>
at $TIMESTAMP;--> 
{| class="wikitable" style="text-align:left"
|-
GFis
if ($compr == 0) {
print <<"GFis"; 
!Rule /<br>column!!Source<br>segments||Condition /<br>remaining!!First source<br>segments!!Target<br>segments!!First target<br>segments!!Dir.
|-
GFis
} else {
print <<"GFis"; 
!Rule /<br>column!!Source<br>segments                          !!First source<br>segments!!Target<br>segments!!First target<br>segments!!Dir.
|-
GFis
}
my ($rule, $cond, $remain, $ssegments, $fssegments, $tsegments, $ftsegments, $dir, $st);
while (<DATA>) {
    s/\s+\Z//; # chompr
    s/\A\s+//; # trim leading whitespace
    my $line = $_;
    if (0) {
    #----
    } elsif ($line =~ m{\A\#\Z}) {
        print STDERR "#---------------------------------------------\n";
        $dir = "'''\&gt;'''";
        $fssegments =~ m{(\d+)};
        my $fsn1 = $1;
        $ftsegments =~ m{(\d+)};
        my $ftn1 = $1;
        if ($fsn1 >= $ftn1) {
            $dir = "\&lt;";
        }
        if ($compr == 0) {
            print <<"GFis";
|'''$rule'''||$ssegments||$cond<br>$remain||$fssegments||$tsegments||$ftsegments||$dir
|-
GFis
        } else {
            $ssegments =~ s{\A6\*?\(}{};
            $ssegments =~ s{\)\s*\-\s*2\s*\Z}{};
            $tsegments =~ s{\A6\*?\(}{};
            $tsegments =~ s{\)\s*\-\s*2\s*\Z}{};
            $fssegments = join(", ", map { ($_ + 2) / 6 } split(/\,\s*/, $fssegments));
            $ftsegments = join(", ", map { ($_ + 2) / 6 } split(/\,\s*/, $ftsegments));
            print <<"GFis";
|'''$rule'''||$ssegments                  ||$fssegments||$tsegments||$ftsegments||$dir
|-
GFis
        }
    #----
    } elsif ($line =~ m{\A\#R(\d+)}) {
        $rule = $1;
        print STDERR "$line\n";
    } elsif ($line =~ m{mod}) {
        print STDERR "$line\n";
        ($cond, $remain) = map { 
            # s/ mod / \&\#x2261\; /; 
            s{\A\s+}{};
            $_ 
            } split(/\;\s+/, substr($line, 1)); 
    #----
    } elsif ($line =~ m{\#}) { # ignore other comments
        print STDERR "$line\n";
    #----
    } else { # statement line
        print STDERR sprintf("#! %-40s || ", $line);
        $line =~ s{\A(\w+)\s*\=\s*}{}; # remove "S = "
        $st = $1;
        my $expr = $line;
        $expr =~ s{\*\*(\d+)}{<sup>\1<\/sup>}g;
        # $expr =~ s{\*}{}g;
        $line =~ s{k}{\$k}g;
        my $first = "";
        for my $k (0..$maxn - 1) {
            $first .= ", " . (eval $line); # errors in $@
        } # for $k
        print STDERR "#$first";
        if ($st eq "s") {
            $ssegments = $expr;
            $fssegments = substr($first, 2);
        } else { # eq "t"
            $tsegments = $expr;
            $ftsegments = substr($first, 2);
        }
        print STDERR "\n";
    } # statement line
    #----
} # while DATA
if ($compr == 0) {
print <<"GFis"; # table trailer
|...||...||...||...||...||...||... 
|-
|}
GFis
} else {
print <<"GFis"; # table trailer
|...||...||...||...||...||...
|-
|}
GFis
}
# |-                                                                                      
# |Rj ||6(2<sup>4</sup>(4k + 1)) - 2||...||...mod 2<sup>k+1</sup><br>...||...||6(3<sup>l</sup>k + m) - 2||...|| &gt; 

__DATA__
# Attachment table for k = 0,1,2,3; Rnew, rold
#R5    16,40,64,88        =>  4,10,16,22
# r2
s = 6*(2**0*(4*k + 3)) - 2
t = 6*(3**0*k + 1   ) - 2
#t = 6*(1*(k + 1      )) -2
#  0 mod 8; 2, 4, 6 mod 8
#
#R6   4,28,52,76         =>  4,22,40,58
# r3
s = 6*(2**0*(4*k + 1)) - 2
t = 6*(3**1*k    + 1) - 2
#t = 6*(1*(3*k + 1)     ) - 2
#  4 mod 8; 2, 6, 10, 14 mod 16
#
#R9  10,58,106,154      =>  4,22,40,58
# r4
s = 6*(2**1*(4*k + 1)) - 2
t = 6*(3**1*k    + 1) - 2
#t = 6*(1*(3*k + 1)    ) - 2
#  10 mod 16; 2, 6, 14 mod 16
#
#R10    34,82,130,178      =>  40,94,148,202
# r5
s = 6*(2**1*(4*k + 3)) - 2
t = 6*(3**2*k    + 7) - 2
#t = 6*(3*(3*k + 3) - 2) - 2
#  2 mod 16; 6, 14, 22, 30 mod 32
#
#R13    70,166,262,358     =>  40,94,148,202
# r6
s = 6*(2**2*(4*k + 3)) - 2
t = 6*(3**2*k    + 7) - 2
#t = 6*(3*(3*k + 3) - 2) - 2
#  6 mod 32; 14, 22, 30 mod 32
#
#R14    22,118,214,310     =>  40,202,364,526
# r7
s = 6*(2**2*(4*k + 1)) - 2
t = 6*(3**3*k    + 7) - 2
#t = 6*(9*(3*k + 1) - 2) - 2
#  22 mod 32; 14, 30, 46, 62 mod 64
#
#R17    46,238,430,622    =>  40,202,364,526
# r8    8,40,72,104             7,34,61,88
s = 6*(2**3*(4*k + 1)) - 2
t = 6*(3**3*k    + 7) - 2
#t = 6*(9*(3*k + 1) - 2) - 2
#  46 mod 64; 14, 30, 62 mod 64
#
#R18    142,334,526,718    =>  364,850,1336,1822
# r9    24,56,88,120        61,142,223,304
s = 6*(2**3*(4*k + 3)) - 2
t = 6*(3**4*k   + 61) - 2
#t = 6*(9*(3*(3*k+3) - 2) - 2) - 2
#  14 mod 64; 30, 62, 94, 126 mod 128
#
#R21    286,670,1054,1438 =>  364,850,1336,1822
# r10   48,112,176,240            61,142,223,304
s = 6*(2**4*(4*k + 3)) - 2
t = 6*(3**4*k   + 61) - 2
#t = 6*(9*(3*(3*k+3) - 2) - 2) - 2
#  30 mod 128; 62, 94, 126 mod 128
#
#R22    94,478,862,1246 =>  364,1822,3280,4738
# r11   80,144,208            61,304,547,790
s = 6*(2**4*(4*k + 1)) - 2
t = 6*(3**5*k   + 61) - 2
#  94 mod 128;  62, 126, 190, 254 mod 256
#
