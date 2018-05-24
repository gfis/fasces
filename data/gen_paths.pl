#!/usr/bin/perl

# FASS: generate all noncrossing paths which fill a square of defined size completely
# 2018-05-21: obe some adjacency conditions
# 2018-05-18: if the path marks a border element, the two neighbours on the border may not be both unmarked
# 2018-05-10: even bases 2, 4, ...; summary
# 2017-08-23, Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl gen_paths [[-b] base] [-s] [-d n]
#       -b   base (default 5)
#       -m x mode, x=symm(etric), diag(onal)
#       -d n debug level n (default: 0)
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $debug  = 0;
my $ansi   = 0;  # whether to use ANSI colors on console output
my $base   = 5;
my $diag   = 0;
my $maxexp = 2;  # compute b-file up to $base**$maxexp
my $mode   = ""; # no special conditions
my $symm   = 0;
my $vert   = "||";
my $hori   = "==";
my $blan   = "  ";
my $letters = "abcdefghijklmnopqrstuvwxyz";
my %attrs  = (); # path attributes: symmetrical, corner, ...

while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if ($opt =~ m{\A(\-b)?(\d+)\Z}) {
        $base  = $2;
    }
    if ($opt eq "\-a") {
        $ansi   = 1;
    }
    if ($opt =~ m{m}) {
        $mode = shift(@ARGV);
    }
    if ($opt =~ m{d}) {
        $debug = shift(@ARGV);
    }
} # while opt
$symm = ($mode =~ m{sy}) ? 1 : 0;
$diag = ($mode =~ m{di}) ? 1 : 0;
my $pathno = 0;

my @matrix = ();
my @filled = ();
my $corner = $base * $base;
my $full = $corner - 1;
my $last = $corner - 1;
my $half = $full / 2;
if ($symm == 1) {
    $last /= 2; # in the center
}
my $bpow2 = $base  * $base;
my $bpow3 = $bpow2 * $base;
my $base_1 = $base - 1;
my @path = ();
my
$ind = 0;
while ($ind < $corner) { # preset filled
    $filled[$ind] = 0;
    $ind ++;
} # preset filled
my $sep = ",";

print <<"GFis";
<?xml version="1.0" encoding="UTF-8" ?>
<paths base="$base">
GFis

my @queue = (); # entries are "path_index${sep}value"
$ind = 0;
&mark($ind); $ind ++;
&mark($ind); $ind ++;
# normalized start: 00->01
# $ind = $base; # comment this out to assume a vertical bar at the beginning
while ($ind < $base) { # start with 00->01->02->...->0b
    &mark($ind);
    $ind ++;
} # vertical bar
&push_urdl();

while (scalar(@queue) > 0) { # pop
    my ($pind, $pval) = split(/$sep/, pop(@queue));
    while (scalar(@path) > $pind) {
        &unmark();
    } # while unmark
    if ($debug >= 2) {
        print "queue[" . sprintf("%3d", scalar(@queue)) . "]\@$pind: "
                . join(",", map { &based0($_) } @path) . " ". &based0($pval)
                . "?\n";
        my $ifil = 0;
        while ($ifil < scalar(@filled)) {
            print &based0($ifil) . ";$filled[$ifil] ";
            $ifil ++;
        }
        print "\n";
    }
    &mark($pval);
    my $plen = scalar(@path);
    if ($symm == 1 ? ($pval == $last) : ($plen <= $last + 1)) {
        print "pval=$pval, plen=$plen, last=$last, full=$full\n" if $debug >= 1;
        if ($plen == $last + 1) { # really at the end or in the center
            while ($plen < $corner) { # fill 2nd half in case of $symm
                push(@path, $full - $path[$full - $plen]);
                $plen ++;
            } # fill
            if ($debug >= 1) {
                print "scalar(path)=" . scalar(@path) . ", plen=$plen, last=$last, full=$full\n";
                print join("/", map { &based0($_) } @path) . "\n";
            }
            &output_path();
            @path = splice(@path, 0, $last + 1); # pop
        } elsif ($diag == 1 and $pval == $last) {
            print "# skipped because of diag, plen=$plen\n" if $debug >= 1;
        } else {
            &push_urdl();
        }
    } else {
        &push_urdl();
    }
} # while popping

print "\n<summary base=\"$base\" count=\"$pathno\"";
foreach my $attr(sort(keys(%attrs))) {
    print " $attr=\"$attrs{$attr}\"";
} # foreach
print " />\n</paths>\n";

