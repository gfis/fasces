#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/collatz_rails.pl
# Print a directory of railways in the Collatz graph
# @(#) $Id$
# 2018-09-05: new kernel format; -a west|east|free
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
my %text   =
    ( "simple",     "Directory"
    , "contig",     "Tree"
    , "west",       "Plan West"
    );
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
my @queue;
my $index = 0;
#----------------
# perform one of the possible actions
if (0) { # switch action

} elsif ($action =~ m{simple}) { # straightforward incrementing of the start values
    $ffrail = scalar(@rails); # (is asserted)
    while ($ffrail < $maxn) {
        @rails[$ffrail] = &build_rail($ffrail);
        $ffrail += $incr6;
    } # while $ffrail
    &print_rails();

} elsif ($action =~ m{contig}) { # identify contiguous blocks of start values
    $ffrail = scalar(@rails); # (is asserted)
    @queue  = ($ffrail);
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
    &print_rails();

} elsif ($action =~ m{west|east|free}) { # follow railways down to the capital
    $ffrail = scalar(@rails); # (is asserted)
    while ($ffrail < $maxn) {
        @rails[$ffrail] = &build_west($ffrail);
        $ffrail += $incr6;
    } # while $ffrail
    &print_west();

} elsif ($action =~ m{test}) { # test the long hypothesis
    while (<DATA>) {
        next if m{^\s*\#};
        s{\s+\Z}{}; # chompr
        my $line = $_;
        my @row = split(/\s+/, $_);
        my $west = &go_west($row[1]);
        my $wkern = &to_kernel($west);
        print "$line\t$west\t$wkern\t"
        . ($wkern eq $row[5] ? "ok" : "not ok")
        . "\n";
    } # while DATA

} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
sub print_rails {
    # output the resulting array
    &print_rails_head();
    my $irail = $start;
    while ($irail < $maxn) {
        if (! defined($rails[$irail])) {
            $irail = $maxn; # break loop
        } else {
            &print_rail($irail);
        }
        $irail += $incr;
    } # while $irail
    &print_rails_tail();
} # print_rails
#----------------
sub print_west {
    print <<"GFis";
<table>
GFis
    my $irail = $start;
    while ($irail < $maxn) {
        my @rail  = split(/$sep/, $rails[$irail]);
        print "<tr>"
            . "<td class=\"\">&nbsp;" . (scalar(@rail) / 2) . "&nbsp;</td>"
            . "<td class=\"\">&nbsp;" . $irail              . "&nbsp;</td>";
        my $ir;
        if (0) {
        } elsif ($action =~ m{west}) {
            $ir = 0;
            while ($ir < scalar(@rail)) {
                print "<td class=\"d4\">&nbsp;$rail[$ir    ]&nbsp;</td>";
                my $class = ($rail[$ir + 1] =~ m{\A0\.0\.}) ? "d5" : "";
                print "<td class=\"$class\"  >&nbsp;$rail[$ir + 1]&nbsp;</td>"; # kernel
                $ir += 2;
            } # while $ir
        } elsif ($action =~ m{east}) {
            $ir = scalar(@rail) - 2;
            while ($ir >= 0) {
            #   print "<td class=\"d4\">&nbsp;$rail[$ir    ]&nbsp;</td>";
                my $class = ($rail[$ir + 1] =~ m{\.\Z}) ? "arl d5" : "arl";
                print "<td class=\"$class\"  >&nbsp;$rail[$ir + 1]&nbsp;</td>"; # kernel
                $ir -= 2;
            } # while $ir
        } elsif ($action =~ m{free}) {
            $ir = scalar(@rail) - 2;
            while ($ir >= 0) {
            #   print "<td class=\"d4\">&nbsp;$rail[$ir    ]&nbsp;</td>";
                if ($rail[$ir + 1] =~ m{\.\Z}) {
                	print "<td class=\"arl d5\"  >&nbsp;$rail[$ir + 1]&nbsp;</td>"; # kernel
                }
                $ir -= 2;
            } # while $ir
        } # switch action
        print "</tr>\n";
        $irail += $incr;
    } # while $irail
    print <<"GFis";
</table>
GFis
} # print_west
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
sub build_west { # build and return a single rail starting with $selem
    my ($elem)  = @_;
    if ($debug >= 1) {
        print "<!--build_west1: " . join("\t", $elem) . "-->\n";
    }
    my @result  = ();
    my $busy    = 1; # as long as we can still do another step
    while ($busy == 1) { # while 4 not reached
        my $lkern  = &to_kernel($elem);
        if ($debug >= 1) {
            print "<!--build_west2: " . join("\t", $elem, $lkern) . "-->\n";
        }
        push(@result, $elem, $lkern);
        if ($lkern ne "1.") {
            $elem = &go_west($elem);
        } else {
            $busy = 0;
        }
    } # while 4 not reached
    return join($sep, @result);
} # build_west
#----------------
sub dequeue { # return lowest queue element
    @queue = sort {$a <=> $b} @queue;
    my $elem = shift(@queue);
    return $elem;
} # dequeue
#----------------
sub to_kernel { # for n6-2, return the 2-3-free factor and the exponents for 2 and 3 of n
    my ($parm) = @_;
    my $result = 0;
    if ($parm % $incr6 == $start4) {
        my $num = $parm / $incr6 + 1; # we had 6*(n-1) + 4
        my $exp3 = 0;
        while ($num % 3 == 0 and $num > 0) {
            $exp3 ++;
            $num /= 3;
        } # while 3
        my $exp2 = 0;
        while ($num % 2 == 0 and $num > 0) {
            $exp2 ++;
            $num /= 2;
        } # while 2
        $result = $num;
        if ($exp2 != 0) {
            $result .= ".$exp2";
        }
        if ($exp3 != 0) {
            $result .= ":$exp3";
        }
        if ($exp2 + $exp3 == 0) {
            $result .= ".";
        }
    }
    return $result;
} # to_kernel
#----------------
sub from_kernel { # for a kernel, return n
    my ($elem)  = @_;
    my @kern    = split(/[\.\:]/, $elem);
    $kern[1] = 0 if ($kern[1] eq "");
    $kern[2] = 0 if (scalar(@kern) == 2);
    my $result = $kern[0] * 2**$kern[1] * 3**$kern[2];
    return $result;
} # from_kernel
#----------------
sub go_west {
    # 82=7.1   -> 376=7.0:2, but for
    # 46=1.3   -> 160=1.0:3
    my ($elem) = @_;
    my $ekern  = &to_kernel($elem);
    $ekern     =~ m{\A(\d+)};
    my @kern   = ($1, 0, 0); # 2-3-free, exp2, exp3
    if ($ekern    =~ m{\.(\d+)}) {
    	$kern[1]  = $1;
    }
    if ($ekern    =~ m{\:(\d+)}) {
    	$kern[2]  = $1;
    }
    $kern[2] = $kern[1];
    $kern[1] = 0;
    if (($kern[0] / 2) % 2 == $kern[2] % 2) {
        $kern[2] ++;
    }
    my $result = 6 * ($kern[0] * 3**$kern[2]) - 2;
    return $result / 4;
} # go_west
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
            $ir = 1;
            print "<tr>"
                . "<td class=\"arc    \">$rail[0]</td>"
                . &cell_html(            $rail[1], "bor", $ir, "");
            if (0) {
            print &cell_html($rail[$ir], " btr", $ir, "");
            }
            $ir += 2;
            while ($ir < scalar(@rail)) {
                my $id = "";
                if (      $rail[$ir    ] % $incr6 == $start4) {
                    $id = $rail[$ir    ];
                }
                if ($ir > 5 and $rail[$ir - 1] % $incr6 == $start4) {
                    $id = $rail[$ir - 1];
                    # print STDERR "$id\n";
                }
                print &cell_html($rail[$ir], "btr", $ir, $id);
                $ir += 2;
            } # while $ir
            print "</tr>\n";

            my $len = 0;
            $ir = 5;
            while ($ir < scalar(@rail)) { # length is number of highlighted elements >= [4]
                if (      $rail[$ir    ] % $incr6 == $start4) {
                    $len ++;
                }
                $ir ++;
            } # while len
            $len = ($len - 1) / 2;
            print "<tr>"
                . "<td class=\"arl\">\&nbsp;</td>"
                . "<td class=\"arr ker\">"
                . &to_kernel($rail[1]) # $rail[1] #
                . "\&gt;"
                . &to_kernel($rail[5])
                . ",$len</td>";
            $ir = 2;
            while ($ir < scalar(@rail)) {
                print &cell_html($rail[$ir], "bbr", $ir, "");
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
    my ($elem, $border, $ir, $id) = @_;
    my $rest = $elem % $incr6;
    my $result = "<td";
    if ($rest == $start4) {
        # $result .= " title=\"$ir:" . &to_kernel($elem) . "\"";
        $result .= " title=\"" . &to_kernel($elem) . "\"";
    }
    if ($id ne "") {
        $result .= " id=\"$id\"";
        # print STDERR "id2: $id\n";
    }
    $result .= " class=\"d$rest";
    if ($border ne "") {
        $result .= " $border";
    }
    $result .= "\">";
    if ($ir == 1) { # start element
        $result .= "\&nbsp;<a href=\"\#$elem\">$elem</a>\&nbsp;"; # to be able to search for " 84 "
    } else {
        $result .=                     "\&nbsp;$elem\&nbsp;";
    }
    $result .= "</td>";
    return $result;
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
<title>3x+1 Railway $text{$action}</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/collatz/collatz_rails.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: right; }
/* from https://stackoverflow.com/questions/10732690/offsetting-an-html-anchor-to-adjust-for-fixed-header
does not work
.anchor   {
          display: block; position: relative;
          top: -250px; visibility: hidden; }
.anch { margin-top: -300px;        /* Size of fixed header */
        padding-bottom: 300px;
        display: block;}
