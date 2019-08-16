#!perl

# Evaluate ladders of long segments
# @(#) $Id$
# 2019-08-14, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl long_ladder.pl [-d debug] 
#       -d  debug level: 0 (none), 1 (some), 2 (more)
#--------------------------------------------------------
use strict;
use integer;
#----------------
# global constants
my $VERSION = "V1.0";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min);
my $MAX_RULE  = 64; # rule 7 has 4 mod 16, rule 11 has 16 mod 64
my @RULENS    = (0, 1, 7, 61, 547, 4921, 44287, 398581, 3587227, 32285041, 290565367, 2615088301); # OEIS A066443
#----------------
# get commandline options
my $debug  = 0;
my $maxn = 16384;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $ind;
my @rules;
my @srcmul;
my @srcadd;
my @tarmul;
my @taradd;
$ind = 0;
while (<DATA>) {
	s/\s+\Z//;
	($rules[$ind], $srcmul[$ind], $srcadd[$ind], $tarmul[$ind], $taradd[$ind]) = split(/\s+/, $_);
	$ind ++;
} # while
my $rmax = $ind;
for ($ind = 0; $ind < $rmax; $ind ++) {
	my $k = 0;
	my $busy = 1;
	while ($busy) {
		my $src = $srcmul[$ind] * $k + $srcadd[$ind];
		my $tar = $tarmul[$ind] * $k + $taradd[$ind];
		$k ++;
		if ($src > $maxn or $tar > $maxn) {
			$busy = 0;
		}
		print "$src	->	$rules[$ind]	$tar\n";
		print "$tar	<-	$rules[$ind]	$src\n";
	} # while busy
} # for #$irul
#---------------------------------------
__DATA__
r9	3	1	8	2
r10	9	9	8	8
r13	9	3	16	5
r14	27	15	16	9
r17	27	6	32	7
r18	81	78	32	31
r21	81	24	64	19
r22	243	132	64	35
r25	243	51	128	27