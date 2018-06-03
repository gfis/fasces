#!/usr/bin/perl

# FASS: generate all noncrossing paths which fill a square of defined size completely
# 2018-06-01: draw_graph with oies, utf8
# 2018-05-30: extrapolate
# 2018-05-18: if the path marks a border element, the two neighbours on the border may not be both unmarked
# 2018-05-10: even bases 2, 4, ...; summary
# 2017-08-23, Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl gen_paths [-b base] [-l dim] [-m mode] [-d n]
#       -b base  (default 5)
#       -e       output paths with extrapolation errors
#       -g gmode none, asc, base, oeis, utf8
#       -l dim   extrapolate up to this dimension (default 3 = cube)
#       -m mode  symm(etric), diag(onal), wave, extra, nobar
#       -v[b]    output vector, maybe in base
#       -d debug level n (default: 0 = none)
#-------------------------
use strict;
use integer; # avoid division problems with reals
use feature 'unicode_strings';
binmode(STDOUT, ":utf8");
my $debug  = 0;
my $ansi   = 0;  # whether to use ANSI colors on console output
my $base   = 5;
my $unit   = 1;  # dual to $base
my $diag   = 0;
my $error  = 0;  # whether to output paths with extrapolation errors
my $graph  = "utf8"; # one of the graph modes: none, oeis, asc, utf8
my $maxexp = 2;  # compute b-file up to $base**$maxexp
my $mode   = "wave,cube"; # no special conditions; maybe "nobar"
my $symm   = 0;
my $maxdim = 3;
my $vector = 0; # whether to output a vector
my $vecstr = "";
my $digits = "0123456789abcdefghijklmnopqrstuvwxyz"; # for counting in base 11, 13, ...
my %attrs  = (); # path attributes: symmetrical, corner, ...

