#!perl

# https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl
# Print a directory of segments in the Collatz graph
# @(#) $Id$
# 2019-08-07: version 2.2
# 2018-12-07: -r root
# 2018-12-03: index in 0, 1, 2 ...
# 2018-11-27: test2
# 2018-11-21: SR, TR
# 2018-11-15: copied from collatz_rails.pl
# 2018-11-12: mark supersegments
# 2018-11-06: links on all numbers for comp
# 2018-09-05: new kernel format; -a west|east|free|comp
# 2018-08-30, Georg Fischer: derived from collatz_roads.pl
#------------------------------------------------------
# Usage:
#   perl segment.pl [-n maxn] [-d debug] [-s 4] [-i 6] [-a comp] > comp.html
#       -a  type of directory to be produced:
#           deta[il}, comp[ress], doub[le], style, test<i>, super
#       -b  bit mask for &get_index
#       -d  debug level: 0 (none), 1 (some), 2 (more)
#       -i  segment index block size for printing
#       -m  output mode: tsv, htm (no css), htm[l], latex
#       -n  maximum segment index
#       -r  degree of rooting, level: 0 (none), 1 (index), 2 (supernode) ...
#       -s  residues of segment indexes to be printed
#
# See http://www.teherba.org/index.php/OEIS/3x%2B1_Problem
#--------------------------------------------------------
use strict;
use integer;
#----------------
# global constants
my $VERSION = "V2.2";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min);
my $SEP       = "\t";
my $MAX_RULE  = 64; # rule 7 has 4 mod 16, rule 11 has 16 mod 64
my @RULENS    = (0, 1, 7, 61, 547, 4921, 44287, 398581, 3587227, 32285041, 290565367, 2615088301); # OEIS A066443
my $a = "a"; # = "a" ("x") => with (no) links
my $index_mask = 0b1111; # index = 0b1000, k = 0b0100, source rule, target rule/segment
#----------------
# get commandline options
my $action = "comp";
my $debug  = 0;
my $imax   = 10000; # max. start value
my $start4 = 4;
my $incr6  = 6;
my $min2   = $incr6 - $start4;
my $start  = 1;
my $incr   = 1;
my $mode   = "html";
my $root   = 0;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{b}) {
        $index_mask = oct("0b" . shift(@ARGV));
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{i}) {
        $incr   = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $mode   = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $imax   = shift(@ARGV);
    } elsif ($opt =~ m{r}) {
        $root   = shift(@ARGV);
    } elsif ($opt =~ m{s}) {
        $start  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my $mask = sprintf("%04b", $index_mask);
$mask =~ s{0}{}g;
my $colspan = length($mask);
my $subset = $incr == 1 ? "" : " (subset i &#x2261; $start mod $incr)";
my %text   =
    ( "detail"  , " Detailed   Segment Directory  S$subset"
    , "comp"    , " Compressed Segment Directory  C$subset"
    , "double"  , " Double Line Segment Directory S$subset"
    , "super"   , " Chains of supersegments"
    , "test"    , " Directory Test"
    );
#----------------
sub left_side  { # increase the degree by 1
    my ($isegm) = @_;
    return $incr6 * $isegm + $start4 - $incr6;
} # left_side
#----------------
sub segm_index { # decrease the degree by 1
    my ($node) = @_;
    return ($node - $start4 + $incr6) / $incr6;
} # segm_index
#----------------
sub segm_root { # get the root of some degree of a node
    my ($node) = @_;
    my $iroot = $root;
    while ($iroot >= 1) {
        $node = ($node - $start4 + $incr6) / $incr6;
        $iroot --;
    } # while iroot
    return $node;
} # segm_root
#----------------
# initialization
&print_html_header();
&print_preface();
#----------------
# generate the segment directory
my $maxn  = &left_side($imax);
my @segms = (0); # [0] is not used
my $isegm = scalar(@segms);
while ($isegm < $imax) {
    @segms[$isegm] = &generate_segment(&left_side($isegm));
    $isegm ++;
} # while $isegm
#----------------
# action for one of the possible forms of directories
my $iblock = 0;
my @mods   = split(/\D/, $start); # comma-separated

if (0) { # switch action

} elsif ($action =~ m{\A(comp|deta|doub)})   { # like "detail", but compressed segments
    &print_head();
    while ($iblock < $imax) {
        foreach my $mod (@mods) {
            $isegm = $iblock + $mod;
            if (0) {
            } elsif ($mode =~ m{^tsv}) {
                print          &get_1_segment($isegm) . "\n";
            } elsif ($mode =~ m{^htm}) {
                print "<tr>" . &get_1_segment($isegm) . "</tr>\n";
            }
        } # foreach $mod
        $iblock += $incr;
    } # while $isegm
    # case comp|deta|doub

} elsif ($action =~ m{\Asuper})   { # chains while expanding only
    @mods = (1, 4, 7, 10, 13, 16); # 1 has no supernode
    $incr = 18;
    &print_head();
    while ($iblock < $imax) {
        foreach my $mod (@mods) {
            $isegm = $iblock + $mod;
            my ($nrule, $itarget, $k) = &get_nrule_itarget_k($isegm);
            if (&is_contracting($nrule) == 1) {
                $index_mask = 0b1111;
                print "<tr>";
                print &get_1_segment($isegm);
                my $last_super = &get_last_super($isegm);
                while ($last_super != 0) { # follow chain
                    $isegm = &segm_index($last_super);
                    ($nrule, $itarget, $k) = &get_nrule_itarget_k($isegm);
                    if (&is_contracting($nrule) == 1) {
                        $last_super = 0; # break loop
                    } else { # not contracting
                        if ($isegm < $imax) {
                            $index_mask = 0b0010;
                            print &get_1_segment($isegm);
                            $last_super = &get_last_super($isegm);
                        } else {
                            print "<td>... ?</td>";
                            $last_super = 0;
                        }
                    } # not contracting
                } # while chain
                print "</tr>\n";
            } # is_contracting
        } # foreach $mod
        $iblock += $incr;
    } # while $isegm
    # case super

} elsif ($action =~ m{\Asuper})   { # chains independant of contraction/expansion
    @mods = (7, 13);
    $incr = 18;
    &print_head();
    while ($iblock < $imax) {
        foreach my $mod (@mods) {
            $isegm = $iblock + $mod;
            $index_mask = 0b1111;
            print "<tr>";
            print &get_1_segment($isegm);
            my $last_super = &get_last_super($isegm);
            while ($last_super != 0) { # follow chain
                $isegm = &segm_index($last_super);
                if ($isegm < $imax) {
                    $index_mask = 0b0010;
                    print &get_1_segment($isegm);
                    $last_super = &get_last_super($isegm);
                } else {
                    print "<td>... ?</td>";
                    $last_super = 0;
                }
            } # while chain
            print "</tr>\n";
        } # foreach $mod
        $iblock += $incr;
    } # while $isegm
    # case super

} elsif ($action =~ m{\Astyle})   { # print stylesheet
    &print_style();
    # case style

} elsif ($action =~ m{\Atest1})   { # test some condition
    print join($SEP, "test1", "index", "k", "sr", "itar", "lhs") . "\n";
    $isegm = $start;
    while ($isegm < $imax) {
        if (! defined($segms[$isegm])) {
            $isegm = $imax; # break loop
        } else {
            my @segment  = split(/$SEP/, $segms[$isegm]);
            my $index    = $segment[0];
            if ($index % 3 == 1) { # rows 1, 4, 7 ...
                my $lhs = $segment[1];
                my ($nrule, $itarget, $k) = &get_nrule_itarget_k($index);
                if ($k % 2 == 0) { # even k
                    if (&is_contracting($nrule) == 0 and &get_degree($lhs) <= 1) {
                        # even k and increasing and no supernode
                        print join($SEP, "test1_0", $index, $k, $nrule, $itarget, $lhs), "\n";
                    }
                } else { # odd $k
                    if ($nrule >= 7                 and &get_degree($lhs) <= 1) {
                        # odd k and rule >= 7 and no supernode
                        print join($SEP, "test1_1", $index, $k, $nrule, $itarget, $lhs), "\n";
                    }
                }
            } # rows 1, 4, 7 ...
        } # defined
        $isegm += $incr;
    } # while $isegm
    # case test1

} elsif ($action =~ m{\Atest2})   {
    # either contracting or attaching to a supersegment == 94 mod 108
    # this leaves us with degree 2 segments only
    print join($SEP, "test2", "index", "k", "sr", "tr", "itar", "tlhs") . "\n";
    $isegm = $start;
    while ($isegm < $imax) {
        if (! defined($segms[$isegm])) {
            $isegm = $imax; # break loop
        } else {
            my @segment  = split(/$SEP/, $segms[$isegm]);
            my $index    = $segment[0];
            # now copied from get_idnex
            my  ($nrule1, $itarget1, $k1) = &get_nrule_itarget_k($index);
            if (&is_contracting($nrule1) == 0) { # expanding
                my $target1 = $incr6 * $itarget1 - $min2;
                my $deg_target1 = &get_degree($target1);
                my ($nrule2, $itarget2, $k2) = &get_nrule_itarget_k($itarget1);
                if (&is_contracting($nrule2) or
                    ($deg_target1 >= 2 and $target1 % 108 == 94)
                    ) {
                    # ok
                } else {
                    # neither decreasing nor supernode
                    print join($SEP, "test2", $index, $k1, $nrule1, $nrule2, $itarget1, $target1), "\n";
                }
            }
        } # defined
        $isegm += $incr;
    } # while $isegm
    # case test2

} else {
    die "invalid action \"$action\"\n";
} # switch action
#----------------
&print_trailer();
# end main
#================================
sub generate_segment { # build and return a single segment starting with $selem
    my ($selem) = @_;
    my @elem    = ($selem, $selem); # 2 parallel branches: $elem[0] (upper, left), $elem[1] (lower, right)
    my $len     = 0;
    my @result  = (($selem + $min2) / $incr6, $selem); # (n, 6*n-2)
    my $state   = "step0";
    my $busy    = 1; # as long as we can still do another step
    while ($busy == 1) { # stepping
        if (0) {
        } elsif ($state eq "step0") {
            $elem[0] = ($elem[0] - 1) / 3; # d possible because of preparation above
            $elem[1] =  $elem[1] * 2;
            push(@result, $elem[0], $elem[1]);
            $state = "step1";
        } elsif ($state eq "step1") {
            $elem[0] =  $elem[0] * 2; # mm, always possible
            $elem[1] =  $elem[1] * 2;
            push(@result, $elem[0], $elem[1]);
            $state = "md"; # enter the alternating sequence of steps: md, dm, md, dm ...
        } elsif ($state eq "md") {
            if (           ($elem[1] - 1) % 3 == 0) {
                $elem[1] = ($elem[1] - 1) / 3;
                $elem[0] =  $elem[0] * 2;
                $state = "dm";
                if ($elem[0] % 3 == 0 or $elem[1] % 3 == 0) {
                    $busy  = 0;
                } else {
                    push(@result, $elem[0], $elem[1]);
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
                } else {
                }
                    push(@result, $elem[0], $elem[1]);
            } else { # should never happen
                print STDERR "# ** assertion 1 in generate_segment, elem=" . join(",", @elem) . "\n";
            }
        } else {
            die "# ** invalid state \"$state\"\n";
        }
        $len ++;
    } # while busy stepping
    if ($debug >= 3) {
        print "<!--generate_segment: " . join(";", @result) . "-->\n";
    }
    return join($SEP, @result);
} # generate_segment
#----------------
sub get_1_segment {
    my ($isegm) = @_;
    my ($result0, $result1);
    if (0) { # switch action
    } elsif ($action =~ m{\Acomp})   {
        $result0 = &get_1_compress($isegm);
    } elsif ($action =~ m{\Adeta})   {
        $result0 = &get_1_detail  ($isegm);
    } elsif ($action =~ m{\Adoub})   {
        ($result0, $result1)
                 = &get_1_double  ($isegm);
        if (0) {
        } elsif ($mode =~ m{^tsv}) {
            $result0 .= "\n" . $result1;
        } elsif ($mode =~ m{^htm}) {
            $result0 .= "</tr><tr>" . $result1;
        }
    } else { # e.g. "super"
        $result0 = &get_1_compress($isegm);
    }
    return $result0;
} # get_1_segment
#----------------
sub get_1_double {
        my ($index) = @_;
        my @segment  = split(/$SEP/, $segms[$index]);
        my $ir;
        my $bold;
        my ($result0, $result1);
        if (0) {
        } elsif ($mode =~ m{tsv} ) {
            print join($SEP, @segment) . "\n";
        } elsif ($mode =~ m{\Ahtm}) {
            # print the upper branch
            $ir = 1;
            $result0 = ""
                . &get_index0($segment[0])
                . &get_cell_html(            $segment[1], "bor", $ir, "");
            $ir += 2;
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
                if ($ir < 5) {
                    $bold = " sei";
                }
                $result0 .= &get_cell_html($segment[$ir], "btr$bold", $ir, $id);
                $ir += 2;
            } # while $ir

            # print the lower branch
            $result1 = ""
                . &get_index1($segment[0])
                ;
            $ir = 2;
            while ($ir < scalar(@segment)) {
                $bold = "";
                if ($segment[$ir] % $incr6 == $start4) {
                    if ($ir % 4 == 2 and $ir > 5) {
                        $bold = " seg";
                    }
                }
                if ($ir < 5) {
                    $bold = " sei";
                }
                $result1 .= &get_cell_html($segment[$ir], "bbr$bold", $ir, "");
                $ir += 2;
            } # while $ir
        } # mode
        return ($result0, $result1);
} # get_1_double
#----------------
sub get_1_compress {
        my ($index) = @_;
        my @segment = split(/$SEP/, $segms[$index]);
        my $ir;
        my $step;
        my ($result0, $result1);
        if (0) {
        } elsif ($mode =~ m{tsv} ) {
            $result0 = join($SEP, $segment[0], $segment[1]);
            $ir = 5;
            $step = 1;
            while ($ir < scalar(@segment)) {
                if ($segment[$ir] % $incr6 == $start4) {
                    $result0 .= "$SEP$segment[$ir]";
                }
                $ir += $step;
                $step = $step == 1 ? 3 : 1;
            } # while $ir
        } elsif ($mode =~ m{\Ahtm}) {
            $result0 = ""
                . &get_index0($segment[0])
                . &get_cell_html($segment[1], "bor", 1, "");
            $ir = 5;
            $step = 1;
            while ($ir < scalar(@segment)) {
                my $id = "";
                if ($segment[$ir] % $incr6 == $start4) {
                    $id = ($segment[$ir]);
                    $result0 .= &get_cell_html($segment[$ir], "bor seg", $ir, $id);
                }
                $ir += $step;
                $step = $step == 1 ? 3 : 1;
            } # while $ir
        } # mode
        return $result0;
} # get_1_compress
#----------------
sub get_1_detail {
        my ($index) = @_;
        my @segment = split(/$SEP/, $segms[$index]);
        my $ir;
        my $step;
        my $bold;
        my ($result0, $result1);
        if (0) {
        } elsif ($mode =~ m{tsv} ) {
            $result0 = join($SEP, @segment);
        } elsif ($mode =~ m{\Ahtm}) {
            $result0 = ""
                . &get_index0($segment[0])
                . &get_cell_html($segment[1], "bor", 1, "");
            $ir = 2;
            $step = 1;
            while ($ir < scalar(@segment)) {
                my $id = $segment[$ir];
                $bold = "";
                if ($segment[$ir] % $incr6 == $start4) {
                    if ($ir % 4 == 1 or ($ir % 4 == 2 and $ir > 5)) {
                        $bold = " seg";
                    }
                }
                if ($ir < 5) {
                    $bold = " sei";
                }
                $result0 .= &get_cell_html($segment[$ir], "bor$bold", $ir, $id);
                $ir += $step;
            } # while $ir
        } # mode
        return $result0;
} # get_1_detail
#----------------
sub is_contracting { # left-shiftig, decreasing
    my ($nrule) = @_;
    return ($nrule == 10 or $nrule == 14 or $nrule >= 18) ? 0 : 1;
} # is_contracting
#----------------
sub get_index0 { # get the index prefix of a row (without the left side)
    # global: $index_mask
    my  ($index) = @_;
    my  ($nrule1, $itarget1, $k1) = &get_nrule_itarget_k($index);
    my  $result = "";
    if (($index_mask & 0b1000) > 0) {
        $result .= "<td class=\"arc\">$index</td>"
    }
    if (($index_mask & 0b0100) > 0) {
        $result .= "<td class=\"arc bor\">$k1</td>";
    }
    if (($index_mask & 0b0010) > 0) {
        $result .= "<td class=\"arc rule$nrule1\" title=\"($nrule1)-$itarget1\">$nrule1</td>";
    }
    if (($index_mask & 0b0001) > 0) {
        my $target1 = $incr6 * $itarget1 - $min2;
        my $deg_target1 = &get_degree($target1);
        my ($nrule2, $itarget2, $k2) = &get_nrule_itarget_k($itarget1);
        if (&is_contracting($nrule1) == 0) {
            if (0 and $deg_target1 >= 2) {
                $result .= "<td class=\"arc super$deg_target1\" title=\"($nrule2)-$itarget2\">$target1</td>";
            } else {
                $result .= "<td class=\"arc rule$nrule2\" title=\"($nrule2)-$itarget2\">$nrule2</td>";
            }
        } else {
                $result .= "<td class=\"arc rule$nrule2\" title=\"($nrule2)-$itarget2\">$nrule2</td>";
            #   $result .= "<td class=\"arc bor\">&nbsp;</td>";
        }
    } # mask 0b0001
    return $result;
} # get_index0
#----------------
sub get_index1 { # get the index prefix of the second branch in a row
    # global: $index_mask
    my  $result = "";
    if (($index_mask & 0b1000) > 0) {
        $result .= "<td class=\"arl\">\&nbsp;</td>";
    }
    if (($index_mask & 0b0100) > 0) {
        $result .= "<td class=\"arl\">\&nbsp;</td>";
    }
    if (($index_mask & 0b0010) > 0) {
        $result .= "<td class=\"arr\">\&nbsp;</td>";
    }
    if (($index_mask & 0b0001) > 0) {
        $result .= "<td class=\"arr\">\&nbsp;</td>";
    } # mask 0b0001
        $result .= "<td class=\"arr\">\&nbsp;</td>";
    return $result;
} # get_index1
#----------------
sub get_index_head0 { # get the header of the index prefix of the first branch in a row
    # global: $index_mask
    my  $result = "";
    if (($index_mask & 0b1000) > 0) {
        $result .= "<td class=\"arc\"    >i</td>";
    }
    if (($index_mask & 0b0100) > 0) {
        $result .= "<td class=\"arc\"    >k</td>";
    }
    if (($index_mask & 0b0010) > 0) {
        $result .= "<td class=\"arc bor\">SR</td>";
    }
    if (($index_mask & 0b0001) > 0) {
        $result .= "<td class=\"arc bor\">TR</td>";
    } # mask 0b0001
    return $result;
} # get_index_head0
#----------------
sub get_index_head1 { # get the header of the index prefix of the second branch in a row
    # global: $index_mask
    my  $result = "";
    if (($index_mask & 0b1000) > 0) {
        $result .= "<td class=\"arc\">\&nbsp;</td>";
    }
    if (($index_mask & 0b0100) > 0) {
        $result .= "<td class=\"arr\">\&nbsp;</td>";
    }
    if (($index_mask & 0b0010) > 0) {
        $result .= "<td class=\"arr\">\&nbsp;</td>";
    }
    if (($index_mask & 0b0001) > 0) {
        $result .= "<td class=\"arr\">\&nbsp;</td>";
    } # mask 0b0001
    return $result;
} # get_index_head1
#----------------
sub get_last_super { # get the last segment element with degree >= 2, or 0 if no supernode in right part
    my  ($index) = @_;
    my @segment = split(/$SEP/, $segms[$index]);
    my $ir = scalar(@segment) - 1;
    my $result = 0;
    my $degree = &get_degree($segment[$ir]);
    while ($ir >= 2 and $degree < 2) {
        $ir --;
        $degree = &get_degree($segment[$ir]);
    } # while $ir
    if ($ir >= 2) {
        $result = $segment[$ir];
    }
    return $result;
} # get_last_super
#----------------
sub get_cell_html { # get the HTML of one table cell
    my ($elem, $border, $ir, $id) = @_;
    my $rest = $elem % $incr6;
    my $isource = ($elem + $min2) / $incr6;
    my ($nrule, $itarget, $k, $target) = ("", "", "", "");
    my $result = "<td";
    if ($id ne "") {
        my $rooted_id = &segm_root($id);
        $result .= " id=\"$rooted_id\" debug=\"1\"";
    }
    my $degree = &get_degree($elem);
    if ($degree >= 1) {
        ($nrule, $itarget, $k) = &get_nrule_itarget_k($isource);
        $target = $itarget * $incr6 - $min2;
        if ($rest == $start4) {
            $result .= " title=\"($nrule)-$target\"";
        }
        $result .= " class=\"super$degree";
        if (0) {
        } elsif ($root >= 1) {
            $elem = $isource;
            if ($root >= 2) {
                if (($elem + $min2) % $incr6 == 0) {
                    $elem = ($elem + $min2) / $incr6;
                    if ($root >= 3) {
                        if (($elem + $min2) % $incr6 == 0) {
                            $elem = ($elem + $min2) / $incr6;
                            if ($root >= 4) {
                                if (($elem + $min2) % $incr6 == 0) {
                                    $elem = ($elem + $min2) / $incr6;
                                } else {
                                    $elem = "";
                                }
                            } # $root >= 4
                        } else {
                            $elem = "";
                        }
                    } # $root >= 3
                } else {
                    $elem = "";
                }
            } # $root >= 2
        } # $root >= 1
    } else {
        $result .= " class=\"d$rest";
    }
    if ($border ne "") {
        $result .= " $border";
    }
    if ($ir == 1) { # start element
        if ($target ne "" and $target < $maxn           and ($mode !~ m{htm\Z})) {
            $result .= "\" id=\"A$elem\"><$a href=\"\#$elem\">$elem</a>";
        } else {
            $result .= "\" id=\"A$elem\">$elem";
        }
    } else {
        if ($elem < $maxn and $elem % $incr6 == $start4 and ($mode !~ m{htm\Z})) {
            $result .=               "\"><$a href=\"\#A$elem\">$elem</a>";
        } else {
            $result .=               "\">$elem";
        }
    }
    $result .= "</td>";
    return $result;
} # get_cell_html
#------------------------
sub get_degree {
    my ($elem) = @_;
    my $result = 0;
    if (0) { # A000400: 46656, 279936, 1679616, 10077696
             # A005610: 2, 14, 86, 518, 3110, 18662, 111974, 671846, 4031078
    } elsif ($elem %  46656 -  46656 ==  -18662) {
        $result = 6;
    } elsif ($elem %   7776 -   7776 ==   -3110) {
        $result = 5;
    } elsif ($elem %   1296 -   1296 ==    -518) {
        $result = 4;
    } elsif ($elem %    216 -    216 ==     -86) {
        $result = 3;
    } elsif ($elem %     36 -     36 ==     -14) {
        $result = 2;
    } elsif ($elem %      6 -      6 ==      -2) {
        $result = 1;
    }
    return $result;
} # get_degree
#------------------------
sub get_nrule_itarget_k {
    my ($isource) = @_;
    my $k       = 1;
    my $orule   = 2;
    my $itarget = 0;
    my $busy    = 1;
    my $tog31   = 3;
    my $pow2_2  = 1;
    my $pow2    = 4;
    my $pow3    = 1;
    my $irulen  = 1;
    while ($busy == 1 and $orule <= $MAX_RULE) {
        my $modfit = $pow2_2 * $tog31;
        if ($isource % $pow2 == $modfit) { # mod condition fits
            $k = ($isource / $pow2_2 - $tog31) / 4;
            $busy = 0;
            $itarget = $pow3 * ($isource - $modfit) / $pow2 + $RULENS[$irulen];
            if ($debug >= 3) {
                print "orule=$orule, pow2=$pow2, pow2-2=$pow2_2, pow3=$pow3"
                    . ", modfit=$modfit, RULENS[$irulen]=$RULENS[$irulen]\n";
            }
        } else {
            $orule ++;
            if ($orule % 4 == 1) {
                $irulen ++;
            }
            if ($orule % 2 == 0) {
                $pow2   *= 2;
                $pow2_2 *= 2;
            } else {
                $pow3   *= 3;
                $tog31  = 4 - $tog31; # 3 1 1 3 -> OEIS A084101
            }
        } # mod cond.
    } # while rules
    my $nrule = ($orule % 2 == 0) ? $orule * 2 + 1 : $orule * 2;
    return ($nrule, $itarget, $k);
} # get_nrule_itarget_k
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
    } elsif ($action =~ m{\Acomp})   {
        &print_compress_head();
    } elsif ($action =~ m{\Adeta})   {
        &print_detail_head  ();
    } elsif ($action =~ m{\Adoub})   {
        &print_double_head  ();
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
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl" />
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
<a href="https://github.com/gfis/fasces/blob/master/oeis/collatz/segment.pl" target="_blank">segment.pl</a>
$VERSION at $TIMESTAMP; 
<a href="#more">more information</a>
<br />
<a href="http://www.teherba.org/index.php/OEIS/3x%2B1_Problem" 
  target="_blank">Article about the 3x+1 problem</a> by <a href="mailto:Dr.Georg.Fischer\@gmail.com">Georg Fischer</a>
<br />
<a href="double.html" target="_blank">Double line</a>,
<a href="detail.html" target="_blank">detailed</a>,
<a href="comp.html"   target="_blank">compressed / level 0</a>
                                            (<a href="https://oeis.org/A307407" target="_blank">A307407</a>),
Level
<a href="root1.html"  target="_blank">1</a> (<a href="https://oeis.org/A322469" target="_blank">A322469</a>),
<a href="root2.html"  target="_blank">2</a> (<a href="https://oeis.org/A307048" target="_blank">A307048</a>),
<a href="root3.html"  target="_blank">3</a> (<a href="https://oeis.org/A160016" target="_blank">A160016</a>),
<a href="root4.html"  target="_blank">4</a> (<a href="https://oeis.org/A000027" target="_blank">A000027</a>)

<!--
<a href="subset.html" target="_blank">Subset</a>, 
-->
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
<td class="arl" colspan="$colspan">Column</td>
<td class="arc">1</td>
<td class="arc">3</td>
<td class="arc">5</td>
<td class="arc">7</td>
<td class="arc">9</td>
<td class="arc">11</td>
<td class="arc">13</td>
<td class="arc">15</td>
<td class="arc">17</td>
<td class="arc">19</td>
</tr>
<tr>
<td class="arl bot" colspan="$colspan">&nbsp;</td><td>&nbsp;</td>
<td class="arc">2</td>
<td class="arc">4</td>
<td class="arc">6</td>
<td class="arc">8</td>
<td class="arc">10</td>
<td class="arc">12</td>
<td class="arc">14</td>
<td class="arc">16</td>
<td class="arc">18</td>
</tr>
<tr>
GFis
        print &get_index_head0();
        print <<"GFis";
<td class="arc bor           ">LS</td>
<td class="arc btr           ">&micro;</td>
<td class="arc btr seg rule5 ">&micro;&micro;</td>
<td class="arc btr           ">&micro;&micro;&delta;</td>
<td class="arc btr seg rule9 ">&micro;&micro;&sigma;</td>
<td class="arc btr           ">&micro;&micro;&sigma;&delta;</td>
<td class="arc btr seg rule13">&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc btr           ">&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc btr seg rule17">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc btr           ">&micro;&micro;&sigma;<sup>3</sup>&delta;</td>
</tr>
<tr>
GFis
        print &get_index_head1();
        print <<"GFis";
<td class="arr               ">&nbsp;</td>
<td class="arc bbr           ">&delta;</td>
<td class="arc bbr           ">&delta;&micro;</td>
<td class="arc bbr seg rule6 ">&delta;&micro;&micro;</td>
<td class="arc bbr           ">&delta;&micro;&micro;&delta;</td>
<td class="arc bbr seg rule10">&delta;&micro;&micro;&sigma;</td>
<td class="arc bbr           ">&delta;&micro;&micro;&sigma;&delta;</td>
<td class="arc bbr seg rule14">&delta;&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bbr           ">&delta;&micro;&micro;&sigma;<sup>2</sup>&delta;</td>
<td class="arc bbr seg rule18">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
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
<td class="arl bot" colspan="$colspan">Column</td>
<td class="arc">1</td>
<td class="arc">5</td>
<td class="arc">6</td>
<td class="arc">9</td>
<td class="arc">10</td>
<td class="arc">13</td>
<td class="arc">14</td>
<td class="arc">17</td>
<td class="arc">18</td>
<td class="arc">21</td>
<td class="arc">22</td>
</tr>
<tr>
GFis
        print &get_index_head0();
        print <<"GFis";
<td class="arc bor           ">LS</td>
<td class="arc bor seg rule5 ">&micro;&micro;</td>
<td class="arc bor seg rule6 ">&delta;&micro;&micro;</td>
<td class="arc bor seg rule9 ">&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg rule10">&delta;&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg rule13">&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg rule14">&delta;&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg rule17">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg rule18">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg rule21">&micro;&micro;&sigma;<sup>4</sup></td>
<td class="arc bor seg rule22">&delta;&micro;&micro;&sigma;<sup>4</sup></td>
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
<p>
Root &lt;-&nbsp;&nbsp;&nbsp;nodes &#x2261;
<span class="d0">\&nbsp;0</span>, <span class="d1">\&nbsp;1</span>,
<span class="d2">\&nbsp;2</span>, <span class="d3">\&nbsp;3</span>,
<span class="d4 seg">\&nbsp;4</span>, <span class="d5">\&nbsp;5</span> mod 6&nbsp;&nbsp;&nbsp;-&gt; &#x221e;
\&nbsp;\&nbsp;\&nbsp;\&nbsp;
<span class="sei">Inserted</span> <span class="">tree</span> nodes
<br />
GFis
        print "Rules <span class=\"rule2\">\&nbsp;2</span>";
        my $nrule = 5;
        while ($nrule <= 30) {
            print ", <span class=\"rule$nrule\">\&nbsp;$nrule</span>";
            $nrule ++;
            print ", <span class=\"rule$nrule\">\&nbsp;$nrule</span>";
            $nrule += 3;
        } # while $nrule
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
265720, 2391484 (OEIS <a href="http://oeis.org/A191681" target="_blank">A191681</a>)
<br />Start values in compressed directory: OEIS <a href="http://oeis.org/A308709" target="_blank">A308709</a>, 
in detailled directory:                     OEIS <a href="http://oeis.org/A309523" target="_blank">A309523</a>
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
supersegments at rows (1), 4, 7, 10, 13 ... 1 mod 3
lhs super at 4 10 16 22 ... 4 mod 6
rp not at 10 19 28 37 ... 1 mod 9
both in lhs and rp at 4 16 22 34 40 52 58 70 76 ... 4,16 mod 18
                       12 6 12  6  12 6 12  6
last-but-one in rp at 7 25 52 61 79 88 106
