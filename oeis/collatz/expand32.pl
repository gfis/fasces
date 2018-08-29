#!perl

# Check wether the sequence contains all positive integers
# @(#) $Id$
# 2018-08-26, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl expand32.pl [-n maxn]
#
# see <http://www.teherba.org/index.php/Collatz_sequences#Can_S_be_generated_starting_at_1.3F>
# when the start values are incremented by 2*3=6, 2*3*9=54, 2*3*9*9=486. 2*3*9*9*9=4374
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
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my (@queue, @roads);
#----------------
# initialization
my $sep = "\t";
my @svis = (2, 1); # [0] is never used
my @stab = ("0", join($sep, 3, 1, 2));
my $ffcontig = scalar(@svis);
my $inext = 1;
my $maxproc = $0;
&print_html_head();
#----------------
# perform one of the possible actions
if (0) { # switch action

} elsif ($action =~ m{simple}) { # straightforward incrementing of the start values
    while ($ffcontig < $maxn) {
        print "$inext? contig=$ffcontig max=$maxproc\r" if $debug >= 1;
        &build_row($inext); 
        # $inext ++;
        while ($svis[$inext] != 1) { # search for next element
            $inext ++;
        } # while searching
    } # while $ffcontig

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
sub enqueue { # queue the parameter
    my ($elem, $father) = @_;
    if (! defined($svis[$elem])) { # new member
        print "  enq $elem" if $debug >= 2;
        $svis[$elem] = 1; # to be processed
        if ($elem < $inext) {
            $inext = $elem;
        }
        if ($elem > $maxproc) {
            $maxproc = $elem;
        }
        if ($elem == $ffcontig) {
            $ffcontig = $elem + 1;
            while (defined($svis[$ffcontig])) {
                $ffcontig ++;
            }
            print "\n" if $debug >= 2;
            print "stop @ " . ($ffcontig - 1) . " <- $father, max=$maxproc\n";
        }
        # new member
    } else {
        print "  skip $elem " if $debug >= 2;
    }
} # enqueue
#----------------
sub build_row { # build and return a single row for index $elem
    my ($ind) = @_;
    my $elem  = $ind * 4 - 1;
    &enqueue($elem, $ind);
    while ($elem % 3 == 0) { # divisible by 3
        $elem /= 3;
        &enqueue($elem, $ind);
        $elem <<= 1;
        &enqueue($elem, $ind);
    } # while divisible by 3
    $svis[$ind] = 2; # is processed
    print "\n  [$ind] built next=$inext contig=$ffcontig max=$maxproc\n" if $debug >= 2;
} # build_row
#----------------
sub dequeue { # return lowest queue element
    @queue = sort {$a <=> $b} @queue;
    my $elem = shift(@queue);
    return $elem;
} # dequeue
#----------------
sub print_road {
    my ($index) = @_;
    if (! defined($roads[$index])) {
        if (0) {
        } elsif ($mode =~ m{html}) {
            print "<tr><td class=\"d4\">$index</td></tr>";
        } elsif ($mode =~ m{tsv} ) {
            print "$index\n";
        } # mode
    } else {
        my @road  = split(/\,/, $roads[$index]);
        if ($debug >= 2) {
            print "<!--print_road: " . join(";", @road) . "-->\n";
        }
        my $ir    = 0;
        my $elem0 = $road[$ir ++];
        my $elem1 = $road[$ir ++];
        my $len   = $elem1;
        if (0) {
        } elsif ($mode =~ m{html}) {
            print "<tr><td class=\"d4\">$elem0</td><td class=\"arr\">$len</td>";
        } elsif ($mode =~ m{tsv} ) {
            print join($sep, $elem0, $len);
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
                print $sep . join($sep, $elem0, $elem1);
            } # mode
        } # while walking

        if (0) {
        } elsif ($mode =~ m{html}) {
            print "</tr>\n";
        } elsif ($mode =~ m{tsv} ) {
            print "\n";
        } # mode
    } # if defined
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
        { font-family: Verdana,Arial,sans-serif; }
tr,td,th,p
        { text-align: right; }
.arr    { background-color: lightyellow; color: black;}
.arl    { background-color: lightyellow; color: black; text-align:left;}
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
<td class="arr">r<sub>0</sub></td>
<td class="arr">r<sub>1</sub></td>
<td class="arr">r<sub>2</sub></td>
<td class="arr">r<sub>3</sub></td>
<td class="arr">r<sub>4</sub></td>
<td class="arr">r<sub>5</sub></td>
<td class="arr">r<sub>6</sub></td>
<td class="arr">r<sub>7</sub></td>
<td class="arr">r<sub>8</sub></td>
<td class="arr">r<sub>9</sub></td>
<td class="arr">r<sub>10</sub></td>
<td class="arr">r<sub>11</sub></td>
<td class="arr">r<sub>12</sub></td>
<td class="arr">r<sub>13</sub></td>
<td class="arr">r<sub>14</sub></td>
<td class="arr">r<sub>15</sub></td>
<td class="arr">...</td>
</tr>
<tr>
<td class="arr">start</td>
<td class="arr">len</td>
<td class="arr"><strong>d</strong>r<sub>0</sub></td>
<td class="arl"><strong>m</strong>r<sub>0</sub></td>
<td class="arr"><strong>m</strong>r<sub>2</sub></td>
<td class="arl"><strong>m</strong>r<sub>3</sub></td>
<td class="arr"><strong>m</strong>r<sub>4</sub></td>
<td class="arl"><strong>d</strong>r<sub>5</sub></td>
<td class="arr"><strong>d</strong>r<sub>6</sub></td>
<td class="arl"><strong>m</strong>r<sub>7</sub></td>
<td class="arr"><strong>m</strong>r<sub>8</sub></td>
<td class="arl"><strong>d</strong>r<sub>9</sub></td>
<td class="arr"><strong>d</strong>r<sub>10</sub></td>
<td class="arl"><strong>m</strong>r<sub>11</sub></td>
<td class="arr"><strong>m</strong>r<sub>12</sub></td>
<td class="arl"><strong>d</strong>r<sub>13</sub></td>
<td class="arr">...</td>
</tr>
<tr>
<td class="arr">&#x394;6</td>
<td class="arr"></td>
<td class="arr">&#x394;2</td>
<td class="arr">&#x394;12</td>
<td class="arr">&#x394;4</td>
<td class="arr">&#x394;24</td>
<td class="arr">&#x394;8</td>
<td class="arr">&#x394;8</td>
<td class="arr">3&#x394;8</td>
<td class="arr">3&#x394;48</td>
<td class="arr">3&#x394;16</td>
<td class="arr">3&#x394;16</td>
<td class="arr">9&#x394;16</td>
<td class="arr">9&#x394;96</td>
<td class="arr">9&#x394;32</td>
<td class="arr">9&#x394;32</td>
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
C:\Users\User\work\gits\fasces\oeis\collatz>perl expand32.pl -n 4096 -d 1
stop @ 3 <- 1, max=3nd32.pl
stop @ 4 <- 7, max=27
stop @ 9 <- 4, max=27
stop @ 12 <- 4, max=27
stop @ 13 <- 10, max=39
stop @ 27 <- 16, max=1539
stop @ 36 <- 16, max=1539
stop @ 48 <- 28, max=1539
stop @ 63 <- 37, max=1539
stop @ 84 <- 547, max=2187
stop @ 112 <- 64, max=2187
stop @ 163 <- 85, max=2187
stop @ 223 <- 277, max=3555
stop @ 319 <- 1276, max=19683
stop @ 351 <- 2734, max=20763
stop @ 435 <- 2005, max=74223
stop @ 580 <- 736, max=95499
stop @ 909 <- 436, max=95499
stop @ 957 <- 1024, max=378351
stop @ 1276 <- 1078, max=378351
stop @ 2127 <- 958, max=378351
stop @ 2295 <- 8080, max=3026727
stop @ 3060 <- 5812, max=4076811
stop @ 4080 <- 2296, max=4076811
stop @ 4831 <- 3061, max=4076811

C:\Users\User\work\gits\fasces\oeis\collatz>