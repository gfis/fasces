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
#       -a  type of directory to be produced: detail, compress, double, super
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
my $MAX_RULE  = 64; # rule 7 has 4 mod 16, rule 11 has 16 mod 64
my @RULENS    = (0, 1, 7, 61
	, 547, 4921, 44287, 398581
	, 3587227, 32285041, 290565367, 2615088301); # OEIS A066443
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
    ( "detail"  , " Detailed   Segment Directory D"
    , "comp"    , " Compressed Segment Directory C"
    , "double"  , " Double     Segment Directory D2 "
    , "super"   , " Supersegment Directory S"
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
    &print_compress_head();
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            $isegms = $maxn; # break loop
        } else {
            &print_1_compress($isegms);
        }
        $isegms += $incr;
    } # while $isegms
    # case compress

} elsif ($action =~ m{\Adouble}) { # two lines per segment
    &print_double_head();
    $isegms = $start4;
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            $isegms = $maxn; # break loop
        } else {
            &print_1_double($isegms);
        }
        $isegms += $incr;
    } # while $isegms
    # case double

} elsif ($action =~ m{\Adetail}) { # like "double", but in one line
    &print_detail_head();
    $isegms = $start4;
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            $isegms = $maxn; # break loop
        } else {
            &print_1_detail($isegms);
        }
        $isegms += $incr;
    } # while $isegms
    # case detail

} elsif ($action =~ m{\Asuper})   { # supersegments
    my @prev = (); # where the segment must be attached, or 0
    my @next = (); # which segment attaches to the last, or 0
    if ($debug >= 1) {
      	print sprintf("%6s:%6s  %6s  | %6s %2s rul > %6s  ...[%2s]  %6s %2s Rul > %6s\n"
			, "index", "prev", "next", "lehs", "dg", "letar", "il", "last", "dg", "latar");
    }
    $isegms = $start4;
    my $index;
    while ($isegms < $maxn) {
        if (! defined($segms[$isegms])) {
            # $isegms = $maxn; # break loop
        } elsif (($isegms - 1) % 3 == 0) { # only rows 1, 4, 7 ... targets of rules >= 3
            my @segment  = split(/$SEP/, $segms[$isegms]);
            $index    = $segment[0];
            if ($index % 3 == 1) { # rows 1, 4, 7 ...
                $prev[$index] = 0;
                $next[$index] = 0;
                my $lehs      = $segment[1];
                my ($lehs_rule, $lehs_tar) = get_rule_target($index);
                my $lehs_deg  = &get_degree($lehs);
                my $ilast     = scalar(@segment) - 1;
                while ($ilast > 0 and $segment[$ilast] % 36 != 22) { # look for degree >= 2
                    $ilast --;
                }
                my $last      = $segment[$ilast];
                my ($last_rule, $last_tar) = get_rule_target($last);
                my $last_deg  = &get_degree($last);
                if (0) {
                } elsif ($ilast == 0) { # no degree >= 2 in whole segment
                } elsif ($ilast == 1) { # lehs only has degree >= 2
                        $prev[$index] = $lehs_tar;
                    #   $next[$index] = ($last + 2) / 6;
                } else { # there is a degree >= 2 in the right part
                    if ($lehs_deg >= 2) { # both have degree >= 2
                        $prev[$index] = $lehs_tar;
                        $next[$index] = ($last + 2) / 6;
                    } else { # only in the right part
                    #   $prev[$index] = $lehs_tar;
                        $next[$index] = ($last + 2) / 6;
                    }
                } # degree >= 2 in the right part

                if ($debug >= 1) {
                    # print join(" ", map { sprintf("%4d", $_) } @segment) . " # ";
                    print sprintf("%6d:%6dp %6dn | %6d %2s r%-2s > %6d  ...[%2d]  %6d %2s R%-2s > %6d\n"
                        , $index
                        , $prev[$index], $next[$index]
                        , $lehs
                        , ($lehs_deg  <= 1 ? "  " : $lehs_deg )
                        , ($lehs_rule <= 3 ? "  " : $lehs_rule)
                        , $lehs_tar
                        , $ilast, $last
                        , ($last_deg  <= 1 ? "  " : $last_deg )
                        , $last_rule
                        , $last_tar
                        );
                } # debug
            } # rows 1, 4, 7 ...
        } # targets of rules >= 3
        $isegms += 3;
    } # while $isegms

    $index = 1;
    while ($index < $maxn) {
        if (defined($prev[$index]) and $prev[$index] == 0) { # was not attachable
       		my ($node_rule, $node_tar) = &get_rule_target($index);
        	print sprintf("%6d %2d: ", $index, $node_rule);
        	my $tar = $next[$index];
        	while ($tar > 0) {
        		($node_rule, $node_tar) = &get_rule_target($tar);
        		print "\t$tar,$node_rule";
        		$tar = $next[$tar];
        	}
        	print "\n";	
        } # not attachable
        $index ++;
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
    if ($debug >= 3) {
        print "<!--generate_segment: " . join(";", @result) . "-->\n";
    }
    return join($SEP, @result);
} # generate_segment
#----------------
sub print_1_double {
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
                . "<td class=\"arl\">\&nbsp;</td>"
                . "<td class=\"arl\">\&nbsp;</td>"
                . "<td class=\"arr\">\&nbsp;</td>"
                ;
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
} # print_1_double
#----------------
sub print_1_compress {
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
        my @segment = split(/$SEP/, $segms[$index]);
        my $ir;
        if (0) {
        } elsif ($mode =~ m{tsv} ) {
            print join($SEP, $segment[0], $segment[1]);
            $ir = 5;
            my $step = 1;
            while ($ir < scalar(@segment)) {
                if ($segment[$ir] % $incr6 == $start4) {
                    print "$SEP$segment[$ir]";
                }
                $ir += $step;
                $step = $step == 1 ? 3 : 1;
            } # while $ir
            print "\n";
        } elsif ($mode =~ m{\Ahtm}) {
            print "<tr>"
                . &get_index($segment[0])
                . &cell_html($segment[1], "bor", 1, "");
            $ir = 5;
            my $step = 1;
            while ($ir < scalar(@segment)) {
                my $id = "";
                if ($segment[$ir] % $incr6 == $start4) {
                    $id = $segment[$ir];
                    print &cell_html($segment[$ir], "bor seg", $ir, $id);
                }
                $ir += $step;
                $step = $step == 1 ? 3 : 1;
            } # while $ir
            print "</tr>\n";
        } # mode
    } # if defined
} # print_1_compress
#----------------
sub print_1_detail {
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
        my @segment = split(/$SEP/, $segms[$index]);
        my $ir;
        if (0) {
        } elsif ($mode =~ m{tsv} ) {
            print join($SEP, @segment) . "\n";
        } elsif ($mode =~ m{\Ahtm}) {
            print "<tr>"
                . &get_index($segment[0])
                . &cell_html($segment[1], "bor", 1, "");
            $ir = 2;
            my $step = 1;
            while ($ir < scalar(@segment)) {
                my $id = $segment[$ir];
                my $bold = "";
                if ($segment[$ir] % $incr6 == $start4) {
                    if ($ir % 4 == 1 or ($ir % 4 == 2 and $ir > 5)) {
                        $bold = " seg";
                    }
                }
                print &cell_html($segment[$ir], "bor$bold", $ir, $id);
                $ir += $step;
            } # while $ir
            print "</tr>\n";
        } # mode
    } # if defined
} # print_1_detail
#----------------
sub get_index {
    my ($index) = @_;
    my ($rule, $target) = &get_rule_target($index);
    my $result = "<td class=\"arc\">$index</td>"
    	.        "<td class=\"arc rule$rule\" title=\"($rule)->$target\">$rule</td>"
    	;
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
        my ($rule, $target) = &get_rule_target($elem);
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
        if ($elem < $maxn and $elem % $incr6 == $start4) {
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
    if (0) { # A000400: 46656, 279936, 1679616, 10077696
             # A005610: 2, 14, 86, 518, 3110, 18662, 111974, 671846, 4031078
    } elsif (1 and $irow %  46656 -  46656 ==  -18662) {
        $result = 5;
    } elsif (1 and $irow %   7776 -   7776 ==   -3110) {
        $result = 5;
    } elsif (1 and $irow %   1296 -   1296 ==    -518) {
        $result = 4;
    } elsif (1 and $irow %    216 -    216 ==     -86) {
        $result = 3;
    } elsif (1 and $irow %     36 -     36 ==     -14) {
        $result = 2;
    } elsif (1 and $irow %      6 -      6 ==      -2) {
        $result = 1;
    }
    return $result;
} # get_degree
#------------------------
sub get_rule_target {
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
            if ($debug >= 3) {
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
    return ($rule, $target);
} # get_rule_target
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
.arr    { background-color: white          ; color: black; text-align: right        }
.arc    { background-color: white          ; color: black; text-align: center;      }
.arl    { background-color: white          ; color: black; text-align: left;        }
.bor    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ; border-right : 1px solid gray    ; border-bottom: 1px solid gray ; }
.btr    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ; border-right : 1px solid gray    ; }
.bbr    { border-left  : 1px solid gray    ; border-right : 1px solid gray ; border-bottom: 1px solid gray ; }
.bot    { border-bottom: 1px solid gray ; }
.d0     { background-color: lemonchiffon   ; color: black; }
.d1     { background-color: lavender       ; color: black; }
.d2     { background-color: white          ; color: black; }
.d3     { background-color: lemonchiffon   ; color: black; }
.d4     { background-color: papayawhip     ; color: black; }
.d5     { background-color: lavender       ; color: black; }
.super2 { background-color: yellow         ; color: black; }
.super3 { background-color: orange         ; color: white; }
.super4 { background-color: crimson        ; color: white; }
.super5 { background-color: aqua           ; color: black; }
.rule2  { background-color: Lime           ; color: black; }
.rule3  { background-color: LawnGreen      ; color: black; }
.rule4  { background-color: Chartreuse     ; color: black; }
.rule5  { background-color: LightSalmon    ; color: black; }
.rule6  { background-color: SpringGreen    ; color: black; }
.rule7  { background-color: DarkSalmon     ; color: black; }
.rule8  { background-color: LightGreen     ; color: black; }
.rule9  { background-color: LightCoral     ; color: white; }
.rule10 { background-color: IndianRed      ; color: white; }
.rule11 { background-color: Crimson        ; color: white; }
.rule12 { background-color: Firebrick      ; color: white; }
.rule13 { background-color: Firebrick      ; color: white; }
.rule14 { background-color: Firebrick      ; color: white; }
.rule15 { background-color: Firebrick      ; color: white; }
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
sub print_double_head {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print "# Col.$SEP" . join($SEP, (1,2,3,4,5,6,7,8,9,10,11)) . "\n";
    } elsif ($mode =~ m{\Ahtm}) {
        print <<"GFis";
<tr>
<td class="arl bot" colspan="2">Column</td>
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
<td class="arc bor    ">i</td>
<td class="arc bor    ">R</td>
<td class="arr btr    ">6*i&#8209;2</td>
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
<td class="arc bbr    ">LHS   </td>
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
} # print_double_head
#----------------
sub print_compress_head {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print "# Col.$SEP" . join($SEP, (1,2,3,4,5,6,7,8,9,10,11)) . "\n";
    } elsif ($mode =~ m{\Ahtm}) {
        print <<"GFis";
<tr>
<td class="arl bot" colspan="2">Column</td>
<td class="arc    ">1</td>
<td class="arc seg">5</td>
<td class="arc seg">6</td>
<td class="arc seg">9</td>
<td class="arc seg">10</td>
<td class="arc seg">13</td>
<td class="arc seg">14</td>
<td class="arc seg">17</td>
<td class="arc seg">18</td>
<td class="arc seg">21</td>
<td class="arc seg">22</td>
GFis
        print <<"GFis";
</tr>
<tr>
<td class="arc bor    ">i</td>
<td class="arc bor    ">R</td>
<td class="arr bor    ">6*i&#8209;2</td>
<td class="arc bor seg">&micro;&micro;</td>
<td class="arc bor seg">&delta;&micro;&micro;</td>
<td class="arc bor seg">&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg">&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg">&micro;&micro;&sigma;<sup>4</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>4</sup></td>
</tr>
GFis
    } else { # invalid mode
    }
} # print_compress_head
#----------------
sub print_detail_head {
    if (0) {
    } elsif ($mode =~ m{\Atsv}) {
        print "# Col.$SEP" . join($SEP, (1,2,3,4,5,6,7,8,9,10,11)) . "\n";
    } elsif ($mode =~ m{\Ahtm}) {
        print <<"GFis";
<tr>
<td class="arl bot" colspan="2">Column</td>
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
<td class="arc bor    ">i</td>
<td class="arc bor    ">R</td>
<td class="arr bor    ">6*i&#8209;2</td>
<td class="arc bor    ">&delta;</td>
<td class="arc bor    ">&micro;</td>
<td class="arc bor    ">&delta;&micro;</td>
<td class="arc bor seg">&micro;&micro;</td>
<td class="arc bor seg">&delta;&micro;&micro;</td>
<td class="arc bor    ">&micro;&micro;&delta;</td>
<td class="arc bor    ">&delta;&micro;&micro;&delta;</td>
<td class="arc bor seg">&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor    ">&micro;&micro;&sigma;<sup>1</sup>&delta;</td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;<sup>1</sup>&delta;</td>
<td class="arc bor seg">&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor    ">&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc bor seg">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor    ">&micro;&micro;&sigma;<sup>3</sup>&delta;</td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;<sup>3</sup>&delta;</td>
<!--
<td class="arc bor seg">&micro;&micro;&sigma;<sup>4</sup></td>
<td class="arc bor seg">&delta;&micro;&micro;&sigma;<sup>4</sup></td>
<td class="arc bor    ">&micro;&micro;&sigma;<sup>4</sup>&delta;</td>
<td class="arc bor    ">&delta;&micro;&micro;&sigma;<sup>4</sup>&delta;</td>
-->
</tr>
GFis
    } else { # invalid mode
    }
} # print_detail_head
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
# k = 0,1,2,3 ... old rule - new rule
# 
# R2 16,40,64,88     	=> 	4,10,16,22
# r2
s = 4*6*k - 8     			
s = 6*(1*(4*k + 3)) - 2	
t = 6*1*k-2
t = 6*(1*(k           ) -2
#  0 mod 8, 2 / 4 6 mod 8
#  
# R3 4,28,52,76      	=> 	4,22,40,58    R6
# r3
s = 4*6*k - 20   			
s = 6*(1*(4*k + 1)) - 2  	
t = 3*6*k+4 
t = 6*(1*(3*k + 1)     ) - 2 
t = 1*(6*(3*k + 1)     ) - 2 
#  4 mod 8, 2 6 / 10 14 mod 16
#  
# R4 10,58,106,154   	=> 	4,22,40,58    R9
# r4
s = 8*6*k - 38    			
s = 6*(2*(4*k + 1)) - 2  	
t = 6*3*k+4
t = 6*(1*(3*k + 1)    ) - 2
t = 1*(6*(3*k + 1)    ) - 2
#  10 mod 16, 2 6 / 14 mod 16
# 
# R5 34,82,130,178   	=> 	40,94,148,202 R10
# r5
s = 8*6*k - 14     		
t = 6*(3*(3*k + 2) - 2) - 2
t = 6*(9*k + 7) - 2
t = 3*(6*(3*k + 1) - 8) - 2
#  2 mod 16, 6 14 / 22 30 mod 32
#  
# R6 70,166,262,358  	=> 	40,94,148,202 R13
# r7
s = 6*(4*(4*k + 3)) - 2	
t = 6*(3*(3*k + 3) - 2) - 2
#  6 mod 32, 14 / 22 30 mod 32
# 
# R7 22,118,214,310   	=> 	40,202,364,526 R14
# r7
s = 6*(4*(4*k + 1)) - 2	
t = 6*(9*(3*k + 1) - 2) - 2
#  22 mod 32, 14 30 / 46 62 mod 64
#  
# R8  46,238,430,622   	=> 	40,202,364,526  R17
# r8	8,40,72,104				7,34,61,88
s = 6*(8*(4*k + 1)) - 2	
t = 6*(9*(3*k + 1) - 2) - 2
#  46 mod 64, 14 30 / 62 mod 64
# 
# R9 142,334,526,718  	=> 	364,850,1336,1822 R18
# r9	24,56,88,120	   	61,142,223,304
s = 6*(8*(4*k + 3)) - 2	
t = 6*27*k+40
t = 6*(27*(3*k + 1) - 2) - 2
#  14 mod 64, 30 62 / 94 126 mod 128
# 
# R10 286,670,1054,1438 =>	364,850,1336,1822 R21
# r10 48,112,176,240     		61,142,223,304
s = 6*(16*(4*k + 3)) - 2	
t = 6*27*k+40
t = 6*(27*(3*k + 1) - 2) - 2
#  30 mod 128, 62 / 94 126 mod 128
#  
# R11	94,478,862,1246	=>	364,1822,3280,4738	R22
# r11,80,144,208	   		61,304,547,790
s = 6*(16*(4*k + 3)) - 2	
t = 6*27*k+40
t = 6*(27*(3*k + 1) - 2) - 2
#  94 mod 128,  62 126 / 190 254 mod 256
