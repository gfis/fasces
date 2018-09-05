#!perl

# Generate operations {d,m}^k which keeps numbers in {n|n = 4 mod 6}
# @(#) $Id$
# 2018-08-30, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl gen_invariants.pl [-n maxn] [-d debug]
#--------------------------------------------------------
use strict;
use integer;
#----------------
# get commandline options
my $debug  = 0;
my $maxn   = 24; # max. length of operation sequence
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
my $sep = "\t";
my @queue = ();
&print_html_head();
my ($len, $exp2, $exp3, $add, $expr) = ("0000", 0, 0, -2, "");
&enqueue($len, $exp2, $exp3, $add, $expr);
#----------------
while (scalar(@queue) > 0) {
    &dequeue();
    $len ++;
    # try multiplication *2
    if (1) { # m is always possible
        &enqueue($len, $exp2 + 1, $exp3, $add * 2      , $expr . "&micro;");
    }
    # try division -1/3
    if (($add - 1) % 3 == 0) { # d possible
        &enqueue($len, $exp2, $exp3 + 1, ($add - 1) / 3, $expr . "&delta;");
    } # d possible
} # while
#----------------
# termination
&print_html_tail();
# end main
#----------------
sub dequeue { # queue the parameter
    @queue = sort(@queue); # dequeue shortes entries first
    ($len, $exp2, $exp3, $add, $expr) = split(/$sep/, shift(@queue)); # process this entry
} # dequeue
#----------------
sub enqueue { # queue an entry
    my ($len, $exp2, $exp3, $add, $expr) = @_;
    if ($len < $maxn) {
        my $busy = 1; # suppose we shall queue the entry
        my $formula = "<td>"
            . ($exp2 > 1 ? "2^$exp2*" : "") . "6*"
            . ($exp3 > 0 ? "3^-$exp3*n" : "n")
            . "$add"
            . "</td><td>$expr</td>"
            ;
            ;
        if ($debug >= 1) {
            print "enqueue $formula; add % 6 = " . ($add % 6) . "\n";
        }
        # evaluate
        if (0) {
        } elsif ($add % 3 == 0) {
            print "<tr>$formula<td>% 3 ...</td></tr>\n";
            $busy = 0; # only m will follow, not necessary to look at that trivial path
        } elsif ($add % 6 == -2) {
            print "<tr>$formula<td>6x-2, ";
            if ($add == -2) {
                print "same n";
            } else {
                my $shift = (- $add / 6);
                print "n-$shift";
            }
            print "</td></tr>\n";
        }
        if ($busy == 1) { # reprocess
            push(@queue, join($sep, ($len, $exp2, $exp3, $add, $expr)));
        }
    } # length not exceeded
} # enqueue
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
<title>Invariant Words</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/collatz/collatz_rails.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; }
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
<h3>Invariant Words</h3>
<table>
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
#================================
__DATA__
