#!/usr/bin/perl
#
# 2018-05-15: 5th attempt, search for paths
# Program in the public domain
# c.f. https://oeis.org/A220952
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl gen_2d_paths.pl [-c] > 2d_paths.tmp
#       -c   generate C code
#   perl 2d_paths.tmp -b 5
# c.f. header comment below
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $ccode  = 0; # output Perl program
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # start with hyphen
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt eq "\-c") {
        $ccode  = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while opt

my $program = <<'GFis';
#!/usr/bin/perl
#
# 2018-05-15: 4th attempt, search for paths
# Program in the public domain
# c.f. https://oeis.org/A220952
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl gen_2d_paths.pl > 2d_paths.tmp
#   perl 2d_paths.tmp [-b n] [-d n] [-f] [-g] [-l n}> 2d_paths.tmp
#       -b n base (default 5)
#       -d n debug level n (default: 0)
#       -f   output bfile
#       -g   output graph of path
#       -l n limit expansion to n nodes (default 10000)
#       -m x mode: "diag"
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $connect_back = 0; # more connections???
my $debug  = 0;
my $ccode  = 0; # output Perl program
my $base   = 5;
my $bfile  = 0;
my $graph  = 0;
my $limit  = 10000;
my $mode   = 2;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # start with hyphen
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt eq "\-b") {
        $base   = shift(@ARGV);
    } elsif ($opt eq "\-c") {
        $ccode  = 1;
    } elsif ($opt eq "\-d") {
        $debug  = shift(@ARGV);
    } elsif ($opt eq "\-f") {
        $bfile  = 1;
    } elsif ($opt eq "\-g") {
        $graph  = 1;
    } elsif ($opt eq "\-l") {
        $limit  = shift(@ARGV);
    } elsif ($opt eq "\-m") {
        $mode   = shift(@ARGV);
    }
} # while opt
my $basep2   = $base   * $base;
my $basep3   = $basep2 * $base;
my $maxpath2 = $basep2 * 2; # because we store tuples (node,dir)
my $diag     = ($mode =~ m{diag}) ? 1 : 0;

my @dircode; # codes for the directions
my $mexp3 = 0; # greater than all bit exponents: 6
my $dr0 = 0;
$dircode[$dr0] = "**";
my $bit = 1;
#  direction masks zzyyxx - caution, the order here is very important below
#                  pmpmpm
my $xm1   = $bit;  $dircode[$bit] = "-x"; $bit <<= 1; $mexp3 ++;  # left
my $xp1   = $bit;  $dircode[$bit] = "+x"; $bit <<= 1; $mexp3 ++;  # right
my $ym1   = $bit;  $dircode[$bit] = "-y"; $bit <<= 1; $mexp3 ++;  # down
my $yp1   = $bit;  $dircode[$bit] = "+y"; $bit <<= 1; $mexp3 ++;  # up
my $mbit2 = $bit;
my $mexp2 = $mexp3;
my $zm1   = $bit;  $dircode[$bit] = "-z"; $bit <<= 1; $mexp3 ++;  # nearer
my $zp1   = $bit;  $dircode[$bit] = "+z"; $bit <<= 1; $mexp3 ++;  # farer
my $mbit3 = $bit; # greater than all bitmask values: 64
my $mbit3m1 = $mbit3 - 1;
my (@addx, @addy); # increments for directions
$addx[$xm1] = -1; $addy[$xm1] =  0;
$addx[$xp1] = +1; $addy[$xp1] =  0;
$addx[$ym1] =  0; $addy[$ym1] = -1;
$addx[$yp1] =  0; $addy[$yp1] = +1;
my @crosum  = (); # $cross[n] = number of bits set in n
my @invmask = (); # inverse masks (^= xor - clear bit)
my @revdir  = (); # reverse directions
my $num;
for ($num = 0; $num < $mbit3; $num ++) {
    my $csum = 0;
    $bit = 1;
    while ($bit <= $num) {
        if (($num & $bit) != 0) {
            $csum ++;
        }
        $bit <<= 1;
    } # while $bit
    $crosum [$num] = $csum;
    $invmask[$num] = 0;
    $revdir [$num] = 0;
} # for $num;
$bit = 1;
my $exp = 0;
while ($bit <= $mbit3) {
    $invmask[$bit] = $mbit3m1 ^ $bit;
    $revdir [$bit] = ($exp & 1) != 0 ? $bit >> 1 : $bit << 1;
    $exp ++;
    $bit <<= 1;
} # while $bit

