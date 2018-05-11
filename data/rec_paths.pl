#!/usr/bin/perl
# 2018-05-11: recursive, 3d; Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# Generate paths
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl rec_paths [[-b] base] [-d n] 
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
	push(@pazyx, "$z$y$x");
	if ($debug >= 2) {
		print sprintf("# try  %3d: ", $pathno) . join(",", @pazyx) . "\n";
	}
	my $tracks_bad = 0; # assume ok
	if (0) {
	} elsif (scalar(@pazyx) >= $bpow3) {
		$pathno ++;
		print sprintf("# path %3d: ", $pathno) . join(",", @pazyx) . "\n";
	} else { 
		$fizyx[$z][$y][$x] ++; 

		my $vazy = "$z$y";
		$fizy[$z][$y] ++;
		if (0) {
		} elsif ($pazy[$cuzy    ] == $vazy) {
		} elsif ($pazy[$cuzy - 1] == $vazy and $cuzy > 0) {
			$cuzy --;
		} elsif ($pazy[$cuzy + 1] == $vazy and $cuzy + 1 <= $lazy) {
			$cuzy ++;
		} elsif ($cuzy == $lazy) {
			if (1) {
				push(@pazy, $vazy);
				$cuzy = scalar(@pazy) - 1;
				$lazy = $cuzy;
			}
		} else {
			$tracks_bad ++;
		}	
		if ($debug >= 2) {
			print sprintf("#       zy  "         ) 
					. join(",", @pazy)  
					. "\tlazy=$lazy,cuzy=$cuzy,tb=$tracks_bad\n";
		}

		my $vazx = "$z$x";
		$fizx[$z][$x] ++;
		if (0) {
		} elsif ($pazx[$cuzx    ] == $vazx) {
		} elsif ($pazx[$cuzx - 1] == $vazx and $cuzy > 0) {
			$cuzx --;
		} elsif ($pazx[$cuzx + 1] == $vazx and $cuzx + 1 <= $lazx) {
			$cuzx ++;
		} elsif ($cuzx == $lazx) {
			if (1) {
				push(@pazx, $vazx);
				$cuzx = scalar(@pazx) - 1;
				$lazx = $cuzx;
			}
		} else {
			$tracks_bad ++;
		}	
		if ($debug >= 2) {
			print sprintf("#       zx  "         ) 
#					. join(",", map { my $p = $_; $_ = "$p(" . $fizx[substr($p, 0, 1), substr($p, 1)] . ")"; $_ } @pazx)  
					. join(",", @pazx)  
					. "\tlazx=$lazx,cuzx=$cuzx,tb=$tracks_bad\n";
		}

		my $vayx = "$y$x";
		$fiyx[$y][$x] ++;
		if (0) {
		} elsif ($payx[$cuyx    ] == $vayx) {
		} elsif ($payx[$cuyx - 1] == $vayx and $cuzy > 0) {
			$cuyx --;
		} elsif ($payx[$cuyx + 1] == $vayx and $cuyx + 1 <= $layx) {
			$cuyx ++;
		} elsif ($cuyx == $layx) {
			if (1) {
				push(@payx, $vayx);
				$cuyx = scalar(@payx) - 1;
				$layx = $cuyx;
			}
		} else {
			$tracks_bad ++;
		}	
		if ($debug >= 2) {
			print sprintf("#       yx  "         ) 
					. join(",", @payx)  
					. "\tlayx=$layx,cuyx=$cuyx,tb=$tracks_bad\n";
		}
		
		if (0 or $tracks_bad <= 0) {
			&check($z, $y, $x); 
		}

		$fizy[$z][$y] --;
		if (0) {
		} elsif ($pazy[$cuzy] == $vazy) {
		} elsif ($pazy[$cuzy - 1] == $vazy) {
			$cuzy --;
		} elsif ($pazy[$cuzy + 1] == $vazy and $cuzy + 1 <= $lazy) {
			$cuzy ++;
		} elsif ($cuzy == $lazy) {
			if ($fizy[$z][$y] <= 0) {
				pop(@pazy);
				$cuzy = scalar(@pazy) - 1;
				$lazy = $cuzy;
			}
		}
		$fizx[$z][$x] --;
		if (0) {
		} elsif ($pazx[$cuzx] == $vazx) {
		} elsif ($pazx[$cuzx - 1] == $vazx) {
			$cuzx --;
		} elsif ($pazx[$cuzx + 1] == $vazx and $cuzx + 1 <= $lazx) {
			$cuzx ++;
		} elsif ($cuzx == $lazx) {
			if ($fizx[$z][$x] <= 0) {
				pop(@pazx);
				$cuzx = scalar(@pazx) - 1;
				$lazx = $cuzx;
			}
		}
		$fiyx[$y][$x] --;
		if (0) {
		} elsif ($payx[$cuyx] == $vayx) {
		} elsif ($payx[$cuyx - 1] == $vayx) {
			$cuyx --;
		} elsif ($payx[$cuyx + 1] == $vayx and $cuyx + 1 <= $layx) {
			$cuyx ++;
		} elsif ($cuyx == $layx) {
			if ($fiyx[$y][$x] <= 0) {
				pop(@payx);
				$cuyx = scalar(@payx) - 1;
				$layx = $cuyx;
			}
		}

		$fizyx[$z][$y][$x] --; 
	}
	pop(@pazyx);
} # alloc
#--------
sub test_track {
	my ($node, $track) = @_;
	my $ind = index($track, $node, 3);
	if ($ind < 0) { # not found - append
		$track .= $node;
	} else {
	}
	return $track;
} # test_track
#--------
sub koin {
	my ($sep, @parr) 
} # koin
__DATA__
		my $vazy = "$z$y";
		$fizy[$vazy] ++;
		if (0) {
		} elsif ($pazy[$cuzy    ] == $vazy) {
		} elsif ($pazy[$cuzy - 1] == $vazy) {
			$cuzy --;
		} elsif ($pazy[$cuzy + 1] == $vazy and $cuzy + 1 <= $lazy) {
			$cuzy ++;
		} elsif ($cuzy == $lazy) {
			if (1) {
				push(@pazy, $vazy);
				$cuzy = scalar(@pazy) - 1;
				$lazy = $cuzy;
			}
		} else {
			tracks_bad ++;
		}	
		
		$fizy[$vazy] --;
		if (0) {
		} elsif ($pazy[$cuzy] == $vazy) {
		} elsif ($pazy[$cuzy - 1] == $vazy) {
			$cuzy --;
		} elsif ($pazy[$cuzy + 1] == $vazy and $cuzy + 1 <= $lazy) {
			$cuzy ++;
		} elsif ($cuzy == $lazy) {
			if ($fizy[$vazy] <= 0) {
				pop(@pazy);
				$cuzy = scalar(@pazy) - 1;
				$lazy = $cuzy;
			}
		} else {
			tracks_bad ++;
		}	