while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-b}) {
        $base   = shift(@ARGV);
    } elsif ($opt =~ m{\-a}) {
        $ansi   = 1;
    } elsif ($opt =~ m{\-e}) {
        $error  = 1;
    } elsif ($opt =~ m{\-g}) {
        $graph  = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $maxdim = shift(@ARGV);
    } elsif ($opt =~ m{\-m}) {
        $mode   = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-vb?}) {
        $vector = ($opt =~ m{b}) ? 2 : 1;
    }
} # while opt
$symm = ($mode =~ m{sy}) ? 1 : 0;
$diag = ($mode =~ m{di}) ? 1 : 0;
my $vert    = "||"; if ($ansi == 1) { $vert = "\x1b[103m$vert\x1b[0m"; }
my $hori    = "=="; if ($ansi == 1) { $hori = "\x1b[103m$hori\x1b[0m"; }
my $blan    = "  ";
my $pathno  = 0;
my @matrix  = ();
my @filled  = ();
my $corner  = $base * $base;
my $full    = $corner - 1;
my $last    = $corner - 1;
my $half    = $full / 2;
if ($symm == 1) {
    $last /= 2; # in the center
}
my $bpow2   = $base * $base;
my $basem1  = $base - 1;
my $basep1  = $base + 1; # mod base+1 = 0 for diagnonal path elements
my $base2m1 = $base * 2 - 1; # 9  for base=5
my $ind = 2;
my @bpow = ($unit, $base, $bpow2);
while ($ind <= 8) { # how many base digits will fit into an integer???
    $bpow[$ind + 1] = $bpow[$ind] * $base;
    $ind ++;
} # while bpow
my @path = ();
my @invp; # at which index does a path value occur
$ind = 0;
while ($ind < $corner) { # preset filled
    $filled[$ind] = 0;
    $ind ++;
} # preset filled
my $ssep = ",";

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
my $count = 0;
&iterate();
exit(0);
#-----------------------------------------
# process the stack
sub iterate { my ($dummy) = @_;
    %attrs = ();
    while (scalar(@stack) > 0) { # pop
        my ($pind, $pval) = split(/$ssep/, pop(@stack));
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
                &check_path();
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

    print "\n<summary base=\"$base\" count=\"$count\" pathno=\"$pathno\"";
    foreach my $attr(sort(keys(%attrs))) {
        print " $attr=\"$attrs{$attr}\"";
    } # foreach
    print " />\n</paths>\n";
} # iterate
#--------
sub check_path { my ($dummy) = @_;
    $pathno ++;
    my $wave           = &check_wave();
    my $not_expandable = &extrapolate($maxdim);
    if (   $error > 0
        or ($wave >= 3 and $not_expandable == 0)
        or ($base & 1) == 0) {
        &output_path($wave, $not_expandable);
    } # success
} # check_path
#--------
sub output_path { my ($wave, $not_expandable) = @_;
    if ($wave >= 3 and $not_expandable == 0) {
        $count ++;
    }
    print "<!-- ========================== -->\n";
    my $attributes = &get_final_attributes();
    my $gear       = &get_gear (@path);
    my $ratio      = &get_ratio($gear);
    print "<meander id=\"$count\" pathno=\"$pathno\" wave=\"$wave\" base=\"$base\"\n"
        . "     nex=\"$not_expandable\" gear=\"$gear\" ratio=\"$ratio\" \t attrs=\"$attributes\"\n"
        . "     path=\""  . join(",", map {         $_  } @path) . "\"\n"
        . "     bpath=\"" . join(",", map { &based0($_) } @path) . "\"\n"
        . "     >\n";
    &draw_graph($graph);
    if ($vector > 0) {
        print "<vector>\n$vecstr\n</vector>\n";
    }
    print "</meander>\n";
} # output_path
#--------
sub mark { my ($val) = @_;
    push(@path, $val);
    $filled[$val]             = 1;
    if ($symm == 1) {
        $filled[$full - $val] = 1;
    }
} # mark
#--------
sub unmark { my ($dummy) = @_;
    my $val = pop(@path);
    $filled[$val]             = 0;
    if ($symm == 1) {
        $filled[$full - $val] = 0;
    }
} # unmark
#--------
sub is_free { my ($vnext) = @_;
    return ($filled[$vnext] == 0 and ($symm == 0 or $filled[$corner - 1 - $vnext] == 0)) ? 1 : 0;
} # is_free
#--------
# check for "stairs"
# resulting bad turnss for base 5 are:
#  with       without
#  2 412      2 412
#  2 3312     2 411
#  2 2        2 3211
#  2 1332     2 211
#  2 132      2 2
#             2 1332
#             2 132
#             2 1234
#             2 122
#             2 1

sub stairs { my ($len, $pdist) = @_; # $path[$len - 1] == $vlast
    if (($error > 0 or ($base & 1) == 0)) { # not if errors allowd or even base
        return 0;
    }
    my $dist = $pdist;
    my $fail = 0;
    my $ind = $len - 1;
    my $vold = $path[$ind]; # $vlast
    my $vnew;
    $ind --;
    while ($fail == 0 and $len - $ind <= 6) {
        $dist = $base + 1 - $dist;
        $vnew = $path[$ind];
        my $diff = abs($vnew - $vold);
        if ($diff != $dist) { # and $diff != ($dist << 1)) {
            $fail = 1;
        }
        $vold = $vnew;
        $ind --;
    } # while $ind
    # if ($debug >= 2 and $len - $ind > 5) {
    #   print "<!-- len=$len, ind=$ind -->\n";
    #   &draw_graph($graph);
    # }
    $fail = $len - $ind <= 5 ? 0 : 1;
    return $fail;
} # stairs
#--------
# Determine and push possible followers of last vertex.
# If the path hits a border, the square is divided in 2 halves,
# and the two neighbours on the border may not be both free,
sub push_urdl {
    my $len   = scalar(@path);
    my $vlast = $path[$len - 1];
    my $vprev = $path[$len - 2];
    my $xlast = &get_digit($vlast, 1);
    my $ylast = &get_digit($vlast, 0); # rightmost character
    my ($vnext, $xnext, $ynext, $vnei1, $vnei2, $fail);
    $fail = 0;
    if ($xlast == $ylast and $xlast == $basem1 and scalar(@path) != $corner and ($base & 1) == 1) {
        # diagonal corner is not last path element (for odd bases)
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
        if ($ylast < $basem1) { $fail = 0;  # may go up
            $vnext = $vlast + $unit;        # go up
            if (&is_free($vnext) == 1 and &stairs($len,   $unit) == 0) {
                $ynext =     &get_digit($vnext, 0);
                if ($ynext == $basem1) {    # at upper border
                    $xnext = &get_digit($vnext, 1);
                    $vnei1 = $xnext == 0       ? $vnext - $unit : $vnext - $base; # down or left
                    if (&is_free($vnei1)) {
                    $vnei2 = $xnext == $basem1 ? $vnext - $unit : $vnext + $base; # down or right
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@stack, "$len$ssep$vnext");
                }                           # push upper
            }
        }
        if ($ylast > 0      ) { $fail = 0;  # may go down
            $vnext = $vlast - $unit;        # go down
            if (&is_free($vnext) == 1 and &stairs($len,   $unit) == 0) {
                $ynext =     &get_digit($vnext, 0);
                if ($ynext == 0      ) {    # at lower  border
                    $xnext = &get_digit($vnext, 1);
                    $vnei1 = $xnext == 0       ? $vnext + $unit : $vnext - $base; # up or left
                    if (&is_free($vnei1)) {
                    $vnei2 = $xnext == $basem1 ? $vnext + $unit : $vnext + $base; # up or right
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@stack, "$len$ssep$vnext");
                }                           # push lower
            }
        }
        if ($xlast < $basem1) { $fail = 0;  # may go right
            $vnext = $vlast + $base;        # go right
            if (&is_free($vnext) == 1 and &stairs($len,   $base) == 0) {
                $xnext =     &get_digit($vnext, 1);
                if ($xnext == $basem1) {    # at right  border
                    $ynext = &get_digit($vnext, 0);
                    $vnei1 = $ynext == $basem1 ? $vnext - $base : $vnext - $unit; # left or down
                    if (&is_free($vnei1)) {
                    $vnei2 = $ynext == 0       ? $vnext - $base : $vnext + $unit; # left or up
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@stack, "$len$ssep$vnext");
                }                           # push right
            }
        }
        if ($xlast > 0      ) { $fail = 0;  # may go left
            $vnext = $vlast - $base;        # go left
            if (&is_free($vnext) == 1 and &stairs($len,   $base) == 0) {
                $xnext =     &get_digit($vnext, 1);
                if ($xnext == 0      ) {    # at left   border
                    $ynext = &get_digit($vnext, 0);
                    $vnei1 = $ynext == $basem1 ? $vnext + $base : $vnext - $unit; # right or down
                    if (&is_free($vnei1)) {
                    $vnei2 = $ynext == 0       ? $vnext + $base : $vnext + $unit; # right or up
                    if (&is_free($vnei2)) { $fail = 1; }
                    }
                }
                if ($fail == 0) {
                    push(@stack, "$len$ssep$vnext");
                }                           # push left
            }
        }
        # if ($debug >= 2) {
        #     print "push_urdl: vlast=$vlast, xlast=$xlast, ylast=$ylast, " . join("/", @stack) . "\n";
        # }
    } # $fail = 0
} # push_urdl
#--------
# compute the inverse of @path
sub set_inverse { my ($dummy) = @_;
    for (my $ind = 0; $ind < $bpow2; $ind ++) { # precompute the inverse
        my $paval = $path[$ind];
        $invp[$paval] = $ind;
    } # for $ind
} # set_inverse
#--------
# try to expand the path up to some dimension
sub extrapolate { my ($maxdim) = @_;
    my $debsave = $debug;
    my $UNKN = -256; # never met
    # $debug = 1;
    my $ind;
    &set_inverse();
    my $vsep = "[";
    if ($vector > 0) {
        $vecstr = "";
        for ($ind = 0; $ind < $bpow2; $ind ++) { # precompute the values where one digit is 0
            my $paval = $path[$ind];
            $vecstr .= $vsep . ($vector == 2 ? &to_base($paval) : $paval);
            if ($ind % 16 == 15) {
                $vecstr .= "\n";
            }
            $vsep = ",";
        } # for $ind
    } # vector
    if ($debug >= 2) {
        print "# ind :   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s",         ($ind          )); } print "\n";
        print "# bind:   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s", &based0 ($ind          )); } print "\n";
        print "# path:   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s", &based0 ($path[$ind]   )); } print "\n";
        print "# invp:   "; for ($ind = 0; $ind < $bpow2; $ind ++) { print sprintf("%4s", &based0 ($invp[$ind]   )); } print "\n";
    }
    $ind       = $bpow2;
    my $fail   = 0;
    my $nprev  = $path[$ind - 2]; # previous node, e.g.  44 for base=5
    my $ncurr  = $path[$ind - 1]; # at least for diagonal paths, with odd base
    my $limit  = $bpow[$maxdim];
    my $slidim = $maxdim; # not yet: ??? 3; # sliding dimension, start with k up to 2 for 044
    my $currdig;
    while ($fail == 0 and $ind < $limit) {
        # compute the successor of $nprev at $ind
        print "# try       " . &to_base($nprev) . " -> " . &to_base($ncurr) . " -> ?\n" if $debug >= 2;
        my $nnext   = $UNKN;
        my $candno = 0; # number of possible candidates
        my $k = 0;
        while ($k < $slidim) {
            my $pm = -1;
            while ($pm < 2) {
                $currdig = &get_digit($ncurr, $k);
                # $currdig = $k != 0 ? (($ncurr / $bpow[$k]) % $base) : $ncurr % $base;
                if (($currdig != 0 or $pm != -1) and ($currdig != $basem1 or $pm != +1)) { # next will not be at any border
                    my $ncand = $ncurr + $pm * $bpow[$k]; # candidate with digit -+ 1
                    print "# candidate " . &to_base($ncand) . " k=$k, pm=$pm, currdig=$currdig\n" if $debug >= 2;
                    if ($ncand != $nprev) { # test whether all subpairs (i,j) of $ncand fulfill the adjacency condition
                        my $adjac = 1; # assume all subpair combinations are adjacent
                        my $j = 0;
                        while ($adjac == 1 and $j < $slidim - 1) {
                            my $i = $j + 1;
                            while ($adjac == 1 and $i < $slidim) { # try all pairs
                                if ($i == $k or $j == $k) {
                                    my $curr2  = &get_pair($ncurr, $i, $j);
                                    my $cand2  = &get_pair($ncand, $i, $j);
                                    if (abs($invp[$curr2] - $invp[$cand2]) > 1) { # the are not equal or adjacent
                                        $adjac = 0;
                                    }
                                    print "# pair ($i,$j): " . &based0($curr2) . ($adjac == 1 ? " isadjac " : " notadj ")
                                        . &based0($cand2) . "\n" if $debug >= 2;
                                } # i or j is k
                                $i ++;
                            } # while $i
                            $j ++;
                        } # while $j
                        if ($adjac == 1) { # found
                            $candno ++;
                            $nnext = $ncand;
                        } # found
                    } # next != prev
                } # not at the border
                $pm += 2;
            } # while $pm
            $k ++;
        } # while $k
        if (0) {
        } elsif ($candno == 0) {
            print "# no candidate " . &to_base($ncurr) . " -> ?\n" if $debug >= 2;
            $fail = 1;
        } elsif ($candno >  1) {
            print "# conflict for " . &to_base($ncurr) . " -> ?\n" if $debug >= 2;
            $fail = $candno;
        } else {
            if ($k == $slidim and $currdig == 0 and $slidim < $maxdim) {
                $slidim ++;
            }
            print "# found     " . &to_base($nprev) . " -> " . &to_base($ncurr) . " -> " . &to_base($nnext) . ", slidim=$slidim\n" if $debug >= 2;
            # print "$ind $nnext\n";
            if ($vector > 0) {
                $vecstr .= $vsep . ($vector == 2 ? &to_base($nnext) : $nnext);
                if ($ind % 16 == 15) {
                    $vecstr .= "\n";
                }
            }
            $nprev = $ncurr;
            $ncurr = $nnext;
        }
        $ind ++;
    } # while $ind
    $vecstr .= "]";
    $debug = $debsave;
    return $fail;
} # extrapolate
#----------
# gets 1 digit; position $k = 0 gets lowest digit to base
sub get_digit { my ($ncurr, $k) = @_;
    return $k != 0 ? ($ncurr / $bpow[$k]) % $base : $ncurr % $base;
} # get_digit
#---------
# get a pair of digits from an element; 0 <= i < j <= 5
sub get_pair { my ($nprev, $i, $j) = @_;
    my $a =   ($i != 0 ? (($nprev / $bpow[$i]) % $base) : $nprev % $base);
    my $b =   ($j != 0 ? (($nprev / $bpow[$j]) % $base) : $nprev % $base);
    if (($base & 1) == 0) { # even base
        if ((abs($i - $j) & 1) == 0) { # even dimension distance
            $a = $basem1 - $a;
            $b = $basem1 - $b;
        }
    }
    return $a * $base + $b;
} # get_pair
#--------
# check whether there is a wave with a center on the diagonal
sub check_wave { my ($dummy) = @_;
    # similiar to checK_symdiag, but the symmetricity must have a wave shape
    my $result = 0; # assume failure
    if ($base <= 3 or ($base & 1) == 0) { # skip for 3 and even bases
        return 3;
    } # skip
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
# add an attribute
sub add_attr { my ($attr) = @_;
    if (defined($attrs{$attr})) {
        $attrs{$attr} ++;
    } else {
        $attrs{$attr} = 1;
    }
    return $attrs{$attr};
} # add_attr
#--------
# determine general properties of the endpoint and of the finished path
sub get_final_attributes { my ($dummy) = @_;
    my $result = "";
    my $last = $path[scalar(@path) - 1];
    #----
    my $dig0 =  $last          % $base;
    my $dig1 = ($last / $base) % $base;
    if (0) {                    # properties of the endpoint
    } elsif ((              $dig0 == $basem1) and (              $dig1 == $basem1)) {
        $result .= ",diagonal"; # right upper
    } elsif (($dig0 == 0                    ) and (              $dig1 == $basem1)) {
        $result .= ",opposite"; # right lower
    } elsif (($dig0 == 0 or $dig0 == $basem1) and ($dig1 == 0 or $dig1 == $basem1)) {
        $result .= ",corner";   # in one of the 3 corners
    } elsif (($dig0 == 0 or $dig0 == $basem1) or  ($dig1 == 0 or $dig1 == $basem1)) {
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
#=========================================
# presentation routines
#=========================================
#-----------------------------------------
# copied into gen_meander.pl, change there and here
# Special encoding of the path with its turns.
# Begin with 1, and assume right turn.
# For each bar, add one to the current digit.
# For a turn in the same direction, a new digit is started.
# If the direction of the turn was in the opposite direction, insert a "-" first.
# (So far that are the same as the rules for 'turns', above).
# In addition, start a new digit if the path element is on the diagonal.
# Assume that the turning direction changes there, and insert a "-" before the new digit,
# but if the turning direction remains the same, insert a "+" before.
# start a new digit.
#    +1                  02==12  22
# -b xy +b               ||  ||  ||
#    -1                  01  11  21  => gear = "211-112" = "211/
#                        ||  ||  ||
#                        00  10==20
#
sub get_gear { my (@path) = @_;
    my $result = "";
    my $code   = 0;
    my $odir   = +$unit; # +y
    my $nturn  = 1; # right=1, left=0
    my $oturn  = $nturn;
    my $change = 0;
    my $sep    = "";
    for (my $ind = 1; $ind < scalar(@path); $ind ++) {
        my $ndir = $path[$ind] - $path[$ind - 1];
        $change = 0;
        if ($odir != $ndir) { # change in direction
            $change |= 1;
            $nturn =  # 4 possible right turns:
                (  ($odir == +$unit and $ndir == +$base)  # up    to right
                or ($odir == +$base and $ndir == -$unit)  # right to down
                or ($odir == -$unit and $ndir == -$base)  # down  to left
                or ($odir == -$base and $ndir == +$unit)  # left  to up
                ) ? 1 : 0; # right : left
        }
        if ($path[$ind - 1] % $basep1 == 0 and ($path[$ind - 1] != 0)) { # diag
            $change |= 2;
        }
        # if ($debug >= 2) {
        #     print "[" . &based0($path[$ind]) ."] "
        #         . (($change & 2 != 0) ? "diag " : "")
        #         . "ndir " . (($change & 1 != 0) ? "same " : "diff ")
        #         . "code=$code sep=\"$sep\" nturn "
        #         . ($nturn == 1 ? "right " : "left  ") . "\n";
        # }
        if (     $change == 0) { # no change at all
            $code ++;
        } elsif ($change == 1) { # only dir change
            if ($oturn != $nturn) {
                $sep = "-";
                $oturn = $nturn;
            }
            $result .= $sep . substr($digits, $code, 1);
            $sep = "";
            $code = 1;
        } elsif ($change == 2) { # only on diagonal
            $result .= $sep . substr($digits, $code, 1);
            $sep = "+";
            $code = 1;
            # $oturn = 1 - $oturn;
        } elsif ($change == 3) { # dir change and on diagonal
            $result .= $sep . substr($digits, $code, 1);
            if ($oturn == $nturn) {
                $sep = "+";
            } else {
                $sep = "-";
                $oturn = $nturn;
            }
            $code = 1;
        }
        # if ($debug >= 2) {
        #     print "[" . &based0($path[$ind]) ."]" . "      change $change"
        #       . " code=$code sep=\"$sep\" $result\n";
        # }
        $odir = $ndir;
    } # for $ind
    $result .= $sep . substr($digits, $code, 1);
    if ($debug >= 2) {
        print "[" . &based0($path[$ind]) ."]" . " $result\n";
    }
    return $result;
} # get_gear
#--------
# c.f. https://github.com/gfis/ramath/src/main/java/org/teherba/ramath/linear/Vector.java
sub gcd { my ($a, $b) = @_;
	my $result = abs($a);
	if ($result != 1) {
		my $p = $result;
		my $q = abs($b);
		while ($q != 0) {
			my $temp = $q;
			$q = $p % $q;
			$p = $temp;
		} # while $q
		$result = $p;
	}
	return abs($result);
} # gcd
#--------
# Gets the gear ratio.
# Replace the n+m portions of the gear expression by p=n+m.
# Interprete the digits as numbers teeth of gear wheel
# (times 16, for example, for a corresponding mechanical gear).
# Concatenated digits will turn in the same direction (by addition
# of an auxiliary connecting wheel of arbitrary size),
# while a "-" will reverse the direction.
# How much and in what direction will the last wheel turn
# if the first wheel turns +360°?
#
sub get_ratio { my ($gear) = @_; # e.g. &gear(Ls) = "413-131-21-211-112"
    my @chars  = split(//, $gear . "  ");
    if ($debug >= 1) {
        print "ratio(\"" . join(".", @chars) . "\")\n";
    }
    my $ind    = 0;
    my $onum   = index($digits, $chars[$ind]); $ind ++;
    my $nnum   = 1;
    my $nomin  = 1;
    my $denom  = 1;
    my $len    = scalar(@chars) - 2; # we did append "  "
    while ($ind < $len) {
        my $nch = $chars[$ind];
        if (0) {
        } elsif ($nch eq "+") {
        	# ignore
        } elsif ($nch eq "-") {
            $denom = - $denom;
        } else { # $nch should be a digit
            $nnum = index($digits, $nch);
            # if ($chars[$ind + 1] eq "+") {
            #     $nnum += index($digits, $chars[$ind + 2]);
            #     $ind += 2
            # }
            if ($onum == $nnum) {
                # ignore
            } else {
                $denom *= $onum;
                $nomin *= $nnum;
            }
            if ($debug >= 1) {
                print "ratio($gear) \@$ind $onum ~ $nnum: $denom/$nomin\n";
            }
            $onum = $nnum;
        }
        $ind ++;
    } # while $ind
    my $dngcd = &gcd($denom, $nomin);
    if ($dngcd > 1) {
    	$denom /= $dngcd;
    	$nomin /= $dngcd;
    }
    return ($nomin == 1) ? $denom : "$denom/$nomin";
} # get_ratio
#-----------------------------------------
# variables for drawing, set when &draw_line is called with $iline == 0
my $no_draw_lines;
my $right_bar;
my $space_bar;  # must have the length of $right_bar
my $down_bar;   # must have the length of a grid coordinate representation
my $space_grid; # must have the length of a grid coordinate representation
#--------
sub draw_line { my ($iline, $graph_mode, $y) = @_; # global $base, @path and the 5 variabless above
    if ($iline == 0) {
        # initialize
        if (1) {
            if (0) {
            } elsif ($graph_mode =~ m{asc} ) { # with + -- |
                $no_draw_lines = 1;
                $right_bar     = "-";
                $space_bar     = " ";
                $down_bar      = "";
                $space_grid    = "";
            } elsif ($graph_mode =~ m{base}  ) { #
                $no_draw_lines = 2;
                $right_bar     = "==";
                $space_bar     = "  ";
                $down_bar      = "||";
                $space_grid    = "  ";
            } elsif ($graph_mode =~ m{oeis}  ) {
                $no_draw_lines = 3;
                $right_bar     = "--";
                $space_bar     = "  ";
                if ($base < 10) { #   "(3,4)"
                    $down_bar      =  "  |  ";
                    $space_grid    =  "     ";
                } else { #           "(13,14)"
                    $down_bar      = "   |   ";
                    $space_grid    = "       ";
                }
            } elsif ($graph_mode =~ m{utf8}   ) { # light unicode box characters
                $no_draw_lines = 1;
                $right_bar     = "\N{U+2500}";
                $space_bar     = " ";
                $down_bar      = "";
                $space_grid    = "";
            }
        }
    } else { # draw 1-3 lines
        # draw one grid point and the right bar
        for (my $x = 0; $x < $base; $x ++) {
            my ($adj_right, $adj_down, $adj_left, $adj_up, $code);
            my $ipa = $x * $base + $y;
            $adj_right = ($x < $base - 1 and abs($invp[$ipa] - $invp[$ipa + $base]) == 1) ? 1 : 0; # whether x,y is adjacent to x+1,y
            $adj_left  = ($x > 0         and abs($invp[$ipa] - $invp[$ipa - $base]) == 1) ? 1 : 0; # whether x,y is adjacent to x-1,y
            $adj_up    = ($y < $base - 1 and abs($invp[$ipa] - $invp[$ipa + 1    ]) == 1) ? 1 : 0; # whether x,y is adjacent to x,y-1
            $adj_down  = ($y > 0         and abs($invp[$ipa] - $invp[$ipa - 1    ]) == 1) ? 1 : 0; # whether x,y is adjacent to x,y-1
            $code = "x";
            if ($iline == 1) { # line with grid points
                if (0) {
                } elsif ($graph_mode =~ m{asc} ) { # with + -- |
                    if (0) {
                    } elsif ($x == 0         and $y == 0        ) {
                        $code = "s";
                    } elsif ($x == $base - 1 and $y == $base - 1) {
                        $code = "e";
                    } elsif ($adj_left ) {
                        if (0) {
                        } elsif ($adj_right) { $code = "-"; # "-"; # horizontal
                        } elsif ($adj_up   ) { $code = "J"; # "d";
                        } elsif ($adj_down ) { $code = "."; # "q";
                        }
                    } elsif ($adj_right) {
                        if (0) {
                        } elsif ($adj_up   ) { $code = "L"; # "b";
                        } elsif ($adj_down ) { $code = "r"; # "p";
                        }
                    } elsif ($adj_up   ) {
                        if (0) {
                        } elsif ($adj_down ) { $code = "|"; # "|"; # vertical
                        }
                    }
                    print $code;
                    # unicode
                } elsif ($graph_mode =~ m{base}  ) { #
                    print substr($digits, $x, 1) . substr($digits, $y, 1);
                } elsif ($graph_mode =~ m{oeis}  ) {
                    print sprintf($base < 10 ? "(%d,%d)" : "(%2d,%2d)", $x, $y);
                } elsif ($graph_mode =~ m{utf8}   ) { # light unicode box characters
                    if (0) {
                    } elsif ($x == 0         and $y == 0        ) {
                        $code = "\N{U+2502}"; # vertical
                    } elsif ($x == $base - 1 and $y == $base - 1) {
                        $code = $adj_left ? "\N{U+2500}" : "\N{U+2502}";
                    } elsif ($adj_left ) {
                        if (0) {
                        } elsif ($adj_right) { $code = "\N{U+2500}"; # "\N{U+2501}"; # horizontal
                        } elsif ($adj_up   ) { $code = "\N{U+2518}"; # "\N{U+251b}";
                        } elsif ($adj_down ) { $code = "\N{U+2510}"; # "\N{U+2513}";
                        }                                            #
                    } elsif ($adj_right) {                           #
                        if (0) {                                     #
                        } elsif ($adj_up   ) { $code = "\N{U+2514}"; # "\N{U+2517}";
                        } elsif ($adj_down ) { $code = "\N{U+250c}"; # "\N{U+250f}";
                        }                                            #
                    } elsif ($adj_up   ) {                           #
                        if (0) {                                     #
                        } elsif ($adj_down ) { $code = "\N{U+2502}"; # "\N{U+2503}"; # vertical
                        }
                    }
                    print $code;
                    # unicode
                }
                if ($x < $base - 1) {
                    print ($adj_right == 1 ? $right_bar : $space_bar);
                } else {
                    print "\n";
                }
            } elsif ($iline > 1 and $y > 0) {
                # draw vertical bars below the grid points (except for last line)
                print ($adj_down == 1 ? $down_bar : $space_grid);
                if ($x < $base - 1) {
                    print $space_bar;
                } else {
                    print "\n";
                }
            } # below the grid points
        } # for $x
    } # draw 1-3 lines
} # draw_line
#--------
# draw a graph showing the path
sub draw_graph { my ($graph_mode) = @_; # global $base, @path
    if ($graph_mode =~ m{none}) {
        return;
    }
    &set_inverse();
    print "<graph>\n";
    &draw_line(0, $graph_mode, 0); # initialize
    for (my $y = $base - 1; $y >= 0; $y --) {
        for (my $iline = 1; $iline <= $no_draw_lines; $iline ++) {
            &draw_line($iline, $graph_mode, $y);
        } # for $iline
    } # for $y
    print "</graph>\n";
} # draw_graph
#--------
# return a number in base $base, 2 digits with leading zero
sub based0 { my ($num) = @_;
    return substr($digits, &get_digit($num, 1), 1)
        .  substr($digits, &get_digit($num, 0), 1)
        ;
} # based0
#--------
# convert from decimal to base, without leading zeroes
sub to_base { my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $base;
        $result =  substr($digits, $digit, 1) . $result;
        $num /= $base;
    } # while > 0
    return $result eq "" ? "0" : $result;
} # to_base
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

<!-- ========================== -->
<meander id="34862" wave="3" attrs="diagonal" base="9"
     path="0,1,2,3,4,5,6,7,8,17,26,35,44,53,62,71,70,61,52,43,34,33,42,51,60,69,68,67,66,57,58,59,50,49,48,39,40,41,32,31,30,29,38,47,56,65,64,55,46,37,28,19,20,21,22,23,24,25,16,15,14,13,12,11,10,9
     ,18,27,36,45,54,63,72,73,74,75,76,77,78,79,80"
     bpath="00,01,02,03,04,05,06,07,08,18,28,38,48,58,68,78,77,67,57,47,37,36,46,56,66,76,75,74,73,63,64,65,55,54,53,43,44,45,35,34,33,32,42,52,62,72,71,61,51,41,31,21,22,23,24,25,26,27,17,16,15,14,13
,12,11,10,20,30,40,50,60,70,80,81,82,83,84,85,86,87,88/"
     >
<draw-path>

08==18==28==38==48==58==68==78  88
||                          ||  ||