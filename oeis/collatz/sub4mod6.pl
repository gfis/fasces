#!perl

# Extract the subset from column r5: all numbers = 4 mod 6
# @(#) $Id$
# 2018-08-25, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl collatz_roads.pl [-n maxn] -m tsv > roads.txt
#   perl sub4mod6.pl roads.txt > output
#
# If divided by 6, the output sequences are alternating:
# 26    8    17    5    11    3     7
#    -2/3  *2+1 -2/3  '2+1 -2/3  *2+1
#--------------------------------------------------------
use strict;
use integer;
#----------------
# get commandline options
my $debug  = 0;
my $maxn   = 512; # max. start value
my $action = "simple";
my $mode   = "html";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $mode   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
# initialization
my @road46;
#----------------
# perform one of the possible actions
if (0) { # switch action

} elsif ($action =~ m{simple}) { # straightforward incrementing of the start values
    my $count = 0;
    while (<>) {
        s{\s+\Z}{}; # chmpr
        @road46 = split(/\t/, $_);
        if (scalar(@road46) >= 8) { # 10 would take the "unusual" only
            my @road = map {
                    ($_ + 2) / 6
                } grep {
                $_ % 6 == 4
                } splice(@road46, 5);
            print join("\t", ($road46[0] + 2)/6, scalar(@road), @road) . "\n";
        } else {
            print "$count\n";
        }
        $count ++;
    } # while $ffroad

} elsif ($action =~ m{contig}) { # identify contiguous blocks of start values

} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
# output the resulting array
#----------------
# termination
# end main
#================================
#================================
__DATA__
4   5   1   8   2   16  4   5   1   10  2   3
10  3   3   20  6   40  12  13
16  3   5   32  10  64  20  21
22  4   7   44  14  88  28  29  9   58
28  3   9   56  18  112 36  37
34  3   11  68  22  136 44  45
40  9   13  80  26  160 52  53  17  106 34  35  11  70  22  23  7   46  14  15
46  3   15  92  30  184 60  61
52  3   17  104 34  208 68  69
58  5   19  116 38  232 76  77  25  154 50  51
64  3   21  128 42  256 84  85
70  3   23  140 46  280 92  93
76  4   25  152 50  304 100 101 33  202
82  3   27  164 54  328 108 109

Output:
2   0   1
6
10
14  4   9
18
22
26  8   17  5   11  3   7
30
34
38  12  25
42
46
50  16  33
54
58
62  20  41  13  27
66
70
74  24  49
78
82
86  28  57
90
94
98  32  65  21  43
102
106
110 36  73
114
118
122 40  81
126
130
134 44  89  29  59  19  39
138
142
146 48  97
150
154
158 52  105
162
166
170 56  113 37  75
174
178
182 60  121
186
190
194 64  129
198
202
206 68  137 45  91
210
214
218 72  145
222
226
230 76  153
234
238
242 80  161 53  107 35  71  23  47  15  31
