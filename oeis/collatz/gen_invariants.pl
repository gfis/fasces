#!perl

# Generate operations {d,m}^k which keeps numbers in {n|n = 4 mod 6}
# @(#) $Id$
# 2018-08-30, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl gen_invariants.pl [-n maxn] [-d debug]
#--------------------------------------------------------
use strict;
use integer;
#----------------
# get commandline options
my $debug  = 0;
my $maxn   = 24; # max. length of operation sequence
my $action = "simple";
my $mode   = "html";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{m}) {
        $mode   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
# initialization
my $sep = "\t";
my @queue = ();
my ($len, $mul, $log3, $add, $expr) = ("0000", 1, 0, -2, "");
&enqueue($len, $mul, $log3, $add, $expr);
#----------------
while (scalar(@queue) > 0) {
    &dequeue();
    $len ++;
    # try multiplication *2
    if (1) { # m is always possible
        &enqueue($len, $mul * 2, $log3, $add * 2      , $expr . ".");
    }
    # try division -1/3
    if (($add - 1) % 3 == 0) { # d possible
        &enqueue($len, $mul, $log3 + 1, ($add - 1) / 3, $expr . "d");
    } # d possible
} # while
#----------------
# termination
# end main
#----------------
sub dequeue { # queue the parameter
    @queue = sort(@queue); # dequeue shortes entries first
    ($len, $mul, $log3, $add, $expr) = split(/$sep/, shift(@queue)); # process this entry
} # dequeue
#----------------
sub enqueue { # queue an entry
    my ($len, $mul, $log3, $add, $expr) = @_;
    if ($len < $maxn) {
        my $busy = 1; # suppose we shall queue the entry
        my $formula = sprintf("%-24s %-24s"
        	, ($mul > 1 ? "$mul*" : "") . "6*"
            	. ($log3 > 0 ? ($log3 != 1 ? "(1/3^${log3}n)" : "(1/3n)") : "n")
            	. "$add"
            , $expr
            );
	    if ($debug >= 1) {
    		print "enqueue $formula; add % 6 = " . ($add % 6) . "\n";
    	}
        # evaluate
        if (0) {
        } elsif ($add % 3 == 0) {
            print "$formula % 3 ...\n";
            $busy = 0; # only m will follow, not necessary to look at that trivial path
        } elsif ($add % 6 == -2) {
            print "$formula 6x-2, ";
            if ($add == -2) {
            	print "same kernel";
            } else {
            	my $shift = (- $add / 6);
            	print "n-$shift";
            }
            print "\n";
        }
        if ($busy == 1) { # reprocess
            push(@queue, join($sep, ($len, $mul, $log3, $add, $expr)));
        }
    } # lengthnot exceeded
} # enqueue
#================================
#================================
__DATA__
