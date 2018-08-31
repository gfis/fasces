#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/collatz_rails.pl
# Print a directory of railways in the Collatz graph
# @(#) $Id$
# 2018-08-30, Georg Fischer: derived from collatz_roads.pl
#
# The algorithm is the same as in collatz_roads.pl,
# only the layout of the output is changed.
#------------------------------------------------------
# Usage:
#   perl collatz_rails.pl [-n maxn] [-d debug] > rails.html
#
# Construction of rails:
# A "rail" is a sequence of pairs
# of elements (in 2 adjacent Collatz sequences, read from right to left).
# A rail is built by taking some n (the last common element of the
# 2 sequences) with n &#x2261; -2 mod 6, and by applying the steps
# d m m d m d m d ...
# m m d m d m d m ...
# in alternating sequence, until one of the elements in the pairs
# becomes divisible by 3.
#
# An "m"-step multiplies n by 2.
# A "d"-step transforms an n &#x2261; 1 mod 3 to (n - 1) / 3.
# Both steps move away from the root of a Collatz graph.
#
# Example of a rail in A070165 (to be read from right to left, starting at "|"):
# 142/104: [142 m  71 d 214 m 107 d 322 m 161 d 484 m  242 m 121 d | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
#            +1  *6+4    +1  *6+4    +1  *6+4    +1   *6+4  *6+2     =     =   ...
# 143/104: [143 d 430 m 215 d 646 m 323 d 970 m 485 d 1456 m 728 m | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
# 
# continuation:
# 124 m 62 m  31 d 94 m  47 d 142 m
#  +2   +1  *6+4    +1 *6+4    +1
# 126 m 63 d 190 m 95 d 286 m 143 d
#        ^--- divisible by 3
#--------------------------------------------------------
use strict;
use integer;
#----------------
# get commandline options
my $sep    = "\t";
my $debug  = 0;
my $maxn   = 512; # max. start value
my $start4 = 4;
my $incr6  = 6;
my $start  = $start4;
my $incr   = $incr6;
my $action = "simple";
my $mode   = "html";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{i}) {
        $incr   = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $mode   = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } elsif ($opt =~ m{s}) {
        $start  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
# initialization
&print_html_head();
my $ffrail  = 0;
my @rails;
while ($ffrail < $start4) { # $rails[0..3] are not used
    push(@rails, $ffrail);
    $ffrail ++;
} # while not used
my @nums   = @rails; # defined if the number was visited
$ffrail    = scalar(@rails); # (is asserted)
my @queue;
my $index = 0;
#----------------
# perform one of the possible actions
if (0) { # switch action

} elsif ($action =~ m{simple}) { # straightforward incrementing of the start values
    while ($ffrail < $maxn) {
        @rails[$ffrail] = &build_rail($ffrail);
        $ffrail += $incr6;
    } # while $ffrail

} elsif ($action =~ m{contig}) { # identify contiguous blocks of start values
    @queue = ($ffrail);
    while (scalar(@queue) > 0) {
        my $selem = &dequeue();
        $index ++;
        if (! defined($rails[$selem])) {
            @rails[$selem] = &build_rail($selem);
        }
        my $oldff = $ffrail;
        while (defined($rails[$ffrail])) { # try to increase
            $ffrail += $incr6;
        } # try to increase
        if ($ffrail > $oldff) {
            if ($mode =~ m{html}) {
                print "<!--stopped at $ffrail-->\n";
            }
        }
    } # while $selem

} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
# output the resulting array
&print_table_head();
my $irail = $start;
while ($irail < $maxn) {
	if (! defined($rails[$irail])) {
		$irail = $maxn; # break loop
	} else {
    	&print_rail($irail);
    }
    $irail += $incr;
} # while $irail
&print_table_tail();
#----------------
# termination
if (0) {
} elsif ($mode =~ m{html}) {
   &print_html_tail();
} elsif ($mode =~ m{tsv} ) {
}
# end main
#================================
sub build_rail { # build and return a single rail starting with $selem
    my ($selem) = @_;
    my @elem    = ($selem, $selem);
            # 2 parallel lanes: $elem[0] (upper, left), $elem[1] (lower, right)
    my $len     = 0;
    my @result  = (($selem + 2) / 6, $selem); # (n, 6*n-2)
    my $state   = "step0";
    my $busy    = 1; # as long as we can still do another step
    while ($busy == 1) { # stepping
        if (0) {
        } elsif ($state eq "step0") {
            $elem[0] = ($elem[0] - 1) / 3; # possible because of preparation above
            $elem[1] = $elem[1] * 2;
            $state = "step1";
        } elsif ($state eq "step1") {
            $elem[0] = $elem[0] * 2; # mm, always possible
            $elem[1] = $elem[1] * 2;
            $state = "md"; # enter the alternating sequence of steps: md, dm, md, dm ...
        } elsif ($state eq "md") {
            if (         ($elem[1] - 1) % 3 == 0) {
                $elem[1] = ($elem[1] - 1) / 3;
                $elem[0] =  $elem[0] * 2;
                $state = "dm";
                if ($elem[0] % 3 == 0 or $elem[1] % 3 == 0) {
                    $busy  = 0;
                }
            } else { # should never happen
                $busy  = 0;
                $state = " 1assert3";
            }
        } elsif ($state eq "dm") {
            if (         ($elem[0] - 1) % 3 == 0) {
                $elem[0] = ($elem[0] - 1) / 3;
                $elem[1] =  $elem[1] * 2;
                $state = "md";
                if ($elem[0] % 3 == 0 or $elem[1] % 3 == 0) {
                    $busy  = 0;
                }
            } else { # should never happen
                $state = " 0assert3";
                $busy  = 0;
            }
        } else {
            die "invalid state \"$state\"\n";
        }
        if ($elem[0] % $incr6 == $start4) {
            if (! defined($rails[$elem[0]])) {
                &enqueue(        $elem[0]);
            }
        }
        if ($elem[1] % $incr6 == $start4) {
            if (! defined($rails[$elem[1]])) {
                &enqueue(        $elem[1]);
            }
        }
        push(@result, $elem[0], $elem[1]);
        $len ++;
    } # while busy stepping
    if ($debug >= 1) {
        print "<!--build_rail: " . join(";", @result) . "-->\n";
    }
    return join($sep, @result);
} # build_rail
#----------------
sub dequeue { # return lowest queue element
    @queue = sort {$a <=> $b} @queue;
    my $elem = shift(@queue);
    return $elem;
} # dequeue
#----------------
sub get_kernel { # for n6-2, return the 2-3-free factor of n
    my ($parm) = @_;
    my $result = 0;
    if ($parm % $incr6 == $start4) {
        my $num = $parm / $incr6 + 1; # we had 6*(n-1) + 4
        my $log3 = 0;
        while ($num % 3 == 0 and $num > 0) {
            $log3 ++;
            $num /= 3;
        } # while 3
        my $log2 = 0;
        while ($num % 2 == 0 and $num > 0) {
            $log2 ++;
            $num /= 2;
        } # while 2
        $result = "$log3.$log2.$num";
    }
    return $result;
} # get_kernel
#----------------
sub enqueue { # queue the parameter
    my ($elem) = @_;
    if ($elem < $maxn) {
        push(@queue, $elem);
    }
} # enqueue
#----------------
sub print_rail {
    my ($index) = @_;
    if (! defined($rails[$index])) {
        $index = ($index + 2) / 6;
        if (0) {
        } elsif ($mode =~ m{html}) {
            print "<tr><td class=\"arc\">$index</td></tr>\n";
        } elsif ($mode =~ m{tsv} ) {
            print "$index\n";
        } # mode
    } else {
        my @rail  = split(/$sep/, $rails[$index]);
        if ($debug >= 2) {
            print "<!--print_rail: " . join(";", @rail) . "-->\n";
        }
        my $ir;
        if (0) {
        } elsif ($mode =~ m{html}) {
            # print the upper path
            print "<tr>"
                . "<td class=\"arc    \">$rail[0]</td>"
                . &cell_html(            $rail[1], " bor");
            $ir = 3;
            while ($ir < scalar(@rail)) {
                print &cell_html($rail[$ir], " btr");
                $ir += 2;
            } # while $ir
            print "</tr>\n";

            print "<tr>"
                . "<td class=\"arl\">\&nbsp;</td>"
                . "<td class=\"arr ker\">"
                . $rail[1] # &get_kernel($rail[1]) 
                . "\&gt;"
                . &get_kernel($rail[5])
                . "," . (scalar(@rail) / 2 - 4)
                . "</td>";
            $ir = 2;
            while ($ir < scalar(@rail)) {
                print &cell_html($rail[$ir], " bbr");
                $ir += 2;
            } # while $ir
            print "</tr>\n";
        } elsif ($mode =~ m{tsv} ) {
            print join($sep, @rail) . "\n";
        } # mode
    } # if defined
} # print_rail
#----------------
sub cell_html { # print one table cell
    my ($elem, $border) = @_;
    my $rest = $elem % 6;
    my $result = "<td";
    if ($rest == 4) {
        $result .= " title=\"" . &get_kernel($elem) . "\"";
    }
    return $result . " class=\"d$rest$border\">$elem</td>";
} # cell_html
#----------------
sub print_html_head {
    return if $mode ne "html";
    print <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>3x+1 railway directory</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/collatz/collatz_rails.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th
        { text-align: right; }
.arr    { background-color: white          ; color: black; }
.arc    { background-color: white          ; color: black; text-align: center;      }
.arl    { background-color: white          ; color: black; text-align: left;        }
.ker    { font-style   : italic            }
.bor    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ;
          border-right : 1px solid gray    ; border-bottom: 1px solid gray ; }
.btr    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ;
          border-right : 1px solid gray    ; }
