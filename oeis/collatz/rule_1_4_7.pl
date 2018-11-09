#!perl

# Evaluate connection rules
# @(#) $Id$
# 2018-11-08, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl rule_1_4_7.pl [-n maxn] [-s start] [-i incr]
#------------------------------------------------------
use strict;
use integer;

my $debug  = 0;
my $maxn   = 4096; # max. start value
my $start  = 4;
my $incr   = 6;
my $MAX_RULE = 32;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{i}) {
        $incr   = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } elsif ($opt =~ m{s}) {
        $start  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my @len = (0, 1, 7, 61, 547, 4921, 44287, 398581, 3587227); # OEIS 066443
my $irow = 4;
while ($irow < $maxn) {
	my $result = &get_rule($irow);
	print sprintf("%6d: %8s", $irow, $result);
	my ($rule, $nrow) = split(/\D+/, $result);
	$result = &get_rule($nrow);
	# print ", $result";
	if ($debug >= 1) {
		print "\n";
	}
	if (($irow + 2) % 24 == 0) {
		print "\n";
	}
	$irow += 6;
} # while $irow
#------------------------
sub get_rule {
	my $result = "-1->0";
	my ($irow) = @_;
	my $rule   = 2;
	my $busy   = 1;
	my $tog31  = 3;
	my $exp2_2 = 1;
	my $exp2   = 4;
	my $exp3   = 1;
	my $ilen   = 1;
	while ($busy == 1 and $rule <= $MAX_RULE) {
		my $subconst = $exp2_2 * $tog31;
		if ($irow % $exp2 == $subconst) { # mod cond.
			$busy = 0;
			$result = $rule;
			my $newnode = $exp3 * ($irow - $subconst) / $exp2 + $len[$ilen];
			$result .= "->$newnode";
			if ($debug >= 1) {
				print "rule $rule, exp2 $exp2, exp2-2 $exp2_2, exp3 $exp3 subconst $subconst, ilen $ilen, len[] $len[$ilen]\n";
			}
		} else {
			$rule ++;
			if ($rule % 4 == 1) {
				$ilen ++;
			}
			if ($rule % 2 == 0) {
				$exp2   *= 2;
				$exp2_2 *= 2;
			} else {
				$exp3   *= 3;
				$tog31 = 4 - $tog31;
			}
		} # mod cond.
	} # while rules  			
	return $result;
} # get_rule
#------------------------
sub get_rule_99 {
	my ($irow) = @_;
	my $rule = 1;
	my $busy = 1;
	while ($busy == 1 and $rule <= $MAX_RULE) {
		$rule ++;
		if (0) {
		} elsif ($irow %    4 ==    3) { $busy = 0; $rule =  2; 
		} elsif ($irow %    4 ==    1) { $busy = 0; $rule =  3; 
		} elsif ($irow %    8 ==    2) { $busy = 0; $rule =  4; 
		} elsif ($irow %    8 ==    6) { $busy = 0; $rule =  5; 
		} elsif ($irow %   16 ==   12) { $busy = 0; $rule =  6; 
		} elsif ($irow %   16 ==    4) { $busy = 0; $rule =  7; 
		} elsif ($irow %   32 ==    8) { $busy = 0; $rule =  8; 
		} elsif ($irow %   32 ==   24) { $busy = 0; $rule =  9; 
		} elsif ($irow %   64 ==   48) { $busy = 0; $rule = 10; 
		} elsif ($irow %   64 ==   16) { $busy = 0; $rule = 11; 
		} elsif ($irow %  128 ==   32) { $busy = 0; $rule = 12; 
		} elsif ($irow %  128 ==   96) { $busy = 0; $rule = 13; 
		} elsif ($irow %  256 ==  192) { $busy = 0; $rule = 14; 
		} elsif ($irow %  256 ==   64) { $busy = 0; $rule = 15; 
		} elsif ($irow %  512 ==  128) { $busy = 0; $rule = 16; 
		} elsif ($irow %  512 ==  384) { $busy = 0; $rule = 17; 
		} elsif ($irow % 1024 ==  768) { $busy = 0; $rule = 18; 
		} elsif ($irow % 1024 ==  256) { $busy = 0; $rule = 19; 
		} elsif ($irow % 2048 ==  512) { $busy = 0; $rule = 20; 
		} elsif ($irow % 2048 == 1536) { $busy = 0; $rule = 21; 
		} elsif ($irow % 4096 == 3072) { $busy = 0; $rule = 22; 
		} elsif ($irow % 4096 == 1024) { $busy = 0; $rule = 23; 
		}
	} # while rules  			
	if ($busy == 0) {
	} else {
		$rule = -1;
	}
	return $rule;
} # get_rule
__DATA__
