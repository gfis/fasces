#!perl

# Roads through the thicket of the Collatz graph
# @(#) $Id$
# 2018-08-29: kernel of n6-2
# 2018-08-22, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl collatz_roads.pl [-n maxn]
#
# Overview:
# When all Collatz sequences are read backwards, they form
# a graph starting with 1, 2 ..., hopefully without cycles
# (except for 1,2,4,1,2,4 ...).
# At each node n in the graph, the path starting at the
# root (4) and  with the last node n can in principle
# be continued to 2 new nodes by a
# "m"-step: n * 2 (which is always possible), or
# "d"-step: (n - 1) / 3 (which is possible only if n - 1 mod 3 = 0).
# When n mod 3 = 0, the path will continue with m-steps only,
# since the duplication maintains the divisibility by 3.
#
# Motivation of the "road"s:
# When Collatz sequences are investigated (in A070165),
# there are a lot of pairs of adjacent start values with the
# same sequence length, and with a characteristical neighbourhood
# of every other value (c.f. example 142/143 behind __DATA__, below).
#
# Construction of roads:
# A "road" (with 2 parallel "lanes") is a sequence of pairs
# of elements (in 2 adjacent Collatz sequences read from right to left).
# A road is built by taking some n (the last common element of the
# 2 sequences) with n mod 6 = 4, and by applying the steps
# d m m d m d m d ... -> upper lane, left  elements in the pairs
# m m d m d m d m ... -> lower lane, right elements in the pairs
# in alternating sequence, until one of the elements in the pairs
# becomes divisible by 3.
#
# Questions:
# (Q1) Are the roads always of finite length?
# (Q2) How are theirs lengths distributed?
# (Q3) Do they cover the whole Collatz graph?
# (Q4) Can they lead to cycles?
# With "yes" for Q3 and "no" for Q4, the Collatz conjecture would
# be proved IMHO.
#
# Properties:
# The program below shows the following for numbers up to 8192:
#
# Algorithm:
# This program leads to hope for
# The lengths of the roads show a fractal structure
# when the start values are incremented by 2*3=6, 2*3*9=54, 2*3*9*9=486. 2*3*9*9*9=4374
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
my $ffroad  = 0;
my @roads;
while ($ffroad < $start4) { # $roads[0..3] are not used
    push(@roads, $ffroad);
    $ffroad ++;
} # while not used
my @nums   = @roads; # defined if the number was visited
$ffroad    = scalar(@roads); # (is asserted)
my @queue;
my $index = 0;
#----------------
# perform one of the possible actions
if (0) { # switch action

} elsif ($action =~ m{simple}) { # straightforward incrementing of the start values
    while ($ffroad < $maxn) {
        @roads[$ffroad] = &build_road($ffroad);
        $ffroad += $incr6;
    } # while $ffroad

} elsif ($action =~ m{contig}) { # identify contiguous blocks of start values
    @queue = ($ffroad);
    while (scalar(@queue) > 0) {
        my $selem = &dequeue();
        $index ++;
        if (! defined($roads[$selem])) {
            @roads[$selem] = &build_road($selem);
        }
        my $oldff = $ffroad;
        while (defined($roads[$ffroad])) { # try to increase
            $ffroad += $incr6;
        } # try to increase
        if ($ffroad > $oldff) {
            if ($mode =~ m{html}) {
                print "<!--stopped at $ffroad-->\n";
            }
        }
    } # while $selem

} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
# output the resulting array
&print_table_head();
my $iroad = $start;
while ($iroad < $maxn) {
    &print_road($iroad);
    $iroad += $incr;
} # while $iroad
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
sub build_road { # build and return a single road starting with $selem
    my ($selem) = @_;
    my @elem    = ($selem, $selem);  
            # 2 parallel lanes: $elem[0] (upper, left), $elem[1] (lower, right)
    my $len     = 0;
    my @result  = 
            (($selem + 2)/6             # 0
            , &get_kernel($selem)       # 1
            , &get_kernel($selem * 4)   # 2
            , $len                      # 3, will be replaced below
            , $selem);                  # 4
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
            if (! defined($roads[$elem[0]])) {
                &enqueue(        $elem[0]);
            }
        }
        if ($elem[1] % $incr6 == $start4) {
            if (! defined($roads[$elem[1]])) {
                &enqueue(        $elem[1]);
            }
        }
        push(@result, $elem[0], $elem[1]);
        $len ++;
    } # while busy stepping
    $result[3] = $len; 
    if ($debug >= 1) {
        print "<!--build_road: " . join(";", @result) . "-->\n";
    }
    return join($sep, @result);
} # build_road
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
        $result = "$log3.$log2" . ($num > 1 ? "/$num" : "");
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
sub print_road {
    my ($index) = @_;
    if (! defined($roads[$index])) {
    	my $kernel1 = &get_kernel($index);
	    $index = ($index + 2) / 6;
        if (0) {
        } elsif ($mode =~ m{html}) {
            print "<tr><td class=\"arr\">$index</td>";
            print "<td class=\"arl\">$kernel1</td></tr>";
        } elsif ($mode =~ m{tsv} ) {
            print "$index$sep$kernel1\n";
        } # mode
    } else {
        my @road  = split(/$sep/, $roads[$index]);
        if ($debug >= 2) {
            print "<!--print_road: " . join(";", @road) . "-->\n";
        }
        my $ir    = 0;
        if (0) {
        } elsif ($mode =~ m{html}) {
            while ($ir < scalar(@road)) { # walk the entire road
                if (0) {
                } elsif ($ir == 1 or $ir == 2) {
                    print "<td class=\"arl\">$road[$ir]</td>";
                } elsif ($ir < 4) {
                    print "<td class=\"arr\">$road[$ir]</td>";
                } else {
                    &print_cell($road[$ir]);
                }
                $ir ++;
            } # while $ir
            print "</tr>\n";
        } elsif ($mode =~ m{tsv} ) {
            print join($sep, @road) . "\n";
        } # mode
    } # if defined
} # print_road
#----------------
sub print_cell { # print one table cell
    my ($elem) = @_;
    my $rest = $elem % 6;
    print "<td";
    if ($rest == 4) {
        my $num = $elem / 6 + 1; # 6 * $num - 2
        print " title=\"$num\"";
    }
    print " class=\"d$rest\">$elem</td>";
} # print_cell
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
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
tr,td,th,p
        { text-align: right; }
