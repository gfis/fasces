#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl
# Print a directory of segments in the Collatz graph
# @(#) $Id$
# 2018-11-15: copied from collatz_rails.pl
# 2018-11-12: mark supersegments
# 2018-11-06: links on all numbers for comp
# 2018-09-05: new kernel format; -a west|east|free|comp
# 2018-08-30, Georg Fischer: derived from collatz_roads.pl
#------------------------------------------------------
# Usage:
#   perl segment.pl [-n maxn] [-d debug] [-s 4] [-i 6] [-a comp] > comp.html
#       -n  maximum start value
#       -s  
#       -i  elements of the form k*i + s
#       -m  output mode: tsv, htm (no css), html, wiki, latex
#       -a  type of directory to be produced: detail, comp(ressed), super
#       -d  debug level: 0 (none), 1 (some), 2 (more)
# 
# See http://www.teherba.org/index.php/OEIS/3x%2B1_Problem
#--------------------------------------------------------
use strict;
use integer;
#----------------
# global constants
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $SEP       = "\t";
my $MAX_RULE  = 32;
my @RULENS    = (0, 1, 7, 61, 547, 4921, 44287, 398581, 3587227); # OEIS 066443
#----------------
# get commandline options
my $debug  = 0;
my $maxn   = 30000; # max. start value
my $start4 = 4;
my $incr6  = 6;
my $incr   = $incr6;
my $mode   = "html";
my $action = "comp";
my %text   =
    ( "detail",     " Detailed Segment Directory D"
    , "comp",       " Compressed Segment Directory C"
    );
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
        $start4 = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
