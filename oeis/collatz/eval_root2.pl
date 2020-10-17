#!perl

# Evaluate the output of segment.pl -r 2 -m tsv
# 2020-10-17, Georg Fischer
#
use strict;
use integer;
use warnings;

my @starts = (); # which starting values have already been seen
my @strows = (); # rows of the starting positions, 1-based
while (<>) {
    next if ! m{\A\d};
    s/\s+\Z//; # chompr
    my @row = split(/\t/, $_);
    splice(@row, 1, 3);
    for (my $icol = 1; $icol < scalar(@row); $icol ++) {
        if (($row[$icol] + 2) % 6 == 0) {
            my $root1 = ($row[$icol] + 2) / 6;
            if  (($root1 + 2) % 6 == 0) {
                my $root2 = ($root1 + 2) / 6;
                if (! defined($starts[$icol])) {
                    $starts[$icol] = $root2;
                    $strows[$icol] = ($row[0] - 1) / 3 + 1;
                    print sprintf("col %2d: %d -> %d\n", $icol, $strows[$icol], $starts[$icol]);
                }
            }
        }
    } # for $icol
} # while <>
shift(@strows);
shift(@starts);
print "# " . join(", ", map { $_ or "" } @strows) . "\n";
print "# " . join(", ", map { $_ or "" } @starts) . "\n";
#================================
__DATA__
# Col.  1   2   3   4   5   6   7   8   9   10  11
1   4   16  4   10

# 0             1   2   3   4   5
4   22  88  28  58
7   40  160 52  106 34  70  22  46
10  58  232 76  154
13  76  304 100 202
16  94  376 124 250 82  166
19  112 448 148 298
22  130 520 172 346
25  148 592 196 394 130 262
28  166 664 220 442
31  184 736 244 490
34  202 808 268 538 178 358 118 238
37  220 880 292 586
40  238 952 316 634
43  256 1024    340 682 226 454
46  274 1096    364 730
49  292 1168    388 778
52  310 1240    412 826 274 550
55  328 1312    436 874
58  346 1384    460 922
61  364 1456    484 970 322 646 214 430 142 286 94  190

make root2 M=tsv # N=
perl segment.pl -r 2  -n 1000000 -m tsv  -d 0 -s 1  -i 3      -a comp   > root2.tsv
perl eval_root2.pl root2.tsv | sort | tee eval_root2.tmp
# 2, 4, 5, 1, 7, 15, 19, 3, 27, 59, 75, 11, 107, 235, 299, 43, 427, 939, 1195, 171, 1707, , 4779, 683
# 2, 9, 6, 3, 12, 75, 48, 21, 102, 669, 426, 183, 912, 6015, 3828, 1641, 8202, 54129, 34446, 14763, 73812, , 310008, 132861
col  1: 2 -> 2
col  2: 9 -> 4
col  3: 6 -> 5
col  4: 3 -> 1
col  5: 12 -> 7
col  6: 75 -> 15
col  7: 48 -> 19
col  8: 21 -> 3
col  9: 102 -> 27
col 10: 669 -> 59
col 11: 426 -> 75
col 12: 183 -> 11
col 13: 912 -> 107
col 14: 6015 -> 235
col 15: 3828 -> 299
col 16: 1641 -> 43
col 17: 8202 -> 427
col 18: 54129 -> 939
col 19: 34446 -> 1195
col 20: 14763 -> 171
col 21: 73812 -> 1707
col 23: 310008 -> 4779
col 24: 132861 -> 683

In[2]:= s={2, 4, 5, 1, 7, 15, 19, 3, 27, 59, 75, 11, 107, 235, 299, 43, 427, 939, 1195, 171, 1707}
In[3]:= FindLinearRecurrence[s]
Out[3]= {1, 0, 0, 4, -4}
In[5]:= FindGeneratingFunction[s,x]
Out[5]= (2 + 2*x + x^2 - 4*x^3 - 2*x^4)/(1 - x - 4*x^4 + 4*x^5)
In[6]:= FullSimplify[Out[5]]
Out[6]= (2 - x*(2 + x)*(-1 + 2*x^2))/(1 - x + 4*(-1 + x)*x^4)

In[7]:= s={2, 9, 6, 3, 12, 75, 48, 21, 102, 669, 426, 183, 912, 6015, 3828, 1641, 8202, 54129, 34446, 14763, 73812}
In[8]:= FindLinearRecurrence[s]
Out[8]= {1, 0, 0, 9, -9}
In[9]:= FindGeneratingFunction[s,x]
Out[9]= (2 + 7*x - 3*x^2 - 3*x^3 - 9*x^4)/(1 - x - 9*x^4 + 9*x^5)
In[10]:= FullSimplify[Out[9]]
Out[10]= (2 + 7*x - 3*x^2*(1 + x + 3*x^2))/(1 - x + 9*(-1 + x)*x^4)