my @poss2;  # possible connections in a square plane of @cube3
my @poss3;  # possible connections in @cube3
my @cube2;  # bitmask for occupied connections in a node
my @cube3;  # bitmask for occupied connections in a node
my ($x, $y, $z);

for ($z = 0; $z < $base; $z ++) { # preset with 0
    for ($y = 0; $y < $base; $y ++) {
        for ($x = 0; $x < $base; $x ++) {
            $poss2    [$y][$x] = 0;
            $cube2    [$y][$x] = 0;
            $poss3[$z][$y][$x] = 0;
            $cube3[$z][$y][$x] = 0;
        } # for $x
    } # for y
} # for z

for ($z = 0; $z < $base; $z ++) { # set bit if move is possible
    for ($y = 0; $y < $base; $y ++) {
        for ($x = 0; $x < $base; $x ++) {
            if ($z - 1 >= 0   ) {                         $poss3[$z][$y][$x] |= $zm1; }
            if ($z + 1 < $base) {                         $poss3[$z][$y][$x] |= $zp1; }
            if ($y - 1 >= 0   ) { $poss2[$y][$x] |= $ym1; $poss3[$z][$y][$x] |= $ym1; }
            if ($y + 1 < $base) { $poss2[$y][$x] |= $yp1; $poss3[$z][$y][$x] |= $yp1; }
            if ($x - 1 >= 0   ) { $poss2[$y][$x] |= $xm1; $poss3[$z][$y][$x] |= $xm1; }
            if ($x + 1 < $base) { $poss2[$y][$x] |= $xp1; $poss3[$z][$y][$x] |= $xp1; }
        } # for $x
    } # for y
} # for z

if ($debug >= 5) { # show preset arrays
    print "# crosum, mexp3=$mexp3, mbit3=$mbit3";
    for ($num = 0; $num < $mbit3; $num ++) {
        if ($num % 8 == 0) {
            print "\n" . sprintf("%3d:  ", $num);
        }
        print sprintf("%3d ", $crosum[$num]);
    } # for
    print "\n";

    print "# masks\n";
    print sprintf("%06b %06b %06b %06b %06b %06b\n\n", $xm1, $xp1, $ym1, $yp1, $zm1, $zp1);
    $bit = 1;
    while ($bit < $mbit3) {
        print sprintf("%06b %06b %06b\n", $bit, $invmask[$bit], $revdir[$bit]);
        $bit <<= 1;
    } # while $bit

    print "# poss2, base=$base\n";
        for ($y = 0; $y < $base; $y ++) { # set bit if move is possible
            for ($x = 0; $x < $base; $x ++) {
                print sprintf("%06b ", $poss2[$y][$x]);
            } # for x
            print "\n";
        } # for y
    print "# poss3\n";
    for ($z = 0; $z < $base; $z ++) { # set bit if move is possible
        for ($y = 0; $y < $base; $y ++) {
            for ($x = 0; $x < $base; $x ++) {
                print sprintf("%06b ", $poss3[$z][$y][$x]);
            } # for $x
            print "\n";
        } # for y
        print "\n";
    } # for z
    print "# end prefilled\n";
} # debug
#-------------------------------
# start with a single bar
my @path2 = ();
my $yp = 0;
my $xp = 0;
my $pathno = 0; # counts the paths found so far
my $level  = 1;
push(@path2, $dr0, $yp, $xp); # stack for current path; tuples (dir, node2); dir = 0 -> no predecessor
my $top = scalar(@path2) - 1; # stack index for @path2
my $yn = $yp + 1;
my $xn = $xp;
my $dirpn2 = $yp1;
my $dir;

