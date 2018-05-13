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
my %prom2; # 2-dimensional proximity: maps to a list of orthogonal neighbours
my $a;
for (my $z = 0; $z < $base; $z ++) {
    for (my $y = 0; $y < $base; $y ++) {
        $prom2{"$z$y"} = "/";
        $a = $z + 1;
        if ($a < $base) { $prom2{"$z$y"} .= "$a$y/"; }
        $a = $z - 1;
        if ($a >= 0   ) { $prom2{"$z$y"} .= "$a$y/"; }
        $a = $y + 1;
        if ($a < $base) { $prom2{"$z$y"} .= "$z$a/"; }
        $a = $y - 1;
        if ($a >= 0   ) { $prom2{"$z$y"} .= "$z$a/"; }
        if ($debug >= 2) {
            print sprintf("%-20s", "$z$y:" . $prom2{"$z$y"});
        }
        for (my $x = 0; $x < $base; $x ++) {
            $fizyx[$z][$y][$x] = 0;
        } # for $x
    } # for $y
    if ($debug >= 2) {
        print "\n";
    }
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
my $tbzy  = 0;
my $tbzx  = 0;
my $tbyx  = 0;
my $cuzy  = 0;
my $cuzx  = 0;
my $cuyx  = 0;

my $tracks_bad;
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
        print sprintf("# add   ") . join(",", @pazyx) . " \+$z$y$x\n";
    }
    push(@pazyx, "$z$y$x");
    $tracks_bad = 0; # assume ok
    $fizyx[$z][$y][$x] ++;
GFis
my $pattern;
$pattern = <<'GFis';
    #--------
    my $vazy = "$z$y";
    $tbzy = 0;
    if ($debug >= 3) {
        print "#   pre zy  \+$vazy cuzy=$cuzy,tb=$tracks_bad ";
        foreach my $pzy (@pazy) {
            print " $pzy\." . $fizy[substr($pzy, 0, 1)]
                                   [substr($pzy, 1, 1)];
        } # foreach
        print "\n";
    }
    $fizy[$z][$y] ++;
    if (0) {
    } elsif (                   $pazy[$cuzy    ] == $vazy) {
    } elsif ($cuzy >   0    and $pazy[$cuzy - 1] == $vazy) {
        $cuzy --;
    } elsif ($cuzy <  scalar(@pazy) - 1 and $pazy[$cuzy + 1] == $vazy) {
        $cuzy ++;
	} else { # elsewhere?
		if ($fizy[$z][$y] > 1) { # already in $pazy
			$tbzy ++;
    	} elsif ($cuzy == scalar(@pazy) - 1                 ) { # current is last
    		if (0 or ($prom2{$pazy[$cuzy]} =~ m{$vazy})) {
    	    	push(@pazy, $vazy); # append behind last
    	    	$cuzy = scalar(@pazy) - 1;
    	    }
    	} elsif ($cuzy == 0                                  ) {
    		if (0 or ($prom2{$pazy[$cuzy]} =~ m{$vazy})) {
		         unshift(@pazy, $vazy);# prepend before first
    		     # $cuzy remains 0
   			}
    	} else {
    	    $tbzy ++;
    	}
    }
    if ($debug >= 2) {
        print "#       zy  \+$z$y cuzy=$cuzy,tb=$tracks_bad ";
        foreach my $pzy (@pazy) {
            print " $pzy\." . $fizy[substr($pzy, 0, 1)]
                                   [substr($pzy, 1, 1)];
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
        my $count = 0;
        print sprintf("# path %3d:\n[", $pathno) 
        		. join(",", map {$count ++; $count % 16 == 0 ? "$_\n" : $_ } @pazyx) . "]\n";
        # do not recurse
    } elsif ($tbzy + $tbzx + $tbyx > 0) {
        # do not recurse
    } else { # recurs
        &check($z, $y, $x);
    }
    #--------
    $fizyx[$z][$y][$x] --;
    pop(@pazyx);
    if ($debug >= 3) {
        print sprintf("#   sub ") . join(",", @pazyx) . " \-$z$y$x\n";
    }
GFis

$pattern = <<'GFis';
    $vazy = "$z$y";
    $fizy[$z][$y] --;
#   if ($tbzy == 0) {
	if (0) {
    } elsif ($pazy[$cuzy    ] == $vazy                   ) {
        if (0 and $fizy[$z][$y] <= 0) { # and $tracks_bad == 0) {
            splice(@pazy, $cuzy, 1); 
            # $cuzy on following?
        }
    } elsif ($pazy[$cuzy - 1] == $vazy                   ) {
        $cuzy --;
    } elsif ($pazy[$cuzy + 1] == $vazy and $cuzy <  scalar(@pazy) - 1) {
        $cuzy ++;
    }
    
#   if ($tbzy == 0) {
	if (0) {
    } elsif (                              $cuzy == scalar(@pazy) - 1) {
        if ($fizy[$z][$y] <= 0) { # and $tracks_bad == 0) {
            pop(@pazy); # remove last
            $cuzy = scalar(@pazy) - 1;
        }
    } elsif (                              $cuzy == 0    ) {
        if ($fizy[$z][$y] <= 0) { # and $tracks_bad == 0) {
            shift(@pazy); # remove first
            # $cuzy remains 0
        }
    }
    if ($debug >= 3) {
        print sprintf("#       zy  "         )
                . "\-$vazy cuzy=$cuzy,tb=$tracks_bad ";
        foreach my $pzy (@pazy) {
            print " $pzy\." . $fizy[substr($pzy, 0, 1)]
                                   [substr($pzy, 1, 1)];
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
} # alloc
__DATA__
GFis