.bbr    { border-left  : 1px solid gray    ; 
          border-right : 1px solid gray    ; border-bottom: 1px solid gray ; }
.d0     { background-color: lemonchiffon   ; color: black;                   }
.d1     { background-color: lavender       ; color: black;                   }
.d2     { background-color: beige          ; color: black;                   }
.d3     { background-color: lemonchiffon   ; color: gray;                    }
.d4     { background-color: papayawhip     ; color: black;                   font-weight: bold; }
.d5     { background-color: lavender       ; color: gray;                    }
</style>
</head>
<body>
<h3>3x+1 railway directory</h3>
GFis
} # print_html_head
#----------------
sub print_table_head {
    return if $mode ne "html";
    print <<"GFis";
<p>
with numbers &#x2261; 
<span class="d0">0</span>, <span class="d1">1</span>,
<span class="d2">2</span>, <span class="d3">3</span>,
<span class="d4">4</span>, <span class="d5">5</span> mod 6
<br />
</p>
<table>
<tr>
<td class="arc"> </td>
<td class="arc">1</td>
<td class="arc">2</td>
<td class="arc">3</td>
<td class="arc">4</td>
<td class="arc">5</td>
<td class="arc">6</td>
<td class="arc">7</td>
<td class="arc">8</td>
<td class="arc">9</td>
<td class="arc">10</td>
<td class="arc">...</td>
</tr>
<!--
# m m d m d m d m ...
# d m m d m d m d ...
-->
<tr>
<td class="arc    ">n</td>
<td class="arr bor"><strong>6n&#8209;2</strong></td>
<td class="arc btr">m</td>
<td class="arc btr">m</td>
<td class="arc btr">d</td>
<td class="arc btr">m</td>
<td class="arc btr">d</td>
<td class="arc btr">m</td>
<td class="arc btr">d</td>
<td class="arc btr">m</td>
<td class="arc btr">d</td>
<td class="arc    ">...</td>
</tr>
<tr>
<td class="arc    "></td>
<td class="arr ker">3.2.lk&gt;3.2.rk,len</td>
<td class="arc bbr">d</td>
<td class="arc bbr">m</td>
<td class="arc bbr">m</td>
<td class="arc bbr">d</td>
<td class="arc bbr">m</td>
<td class="arc bbr">d</td>
<td class="arc bbr">m</td>
<td class="arc bbr">d</td>
<td class="arc bbr">m</td>
<td class="arc    ">...</td>
</tr>
GFis
} # print_table_head
#----------------
sub print_table_tail {
    return if $mode ne "html";
    print <<"GFis";
</table>
<p>End of directory</p>
GFis
} # print_table_tail
#----------------
sub print_html_tail {
    return if $mode ne "html";
    print <<"GFis";
</table>
</body>
</html>
GFis
} # print_html_tail
#================================
__DATA__