$yn = 0;
$xn = 1;
@path2 = (0, 0, $ym1, 1, 0, $dr0);
#                -3  -2 -1    0
$top = scalar(@path2) - 1; #--^
$level = 2;

while ($top > 0) {
    $yp  = $path2[$top - 2]; # (yn,xn) was possible
    $xp  = $path2[$top - 1];
    $dir = $path2[$top - 0]; # previous direction
    $dir = $dir == 0 ? 1 : $dir << 1; # now try the next direction
	$path2[$top - 0] = $dir;
    if ($debug >= 1) {
        print sprintf("#%3d eval  (%d,%d) %s "
            , $level, $yp, $xp, $dircode[$dir]) . &pastr(0);
    }
    if ($dir >= $mbit2) { # all directions exhausted, pop
        $level --;
        $cube2[$yp][$xp] = 0; # free
        $top -= 3; # pop
        if ($debug >= 1) {
            print sprintf("#%3d   pop (%d,%d) %s "
                , $level, $yp, $xp, $dircode[$dir]) . &pastr(0) . "\n";
        }
    } else { # try next dir
        # determine next node
        if (($poss2[$yp][$xp] & $dir) != 0) { # next node exists
            $yn = $yp + $addy[$dir];
            $xn = $xp + $addx[$dir];
            if ($cube2[$yn][$xn] == 0) { # it is not occupied
                $cube2[$yn][$xn] = 1; # occupy it
                if ($top + 4 >= $basep3) { # path found
                    $pathno ++;
                    my $count = 0;
                    print "# path $pathno:\n" . &path_output(1);
                    # $top -= 3;
                } else {
                    $cube2[$yp][$xp] = $dir; # go to it - push
                    $path2[++ $top]  = $yn;
                    $path2[++ $top]  = $xn;
                    $path2[++ $top]  = $dr0; # start with 1st direction
                    $level ++;
                    if ($debug >= 2) {
                        print sprintf("#%3d   push(%d,%d) %s "
                            , $level, $yn, $xn, $dircode[$dr0]) . &pastr(0);
                    }
                }
            } else { # occupied
                $path2[$top] = $dir;
                if ($debug >= 2) {
                    print sprintf("#%3d   occ (%d,%d) %s "
                        , $level, $yn, $xn, $dircode[$dir]) . &pastr(0);
                }
            }
        } else { # not possible
            $path2[$top] = $dir;
                if ($debug >= 2) {
                    print sprintf("#%3d   npos(%d,%d) %s "
                        , $level, $yn, $xn, $dircode[$dir]) . &pastr(0);
                }
        }
    } # try next dir
} # while popping
#-------------------------------
sub pastr { # return a string for @path2
    my ($mode) = @_;
    my $result = "";
    my $ind = 0;
    while ($ind <= $top) {
        my $elem = "$path2[$ind+0]$path2[$ind+1]" . $dircode[$path2[$ind+2]];
        $ind += 3;
        $elem =~ s{\D}{}g;
        $result .= ",$elem";
        if ($ind % 96 == 0) {
            $result .= "\n";
        }
    } # while
    return substr($result, 0) . "\n";
} # pastr
#-------------------------------
sub path_output { # return a string for @path2
    my ($break) = @_;
    my $result = "";
    my $ind = 0;
    while ($ind <= $top) {
        my $elem = "$path2[$ind+0]$path2[$ind+1]";
        $ind += 3;
        $elem =~ s{\D}{}g;
        $result .= ",$elem";
        if ($ind % 32 == 0 and $break > 0) {
            $result .= "\n";
        }
    } # while
    return "[" . substr($result, 1) . "]\n";
} # pastr
#--------
__DATA__
GFis
if ($ccode == 1) {
} else { # Perl
    print $program;
}
__DATA__