exit(0);

#--------
sub mark {
    my ($val) = @_;
    push(@path, $val);
    $filled[$val]             = 1;
    if ($symm == 1) {
        $filled[$full - $val] = 1;
    }
} # mark
#--------
sub unmark {
    my $val = pop(@path);
    $filled[$val]             = 0;
    if ($symm == 1) {
        $filled[$full - $val] = 0;
    }
} # unmark
#--------
sub is_free {
    my ($vnext) = @_;
    return ($filled[$vnext] == 0 and ($symm == 0 or $filled[$corner - 1 - $vnext] == 0)) ? 1 : 0;
} # is_free
#--------
sub push_urdl {
    # Determine and push possible followers of last vertex.
    # If the path hits a border, the square is divided in 2 halves,
    # and the two neighbours on the border may not be both free,
    my $len   = scalar(@path);
    my $vlast = $path[$len - 1];
    my $vprev = $path[$len - 2];
    my $xlast = &get_digit($vlast, 1);
    my $ylast = &get_digit($vlast, 0); # rightmost character
    my ($vnext, $xnext, $ynext, $vnei1, $vnei2, $fail);
    $fail = 0;
    if ($xlast == $ylast and $xlast == $base_1 and scalar(@path) != $corner) { # digonal corner is not last path element
        $fail = 1;
    }
    if (0 and ($xlast eq $ylast)) { # on the diagonal nn
        # if there are 2 continuations nm and qn, there may not be 0n,1n
        # otherwise there will be a multiway branch from nn to 1nn and nm (or nq)
        my $search = $ylast; # really "0$last"
        my $ind = 0;
        while ($ind < scalar(@path) and ($path[$ind] != $ylast)) {
            $ind ++;
        } # while
        if ($ind < scalar(@path) - 1) { # found one more
            print "# multiway $xlast$ylast, scalar=" . scalar(@path) . ", search=$ylast"
                . ", path[$ind]=$path[$ind]; path[$ind+1]=$path[$ind+1]; path=" . join(",", map { &based0($_) } @path) . "\n" if $debug >= 2;
            if ($path[$ind + 1] == $ylast + $base) { # this would cause a multiway branch
                $fail = 1;
                &add_attr("conflict");
                # print "<conflict id=\"$pathno\" />\n";
            }
        } # found $search
    } # on the diagonal

    if ($fail == 0) {
        if ($ylast < $base_1) { $fail = 0;  # may go up
            $vnext = $vlast + 1    ;        # go up
            if (&is_free($vnext) == 1) {
                $ynext =     &get_digit($vnext, 0);
                if ($ynext == $base_1) {    # at upper border
                    $xnext = &get_digit($vnext, 1);
                    $vnei1 = $xnext == 0       ? $vnext - 1     : $vnext - $base; # down or left
                    if (&is_free($vnei1)) {
                    $vnei2 = $xnext == $base_1 ? $vnext - 1     : $vnext + $base; # down or right
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@queue, "$len$sep$vnext");
                }                           # push upper
            }
        }
        if ($ylast > 0      ) { $fail = 0;  # may go down
            $vnext = $vlast - 1    ;        # go down
            if (&is_free($vnext) == 1) {
                $ynext =     &get_digit($vnext, 0);
                if ($ynext == 0      ) {    # at lower  border
                    $xnext = &get_digit($vnext, 1);
                    $vnei1 = $xnext == 0       ? $vnext + 1     : $vnext - $base; # up or left
                    if (&is_free($vnei1)) {
                    $vnei2 = $xnext == $base_1 ? $vnext + 1     : $vnext + $base; # up or right
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@queue, "$len$sep$vnext");
                }                           # push lower
            }
        }
        if ($xlast < $base_1) { $fail = 0;  # may go right
            $vnext = $vlast + $base;        # go right
            if (&is_free($vnext) == 1) {
                $xnext =     &get_digit($vnext, 1);
                if ($xnext == $base_1) {    # at right  border
                    $ynext = &get_digit($vnext, 0);
                    $vnei1 = $ynext == $base_1 ? $vnext - $base : $vnext - 1    ; # left or down
                    if (&is_free($vnei1)) {
                    $vnei2 = $ynext == 0       ? $vnext - $base : $vnext + 1    ; # left or up
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@queue, "$len$sep$vnext");
                }                           # push right
            }
        }
        if ($xlast > 0      ) { $fail = 0;  # may go left
            $vnext = $vlast - $base;        # go left
            if (&is_free($vnext) == 1) {
                $xnext =     &get_digit($vnext, 1);
                if ($xnext == 0      ) {    # at left   border
                    $ynext = &get_digit($vnext, 0);
                    $vnei1 = $ynext == $base_1 ? $vnext + $base : $vnext - 1    ; # right or down
                    if (&is_free($vnei1)) {
                    $vnei2 = $ynext == 0       ? $vnext + $base : $vnext + 1    ; # right or up
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@queue, "$len$sep$vnext");
                }                           # push left
            }
        }
        if ($debug >= 2) {
            print "push_urdl: vlast=$vlast, xlast=$xlast, ylast=$ylast, " . join("/", @queue) . "\n";
        }
    } # $fail = 0
} # push_urdl
#--------
sub output_path {
    $pathno ++;
    my $symdiag = 0; # &check_symdiag();
    my $wave = &check_wave();
    if ($wave >= 3) {
        print "<!-- ========================== -->\n";
        my $attributes = &get_final_attributes();
        print "<matrix id=\"$pathno\" symdiag=\"$symdiag\" wave=\"$wave\" attrs=\"$attributes\" base=\"$base\"\n";
        print "     path=\""  . join(",", map {         $_  } @path) . "\"\n"
            . "     bpath=\"" . join(",", map { &based0($_) } @path) . "/\"\n"
            . "     >\n";
        if (1) {
            &draw_path(@path);
        }
        print "</matrix>\n";
    } # success
} # output_path
#--------
# no more used
sub check_symdiag { # check whether there are symmetric shapes on any diagonal node
    my $result = 0; # assume failure
    my $basep1 = $base + 1;
    my $inode = $basep1 * 2;
    while ($result == 0 and $inode < $full) { # diagonal nodes 22..33 for base=5
        my $dnode = $path[$inode];
        if ($dnode % $basep1 == 0 and $dnode > $basep1 and $dnode < $full) { # a diagonal value
            my $dist = 1; # from the diagonal node
            my $symmetric = 1; # as long as the path is symmetric around $inode
            while ($symmetric == 1 and $dist < $half) { # determine 1st deviation from symmetricity
                my $diff   = $path[$inode + $dist] - $dnode ;
                if ($dnode - $path[$inode - $dist] != $diff) { # deviation found
                    print "# id=$pathno inode=$inode, dnode=" . &based0($dnode) . ", diff=$diff, <> "
                            . ($dnode - $path[$inode - $dist]) . "\n" if $debug >= 1;
                    $symmetric = 0;
                    if ($dist > 4) {
                        $result = $dist;
                    }
                    # deviation found
                } else { # no deviation
                    print "# id=$pathno inode=$inode, dnode=" . &based0($dnode)
                            . ", dist=$dist, diff=$diff\n" if $debug >= 1;
                }
                $dist ++;
            } # while symmetricity
            if ($symmetric == 1) {
                $result = $dist;
            }
        } # a diagnoal value
        $inode ++;
    } # while on diagonal
    return $result;
} # check_symdiag
#--------
sub check_wave { # check whether there is a wave with a center on the diagonal
    # similiar to checK_symdiag, but the symmetricity must have a wave shape
    my $result = 0; # assume failure
    my $basep1 = $base + 1;
    my @diff2; # 2nd differences
    my $inode = $basep1 * 2;
    while ($result == 0 and $inode < $full) { # diagonal nodes 22..33 for base=5
        my $dnode = $path[$inode];
        my $odiff = 0;
        @diff2 = ();
        if ($dnode % $basep1 == 0 and $dnode > $basep1 and $dnode < $full) { # a diagonal value
            my $dist = 1; # from the diagonal node
            my $symmetric = 1; # as long as the path is symmetric around $inode
            while ($symmetric == 1 and $dist <= $half) { # determine 1st deviation from symmetricity
                my $diff   = $path[$inode + $dist] - $dnode ;
                if ($dnode - $path[$inode - $dist] != $diff) { # deviation found
                    print "# id=$pathno inode=$inode, dnode=" . &based0($dnode) . ", diff=$diff, <> "
                            . ($dnode - $path[$inode - $dist]) . "\n" if $debug >= 1;
                    $symmetric = 0;
                    # deviation found
                } else { # no deviation
                    push(@diff2, $odiff - $diff);
                    $odiff = $diff;
                    print "# id=$pathno inode=$inode, dnode=" . &based0($dnode)
                            . ", dist=$dist, diff=$diff\n" if $debug >= 1;
                }
                $dist ++;
            } # while symmetricity
            if (scalar(@diff2) >= 4) { # evaluate the 2nd differences and check for wave shape
                # for example -5,+1,+5,+5 for base-5 "s" with normal stroke direction
                # the 2nd differences switch between +-5 and -+1
                my $hlen = 0;
                print "# id=$pathno inode=$inode, dnode=" . &based0($dnode)
                        . ", #diff2=" . scalar(@diff2)
                        . ", diff2=" . join(",", @diff2) . "\n" if $debug >= 0;
                my $first = $diff2[$hlen ++];
                while ($diff2[$hlen] == $first) {
                    $hlen ++;
                } # while
                # now $hlen = half of the length of the bar from the $dnode
                # a 7-wave MM would have @diff2 =  1 1 1 9 -1 -1 -1 -1 -1 -1 9 1 1 1 1 1 1 9 -1 -1 -1 -1 -1 -1
                if (scalar(@diff2) >= $hlen + $hlen + (2 * $hlen) * $hlen) { # long enough fo ra complete wave
                    my $parity = $inode % 2; # indicates the displacement from the center
                    my $nshape = abs($first) == 1 ? 1 : 0; # whether bars are vertical
                    print "# id=$pathno inode=$inode, dnode=" . &based0($dnode)
                            . ", hlen=$hlen, parity=$parity, nshape=$nshape\n" if $debug >= 0;
                    my $fail = 0;
                    # (1) check the bars: half(= $first), -full, +full, ...
                    my $target = - $first;
                    my $ind = $hlen;
                    my $iter = 0;
                    while ($fail == 0 and $iter < $hlen) {
                        $ind ++; # skip over the separator, the unit connector
                        my $loop = 2 * $hlen;
                        while ($fail == 0 and $loop > 0) {
                            if ($diff2[$ind] != $target) {
                                $fail = 1;
                            }
                            $ind ++;
                            $loop --;
                        } # while $loop
                        $target = - $target;
                        $iter ++;
                    } # while $iter
                    if ($fail == 0) {
                        $result = 2 * $hlen + 1;
                    }
                } # long enough
            } # >= 4
        } # a diagnoal value
        $inode ++;
    } # while on diagonal
    return $result;
} # check_wave
#--------
sub add_attr { # add an attribute
    my ($attr) = @_;
    if (defined($attrs{$attr})) {
        $attrs{$attr} ++;
    } else {
        $attrs{$attr} = 1;
    }
    return $attrs{$attr};
} # add_attr
#--------
sub get_final_attributes {
    # determine general properties of the finished path
    my $result = "";
    my $last = $path[scalar(@path) - 1];
    #----
    my $dig0 =  $last          % $base;
    my $dig1 = ($last / $base) % $base;
    if (0) {
    } elsif ((              $dig0 == $base_1) and (              $dig1 == $base_1)) {
        $result .= ",diagonal";
    } elsif (($dig0 == 0                    ) and (              $dig1 == $base_1)) {
        $result .= ",opposite";
    } elsif (($dig0 == 0 or $dig0 == $base_1) and ($dig1 == 0 or $dig1 == $base_1)) {
        $result .= ",corner";
    } elsif (($dig0 == 0 or $dig0 == $base_1) or  ($dig1 == 0 or $dig1 == $base_1)) {
        $result .= ",outside";
    } else {
        $result .= ",inside";
    }
    #----
    my $ipa = 0;
    my $half = $full / 2;
    my $compl = 1;
    while ($compl == 1 and $ipa <= $half) {
        $compl = $path[$ipa] == $full - $path[$full - $ipa] ? 1 : 0;
        $ipa ++;
    }
    if ($compl == 1) {
        $result .= ",symmetrical";
    }
    #----
    $result = substr($result, 1);
    foreach my $attr (split(/\,/, $result)) {
        &add_attr($attr);
    } # foreach
    return $result;
} # get_final_attributes
#--------
sub draw_path {
    our $vert   = "||"; if ($ansi == 1) { $vert = "\x1b[103m$vert\x1b[0m"; }
    our $hori   = "=="; if ($ansi == 1) { $hori = "\x1b[103m$hori\x1b[0m"; }
    our @matrix = ();
    our $blan   = "  ";
    #----
    sub get_matrix_pos {
        my ($x, $y) = @_;
        my $base2_1 = $base * 2 - 1; # 9  for base=5
        return $x * 2 + ($base2_1 - 1) * $base2_1 - $y * 2 *$base2_1;
    } # get_matrix_pos
    #----
    sub connect {
        my ($pa0, $pa1) = @_;
        if ($pa0 > $pa1) { # exchange, make p1 smaller
            my $temp = $pa0;
            $pa0 = $pa1;
            $pa1 = $temp;
        } # pa0 <= pa1
        my $ba0 = &based0($pa0);
        my $ba1 = &based0($pa1);
        print "ba0=$ba0, ba1=$ba1" if $debug >= 2;
        my $x0 = &get_digit($pa0, 1);
        my $y0 = &get_digit($pa0, 0);
        my $x1 = &get_digit($pa1, 1);
        my $y1 = &get_digit($pa1, 0);
        print ", x0=$x0, y0=$y0, x1=$x1, y1=$y1" if $debug >= 2;
        my $mp0 = &get_matrix_pos($x0, $y0);
        if ($x0 eq $x1) { # up
            $matrix[$mp0 - ($base * 2 - 1)] = $vert; # up
            print " $vert\n" if $debug >= 2;
        } else {
            $matrix[$mp0 + 1]               = $hori; # right
            print " $hori\n" if $debug >= 2;
        }
    } # connect
    #----
    # initialize the matrix
    my $x = 0;
    my $y = 0;
    while ($x < $base) {
        $y = 0;
        while ($y < $base) {
            my $mp = &get_matrix_pos($x, $y);
            $matrix[$mp] = $ansi == 1 ? "\x1b[102m$x$y\x1b[0m" : "$x$y";
            if ($x < $base_1) {
                $matrix[$mp + 1] = $blan; # " "; # right
            }
            if ($y > 0) {
                $matrix[$mp + $base * 2 - 1] = $blan; # "  "; # down
                if ($x < $base_1) {
                    $matrix[$mp + $base * 2 - 1 + 1] = $blan; # " "; # down
                }
            }
            $y ++;
        } # while y
        $x ++;
    } # while $x

    my $ipa = 1;
    while ($ipa < scalar(@path)) {
        &connect($path[$ipa - 1], $path[$ipa]);
        $ipa ++;
    } # while $ipa
    print "<draw-path>\n\n";
    my $imp = 0;
    while ($imp < scalar(@matrix)) { # print
        print "$matrix[$imp]";
        $imp ++;
        if ($imp % ($base * 2 - 1) == 0) {
            print "\n";
        }
    } # printing
    print "\n</draw-path>\n";
} # draw_path
#---------
sub get_digit {
    # return the value of a digit from a string in $base representation
    # $base <= 10 for the moment, but hex is prepared
    my ($num, $pos) = @_; # pos is 0 for last character
    my $bum = &based0($num);
    return substr($bum, length($bum) - 1 - $pos, 1);
} # get_digit
#--------
sub based0 {
    # return a number in base $base,
    # filled to $maxexp - 1 with leading zeroes
    my ($num) = @_;
    my $result = "";
    my $ind = 0;
    while ($ind < $maxexp) {
       $result = ($num % $base) . $result;
       $num    /= $base;
       $ind ++;
    } # while $idig
    return $result;
} # based0

