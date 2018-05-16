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

my @dircode = ("**"); # codes for the directions
my $mexp3 = 0; # greater than all bit exponents: 6
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
$y = 0;
$x = 0;
my $pathno = 0; # counts the paths found so far
my $level  = 1;
push(@path2, 0, "$y,$x"); # stack for current path; tuples (dir, node2); dir = 0 -> no predecessor
&evaluate2($y, $x, $yp1, $y + 1, $x);
exit();
#--------
sub evaluate2 {
    # evaluate all possible continuations for @path2
    # and check whether corresponding nodes on @path3 have at most 2 connections to other nodes
    return if $level == 0; # do not change 1st bar
    my         ($yp, $xp, $dirpn2, $yn, $xn) = @_; # old node, direction, new node
    $level ++;
    push(@path2, $dirpn2, "$yn,$xn"); # tuples (dir,node)
    if ($debug >= 1) {
        print sprintf("#%3d eval  (%d,%d) %s (%d,%d) "
                , $level, $yp, $xp, $dircode[$dirpn2], $yn, $xn)
                . &pastr(0) . "\n";
    }
    my $fail = &alloc2($yp, $xp, $dirpn2, $yn, $xn);
    if ($fail == 0) { # ($yn,$xn) is possible
        my $dirnp2 = $revdir[$dirpn2];
        # recurse: try all 4 positions for next node
        $bit = $yp1; if ($dirnp2 != $bit and ($poss2[$yn][$xn] & $bit) != 0) { &evaluate2($yn, $xn, $bit, $yn + 1, $xn    ); }
        $bit = $ym1; if ($dirnp2 != $bit and ($poss2[$yn][$xn] & $bit) != 0) { &evaluate2($yn, $xn, $bit, $yn - 1, $xn    ); }
        $bit = $xp1; if ($dirnp2 != $bit and ($poss2[$yn][$xn] & $bit) != 0) { &evaluate2($yn, $xn, $bit, $yn,     $xn + 1); }
        $bit = $xm1; if ($dirnp2 != $bit and ($poss2[$yn][$xn] & $bit) != 0) { &evaluate2($yn, $xn, $bit, $yn,     $xn - 1); }
    } # if alloc

    &free2($yp, $xp, $dirpn2, $yn, $xn);
    my $node = pop(@path2); # node
    $bit     = pop(@path2); # dir
    if ($debug >= 2) {
        print sprintf("#%3d return(%d,%d) %s (%d,%d) "
                , $level, $yp, $xp, $dircode[$bit], $yn, $xn)
                . &pastr(0) . "\n";
    }
    $level --;
} # evaluate2
#-------------------------------
sub pastr { # return a string for @path2
    my ($break) = @_;
    my $result = "";
    my $ind = 0;
    while ($ind < scalar(@path2)) {
        my $elem = $path2[$ind + 1];
        $elem =~ s{\D}{}g;
        $result .= ",$elem";
        $ind += 2;
        if ($ind % 32 == 0 and $break > 0) {
            $result .= "\n";
        }
    } # while
    return "[" . substr($result, 1) . "]";
} # pastr
#-------------------------------
sub alloc2 {
    my ($yp, $xp, $dirpn2, $yn, $xn) = @_; # old node, direction, new node
    #              00yyxx
    my $fail = 0; # assume success
    if ($cube2[$yn][$xn] != 0) {
        $fail = 2; # already occupied
    } elsif ($yn == $base - 1 and $xn == $base - 1 and scalar(@path2) < $maxpath2 and $diag == 1) {
    	$fail = 4; # not diagonal
    } else { # not yet occupied
        $cube2[$yp][$xp] |=         $dirpn2 ; # connect prev to new
        $cube2[$yn][$xn] |= $revdir[$dirpn2]; # connect new  to prev, backwards
        if (scalar(@path2) >= $maxpath2) { # path found
            $pathno ++;
            my $count = 0;
            print "# path $pathno:\n" . &pastr(1) . "\n";
            $fail = 99; # end reached
        } # path found
    } # if not yet occupied
    if ($debug >= 2) {
            print sprintf("#    alloc2(%d,%d) %s (%d,%d) ", $yp, $xp, $dircode[$dirpn2], $yn, $xn) . &pastr(0);
            print $fail != 0 ? " failure $fail\n" : " ok\n";
    }
    return $fail;
} # alloc2
#--------
sub free2 {
    my ($yp, $xp, $dirpn2, $yn, $xn) = @_; # old node, direction, new node
    #              00yyxx
    $cube2[$yp][$xp]      &= $invmask[        $dirpn2 ]; # disconnect prev to new
    $cube2[$yn][$xn]      &= $invmask[$revdir[$dirpn2]]; # disconnect new  to prev, backwards
    if ($debug >= 3) {
        print sprintf("#    free 2(%d,%d) %s (%d,%d) ", $yp, $xp, $dircode[$dirpn2], $yn, $xn) . &pastr(0) . "\n";
    }
} # free2
#--------
__DATA__
GFis
if ($ccode == 1) {
} else { # Perl
    print $program;
}
__DATA__
