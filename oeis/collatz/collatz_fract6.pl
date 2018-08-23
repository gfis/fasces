#!perl

# Roadmap for the thicket of the Collatz graph
# @(#) $Id$
# 2018-08-21, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl collatz_fract6.pl [-n maxn] [-s start] [-i incr]
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

my $debug  = 0;
my $maxn   = 4096; # max. start value
my $start  = 4;
my $incr   = 6;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{i}) {
        $incr   = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } elsif ($opt =~ m{s}) {
        $start  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
&print_html_head();

my @roads  = (0, 1, 2, 4); # $roads[0..3] are not used
my @nums   = @roads; # whether all numbers are visited
my $ffroad = scalar(@roads); # 1st free in @roads
my @queue  = ($ffroad);
my $elem0  = $start; # 364; 40;
while ($ffroad < $maxn) { # dequeue
	print "dequeue $elem0\n" if $debug > 0;
	@queue = sort {$a <=> $b} @queue;
	$elem0 = shift(@queue);
	if (! defined($roads[$elem0])) {
		&add_road($elem0, &build_road($elem0));
	}
} # while dequeuing
print <<"GFis";
</table>
GFis

my $ffnum = $start;
while ($ffnum < $maxn) { # look for first undefined @nums
	if (! defined($nums[$ffnum])) {
		print "<h4>first uncovered number: $ffnum</h4>\n";
		$ffnum = $maxn; # break loop
	}
	$ffnum ++;
} # while defined
&print_html_tail();
# end main
#**************************************************
sub add_road {
	my ($elem0, $buffer) = @_;
	$roads[$elem0] = $buffer;
	if ($ffroad == $elem0) { # output and increase
		while (defined($roads[$ffroad])) {
			print "<!-- $ffroad -->$roads[$ffroad]";
			$ffroad += $incr;
		} # while printing
	} # increase
} # add_road
#-----------------------
sub fill3 {
	my ($elem) = @_;
	while ($elem < $maxn) {
		$nums[$elem] = 1;
		$elem *= 2;
	} # while $elem
} # fill3
#-----------------------
sub build_road {
    my ($elem) = @_;
    my $elem0 = $elem;
    my $count = 0;
    my $buffer = "<td>dm</td>";
    my $elem1  = $elem0; # 2 parallel threads: $elem0 (upper, left), $elem1 (lowe, right)
    my $state  = "st"; # both resulted from mult.
    my $busy   = 1; # as long as loop should continue
    while ($busy == 1) {
        if (0) {
        } elsif ($state eq "st") {
            $elem0 = ($elem0 - 1) / 3; # possible because of preparation above
            $elem1 = $elem1 * 2;
            $state = "mm";
        } elsif ($state eq "mm") {
            $elem0 = $elem0 * 2; # always possible
            $elem1 = $elem1 * 2;
            $state = "md";
        } elsif ($state eq "md") {
            if (($elem1 - 1) % 3 == 0) {
                $elem1 = ($elem1 - 1) / 3;
                $elem0 = $elem0 * 2; # always possible
                $state = "dm";
                if ($elem0 % 3 == 0) {
                    $busy  = 0;
                    $state = " 0/3";
                    &fill3($elem0);
                } elsif ($elem1 % 3 == 0) {
                    $busy  = 0;
                    $state = " 1/3";
                    &fill3($elem1);
                }
            } else {
                $busy  = 0;
                $state = " 1n3";
            }
        } elsif ($state eq "dm") {
            if (($elem0 - 1) % 3 == 0) {
                $elem0 = ($elem0 - 1) / 3;
                $elem1 = $elem1 * 2; # always possible
                $state = "md";
                if ($elem0 % 3 == 0) {
                    $busy  = 0;
                    $state = " 0/3";
                    &fill3($elem0);
                } elsif ($elem1 % 3 == 0) {
                    $busy  = 0;
                    $state = " 1/3";
                    &fill3($elem1);
                }
            } else {
                $state = " 0n3";
                $busy  = 0;
            }
        } else {
            die "invalid state \"$state\"\n";
        }
        $buffer .= "<td>";
        $nums[$elem0] = 1;
        if ($elem0 % $incr == $start) {
            $buffer .= "<strong>$elem0</strong>";
            push(@queue,        $elem0);
        } else {
            $buffer .=          $elem0;
        }
        $buffer .= ",";
        $nums[$elem1] = 1;
        if ($elem1 % $incr == $start) {
            $buffer .= "<strong>$elem1</strong>";
            push(@queue,        $elem1);
        } else {
            $buffer .=          $elem1;
        }
        $buffer .= "</td><td>$state</td>";
        $count ++;
    } # while busy
    return "<tr><td>$count</td><td>$elem</td>$buffer</tr>\n";
} # build_road
#----------------
sub print_ruler {
} # sub print_ruler
#-----------------
sub print_html_head {
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
.arr    { background-color: lightyellow;}
/* resulting from multiplication, mod 6 */
.m4     { background-color: darkblue;  color: white; font-weight: bold; }
.m2     { background-color:     blue;  color: white; }
.m0     { background-color: lightblue; color: black; }
.m3     { background-color: green    ;  color: black; }
/* resulting from division,       mod 6 */
.dx     { background-color: darkred;   color: white; font-weight: bold; }
.d4     { background-color: crimson;   color: white; }
.d2     { background-color: orangered; color: white; }
.d0     { background-color: orange;    color: black; }
.d3     { background-color: limegreen; color: white; }
</style>
</head>
<body>
<h3>1/6 of Collatz Graph</h3>
<table>
GFis
} # print_html_head
#-----------------
sub print_html_tail {
    print <<"GFis";
</body>
</html>
GFis
} # print_html_tail
#-----------------
__DATA__
A070165:
142/104: [142 m  71 d 214 m 107 d 322 m 161 d 484 m  242 m 121 d | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
           +1  *6+4    +1  *6+4    +1  *6+4    +1   *6+4  *6+2     =     =   ...
143/104: [143 d 430 m 215 d 646 m 323 d 970 m 485 d 1456 m 728 m | 364 m 182, 91, ... 10, 5, 16, 8, 4, 2, 1]
              i     i     i     i     i     i     i      1     1       0
124 m 62 m  31 d 94 m  47 d 142 m
 +2   +1  *6+4    +1 *6+4    +1
126 m 63 d 190 m 95 d 286 m 143 d
         i     i    i     i     i