#--------
sub check_cube { # check the continuation to a cube
    my $maxdig = 3;
    my $ind;
    my $ncurr;
    my (@invp, @p2);  # numbers have 3 digits: zxy
    for ($ind = 0; $ind < $base; $ind ++) { # precompute the values where one digit is 0
        my $paval = $path[$ind];
        $invp[$paval] = $ind;
        $p2[0][$ind] = ($paval / $base)  * $base;                   # zx0
        $p2[1][$ind] = ($paval / $bpow2) * $bpow2 + $paval % $base; # z0y
        $p2[2][$ind] = $paval % $bpow2;                             # 0xy
    } # for
    $ind = $bpow2;
    my $nprev = $path[$ind - 1] + $bpow2; # previous node, e.g. 188
    my $fail = 0;
    while ($fail == 0 and $ind < $bpow3) {
        # compute the successor of $nprev at $ind
        my $next = -1; # no candidate found so far
        my $cand = -1;
        my $idig = 0;
        while ($fail == 0 and $idig < $maxdig) { # try all pairs
            my $pair = &get_pair($idig, $nprev);
            my $miss = &get_miss($idig, $nprev);
            my $papos = $invp[$pair]; # position in @path; try lower and higher (if they exist)
            my $compare = 0; # skip for this first
            my $incr = -1;
            while ($fail == 0 and $incr <= 1) { # first the lower
                if ($papos != $compare) { # neighbour exists
                    $cand = $p2[$idig][$papos + $incr] + $miss;
                    if ($cand != $nprev) { # now check whether all pairs in $cand are adjacent to $nprev
                        my $adjacent = 1;
                        my $jdig = 0;
                        while ($adjacent == 1 and $jdig < $maxdig) {
                            if ($jdig != $idig) { # the pair corresponding to $idig needs not to be checked, only the other 2
                                my $prev2 = &get_pair($jdig, $nprev);
                                my $cand2 = &get_pair($jdig, $cand );
                                if ($prev2 != $cand2 and abs($invp[$prev2] - $invp[$cand2]) > 1) { # not adjacent
                                    $adjacent = 0;
                                } # not adjacent
                            } # != $idig
                            $jdig ++;
                        } # while $jdig
                        if ($adjacent == 1) {
                            if ($next < 0) {
                                $next = $cand;
                            } else { # conflict, more than 1 candidate
                                $fail = 1;
                            }
                        }
                    } # $cand != $nprev
                } # neighbour exists
                $compare = $base;
                $incr += 2;
            } # while $incr
            $idig ++;
        } # while $idig
        if ($next >= 0) {
            $nprev = $next;
        } else { # no candidate found
            $fail = 1;
        }
        $ind ++;
    } # while $ind
    return $fail == 0 ? 0 : $nprev;
} # check_cube
#--------
sub get_pair { # get a pair of digits
    my ($idig, $nprev) = @_;
    my $result;
    if (0) {
    } elsif ($idig == 0) {
        $result = $nprev / $base;                                  #  zx
    } elsif ($idig == 1) {
        $result = ($nprev / $bpow2) * $base + $nprev % $base;      #  zy
    } elsif ($idig == 2) {
        $result = $nprev % $bpow2;                                 #  xy
    }
    return $result;
} # get_pair
#--------
sub get_mask { # get all digits, but one replaced by 0
    my ($idig, $nprev) = @_;
    my $result;
    if (0) {
    } elsif ($idig == 0) {
        $result = ($nprev / $base)  * $base;                   # zx0
    } elsif ($idig == 1) {
        $result = ($nprev / $bpow2) * $bpow2 + $nprev % $base; # z0y
    } elsif ($idig == 2) {
        $result = $nprev % $bpow2;                             # 0xy
    }
    return $result;
} # get_mask
#--------
sub get_miss { # get all digits, but one replaced by 0
    my ($idig, $nprev) = @_;
    my $result;
    if (0) {
    } elsif ($idig == 0) {
        $result = ($nprev / $base)  * $base;                   # zx0
    } elsif ($idig == 1) {
        $result = ($nprev / $bpow2) * $bpow2 + $nprev % $base; # z0y
    } elsif ($idig == 2) {
        $result = $nprev % $bpow2;                             # 0xy
    }
    return $result;
} # get_miss
#--------
__DATA__
with first vertical bar:
C:\Users\gfis\work\gits\fasces\data>grep summary paths.*.tmp
paths.2.tmp:<summary count="1" opposite="1" />
paths.3.tmp:<summary count="3" diagonal="1" inside="1" opposite="1" symmetrical="1" />
paths.4.tmp:<summary count="17" inside="6" opposite="4" outside="7" />
paths.5.tmp:<summary count="160" diagonal="23" inside="80" opposite="20" outside="37" symmetrical="4" />
paths.6.tmp:<summary count="3501" inside="1970" opposite="378" outside="1153" />
paths.7.tmp:<summary count="144476" diagonal="11658" inside="89873" opposite="10204" outside="32741" symmetrical="66" />

<summary count="144476" diagonal="11658" inside="89873" opposite="10204" outside="32741" symmetrical="66" />
</paths>
real    24m21.520s
user    24m3.357s
sys     2m4.309s


with 00->01 only:
<summary count="412" corner="45" diagonal="52" inside="182" opposite="41" outside="92" symmetrical="8" />
<summary base="7" count="13541" diagonal="11658" inside="1883" multiway="2968247" symmetrical="66" />
<summary base="7" count="11658" diagonal="11658" symmetrical="66" />
</paths>

real    5m14.596s
user    5m13.858s
sys     0m0.169s
