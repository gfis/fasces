#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/collatz_rails.pl
# Print a directory of railways in the Collatz graph
# @(#) $Id$
# 2018-11-06: links on all numbers for comp
# 2018-09-05: new kernel format; -a west|east|free|comp
# 2018-08-30, Georg Fischer: derived from collatz_roads.pl
#
# The algorithm is the same as in collatz_roads.pl,
# only the layout of the output is changed.
#------------------------------------------------------
# Usage:
#   perl collatz_rails.pl [-n maxn] [-d debug] [-s 4] [-i 6] [-a comp] > comp.html
#       -n	maximum start value
#       -s	
#       -i  elements of the form n*i + s
#       -d  debug level: 0 (none), 1 (some), 2 (more)
#       -a  type of directory to be produced: simple, comp(ressed), 
#             contig(uous), west, east, free, crop
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

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);#----------------
# get commandline options
my $sep    = "\t";
my $debug  = 0;
my $maxn   = 30000; # max. start value
my $start4 = 4;
my $incr6  = 6;
my $start  = $start4;
my $incr   = $incr6;
my $action = "comp";
my %text   =
    ( "simple",     " Detailed Segment Directory D"
    , "comp",       " Compressed Segment Directory C"
    , "contig",     " Tree"
    , "west",       "s (West)"
    , "east",       "s (East)"
    , "free",       "s (2-3-free)"
    , "crop",       "s (Regional)"
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

} elsif ($action =~ m{comp})   { # like "simple", but compressed segments
    $ffrail = scalar(@rails); # (is asserted)
    while ($ffrail < $maxn) {
        @rails[$ffrail] = &build_rail($ffrail);
        $ffrail += $incr6;
    } # while $ffrail
    &print_compressed();

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

} elsif ($action =~ m{west|east|free|crop}) { # follow railways down to the capital
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
            &print_1_rail($irail);
        }
        $irail += $incr;
    } # while $irail
    &print_rails_tail();
} # print_rails
#----------------
sub print_compressed {
    # output the resulting array
    &print_compressed_head();
    my $irail = $start;
    while ($irail < $maxn) {
        if (! defined($rails[$irail])) {
            $irail = $maxn; # break loop
        } else {
            &print_1_compressed($irail);
        }
        $irail += $incr;
    } # while $irail
    &print_compressed_tail();
} # print_compressed
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
    my @elem    = ($selem, $selem); # 2 parallel tracks: $elem[0] (upper, left), $elem[1] (lower, right)
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
            if (           ($elem[1] - 1) % 3 == 0) {
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
            if (           ($elem[0] - 1) % 3 == 0) {
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
        if (1) {
                $result .= ".$exp2:$exp3";
        } else { # no more
            if ($exp2 != 0) {
                $result .= ".$exp2";
            }
            if ($exp3 != 0) {
                $result .= ":$exp3";
            }
            if ($exp2 + $exp3 == 0) {
                $result .= ".";
            }
        } # no more
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
sub print_1_rail {
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
        my $ir;
        if (0) {
        } elsif ($mode =~ m{html}) {
            # print the northern track
            $ir = 1;
            print "<tr>"
                . "<td class=\"arc    \">$rail[0]</td>"
                . &cell_html(            $rail[1], "bor", $ir, "");
            $ir += 2;
            my $bold;
            while ($ir < scalar(@rail)) {
                my $id = "";
                $bold = "";
                if (      $rail[$ir    ] % $incr6 == $start4) {
                    $id = $rail[$ir    ];
                    if ($ir % 4 == 1) {
                        $bold = " seg";
                    }
                }
                if ($ir > 5 and $rail[$ir - 1] % $incr6 == $start4) {
                    $id = $rail[$ir - 1];
                }
                if ($ir <= 3) {
                    $bold = " sei";
                }
                print &cell_html($rail[$ir], "btr$bold", $ir, $id);
                $ir += 2;
            } # while $ir
            print "</tr>\n";

            # print the southern track
            print "<tr>"
                . "<td class=\"arl\">\&nbsp;</td>";
            print "<td class=\"arr\">\&nbsp;</td>";
            $ir = 2;
            while ($ir < scalar(@rail)) {
                $bold = "";
                if ($rail[$ir] % $incr6 == $start4) {
                    if ($ir % 4 == 2 and $ir > 5) {
                        $bold = " seg";
                    }
                }
                if ($ir <= 5) {
                    $bold = " sei";
                }
                print &cell_html($rail[$ir], "bbr$bold", $ir, "");
                $ir += 2;
            } # while $ir
            print "</tr>\n";
        } elsif ($mode =~ m{tsv} ) {
            print join($sep, @rail) . "\n";
        } # mode
    } # if defined
} # print_1_rail
#----------------
sub print_1_compressed {
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
            $ir = 1;
            print "<tr>"
                . "<td class=\"arc\">$rail[0]</td>"
                . &cell_html(        $rail[$ir], "bor", $ir, "");
            $ir += 4;
            my $step = 1;
            while ($ir < scalar(@rail)) {
                my $id = "";
                if (      $rail[$ir    ] % $incr6 == $start4) {
                    $id = $rail[$ir    ];
                    print &cell_html($rail[$ir], "bor seg", $ir, $id);
                }
                $ir += $step;
                $step = $step == 1 ? 3 : 1;
            } # while $ir
            print "</tr>\n";
        } elsif ($mode =~ m{tsv} ) {
            print join($sep, @rail) . "\n";
        } # mode
    } # if defined
} # print_1_compressed
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
                print &cell_html($rail[$ir], "btr", $ir, $ir);
                $ir += 2;
            } # while $ir
        } elsif ($action =~ m{east}) {
            $ir = scalar(@rail) - 2;
            while ($ir >= 0) {
                print &cell_html($rail[$ir], "btr", $ir, $ir);
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
        } elsif ($action =~ m{crop}) {
            my $region = 728;
            $ir = scalar(@rail) - 2;
            while ($ir >= 0) {
                if ($rail[$ir] <= $region) {
                    print &cell_html($rail[$ir], "btr"
                    . ($rail[$ir] <= 80 ? " d5" : "") , $ir, $ir);
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
sub cell_html { # print one table cell
    my ($elem, $border, $ir, $id) = @_;
    my $rest = $elem % $incr6;
    my $result = "<td";
    if ($rest == $start4) {
        # $result .= " title=\"$ir:" . &to_kernel($elem) . "\"";
        # $result .= " title=\"" . &to_kernel($elem) . "\"";
    }
    if ($id ne "") {
        $result .= " id=\"$id\"";
        # print STDERR "id2: $id\n";
    }
    $result .= " class=\"d$rest";
    if ($border ne "") {
        $result .= " $border";
    }
    if ($ir == 1) { # start element
        $result .= "\" id=\"A$elem\"><a href=\"\#$elem\">$elem</a>"; 
    } else {
    	if ($elem < $maxn) {
        	$result .=           "\"><a href=\"\#A$elem\">$elem</a>"; 
    	} else {
        	$result .=           "\">$elem"; 
    	}
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
<title>3x+1 $text{$action}</title>
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
.d4     { background-color: papayawhip     ; color: black;                   }
.d5     { background-color: lavender       ; color: gray;                    }
.seg    { font-weight: bold; }
.sei    { font-weight: bold; font-style    : italic; }
</style>
</head>
<body>
<h3>3x+1 $text{$action}</h3>
GFis
} # print_html_head
#----------------
sub print_rails_head {
    return if $mode ne "html";
    &print_preface();
    print <<"GFis";
<table>
<tr>
<td class="arc"> </td>
<td class="arc">1</td>
<td class="arc"> </td>
<td class="arc">2</td>
<td class="arc">3</td>
<td class="arc">4</td>
<td class="arc">5</td>
<td class="arc">6</td>
<td class="arc">7</td>
<td class="arc">8</td>
<td class="arc">9</td>
<td class="arc">...</td>
<td class="arc">2*j</td>
<td class="arc">2*j+1</td>
</tr>
<!--
# m m d m d m d m ...
# d m m d m d m d ...
-->
<tr>
<td class="arc        ">i</td>
<td class="arr bor    ">6*i&#8209;2</td>
<td class="arc btr    ">&micro;</td>
<td class="arc btr seg">&micro;&micro;</td>
<td class="arc btr    ">&micro;&micro;&delta;</td>
<td class="arc btr seg">&micro;&micro;&sigma;</td>
<td class="arc btr    ">&micro;&micro;&sigma;&delta;</td>
<td class="arc btr seg">&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc btr    ">&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc btr seg">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc btr    ">&micro;&micro;&sigma;<sup>3</sup>&delta;</td>
<td class="arc        ">...</td>
<td class="arc btr seg">&micro;&micro;&sigma;<sup>j-1</sup></td>
<td class="arc btr    ">&micro;&micro;&sigma;<sup>j-1</sup>&delta;</td>
</tr>
<tr>
<td class="arc        ">&nbsp;</td>
<td class="arr        ">&nbsp;</td>
<td class="arc bbr    ">&delta;</td>
<td class="arc bbr    ">&delta;&micro;</td>
<td class="arc bbr seg">&delta;&micro;&micro;</td>
<td class="arc bbr    ">&delta;&micro;&micro;&delta;</td>
<td class="arc bbr seg">&delta;&micro;&micro;&sigma;</td>
<td class="arc bbr    ">&delta;&micro;&micro;&sigma;&delta;</td>
<td class="arc bbr seg">&delta;&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bbr    ">&delta;&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc bbr seg">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc        ">...</td>
<td class="arc bbr    ">&delta;&micro;&micro;&sigma;<sup>j-2</sup>&delta;</td>
<td class="arc bbr seg">&delta;&micro;&micro;&sigma;<sup>j-1</sup></td>
</tr>
GFis
} # print_rails_head
#----------------
sub print_preface {
    print <<"GFis";
<p>
Generated with 
<a href="https://github.com/gfis/fasces/blob/master/oeis/collatz/collatz_rails.pl">Perl</a> 
at $timestamp;<br /> 
-&gt; <a href="http://www.teherba.org/index.php/OEIS/3x%2B1_Problem">Article 
about the 3x+1 problem</a> 
 from <a href="mailto:Georg.Fischer\@t-online.de">Georg Fischer</a>
<br />
<a href="#more">More information</a>
</p>
GFis
} # print_preface
#----------------
sub print_compressed_head {
    return if $mode ne "html";
    &print_preface();
    print <<"GFis";
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
<td class="arc">11</td>
<td class="arc">...</td>
<td class="arc">2*j</td>
<td class="arc">2*j+1</td>
</tr>
<!--
# m m d m d m d m ...
# d m m d m d m d ...
-->
<tr>
<td class="arc bor    ">i</td>
<td class="arr bor    ">6*i&#8209;2</td>
<td class="arc bor    ">&micro;&micro;</td>
<td class="arc bor    ">&delta;&micro;&micro;</td>
<td class="arc bor    ">&micro;&micro;&sigma;</td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;</td>
<td class="arc bor    ">&micro;&micro;&sigma;&sigma;</td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;&sigma;</td>
<td class="arc bor    ">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor    ">&micro;&micro;&sigma;<sup>4</sup></td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;<sup>4</sup></td>
<td class="arc        ">...</td>
<td class="arc bor    ">&micro;&micro;&sigma;<sup>j-1</sup></td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;<sup>j-1</sup></td>
</tr>
GFis
} # print_compressed_head
#----------------
sub print_rails_tail {
    return if $mode ne "html";
    print <<"GFis";
</table>
<p id="more">End of directory</p>
<p>
Root &lt;-&nbsp;&nbsp;&nbsp;numbers &#x2261;
<span class="d0">0</span>, <span class="d1">1</span>,
<span class="d2">2</span>, <span class="d3">3</span>,
<span class="d4">4</span>, <span class="d5">5</span> mod 6&nbsp;&nbsp;&nbsp;-&gt; &#x221e;
\&nbsp;\&nbsp;\&nbsp;\&nbsp;
<span class="sei">Inserted</span> <span class="seg">tree</span> nodes 
<br />
Longest segments:
<a href="#16">4</a>,
<a href="#160">40</a>,
<a href="#1456">364</a>,
<a href="#13120">3280</a>,
<a href="#118096">29524</a>
(OEIS <a href="http://oeis.org/A191681">A191681</a>)
</p>
<p>
The links on the left side (column 1) jump to the segment 
which contains that number in its right part, if
that segment was calculated. 
Successive klicks on the top left element will finally reach the root 4.
The links on the right part numbers jump to the corresponding segment.
</p>
GFis
} # print_rails_tail
#----------------
sub print_compressed_tail {
    &print_rails_tail();
} # print_compressed_tail
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
                 left    kern  col
<!--build_west1: 82              5-->
<!--build_west2: 82        7.1   5-->
<!--build_west2: 94        1.4  11-->
<!--build_west2: 364      61.0   3-->
<!--build_west2: 274      23.1   5-->
<!--build_west2: 310      13.2   7-->
<!--build_west2: 526      11.3   9-->
<!--build_west2: 1336    223.0   2-->
<!--build_west2: 334       7.3   9-->
<!--build_west2: 850      71.1   5-->
<!--build_west2: 958       5.5  12-->
<!--build_west2: 1822     19.4  10-->
<!--build_west2: 2308    385.0   3-->
<!--build_west2: 1732    289.0   3-->
<!--build_west2: 1300    217.0   3-->
<!--build_west2: 976     163.0   2-->
<!--build_west2: 244      41.0   3-->
<!--build_west2: 184      31.0   2-->
<!--build_west2: 46        1.3   8-->
<!--build_west2: 40        7.0   2-->
<!--build_west2: 10        1.1   4-->
<!--build_west2: 4         1.0  -->

<!--build_west1: 88-->
<!--build_west2: 88     5:1-->
<!--build_west2: 22     1.2-->
<!--build_west2: 40     7.-->
<!--build_west2: 10     1.1-->
<!--build_west2: 4      1.-->

# Railways to capital (-a long)
#   col1                col3n
#i  a[i]    kern(a[i])  4a[i+1] kern(4a[i+1])  len
1   82      7  .1     ->  376     7  :2        2   /4 ->
2   94      1  .4     ->  1456    1  :5        5   /4 ->
3   364     61 .0     ->  1096    61 :1        1   /4 ->
4   274     23 .1     ->  1240    23 :2        2   /4 ->
5   310     13 .2     ->  2104    13 :3        3   /4 ->
6   526     11 .3     ->  5344    11 :4        4   /4 ->
7   1336    223.0     ->  1336    223:0        0   /4 ->   =
8   334     7  .3     ->  3400    7  :4        4   /4 ->
9   850     71 .1     ->  3832    71 :2        2   /4 ->
10  958     5  .5     ->  7288    5  :5        5   /4 ->   *
11  1822    19 .4     ->  9232    19 :4        4   /4 ->   *
12  2308    385.0     ->  6928    385:1        1   /4 ->
13  1732    289.0     ->  5200    289:1        1   /4 ->
14  1300    217.0     ->  3904    217:1        1   /4 ->
15  976     163.0     ->  976     163:0        0   /4 ->   =
16  244     41 .0     ->  736     41 :1        1   /4 ->
17  184     31 .0     ->  184     31 :0        0   /4 ->   =
18  46      1  .3     ->  160     1  :3        3   /4 ->   *
19  40      7  .0     ->  40      7  :0        0   /4 ->   =
20  10      1  .1     ->  16      1  :1        1   /4 ->   *
21  4       1  .0     ->  4       1  :0        0   /4 ->   =
# "*" if 4a[i+1] occurs in column 3 south, i.e.
# (4a[i+1]-1) / 3 * 2 = a[i]
#-----------------------------------------------
[1] = 6n-2;         d6, s4      ; start
[2b] = 2n-1;        d2, s1      ; all odd
[2a] = [1]*2;       d12, s8
[3a] = [1]*4;       d24, s16    ; *
[3b] = [2b]*2;      d4, s2
[4a] = ([3a]-1)/3;  d8, s5
[4b] = [3b]*2;      d8, s4

[3b]                d12, s10    ; 10,22 mod 24
#-----------------------------------------------
bold only
[3a] = [1]*4;       d24, s16    ; 16,40 mod 48
[4b]                d24, s4     ; 4,28  mod 48
[5a]        ;       d48, s10    ; 10    mod 48
[6b]        ;       d48, s34    ; 34    mod 48 missing: 22,46
[7a]                d96, s70
[8b]                d192, s22
[9a]                d384, s46
#--------------------------------------------------
Col. source   target row
2   			<
	16@3    	@1
    40@7    	@2
    64@11   	@3
    88@15   	@4
3   			< (=)
	 4@1    	@1 = !
    28@5    	@4
    52@9    	@7
    76@13   	@10
4				<
	10@2		@1
	58@10		@4
	106@18		@7
	154@26		@10
5				>
	34@6		@7
	82@14		@16
	130@22		@25
	178@30		@34
6				<
   	70@12		@7  
   	166@28		@16 
   	262@44		@25 
   	358@60		@34 
7				>
	22@4		@7
	118@20		@34
	214@36		@61
	310@52		@88
8				<
	46@8		@7
	238@40		@34
	430@72		@61
	622@104		@88
9				>
	142@24		@61
	334@56		@142
	526@88		@223
	718@120		@304
10				>
	286@48		@61
	670@112		@142
	1054@176	@223
	1438@240   	@304 	
11				>
	94@16		@61
	478@80		@304
	862@144    	@547
	1246@208    @790	