*/
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
/*
.d2     { background-color: beige          ; color: black;                   }
*/
.d2     { background-color: white          ; color: gray ;                   }
.d3     { background-color: lemonchiffon   ; color: gray;                    }
.d4     { background-color: papayawhip     ; color: black;                   font-weight: bold; }
.d5     { background-color: lavender       ; color: gray;                    }
</style>
</head>
<body>
<h3>3x+1 Railway $text{$action}</h3>
GFis
} # print_html_head
#----------------
sub print_rails_head {
    return if $mode ne "html";
    print <<"GFis";
<p>
tree root &lt;-&nbsp;&nbsp;&nbsp;numbers &#x2261;
<span class="d0">0</span>, <span class="d1">1</span>,
<span class="d2">2</span>, <span class="d3">3</span>,
<span class="d4">4</span>, <span class="d5">5</span> mod 6&nbsp;&nbsp;&nbsp;-&gt; infinity
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
<td class="arc btr">&micro;</td>
<td class="arc btr">&micro;</td>
<td class="arc btr">&delta;</td>
<td class="arc btr">&micro;</td>
<td class="arc btr">&delta;</td>
<td class="arc btr">&micro;</td>
<td class="arc btr">&delta;</td>
<td class="arc btr">&micro;</td>
<td class="arc btr">&delta;</td>
<td class="arc    ">...</td>
</tr>
<tr>
<td class="arc    "></td>
<td class="arr ker"></td>
<td class="arc bbr">&delta;</td>
<td class="arc bbr">&micro;</td>
<td class="arc bbr">&micro;</td>
<td class="arc bbr">&delta;</td>
<td class="arc bbr">&micro;</td>
<td class="arc bbr">&delta;</td>
<td class="arc bbr">&micro;</td>
<td class="arc bbr">&delta;</td>
<td class="arc bbr">&micro;</td>
<td class="arc    ">...</td>
</tr>
GFis
} # print_rails_head
#----------------
sub print_rails_tail {
    return if $mode ne "html";
    print <<"GFis";
</table>
<p>End of directory</p>
GFis
} # print_rails_tail
#----------------
sub print_html_tail {
    return if $mode ne "html";
    print <<"GFis";
</body>
</html>
GFis
} # print_html_tail
#================================
__DATA__
<!--build_west1: 82-->
<!--build_west2: 82     7.1-->
<!--build_west2: 94     1.4-->
<!--build_west2: 364    61.-->
<!--build_west2: 274    23.1-->
<!--build_west2: 310    13.2-->
<!--build_west2: 526    11.3-->
<!--build_west2: 1336   223.-->
<!--build_west2: 334    7.3-->
<!--build_west2: 850    71.1-->
<!--build_west2: 958    5.5-->
<!--build_west2: 1822   19.4-->
<!--build_west2: 2308   385.-->
<!--build_west2: 1732   289.-->
<!--build_west2: 1300   217.-->
<!--build_west2: 976    163.-->
<!--build_west2: 244    41.-->
<!--build_west2: 184    31.-->
<!--build_west2: 46     1.3-->
<!--build_west2: 40     7.-->
<!--build_west2: 10     1.1-->
<!--build_west2: 4      1.-->