grep -E "\.5," kernels.tmp
0.2.1>1.0.5,1
0.1.17>3.0.5,5
0.4.19>5.0.5,9
0.1.1367>7.0.5,13
0.2.6151>9.0.5,17

grep -E "\.7," kernels.tmp
0.1.1>0.0.7,0
0.4.1>2.0.7,3
0.1.71>4.0.7,7
0.2.319>6.0.7,11
0.1.5741>8.0.7,15
0.3.12917>10.0.7,19

grep -E "\.11," kernels.tmp
1.0.1>0.0.11,0
0.0.25>2.0.11,4
0.0.223>4.0.11,8
0.0.2005>6.0.11,12
0.0.18043>8.0.11,16
0.0.162385>10.0.11,20

grep -E "\.13," kernels.tmp
0.1.5>1.0.13,2
0.3.11>3.0.13,6
0.1.395>5.0.13,10
0.2.1777>7.0.13,14
0.1.31985>9.0.13,18

grep -E "\.17," kernels.tmp
0.0.13>1.0.17,1
0.0.115>3.0.17,5
0.0.1033>5.0.17,9
0.0.9295>7.0.17,13
0.0.83653>9.0.17,17

grep -E "\.19," kernels.tmp
0.0.5>0.0.19,0
0.0.43>2.0.19,3
0.0.385>4.0.19,7
0.0.3463>6.0.19,11
0.0.31165>8.0.19,15