# initialization
my $ffsegms  = 0;
my @segms;
my $isegms;
while ($ffsegms < $start4) { # $segms[0..3] are not used
    push(@segms, $ffsegms);
    $ffsegms ++;
} # while not used
&print_header();
&print_preface();
#----------------
# generate the segment directory
$ffsegms = scalar(@segms); # (is asserted)
while ($ffsegms < $maxn) {
    @segms[$ffsegms] = &generate_segment($ffsegms);
    $ffsegms += $incr6;
} # while $ffsegms
#----------------
# action for one of the possible forms of directories
if (0) { # switch action
	
} elsif ($action =~ m{\Acomp})   { # like "detail", but compressed segments
    $isegms = $start4;
    &print_compressed_head();
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            $isegms = $maxn; # break loop
        } else {
            &print_1_compressed($isegms);
        }
        $isegms += $incr;
    } # while $isegms
    # case compressed

} elsif ($action =~ m{\Adetail}) { # straightforward incrementing of the start values
    &print_detailed_head();
    $isegms = $start4;
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            $isegms = $maxn; # break loop
        } else {
            &print_1_detailed($isegms);
        }
        $isegms += $incr;
    } # while $isegms
    # case detail

} elsif ($action =~ m{\Asuper})   { # supersegments
	my @targets = (); # where must a supernode be attached
    $isegms = 1;
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            $isegms = $maxn; # break loop
        } elsif () {
            
        }
        $isegms += $incr;
    } # while $isegms

    $isegms = 1;
    &print_compressed_head();
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            $isegms = $maxn; # break loop
        } else {
            &print_1_compressed($isegms);
        }
        $isegms += $incr;
    } # while $isegms
    # case super

} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
&print_trailer();
# end main
#================================
sub generate_segment { # build and return a single segment starting with $selem
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
                print STDERR "# ** assertion 1 in generate_segment, elem=" . join(",", @elem) . "\n";
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
                print STDERR "# ** assertion 1 in generate_segment, elem=" . join(",", @elem) . "\n";
            }
        } else {
            die "# ** invalid state \"$state\"\n";
        }
        push(@result, $elem[0], $elem[1]);
        $len ++;
    } # while busy stepping
    if ($debug >= 1) {
        print "<!--generate_segment: " . join(";", @result) . "-->\n";
    }
    return join($SEP, @result);
} # generate_segment
#----------------
sub print_1_detailed {
    my ($index) = @_;
    if (! defined($segms[$index])) {
        $index = ($index + 2) / 6;
        if (0) {
        } elsif ($mode =~ m{\Atsv} ) {
            print "$index\n";
        } elsif ($mode =~ m{\Ahtm}) {
            print "<tr>" . &get_index($index) . "</tr>\n";
        } # mode
    } else {
        my @segment  = split(/$SEP/, $segms[$index]);
        my $ir;
        if (0) {
        } elsif ($mode =~ m{tsv} ) {
            print join($SEP, @segment) . "\n";
        } elsif ($mode =~ m{\Ahtm}) {
            # print the northern track
            $ir = 1;
            print "<tr>"
                . &get_index($segment[0])
                . &cell_html(            $segment[1], "bor", $ir, "");
            $ir += 2;
            my $bold;
            while ($ir < scalar(@segment)) {
                my $id = "";
                $bold = "";
                if (      $segment[$ir    ] % $incr6 == $start4) {
                    $id = $segment[$ir    ];
                    if ($ir % 4 == 1) {
                        $bold = " seg";
                    }
                }
                if ($ir > 5 and $segment[$ir - 1] % $incr6 == $start4) {
                    $id = $segment[$ir - 1];
                }
                if ($ir <= 3) {
                    $bold = " sei";
                }
                print &cell_html($segment[$ir], "btr$bold", $ir, $id);
                $ir += 2;
            } # while $ir
            print "</tr>\n";

            # print the southern track
            print "<tr>"
                . "<td class=\"arl\">\&nbsp;</td>";
            print "<td class=\"arr\">\&nbsp;</td>";
            $ir = 2;
            while ($ir < scalar(@segment)) {
                $bold = "";
                if ($segment[$ir] % $incr6 == $start4) {
                    if ($ir % 4 == 2 and $ir > 5) {
                        $bold = " seg";
                    }
                }
                if ($ir <= 5) {
                    $bold = " sei";
                }
                print &cell_html($segment[$ir], "bbr$bold", $ir, "");
                $ir += 2;
            } # while $ir
            print "</tr>\n";
        } # mode
    } # if defined
} # print_1_detailed
#----------------
sub print_1_compressed {
    my ($index) = @_;
    if (! defined($segms[$index])) {
        $index = ($index + 2) / 6;
        if (0) {
        } elsif ($mode =~ m{\Atsv} ) {
            print "$index\n";
        } elsif ($mode =~ m{\Ahtm}) {
            print "<tr>" . &get_index($index) . "</tr>\n";
        } # mode
    } else {
        my @segment  = split(/$SEP/, $segms[$index]);
        my $ir;
        if (0) {
        } elsif ($mode =~ m{tsv} ) {
            $ir = 1;
            print join($SEP, $segment[0], $segment[1]);
            $ir += 4;
            my $step = 1;
            while ($ir < scalar(@segment)) {
                if (      $segment[$ir    ] % $incr6 == $start4) {
                    print "$SEP$segment[$ir]";
                }
                $ir += $step;
                $step = $step == 1 ? 3 : 1;
            } # while $ir
            print "\n";
        } elsif ($mode =~ m{\Ahtm}) {
            $ir = 1;
            print "<tr>"
                . &get_index($segment[0])
                . &cell_html(        $segment[$ir], "bor", $ir, "");
            $ir += 4;
            my $step = 1;
            while ($ir < scalar(@segment)) {
                my $id = "";
                if (      $segment[$ir    ] % $incr6 == $start4) {
                    $id = $segment[$ir    ];
                    print &cell_html($segment[$ir], "bor seg", $ir, $id);
                }
                $ir += $step;
                $step = $step == 1 ? 3 : 1;
            } # while $ir
            print "</tr>\n";
        } # mode
    } # if defined
} # print_1_compressed
#----------------
sub get_index {
    my ($index) = @_;
    my ($rule, $target, $color) = &get_rule_target_color($index);
    my $result = "<td class=\"rule$rule\""
        . " title=\"($rule)->$target\">$index</td>";
    return $result;
} # get_index
#----------------
sub cell_html { # print one table cell
    my ($elem, $border, $ir, $id) = @_;
    my $rest = $elem % $incr6;
    my $result = "<td";
    if ($id ne "") {
        $result .= " id=\"$id\"";
        # print STDERR "id2: $id\n";
    }    
    my $degree = &get_degree($elem);
    if ($degree >= 2) {
	    my ($rule, $target, $color) = &get_rule_target_color($elem);
	    $target = ($elem + 2) / 6;
	    $result .= " title=\"($rule)->$target\"";
        $result .= " class=\"super$degree";
    } else {
        $result .= " class=\"d$rest";
    }
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
#------------------------
sub get_degree {
    my ($irow) = @_;
    my $result = 0;
    if (0) {
    } elsif (1 and $irow % 7776 - 7776 == -3110) {
        $result = 5;
    } elsif (1 and $irow % 1296 - 1296 ==  -518) {
        $result = 4;
    } elsif (1 and $irow %  216 -  216 ==   -86) {
        $result = 3;
    } elsif (1 and $irow %   36 -   36 ==   -14) {
        $result = 2;
    } elsif (1 and $irow %    6 -    6 ==    -2) {
        $result = 1;
    }
    return $result;
} # get_degree
#------------------------
sub get_rule_target_color {
    my ($irow) = @_;
    my $rule   = 2;
    my $target = 0;
    my $busy   = 1;
    my $tog31  = 3;
    my $exp2_2 = 1;
    my $exp2   = 4;
    my $exp3   = 1;
    my $irulen = 1;
    while ($busy == 1 and $rule <= $MAX_RULE) {
        my $subconst = $exp2_2 * $tog31;
        if ($irow % $exp2 == $subconst) { # mod cond.
            $busy = 0;
            $target = $exp3 * ($irow - $subconst) / $exp2 + $RULENS[$irulen];
            if ($debug >= 1) {
                print "rule=$rule, exp2=$exp2, exp2-2=$exp2_2, exp3=$exp3"
                    . ", subconst=$subconst, RULENS[$irulen]=$RULENS[$irulen]\n";
            }
        } else {
            $rule ++;
            if ($rule % 4 == 1) {
                $irulen ++;
            }
            if ($rule % 2 == 0) {
                $exp2   *= 2;
                $exp2_2 *= 2;
            } else {
                $exp3   *= 3;
                $tog31 = 4 - $tog31;
            }
        } # mod cond.
    } # while rules
    my $color = sprintf("\&#x%02x%02x%02x;", 0xff, $rule, 0xff);
    return ($rule, $target, $color);
} # get_rule_target_color
#----------------
sub print_header {
    if (0) {
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
<title>3x+1 $text{$action}</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
table   {  }
.arr    { background-color: white          ; color: black; }
.arc    { background-color: white          ; color: black; text-align: center;      }
.arl    { background-color: white          ; color: black; text-align: left;        }
.bor    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ; border-right : 1px solid gray    ; border-bottom: 1px solid gray ; }
.btr    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ; border-right : 1px solid gray    ; }
.bbr    { border-left  : 1px solid gray    ; border-right : 1px solid gray ; border-bottom: 1px solid gray ; }
.d0     { background-color: lemonchiffon   ; color: black;                   }
.d1     { background-color: lavender       ; color: black;                   }
.d2     { background-color: white          ; color: gray ;                   }
.d3     { background-color: lemonchiffon   ; color: gray;                    }
.d4     { background-color: papayawhip     ; color: black;                   }
.d5     { background-color: lavender       ; color: gray;                    }
.super2 { background-color: yellow         ; color: black                    }
.super3 { background-color: orange         ; color: white                    }
.super4 { background-color: crimson        ; color: white                    }
.super5 { background-color: aqua           ; color: black                    }
.rule2  { background-color: Lime           ; color: black                    }
.rule3  { background-color: LawnGreen      ; color: black                    }
.rule4  { background-color: Chartreuse     ; color: black                    }
.rule5  { background-color: LightSalmon    ; color: black                    }
.rule6  { background-color: SpringGreen    ; color: black                    }
.rule7  { background-color: DarkSalmon     ; color: black                    }
.rule8  { background-color: LightGreen     ; color: black                    }
.rule9  { background-color: LightCoral     ; color: white                    }
.rule10 { background-color: IndianRed      ; color: white                    }
.rule11 { background-color: Crimson        ; color: white                    }
.rule12 { background-color: Firebrick      ; color: white                    }
.seg    { font-weight: bold; }
.sei    { font-weight: bold; font-style    : italic; }
</style>
</head>
<body style=\"font-family: Verdana,Arial,sans-serif;\" >
<h3>3x+1 $text{$action}</h3>
GFis
    } else { # invalid mode
    }
} # print_header
#----------------
sub print_preface {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print <<"GFis";
#
# Generated with https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl at $TIMESTAMP
# Article: http://www.teherba.org/index.php/OEIS/3x%2B1_Problem by Georg Fischer
#
GFis
    } elsif ($mode =~ m{\Ahtm\Z}) {
        print <<"GFis";
<table style=\"border-collapse: collapse; text-align: right;  padding-right: 4px;\">
GFis
    } elsif ($mode =~ m{\Ahtml}) {
        print <<"GFis";
<p>
Generated with 
<a href="https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl">Perl</a> 
at $TIMESTAMP;<br /> 
<a href="http://www.teherba.org/index.php/OEIS/3x%2B1_Problem">Article 
about the 3x+1 problem</a> 
 by <a href="mailto:Dr.Georg.Fischer\@gmail.com">Georg Fischer</a>
<br />
<a href="#more">More information</a>
</p>
<table style=\"border-collapse: collapse; text-align: right;  padding-right: 4px;\">
GFis
    } else { # invalid mode
    }
} # print_preface
#----------------
sub print_detailed_head {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print "# Col.$SEP" . join($SEP, (1,2,3,4,5,6,7,8,9,10,11)) . "\n";
    } elsif ($mode =~ m{\Ahtm}) {
        print <<"GFis";
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
</tr>
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
</tr>
GFis
    } else { # invalid mode
    }
} # print_detailed_head
#----------------
sub print_compressed_head {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print "# Col.$SEP" . join($SEP, (1,2,3,4,5,6,7,8,9,10,11)) . "\n";
    } elsif ($mode =~ m{\Ahtm}) {
        print <<"GFis";
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
GFis
        print <<"GFis";
</tr>
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
</tr>
GFis
    } else { # invalid mode
    }
} # print_compressed_head
#----------------
sub print_trailer {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print "# End of directory\n";
    } elsif ($mode =~ m{\Ahtm\Z}) {
        print <<"GFis";
<!-- End of directory -->
GFis
    } elsif ($mode =~ m{\Ahtml}) {
        print <<"GFis";
</table>

<p id="more">End of directory</p>
<p>
Root &lt;-&nbsp;&nbsp;&nbsp;nodes &#x2261;
<span class="d0">\&nbsp;0</span>, <span class="d1">\&nbsp;1</span>,
<span class="d2">\&nbsp;2</span>, <span class="d3">\&nbsp;3</span>,
<span class="d4">\&nbsp;4</span>, <span class="d5">\&nbsp;5</span> mod 6&nbsp;&nbsp;&nbsp;-&gt; &#x221e;
\&nbsp;\&nbsp;\&nbsp;\&nbsp;
<span class="sei">Inserted</span> <span class="seg">tree</span> nodes 
<br />
GFis
        print "Rules <span class=\"rule2\">\&nbsp;2</span>"; 
        for (my $rule = 3; $rule <= 11; $rule ++) {
            print ", <span class=\"rule$rule\">\&nbsp;$rule</span>";
        } # for $rule
        print ".\&nbsp;\&nbsp;\&nbsp;\&nbsp;";  
        print "Nodes with degree <span class=\"d2\">\&nbsp;1</span>"; 
        for (my $degree = 2; $degree <= 5; $degree ++) {
            print ", <span class=\"super$degree\">\&nbsp;$degree</span>";
        } # for $degree
        print <<"GFis";
<br />
Longest segments:
<a href="#16">4</a>,
<a href="#160">40</a>,
<a href="#1456">364</a>,
<a href="#13120">3280</a>,
<a href="#118096">29524</a>,
265720, 2391484 (OEIS <a href="http://oeis.org/A191681">A191681</a>)
</p>
<p>
The links on the left side (column 1) jump to the segment 
which contains that number in its right part, if
that segment was calculated. 
Successive klicks on the top left element will finally reach the root 4.
The links on the right part numbers jump to the corresponding segment.
</p>
</body>
</html>
GFis
    } else { # invalid mode
    }
} # print_trailer
#================================
__DATA__