<!--build_west1: 88-->
<!--build_west2: 88     5:1-->
<!--build_west2: 22     1.2-->
<!--build_west2: 40     7.-->
<!--build_west2: 10     1.1-->
<!--build_west2: 4      1.-->

# Railways to capital (-a long)
#   col1                col3n
#i  a[i]    kern(a[i])  4a[i+1] kern(4a[i+1])  len
1   82      0.1.7   ->  376     2.0.7           2   /4 ->
2   94      0.4.1   ->  1456    5.0.1           5   /4 ->
3   364     0.0.61  ->  1096    1.0.61          1   /4 ->
4   274     0.1.23  ->  1240    2.0.23          2   /4 ->
5   310     0.2.13  ->  2104    3.0.13          3   /4 ->
6   526     0.3.11  ->  5344    4.0.11          4   /4 ->
7   1336    0.0.223 ->  1336    0.0.223         0   /4 ->   =
8   334     0.3.7   ->  3400    4.0.7           4   /4 ->
9   850     0.1.71  ->  3832    2.0.71          2   /4 ->
10  958     0.5.5   ->  7288    5.0.5           5   /4 ->   *
11  1822    0.4.19  ->  9232    4.0.19          4   /4 ->   *
12  2308    0.0.385 ->  6928    1.0.385         1   /4 ->
13  1732    0.0.289 ->  5200    1.0.289         1   /4 ->
14  1300    0.0.217 ->  3904    1.0.217         1   /4 ->
15  976     0.0.163 ->  976     0.0.163         0   /4 ->   =
16  244     0.0.41  ->  736     1.0.41          1   /4 ->
17  184     0.0.31  ->  184     0.0.31          0   /4 ->   =
18  46      0.3.1   ->  160     3.0.1           3   /4 ->   *
19  40      0.0.7   ->  40      0.0.7           0   /4 ->   =
20  10      0.1.1   ->  16      1.0.1           1   /4 ->   *
21  4       0.0.1   ->  4       0.0.1           0   /4 ->   =
# "*" if 4a[i+1] occurs in column 3 south, i.e.
# (4a[i+1]-1) / 3 * 2 = a[i]
