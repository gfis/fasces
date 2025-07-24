#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/coltree.pl
# Build and print the Collatz tree
# @(#) $Id$
# 2022-10-16, Georg Fischer: recovered from C19
#------------------------------------------------------
# Usage:
#   perl coltree.pl [-d debug] [-p 24] [-s 16] > coltree.html
#       -a  type of directory to be produced:
#           deta[il}, comp[ress], doub[le], style, test<i>, super
#       -d  debug level: 0 (none), 1 (some), 2 (more)
#       -m  output mode: tsv, htm (no css), htm[l], latex
#       -p  2**p is the maximum node on the main branch
#       -r  2**r is the maximum level of dependant branches
#       -s
#--------------------------------------------------------
use strict;
use integer;
#----------------
# global constants
my $VERSION = "V1.0";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min);
my $SEP       = "\t";

# get commandline options
my $action = "detail";
my $debug  = 0;
my $mode   = "html";
my $pmax   = 24;
my $rmax   = 64;
my $start  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $mode   = shift(@ARGV);
    } elsif ($opt =~ m{p}) {
        $pmax   = shift(@ARGV);
    } elsif ($opt =~ m{r}) {
        $rmax   = shift(@ARGV);
    } elsif ($opt =~ m{s}) {
        $start  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $colspan = 1;
my $subset = "";
my %text   =
    ( "detail"  , " Collatz Tree"
    );
#----------------
# initialization
&print_html_header();
&print_preface();
#----------------
my @arrs = ();
my @aops = ();
&powRow();
&divRow(0);
# &mulRow(1);
my $irow = 1;
while ($irow < $rmax) { # expand each row
    if ($aops[$irow] =~ m{d\Z}) { # created by "divRow", odd terms
        &mulRow($irow);
        # &divRow($irow);
    } else { # created by "mulRow", even terms
        &mulRow($irow);
        &divRow($irow);
    }
    $irow ++;
} # while expanding
&printArray();
&print_trailer();
exit(0);
#----------------
sub powRow { # create a row with powers of 2
    my @row = ();
    my $pow2 = 16;
    for (my $icol = 0; $icol < $pmax; $icol ++) {
        $row[$icol] = $pow2;
        $pow2 *= 4;
    } # for $icol
    push(@arrs, [ @row ]);
    push(@aops, "");
} # powRow
#----------------
sub mulRow { # multiply a row by 2
    my ($irow) = @_;
    my @row = ();
    for (my $icol = 0; $icol < $pmax; $icol ++) {
        $row[$icol] = $arrs[$irow][$icol] * 2;
    } # for $icol
    push(@arrs, [ @row ]);
    push(@aops, $aops[$irow] . "n");
} # mulRow
#----------------
sub divRow { # subtract 1 and try to divide by 3
    my ($irow) = @_;
    my @row = ();
    for (my $icol = 0; $icol < $pmax; $icol ++) {
        my $sub1 = $arrs[$irow][$icol] - 1;
        $row[$icol] = ($sub1 % 3 == 0) ? $sub1 / 3 : 0;
    } # for $icol
    push(@arrs, [ @row ]);
    push(@aops, $aops[$irow] . "d");
} # mulRow
#----------------
sub printArray { # print the whole array
    if (0) {
    } elsif ($mode =~ m{\Ahtm}) {
        # print "<table>\n";
    } elsif ($mode =~ m{\Atsv}) {
    }
    for (my $irow = 0; $irow < scalar(@arrs); $irow ++) {
        if (0) {
        } elsif ($mode =~ m{\Ahtm}) {
            print "<tr><td class=\"bor\">$aops[$irow]";
        } elsif ($mode =~ m{\Atsv}) {
            print "\n";
        }
        for (my $icol = 0; $icol < $pmax; $icol ++) {
            if (0) {
            } elsif ($mode =~ m{\Ahtm}) {
                my $elem = $arrs[$irow][$icol];
                if ($elem == 0) {
                    print "</td><td class=\"bor\">";
                } else {
                    print "</td><td class=\"bor\" title=\"" . sprintf("%b", $elem) . "\">$elem";
                }
            } elsif ($mode =~ m{\Atsv}) {
                print "\t" . $arrs[$irow][$icol];
            }
        } # for $icol
        if (0) {
        } elsif ($mode =~ m{\Ahtm}) {
            print "</td></tr>\n";
        } elsif ($mode =~ m{\Atsv}) {
            print "\n";
        }
    } # for $irow
    if (0) {
    } elsif ($mode =~ m{\Ahtm}) {
        # print "</table>\n";
    } elsif ($mode =~ m{\Atsv}) {
        print "\n";
    }
} # printArray
#----------------
sub print_style {
    my $stylesheet = <<"GFis";
.arr    { background-color: white          ; color: black; text-align: right        }
.arc    { background-color: white          ; color: black; text-align: center;      }
.arl    { background-color: white          ; color: black; text-align: left;        }
.bor    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ;
          border-right : 1px solid gray    ; border-bottom: 1px solid gray ;
    /*
          border-bottom-left-radius: 50px;
          padding: 5px;
    */
        }
.btr    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ; border-right : 1px solid gray    ; }
.bbr    { border-left  : 1px solid gray    ; border-right : 1px solid gray ; border-bottom: 1px solid gray ; }
.bot    { border-bottom: 1px solid gray ;  }
.d0     { background-color: lemonchiffon   ; color: black; }
.d1     { background-color: lavender       ; color: black; }
.d2     { background-color: white          ; color: black; }
.d3     { background-color: lemonchiffon   ; color: black; }
.super1
.d4     { background-color: khaki          ; color: black; }
.d5     { background-color: lavender       ; color: black; }
.super2 { background-color: yellow         ; color: black; }
.super3 { background-color: gold           ; color: black; }
.super4 { background-color: coral          ; color: white; }
.super5 { background-color: crimson        ; color: white; }
.super6 { background-color: firebrick      ; color: white; }
.super7 { background-color: black          ; color: white; }
.super8 { background-color: black          ; color: white; }
.super3 a { color: inherit; }
.super4 a { color: inherit; }
.super5 a { color: inherit; }
.super6 a { color: inherit; }
.super7 a { color: inherit; }
.super8 a { color: inherit; }
.rule5  { background-color: Lime           ; color: white; }
.rule6  { background-color: LawnGreen      ; color: white; }
.rule9  { background-color: Chartreuse     ; color: white; }
.rule10 { background-color: LightBlue      ; color: white; }
.rule13 { background-color: SpringGreen    ; color: white; }
.rule14 { background-color: SkyBlue        ; color: white; }
.rule17 { background-color: LightGreen     ; color: white; }
.rule18 { background-color: DeepSkyBlue    ; color: white; }
.rule21 { background-color: Blue           ; color: white; }
.rule22 { background-color: DarkBlue       ; color: white; }
.rule25 { background-color: DarkBlue       ; color: white; }
.rule26 { background-color: DarkBlue       ; color: white; }
.rule29 { background-color: DarkBlue       ; color: white; }
.rule30 { background-color: DarkBlue       ; color: white; }
.seg    { font-weight: bold; }
.sei    { /* font-weight: bold; */
          font-style    : italic; }
