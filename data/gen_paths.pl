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
#   perl gen_paths [-b base] [-l dim] [-m mode] [-d n]
#       -b base  (default 5)
#       -m mode  symm(etric), diag(onal), wave, extra, nobar
#       -l dim   extrapolate up to this dimension (default 3 = cube)
#       -d debug level n (default: 0 = none)
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $debug  = 0;
my $ansi   = 0;  # whether to use ANSI colors on console output
my $base   = 5;
my $diag   = 0;
my $maxexp = 2;  # compute b-file up to $base**$maxexp
my $mode   = "wave,cube"; # no special conditions; maybe "nobar"
my $symm   = 0;
my $maxdim = 3;
my $vert   = "||";
my $hori   = "==";
my $blan   = "  ";
my $letters = "abcdefghijklmnopqrstuvwxyz";
my %attrs  = (); # path attributes: symmetrical, corner, ...

while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{b}) {
        $base   = shift(@ARGV);
    } elsif ($opt =~ m{a}) {
        $ansi   = 1;
    } elsif ($opt =~ m{l}) {
        $maxdim = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $mode   = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
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
my @bpow = (1, $base, $bpow2, $bpow3, $bpow3 * $base, $bpow3 * $bpow2); # up to ^5

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

my @stack = (); # entries are "path_index${sep}value"
$ind = 0;
&mark($ind); $ind ++;
&mark($ind); $ind ++;
# always with a normalized start: 00->01
if ($mode =~ m{nobar}) { # but full length bar can be suppressed by "nobar"
    $ind = $base;
}
while ($ind < $base) { # start with 00->01->02->...->0b
    &mark($ind);
    $ind ++;
} # vertical bar
&push_urdl();
&iterate();
exit(0);
#-----------------------------------------
sub iterate { # process stack
    %attrs = ();
    while (scalar(@stack) > 0) { # pop
        my ($pind, $pval) = split(/$sep/, pop(@stack));
        while (scalar(@path) > $pind) {
            &unmark();
        } # while unmark
        # if ($debug >= 2) {
        #     print "stack[" . sprintf("%3d", scalar(@stack)) . "]\@$pind: "
        #             . join(",", map { &based0($_) } @path) . " ". &based0($pval)
        #             . "?\n";
        #     my $ifil = 0;
        #     while ($ifil < scalar(@filled)) {
        #         print &based0($ifil) . ";$filled[$ifil] ";
        #         $ifil ++;
        #     }
        #     print "\n";
        # }
        &mark($pval);
        my $plen = scalar(@path);
        if ($symm == 1 ? ($pval == $last) : ($plen <= $last + 1)) {
            print "pval=$pval, plen=$plen, last=$last, full=$full\n" if $debug >= 2;
            if ($plen == $last + 1) { # really at the end or in the center
                while ($plen < $corner) { # fill 2nd half in case of $symm
                    push(@path, $full - $path[$full - $plen]);
                    $plen ++;
                } # fill
                # if ($debug >= 2) {
                #     print "scalar(path)=" . scalar(@path) . ", plen=$plen, last=$last, full=$full\n";
                #     print join("/", map { &based0($_) } @path) . "\n";
                # }
                &output_path();
                @path = splice(@path, 0, $last + 1); # pop
            } elsif ($diag == 1 and $pval == $last) {
                # print "# skipped because of diag, plen=$plen\n" if $debug >= 2;
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
} # iterate
#--------
sub output_path {
    $pathno ++;
    my $wave = &check_wave();
    if ($wave >= 3) {
        my $not_expandable = &extrapolate($maxdim);
        # my $cube = &check_cube();
        if ($not_expandable == 0) {
            print "<!-- ========================== -->\n";
            my $attributes = &get_final_attributes();
            print "<matrix id=\"$pathno\" wave=\"$wave\" attrs=\"$attributes\" base=\"$base\"\n";
            print "     path=\""  . join(",", map {         $_  } @path) . "\"\n"
                . "     bpath=\"" . join(",", map { &based0($_) } @path) . "/\"\n"
                . "     >\n";
            &draw_path(@path);
            print "</matrix>\n";
        } # cube success
    } # wave success
} # output_path
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
            # print "# multiway $xlast$ylast, scalar=" . scalar(@path) . ", search=$ylast"
            #     . ", path[$ind]=$path[$ind]; path[$ind+1]=$path[$ind+1]; path=" . join(",", map { &based0($_) } @path) . "\n" if $debug >= 2;
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
                    push(@stack, "$len$sep$vnext");
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
                    push(@stack, "$len$sep$vnext");
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
                    push(@stack, "$len$sep$vnext");
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
                    push(@stack, "$len$sep$vnext");
                }                           # push left
            }
        }
        # if ($debug >= 2) {
        #     print "push_urdl: vlast=$vlast, xlast=$xlast, ylast=$ylast, " . join("/", @stack) . "\n";
        # }
    } # $fail = 0
} # push_urdl
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
                    # print "# id=$pathno inode=$inode, dnode=" . &based0($dnode) . ", diff=$diff, <> "
                    #         . ($dnode - $path[$inode - $dist]) . "\n" if $debug >= 2;
                    $symmetric = 0;
                    # deviation found
                } else { # no deviation
                    push(@diff2, $odiff - $diff);
                    $odiff = $diff;
                    # print "# id=$pathno inode=$inode, dnode=" . &based0($dnode)
                    #         . ", dist=$dist, diff=$diff\n" if $debug >= 2;
                }
                $dist ++;
            } # while symmetricity
            if (scalar(@diff2) >= 4) { # evaluate the 2nd differences and check for wave shape
                # for example -5,+1,+5,+5 for base-5 "s" with normal stroke direction
                # the 2nd differences switch between +-5 and -+1
                my $hlen = 0;
                # print "# id=$pathno inode=$inode, dnode=" . &based0($dnode)
                #         . ", #diff2=" . scalar(@diff2)
                #         . ", diff2=" . join(",", @diff2) . "\n" if $debug >= 2;
                my $first = $diff2[$hlen ++];
                while ($diff2[$hlen] == $first) {
                    $hlen ++;
                } # while
                # now $hlen = half of the length of the bar from the $dnode
                # a 7-wave MM would have @diff2 =  1 1 1 9 -1 -1 -1 -1 -1 -1 9 1 1 1 1 1 1 9 -1 -1 -1 -1 -1 -1
                if (scalar(@diff2) >= $hlen + $hlen + (2 * $hlen) * $hlen) { # long enough fo ra complete wave
                    my $parity = $inode % 2; # indicates the displacement from the center
                    my $nshape = abs($first) == 1 ? 1 : 0; # whether bars are vertical
                    # print "# id=$pathno inode=$inode, dnode=" . &based0($dnode)
                    #         . ", hlen=$hlen, parity=$parity, nshape=$nshape\n" if $debug >= 2;
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
    # determine general properties of the endpoint and of the finished path
    my $result = "";
    my $last = $path[scalar(@path) - 1];
    #----
    my $dig0 =  $last          % $base;
    my $dig1 = ($last / $base) % $base;
    if (0) {                    # properties of the endpoint
    } elsif ((              $dig0 == $base_1) and (              $dig1 == $base_1)) {
        $result .= ",diagonal"; # right upper
    } elsif (($dig0 == 0                    ) and (              $dig1 == $base_1)) {
        $result .= ",opposite"; # right lower
    } elsif (($dig0 == 0 or $dig0 == $base_1) and ($dig1 == 0 or $dig1 == $base_1)) {
        $result .= ",corner";   # in one of the 3 corners
    } elsif (($dig0 == 0 or $dig0 == $base_1) or  ($dig1 == 0 or $dig1 == $base_1)) {
        $result .= ",outside";  # at the border
    } else {
        $result .= ",inside";   # inside
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
#---------------------------------------------------------------------------
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
sub to_base { # convert from decimal to base
    my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $base;
        $result =  $digit . $result;
        $num /= $base;
    } # while > 0
    return $result eq "" ? "0" : $result;
} # to_base
#--------
sub extrapolate { # try to expand the path up to some dimension
    my ($maxdim) = @_;
    my $debsave = $debug;
    my $UNKN = -256; # never met
    # $debug = 1;
    my $ind;
    my @invp; # at which index does a path value occur
    for ($ind = 0; $ind < $bpow2; $ind ++) { # precompute the values where one digit is 0
        my $paval = $path[$ind];
        $invp[$paval] = $ind;
    } # for
    if ($debug >= 2) {
        print "# ind :   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s",         ($ind          )); } print "\n";
        print "# bind:   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s", &based0 ($ind          )); } print "\n";
        print "# path:   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s", &based0 ($path[$ind]   )); } print "\n";
        print "# invp:   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s", &based0 ($invp[$ind]   )); } print "\n";
    }
    $ind      = $bpow2;
    my $fail  = 0;
    my $nprev = $path[$ind - 2]; # previous node, e.g.  44 for base=5
    my $ncurr = $path[$ind - 1]; # at least for diagonal paths, with odd base
    my $limit = $bpow[$maxdim];
    while ($fail == 0 and $ind < $limit) {
        # compute the successor of $nprev at $ind
        print "# try       " . &to_base($nprev) . " -> " . &to_base($ncurr) . " -> ?\n" if $debug >= 1;
        my $nnext   = $UNKN;
        my $candno = 0; # number of possible candidates
        my $k = 0;
        while ($k < $maxdim) {
            my $pm = -1;
            while ($pm < 2) {
                # my $currdig = &get_digit1($ncurr, $k);
                my $currdig = $k != 0 ? (($ncurr / $bpow[$k]) % $base) : $ncurr % $base;
                if (($currdig != 0 or $pm != -1) and ($currdig != $base_1 or $pm != +1)) { # next will not be at any border
                    my $ncand = $ncurr + $pm * $bpow[$k]; # candidate with digit -+ 1
                    # print "# candidate " . &to_base($ncand) . " k=$k, pm=$pm\n" if $debug >= 1;
                    if ($ncand != $nprev) { # test whether all subpairs (i,j) of $ncand fulfill the adjacency condition
                        my $adjac = 1; # assume all subpair combinations are adjacent
                        my $j = 0;
                        while ($adjac == 1 and $j < $maxdim - 1) {
                            my $i = $j + 1;
                            while ($adjac == 1 and $i < $maxdim) { # try all pairs
                                my ($curra, $currb) = &get_pair($ncurr, $i, $j);
                                my ($canda, $candb) = &get_pair($ncand, $i, $j);
                                my $curr2  = $curra * $base + $currb;
                                my $cand2  = $canda * $base + $candb;
                                if ($curr2 != $cand2 and abs($invp[$curr2] - $invp[$cand2]) != 1) {
                                    $adjac = 0;
                                }
                                # print "# pair ($i,$j): curr($curra,$currb) " . ($adjac == 1 ? "isadjac" : "notadj") . " cand($canda,$candb)\n" if $debug >= 2;
                                $i ++;
                            } # while $i
                            $j ++;
                        } # while $j
                        if ($adjac == 1) {
                            $candno ++;
                            $nnext = $ncand;
                        }
                        # next != prev
                    } else {
                        # print "# same as previous: " . &to_base($nprev) . "\n" if $debug >= 1;
                    }
                } # not at the border
                $pm += 2;
            } # while $pm
            $k ++;
        } # while $k
        if (0) {
        } elsif ($candno == 0) {
            print "# no candidate " . &to_base($ncurr) . " -> ?\n" if $debug >= 1;
            $fail = 1;
        } elsif ($candno >  1) {
            print "# conflict for " . &to_base($ncurr) . " -> ?\n" if $debug >= 1;
            $fail = $candno;
        } else {
            # print "# found        " . &to_base($nprev) . " -> " . &to_base($ncurr) . " -> " . &to_base($nnext) . "\n" if $debug >= 1;
            # print "$ind $nnext\n";
            $nprev = $ncurr;
            $ncurr = $nnext;
        }
        $ind ++;
    } # while $ind
    $debug = $debsave;
    return $fail;
} # extrapolate
#---------
sub get_pair { # get a pair of digits from an element; 0 <= i < j <= 5
    my ($nprev, $i, $j) = @_;
    my ($a, $b) =
            ( ($i != 0 ? (($nprev / $bpow[$i]) % $base) : $nprev % $base)
            , ($j != 0 ? (($nprev / $bpow[$j]) % $base) : $nprev % $base)
            );
    return ($a, $b);
} # get_pair
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

2018-05-29, 23:54:
<summary base="7" count="11658" diagonal="47" symmetrical="9" />
