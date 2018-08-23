#!perl

# Roads through the thicket of the Collatz graph
# @(#) $Id$
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
my $debug  = 0;
my $maxn   = 512; # max. start value
my $start4 = 4;
my $incr6  = 6;
my $start  = $start4;
my $incr   = $incr6;
my $action = "simple";
my $mode   = "html";
while (scalar(@ARGV) > 0) {
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
my @queue  = ($ffroad);
#----------------
# perform one of the possible actions
if (0) { # switch action
} elsif ($action =~ m{simple}) {
    # straightforward incrementing of the start values
    while ($ffroad < $maxn) {
        @roads[$ffroad] = &build_road($ffroad);
        $ffroad += $incr6;
    } # while $ffroad
} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
# output the resulting array
my $iroad = $start;
while ($iroad < $maxn) {
    &print_road($iroad);
    $iroad += $incr;
} # while $iroad
#----------------
# termination
if (0) {
} elsif ($mode =~ m{html}) {
   &print_html_tail();
} elsif ($mode =~ m{tsv} ) {
}
# end main
#================================
sub add_road {
    my ($elem0, $buffer) = @_;
    $roads[$elem0] = $buffer;
    if ($ffroad == $elem0) { # output and increase
        while (defined($roads[$ffroad])) {
            print "<!-- $ffroad -->$roads[$ffroad]";
            $ffroad += $incr6;
        } # while printing
    } # increase
} # add_road
#----------------
sub fill3 {
    my ($elem) = @_;
    while ($elem < $maxn) {
        $nums[$elem] = 1;
        $elem *= 2;
    } # while $elem
} # fill3
#----------------
sub build_road { # build and return a single road starting with $elem
    my ($elem) = @_;
    my $elem0  = $elem;
    my $elem1  = $elem0; # 2 parallel lanes: $elem0 (upper, left), $elem1 (lower, right)
    my $count  = 0;
    my @result = ($elem, $count); # [1] will be replaced later
    my $state  = "step0";
    my $busy   = 1; # as long as we can still do another step
    while ($busy == 1) { # stepping
        if (0) {
        } elsif ($state eq "step0") {
            $elem0 = ($elem0 - 1) / 3; # possible because of preparation above
            $elem1 = $elem1 * 2;
            $state = "step1";
        } elsif ($state eq "step1") {
            $elem0 = $elem0 * 2; # mm, always possible
            $elem1 = $elem1 * 2;
            $state = "md"; # enter the alternating sequence of steps: md, dm, md, dm ...
        } elsif ($state eq "md") {
            if (         ($elem1 - 1) % 3 == 0) {
                $elem1 = ($elem1 - 1) / 3;
                $elem0 =  $elem0 * 2;
                $state = "dm";
                if ($elem0 % 3 == 0 or $elem1 % 3 == 0) {
                    $busy  = 0;
                }
            } else { # should never happen
                $busy  = 0;
                $state = " 1assert3";
            }
        } elsif ($state eq "dm") {
            if (         ($elem0 - 1) % 3 == 0) {
                $elem0 = ($elem0 - 1) / 3;
                $elem1 =  $elem1 * 2;
                $state = "md";
                if ($elem0 % 3 == 0 or $elem1 % 3 == 0) {
                    $busy  = 0;
                }
            } else { # should never happen
                $state = " 0assert3";
                $busy  = 0;
            }
        } else {
            die "invalid state \"$state\"\n";
        }
        if ($elem0 % $incr6 ==   $start4) {
            if (! defined($roads[$elem0])) {
                &enqueue(        $elem0);
            }
        }
        if ($elem1 % $incr6 ==   $start4) {
            if (! defined($roads[$elem1])) {
                &enqueue(        $elem1);
            }
        }
        push(@result, $elem0, $elem1);
        $count ++;
    } # while busy stepping
    $result[1] = $count;
    if ($debug >= 2) {
        print "<!--build_road: " . join(";", @result) . "-->\n";
    }
    return join(",", @result);
} # build_road
#----------------
sub dequeue {
    @queue = sort {$a <=> $b} @queue;
    my $elem = shift(@queue);
    return $elem;
} # dequeue
#----------------
sub enqueue {
    my ($elem) = @_;
    push(@queue, $elem);
} # enqueue
#----------------
sub print_road {
    my ($index) = @_;
    return if (! defined($roads[$index]));
    my @road  = split(/\,/, $roads[$index]);
    if ($debug >= 1) {
        print "<!--print_road: " . join(";", @road) . "-->\n";
    }
    my $ir    = 0;
    my $elem0 = $road[$ir ++];
    my $elem1 = $road[$ir ++];
    my $len   = $elem1;
    if (0) {
    } elsif ($mode =~ m{html}) {
        print "<tr><td class=\"d4\">$elem0</td><td class=\"m3\">$len</td>";
    } elsif ($mode =~ m{tsv} ) {
        print join("\t", $elem0, $len);
    } # mode

    while ($ir < scalar(@road)) { # walk the entire road
        $elem0 = $road[$ir ++];
        $elem1 = $road[$ir ++];
        if (0) {
        } elsif ($mode =~ m{html}) {
            my $cla0 = &get_class($elem0);
            my $cla1 = &get_class($elem1);
            print "<td class=\"$cla0\">$elem0</td><td class=\"$cla1\">$elem1</td>";
        } elsif ($mode =~ m{tsv} ) {
            print "\t" . join("\t", $elem0, $len);
        } # mode
    } # while walking

    if (0) {
    } elsif ($mode =~ m{html}) {
        print "</tr>\n";
    } elsif ($mode =~ m{tsv} ) {
        print "\n";
    } # mode
} # print_road
#----------------
sub get_class { # get the CSS class (color) for a value
    my ($elem) = @_;
    my $result = "";
    my $rest = $elem % 6;
    if (0) {
    } elsif ($rest == 0) {
        $result = "d0";
    } elsif ($rest == 1) {
        $result = "d1";
    } elsif ($rest == 2) {
        $result = "d2";
    } elsif ($rest == 3) {
        $result = "d3";
    } elsif ($rest == 4) {
        $result = "d4";
    } elsif ($rest == 5) {
        $result = "d5";
    }
    return $result;
} # get_class
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
        { font-family: Arial; }
tr,td,th,p
        { text-align: right; }
.frame  { font-size:smaller; background-color: lightgray;}
.arr    { background-color: lavender;  color: black}
.m4     { background-color: darkblue;  color: white; font-weight: bold; }
.m5     { background-color:     blue;  color: white; }
.m3     { background-color: lightgreen; color: black; }
.m0     { background-color: orange;    color: black; }

.d5     { background-color: lightblue; color: black; }
.d1     { background-color: lavender ; color: black; }
.d4     { background-color: crimson;   color: white; font-weight: bold; }
.d2     { background-color: orangered; color: white; }
.d0     { background-color: yellow;    color: black; }
.d3     { background-color: yellow;    color: black; }
</style>
</head>
<body>
<h3>Roads in the thicket of the Collatz graph</h3>
<table>
<tr>
<td class="arr">0</td>
<td class="arr">1</td>
<td class="arr">2</td>
<td class="arr">3</td>
<td class="arr">4</td>
<td class="arr">5</td>
<td class="arr">6</td>
<td class="arr">7</td>
<td class="arr">8</td>
<td class="arr">9</td>
<td class="arr">10</td>
<td class="arr">11</td>
<td class="arr">12</td>
<td class="arr">13</td>
<td class="arr">...</td>
</tr>
<tr>
<td class="arr">start</td>
<td class="arr">len</td>
<td class="arr">d[0]</td>
<td class="arr">m[0]</td>
<td class="arr">m[2]</td>
<td class="arr">m[3]</td>
<td class="arr">m[4]</td>
<td class="arr">d[5]</td>
<td class="arr">d[6]</td>
<td class="arr">m[7]</td>
<td class="arr">m[8]</td>
<td class="arr">d[9]</td>
<td class="arr">d[10]</td>
<td class="arr">m[11]</td>
<td class="arr">...</td>
</tr>
GFis
} # print_html_head
#----------------
sub print_html_tail {
    return if $mode ne "html";
    print <<"GFis";
</table>
</body>
</html>
GFis
} # print_html_tail
#----------------
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

#----------------
    my $ffnum = $start;
    while ($ffnum < $maxn) { # look for first undefined @nums
        if (! defined($nums[$ffnum])) {
            print "<h4>first uncovered number: $ffnum</h4>\n";
            $ffnum = $maxn; # break loop
        }
        $ffnum ++;
    } # while defined