grep -E "\.23," kernels.tmp
1.1.1>0.0.23,0
0.2.13>2.0.23,4
0.1.233>4.0.23,8
0.5.131>6.0.23,12
0.1.18863>8.0.23,16

grep -E "\.25," kernels.tmp
0.0.19>1.0.25,2
0.0.169>3.0.25,6
0.0.1519>5.0.25,10
0.0.13669>7.0.25,14
0.0.123019>9.0.25,18

grep -E "\.29," kernels.tmp
0.1.11>1.0.29,1
0.2.49>3.0.29,5
0.1.881>5.0.29,9
0.4.991>7.0.29,13
0.1.71351>9.0.29,17

grep -E "\.31," kernels.tmp
0.3.1>0.0.31,0
0.1.35>2.0.31,3
0.2.157>4.0.31,7
0.1.2825>6.0.31,11
0.5.1589>8.0.31,15

grep -E "\.35," kernels.tmp
2.0.1>0.0.35,0
0.0.79>2.0.35,4
0.0.709>4.0.35,8
0.0.6379>6.0.35,12
0.0.57409>8.0.35,16

grep -E "\.37," kernels.tmp
0.2.7>1.0.37,2
0.1.125>3.0.37,6
0.3.281>5.0.37,10
0.1.10115>7.0.37,14

grep -E "\.41," kernels.tmp
0.0.31>1.0.41,1
0.0.277>3.0.41,5
0.0.2491>5.0.41,9
0.0.22417>7.0.41,13

grep -E "\.47," kernels.tmp
1.2.1>0.0.47,0
0.1.53>2.0.47,4
0.3.119>4.0.47,8
0.1.4283>6.0.47,12
0.2.19273>8.0.47,16

grep -E "\.49," kernels.tmp
0.0.37>1.0.49,2
0.0.331>3.0.49,6
0.0.2977>5.0.49,10
0.0.26791>7.0.49,14

grep -E "\.53," kernels.tmp
0.3.5>1.0.53,1
0.1.179>3.0.53,5
0.2.805>5.0.53,9
0.1.14489>7.0.53,13

grep -E "\.55," kernels.tmp
0.1.7>0.0.55,0
0.2.31>2.0.55,3
0.1.557>4.0.55,7
0.3.1253>6.0.55,11
0.1.45107>8.0.55,15

grep -E "\.59," kernels.tmp
1.0.5>0.0.59,0
0.0.133>2.0.59,4
0.0.1195>4.0.59,8
0.0.10753>6.0.59,12
0.0.96775>8.0.59,16

grep -E "\.61," kernels.tmp
0.1.23>1.0.61,2
0.2.103>3.0.61,6
0.1.1853>5.0.61,10
0.3.4169>7.0.61,14

grep -E "\.65," kernels.tmp
0.0.49>1.0.65,1
0.0.439>3.0.65,5
0.0.3949>5.0.65,9
0.0.35539>7.0.65,13

grep -E "\.67," kernels.tmp
0.0.17>0.0.67,0
0.0.151>2.0.67,3
0.0.1357>4.0.67,7
0.0.12211>6.0.67,11
0.0.109897>8.0.67,15

grep -E "\.71," kernels.tmp
2.1.1>0.0.71,0
0.5.5>2.0.71,4
0.1.719>4.0.71,8
0.2.3235>6.0.71,12
0.1.58229>8.0.71,16

grep -E "\.73," kernels.tmp
0.0.55>1.0.73,2
0.0.493>3.0.73,6
0.0.4435>5.0.73,10
0.0.39913>7.0.73,14

grep -E "\.77," kernels.tmp
0.1.29>1.0.77,1
0.3.65>3.0.77,5
0.1.2339>5.0.77,9
0.2.10525>7.0.77,13

grep -E "\.79," kernels.tmp
0.2.5>0.0.79,0
0.1.89>2.0.79,3
0.6.25>4.0.79,7
0.1.7199>6.0.79,11
0.2.32395>8.0.79,15
