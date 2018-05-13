#!/usr/bin/perl
#
# 2018-05-13: generating, recursive, 3d; Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# Generate paths
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl gen_3d_paths.pl
#-------------------------
use strict;
use integer; # avoid division problems with reals

print <<'GFis'; # header
#!/usr/bin/perl
#
# 2018-05-13: recursive, 3d; Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# Generate paths
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl 3d_paths.tmp [[-b] base] [-d n]
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
my $full =  $bpow3 - 1; # highest index in the cubes
my @filled; # whether a node in the 3d cube is occupied
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
        if ($debug >= 1) {
            print sprintf("%-20s", "$z$y:" . $prom2{"$z$y"});
        }
        for (my $x = 0; $x < $base; $x ++) {
            $filled[$z][$y][$x] = 0;
        } # for $x
    } # for $y
    if ($debug >= 1) {
        print "\n";
    }
} # for $z
$filled[0][0][0] = 1;
$filled[0][0][1] = 1;
my $pathno = 0;
my @path = ("000","001"); # the FASS curve
# my $pazy  = ".00.";    # projection to x = 0
# my $pazx  = ".00.01."; # projection to y = 0
# my $payx  = ".00.01";  # projection to z = =
my $cuzy;
my $cuzx;
my $cuyx;

my $zmove = 1;
&check(0, 0, 1, "<00>", ".00<01>", ".00<01>");
exit(0);
#--------
sub check {
    my ($z, $y, $x, $pazy, $pazx, $payx) = @_;
    if ($x > 0        ) { $x --; if ($filled[$z][$y][$x] == 0) { &alloc($z, $y, $x, $pazy, $pazx, $payx); } $x ++; }
    if ($x < $base - 1) { $x ++; if ($filled[$z][$y][$x] == 0) { &alloc($z, $y, $x, $pazy, $pazx, $payx); } $x --; }
    if ($y > 0        ) { $y --; if ($filled[$z][$y][$x] == 0) { &alloc($z, $y, $x, $pazy, $pazx, $payx); } $y ++; }
    if ($y < $base - 1) { $y ++; if ($filled[$z][$y][$x] == 0) { &alloc($z, $y, $x, $pazy, $pazx, $payx); } $y --; }
    if ($zmove == 1) {
    if ($z > 0        ) { $z --; if ($filled[$z][$y][$x] == 0) { &alloc($z, $y, $x, $pazy, $pazx, $payx); } $z ++; }
    if ($z < $base - 1) { $z ++; if ($filled[$z][$y][$x] == 0) { &alloc($z, $y, $x, $pazy, $pazx, $payx); } $z --; }
    } # if zmove
} # check
#--------
sub alloc {
    my ($z, $y, $x, $pazy, $pazx, $payx) = @_;
    if ($debug >= 1) {
        print sprintf("# add   ") . join(",", @path) . " \+$z$y$x\n";
    }
    push(@path, "$z$y$x");
    my $snail = 1; # assume a line without circle and branches
    $filled[$z][$y][$x] = 1;
GFis
my $pattern;
$pattern = <<'GFis';
    #--------
    my $vazy = "$z$y";
    my $message = "";
    if ($debug >= 3) {
        print "# pre   zy  $pazy \+$vazy\n";
    }
    if ($snail == 1) { 
		if (0) {
	    } elsif ($pazy =~ m{\<$vazy\>}       ) { # same as current
	        # do nothing
	    } elsif ($pazy =~ m{\<(\d+)\>$vazy\.}) { # behind current
	        $pazy      =~ s{\<(\d+)\>$vazy\.}{\.\1\<$vazy\>}; # move to successor
	    } elsif ($pazy =~ m{\.$vazy\<(\d+)\>}) { # before current
	        $pazy      =~ s{\.$vazy\<(\d+)\>}{\<$vazy\>\1\.}; # move to predecessor
	    } elsif ($pazy =~ m{\.$vazy\.}       ) { # found, but elsewhere
	        $snail = 0;
	        $message .= " middle";
	    } else { # not found
	    	$snail = 0;
	        my ($head, $tail);
	        if ($pazy =~ m{\<(\d+)\>\Z}) { # current is tail
	            $tail = $1;
	            if ($prom2{$tail} =~ m{$vazy}) {
	                $pazy      =~ s{\<$tail\>}{\.$tail\<$vazy\>}; # append
	                $snail = 1;
	            } else {
	        		$message .= " !promt";
	        	}
	        }
	        if ($snail == 0 and ($pazy =~ m{\A\<(\d+)\>})) { # current is head
	            $head = $1;
	            if ($prom2{$head} =~ m{$vazy}) {
	                $pazy      =~ s{\<$head\>}{\<$vazy\>$head\.}; # prepend
	                $snail = 1;
	            } else {
	        		$message .= " !promh";
	        	}
	        }
	    } # not found
	    if ($debug >= 2) {
	        print "#       zy  $pazy \+$vazy sn=$snail $message\n";
	    }
	} # $snail == 1
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
    } elsif ($snail < 1) {
        # do not recurse
    } elsif (scalar(@path) >= $bpow3) {
        $pathno ++;
        my $count = 0;
        print sprintf("# path %3d:\n[", $pathno) 
                . join(",", map {$count ++; $count % 16 == 0 ? "$_\n" : $_ } @path) . "]\n";
        # do not recurse
    } else { # recurse
        &check($z, $y, $x, $pazy, $pazx, $payx);
    }
    #--------
    $filled[$z][$y][$x] = 0;
    pop(@path);
    if ($debug >= 3) {
        print sprintf("#   sub ") . join(",", @path) . " \-$z$y$x\n";
    }
} # alloc
__DATA__
GFis