.arr    { background-color: white; color: black;}
.arc    { background-color: white; color: black; text-align: center;}
.arl    { background-color: white; color: black; text-align: left;}
/*
.d5     { background-color: peachpuff;   color: black; }
.d1     { background-color: papayawhip;  color: black; }
.d4     { background-color: lightsalmon; color: black; font-weight: bold; }
.d2     { background-color: lightpink;   color: black; }
.d0     { background-color: yellow;      color: black; }
.d3     { background-color: yellow;      color: black; }

.d5     { background-color: white      ; color: lightgray; }
.d1     { background-color: white      ; color: lightgray; }
.d4     { background-color: white      ; color: black    ; font-weight: bold; }
.d2     { background-color: white      ; color: lightgray; }
.d0     { background-color: white      ; color: lightgray; }
.d3     { background-color: white      ; color: lightgray; }
*/
.d5     { background-color: white      ; color: gray; }
.d1     { background-color: white      ; color: gray; }
.d4     { background-color: white      ; color: black    ; font-weight: bold; }
.d2     { background-color: white      ; color: gray; }
.d0     { background-color: white      ; color: gray; }
.d3     { background-color: white      ; color: gray; }
</style>
</head>
<body>
<h3>Roads in the Collatz graph</h3>
GFis
} # print_html_head
#----------------
sub print_table_head {
    return if $mode ne "html";
    print <<"GFis";
<table>
<tr>
<td class="arr">index</td>
<td class="arl">kernel1</td>
<td class="arl">kernel2</td>
<td class="arr">len</td>
<td class="arr">start</td>
<td class="arr">col2</td>
<td class="arr">col3</td>
<td class="arr">col4</td>
<td class="arr">col5</td>
<td class="arr">col6</td>
<td class="arr">col7</td>
<td class="arr">col8</td>
<td class="arr">col9</td>
<td class="arr">...</td>
</tr>
<tr>
<td class="arr"></td>
<td class="arr"></td>
<td class="arr"></td>
<td class="arr"></td>
<td class="arr"></td>
<td class="arr">d</td>
<td class="arr">m</td>
<td class="arr">m</td>
<td class="arr">m</td>
<td class="arr">m</td>
<td class="arr">d</td>
<td class="arr">d</td>
<td class="arr">m</td>
<td class="arr">m</td>
<td class="arr">d</td>
<td class="arr">d</td>
<td class="arr">m</td>
<td class="arr">...</td>
</tr>
GFis
} # print_table_head
#----------------
sub print_table_tail {
    return if $mode ne "html";
    print <<"GFis";
</table>
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
Example of a road in A070165 (to be read from right to left, starting at "|"):
142/104: [142 m  71 d 214 m 107 d 322 m 161 d 484 m  242 m 121 d | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
           +1  *6+4    +1  *6+4    +1  *6+4    +1   *6+4  *6+2     =     =   ...
143/104: [143 d 430 m 215 d 646 m 323 d 970 m 485 d 1456 m 728 m | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]

continuation:
124 m 62 m  31 d 94 m  47 d 142 m
 +2   +1  *6+4    +1 *6+4    +1
126 m 63 d 190 m 95 d 286 m 143 d
       ^--- divisible by 3
#================================
