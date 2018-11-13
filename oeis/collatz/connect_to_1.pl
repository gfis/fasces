#!perl

# Connect to root (1)
# @(#) $Id$
# 2018-11-13, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl connect_to_1.pl [-n maxn] [-d debug] 
# Evaluates rules 2 and 3 for odd row numbers.
# Target rows 1,2,3 initially connect to the root.
# Run rule 2:
#   3  7 11 15 19 23 27 31 35 39 43 47 51 55 59 63 67 71 75 79 ... source rows
#   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 ... target rows
# and in parallel rule 3:
#   5  9 13 17 21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 80 ... source rows
#   4  7 10 13 16 19 22 25 28 31 34 37 40 43 46 49 52 55 58 61 ... target rows
# Even target rows > 3 are treatedd separately and are assumed to be attached.
#------------------------------------------------------
use strict;
use integer;

my $debug  = 0;
my $maxn   = 10000; # max. start value
my $MAX_RULE = 32;
my @len = (0, 1, 7, 61, 547, 4921, 44287, 398581, 3587227); # OEIS 066443
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{p}) {
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my @atts = (0,  1);

my $isrc = 1;
my $src2 = 3;
my $src3 = 5;
while ($isrc < $maxn) {
	my $tar2 = (    $src2 + 1) / 4;
	my $tar3 = (3 * $src3 + 1) / 4;
	&attach($src2, $tar2);
	&attach($src3, $tar3);
	# push(@src3, $isrc * 4 - 3);
	# push(@src2, $isrc * 4 - 1);
    $src2 += 4;
    $src3 += 4;
    $isrc ++;
} # while $isrc
#----------------
sub attach {
	my ($src, $tar) = @_;
	my $result = 0; # not attached
	if (0) {
	} elsif ($tar <= 3) {
		$result = "1A";
	} elsif ($tar % 2 == 0) { # even
		$result = sprintf("%6d", $tar);
		$result .= " R" . &get_rule($tar);
		if (0) {
			if ($tar % 6 == 4) {
				$result .= "S";
			} else {
				$result .= "B";
			}
		}
	} else {
		$result = $atts[$tar];
	}		
	$atts[$src] = $result;
	$atts[$tar] = $result;
	print sprintf("%6d -> %6d = %-8s ", $src, $tar, $result);
	if ($result == 0) {
		print " XXXXXXX";
	}
	print "\n";
	return $result;
} # attach
#------------------------
sub get_rule {
    my $result = "0";
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
            # $result .= "->$newnode";
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
__DATA__