GFis
    if (0) {
    } elsif ($action =~ m{\Astyle}) {
        print "$stylesheet\n";
    } elsif ($mode =~ m{\Ahtm\Z}) {
    } elsif ($mode =~ m{\Ahtml}) {
        print "<link rel=\"stylesheet\" href=\"stylesheet.css\" />\n"; # new code; separate stylesheet
    } elsif ($mode =~ m{\Ahtml}) { # old code, stylesheet included in HTML
        print "<style>\n$stylesheet\n</style>\n";
    } # ignore for tsv etc.
} # print_style
#----------------
sub print_head {
    if (0) { # switch action
    } elsif ($action =~ m{\Adeta})   {
        &print_detail_head  ();
    } else {
    }
} # print_head
#------------------------
sub print_html_header {
    if (0) {
    } elsif ($action =~ m{\Astyle}) {
        # ignore
    } elsif ($mode =~ m{\Atsv}) {
        print <<"GFis";
# 3x+1 $text{$action}
GFis
    } elsif ($mode =~ m{\Ahtm\Z}) {
        print <<"GFis";
<!-- 3x+1 $text{$action} -->
GFis
    } elsif ($mode =~ m{\Ahtml}) {
        print <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$text{$action}</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/collatz/coltree.pl" />
<meta name="author"    content="Georg Fischer" />
GFis
        &print_style();
        print <<"GFis";
</head>
<body style=\"font-family: Verdana,Arial,sans-serif;\" >
<h3 id="start">3x+1 $text{$action}</h3>
GFis
    } else { # invalid mode
    }
} # print_html_header
#----------------
sub print_preface {
    if (0) {
    } elsif ($action =~ m{\Astyle}) {
        # ignore
    } elsif ($mode =~ m{\Atsv}) {
        print <<"GFis";
#
# Generated with https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl $VERSION at $TIMESTAMP
# Article: http://www.teherba.org/index.php/OEIS/3x%2B1_Problem by Georg Fischer
#
GFis
    } elsif ($mode =~ m{\Ahtm\Z}) {
        print <<"GFis";
<table style=\"border-collapse: collapse; text-align: right;  padding-right: 4px;\"><!--$TIMESTAMP-->
GFis
    } elsif ($mode =~ m{\Ahtml}) {
        print <<"GFis";
<p>
Generated with
<a href="https://github.com/gfis/fasces/blob/master/oeis/collatz/coltree.pl" target="_blank">coltree.pl</a>
$VERSION at $TIMESTAMP;
</p>
<table style=\"border-collapse: collapse; text-align: right;  padding-right: 4px;\">
GFis
    } else { # invalid mode
    }
} # print_preface
#----------------
sub print_detail_head {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print "# Col.$SEP" . join($SEP, (1,2,3,4,5,6,7,8,9,10,11)) . "\n";
    } elsif ($mode =~ m{\Ahtm}) {
        print <<"GFis";
<tr>
<td class="arl bot" colspan="$colspan">Column</td>
<td class="arc    ">1</td>
<td class="arc    ">2</td>
<td class="arc    ">3</td>
<td class="arc    ">4</td>
<td class="arc seg">5</td>
<td class="arc seg">6</td>
<td class="arc    ">7</td>
<td class="arc    ">8</td>
<td class="arc seg">9</td>
<td class="arc seg">10</td>
<td class="arc    ">11</td>
<td class="arc    ">12</td>
<td class="arc seg">13</td>
<td class="arc seg">14</td>
<td class="arc    ">15</td>
<td class="arc    ">16</td>
<td class="arc seg">17</td>
<td class="arc seg">18</td>
<td class="arc    ">19</td>
<td class="arc    ">20</td>
</tr>
<tr>
GFis
        print &get_index_head0();
        print <<"GFis";
<td class="arc bor           ">LS</td>
<td class="arc bor           ">&delta;</td>
<td class="arc bor           ">&micro;</td>
<td class="arc bor           ">&delta;&micro;</td>
<td class="arc bor seg rule5 ">&micro;&micro;</td>
<td class="arc bor seg rule6 ">&delta;&micro;&micro;</td>
<td class="arc bor           ">&micro;&micro;&delta;</td>
<td class="arc bor           ">&delta;&micro;&micro;&delta;</td>
<td class="arc bor seg rule9 ">&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg rule10">&delta;&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor           ">&micro;&micro;&sigma;<sup>1</sup>&delta;</td>
<td class="arc bor           ">&delta;&micro;&micro;&sigma;<sup>1</sup>&delta;</td>
<td class="arc bor seg rule13">&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg rule14">&delta;&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor           ">&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc bor           ">&delta;&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc bor seg rule17">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg rule18">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor           ">&micro;&micro;&sigma;<sup>3</sup>&delta;</td>
<td class="arc bor           ">&delta;&micro;&micro;&sigma;<sup>3</sup>&delta;</td>
</tr>
GFis
    } else { # invalid mode
    }
} # print_detail_head
#----------------
sub print_trailer {
    if (0) {
    } elsif ($action =~ m{\Astyle}) {
        # ignore
    } elsif ($mode =~ m{\Atsv}) {
        print "# End of directory\n";
    } elsif ($mode =~ m{\Ahtm\Z}) {
        print <<"GFis";
</table>
<!-- End of directory -->
GFis
    } elsif ($mode =~ m{\Ahtml}) {
        print <<"GFis";
</table>

<p id="more">End of directory; back to <a href="#start">start</a> </p>
</body>
</html>
GFis
    } else { # invalid mode
    }
} # print_trailer
#================================
__DATA__

dndnd 151         39768215                        10424999137431
      10010111    10010111 1011010000 10010111    10010111 1011010000 10010111 1011010000 10010111
      
dnndnd			75									19884107									5212499568715
      			1001011								1001011 11011010000 1001011					1001011 11011010000 1001011 11011010000 1001011
      			
dndnnd							19417									5090331609									1334399889591257	
								100101111011001							100101111011010000 100101111011001			100101111011010000 100101111011010000 100101111011001