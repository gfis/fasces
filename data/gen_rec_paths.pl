#!/usr/bin/perl
#
# 2018-05-12: generating, recursive, 3d; Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# Generate paths
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl gen_rec_paths.pl
#-------------------------
use strict;
use integer; # avoid division problems with reals

print <<'GFis'; # header
#!/usr/bin/perl
#
# 2018-05-11: recursive, 3d; Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# Generate paths
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl rec_paths.tmp [[-b] base] [-d n]
#       -b   base (default 5)
#       -d n debug level n (default: 0)
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $debug  = 0;
my $base   = 2;

while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if ($opt =~ m{\A(\-b)?(\d+)\Z}) {
        $base  = $2;
    }
    if ($opt =~ m{d}) {
        $debug = shift(@ARGV);
    }
} # while opt

my $bpow2 = $base * $base;
my $bpow3 = $base * $bpow2;
my $full =  $bpow3 - 1;
my (@fizyx, @fizy, @fizx, @fiyx);
for (my $z = 0; $z < $base; $z ++) {
for (my $y = 0; $y < $base; $y ++) {
for (my $x = 0; $x < $base; $x ++) {
    $fizyx[$z][$y][$x] = 0;
    $fizy [$z][$y]     = 0;
    $fizx [$z][$x]     = 0;
    $fiyx [$y][$x]     = 0;
} # for $x
} # for $y
} # for $z
$fizyx[0][0][0] = 1;
$fizy [0][0]    = 1;
$fizx [0][0]    = 1;
$fiyx [0][0]    = 1;
# $fizyx[0][0][1] = 1;
my $pathno = 0;
my @pazyx = ("000");
my @pazy  = ("00");
my @pazx  = ("00");
my @payx  = ("00");
my $lazy  = 0;
my $lazx  = 0;
my $layx  = 0;
my $cuzy  = 0;
my $cuzx  = 0;
my $cuyx  = 0;

# my $tracks_bad;
&check(0,0,0);
exit(0);
#--------
sub check {
    my ($z, $y, $x) = @_;
    if ($x > 0        ) { $x --; if ($fizyx[$z][$y][$x] == 0) { &alloc($z, $y, $x); } $x ++; }
    if ($x < $base - 1) { $x ++; if ($fizyx[$z][$y][$x] == 0) { &alloc($z, $y, $x); } $x --; }
    if ($y > 0        ) { $y --; if ($fizyx[$z][$y][$x] == 0) { &alloc($z, $y, $x); } $y ++; }
    if ($y < $base - 1) { $y ++; if ($fizyx[$z][$y][$x] == 0) { &alloc($z, $y, $x); } $y --; }
    if ($z > 0        ) { $z --; if ($fizyx[$z][$y][$x] == 0) { &alloc($z, $y, $x); } $z ++; }
    if ($z < $base - 1) { $z ++; if ($fizyx[$z][$y][$x] == 0) { &alloc($z, $y, $x); } $z --; }
} # check
#--------
sub alloc {
    my ($z, $y, $x) = @_;
    if ($debug >= 1) {
        print sprintf("# enter ") . join(",", @pazyx) . " \+$z$y$x\n";
    }
    push(@pazyx, "$z$y$x");
    my $tracks_bad = 0; # assume ok
    $fizyx[$z][$y][$x] ++;
GFis
my $pattern;
$pattern = <<'GFis';
    #--------
    my $vazy = "$z$y";
    if ($debug >= 3) {
        print sprintf("#   pre zy  "         )
                . "\+$vazy lazy=$lazy,cuzy=$cuzy,tb=$tracks_bad\t";
        foreach my $pzy (@pazy) {
            print " $pzy\(" . $fizy[substr($pzy, 0, 1)]
                                   [substr($pzy, 1, 1)] .  ")";
        } # foreach
        print "\n";
    }
    $fizy[$z][$y] ++;
    if (0) {
    } elsif ($pazy[$cuzy    ] == $vazy                   ) {
    } elsif ($pazy[$cuzy - 1] == $vazy and $cuzy >  0    ) {
        $cuzy --;
    } elsif ($pazy[$cuzy + 1] == $vazy and $cuzy <  $lazy) {
        $cuzy ++;
    } elsif (                              $cuzy == $lazy) {
        push(@pazy, $vazy); # append behind last
        $lazy = scalar(@pazy) - 1; $cuzy = $lazy;
    } elsif (                              $cuzy == 0    ) {
        unshift(@pazy, $vazy);# prepend before first
        $lazy = scalar(@pazy) - 1; # $cuzy remains 0

    } else {
        $tracks_bad ++;
    }
    if ($debug >= 2) {
        print sprintf("#       zy  "         )
                . "\+$z$y lazy=$lazy,cuzy=$cuzy,tb=$tracks_bad\t";
        foreach my $pzy (@pazy) {
            print " $pzy\(" . $fizy[substr($pzy, 0, 1)]
                                   [substr($pzy, 1, 1)] .  ")";
        } # foreach
        print "\n";
    }
GFis
print $pattern;
$pattern =~ s{\$y}{\$x}g;
$pattern =~ s{zy}{zx}g;
print $pattern;
$pattern =~ s{\$z}{\$y}g;
$pattern =~ s{zx}{yx}g;
print $pattern;

print <<'GFis';
    #--------
    if (0) {
    } elsif (scalar(@pazyx) >= $bpow3) {
        $pathno ++;
        print sprintf("# path %3d:\n", $pathno) . join(",", @pazyx) . "\n";
        # do not recurse
    } elsif ($tracks_bad > 0) {
        # do not recurse
    } else { # recurs
        &check($z, $y, $x);
    }
    #--------
    if ($debug >= 1) {
        print sprintf("# leave ") . join(",", @pazyx) . " \-$z$y$x\n";
    }
GFis

$pattern = <<'GFis';
    $vazy = "$z$y";
    $fizy[$z][$y] --;
    if (0) {
#   } elsif ($pazy[$cuzy    ] == $vazy                   ) {
    } elsif ($pazy[$cuzy - 1] == $vazy                   ) {
        $cuzy --;
    } elsif ($pazy[$cuzy + 1] == $vazy and $cuzy <  $lazy) {
        $cuzy ++;
    } elsif (                              $cuzy == $lazy) {
        if ($fizy[$z][$y] <= 0) {
            pop(@pazy); # remove last
            $lazy = scalar(@pazy) - 1; $cuzy = $lazy;
        }
    } elsif (                                  $cuzy == 0) {
        if ($fizy[$z][$y] <= 0) {
            shift(@pazy); # remove first
            $lazy = scalar(@pazy) - 1; # $cuzy remains 0
        }
    }
    if ($debug >= 2) {
        print sprintf("#       zy  "         )
                . "\-$vazy lazy=$lazy,cuzy=$cuzy,tb=$tracks_bad\t";
        foreach my $pzy (@pazy) {
            print " $pzy\(" . $fizy[substr($pzy, 0, 1)]
                                   [substr($pzy, 1, 1)] .  ")";
        } # foreach
        print "\n";
    }
    #--------
GFis
print $pattern;
$pattern =~ s{\$y}{\$x}g;
$pattern =~ s{zy}{zx}g;
print $pattern;
$pattern =~ s{\$z}{\$y}g;
$pattern =~ s{zx}{yx}g;
print $pattern;

print <<'GFis';
    $fizyx[$z][$y][$x] --;
    pop(@pazyx);
} # alloc
__DATA__
GFis
