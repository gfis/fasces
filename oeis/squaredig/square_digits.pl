#!perl

# Evaluate - for a selection of decimal digits - which
#   numbers and their squares use only those digits.
# @(#) $Id$
# 2019-07-17: attach at the end
# 2019-07-09: new attempt
# 2018-10-17, Georg Fischer
# For Jonathan Wellon's sequences A136808-A137147
#
#:# Usage:
#:#   perl squere_digits.pl [-d debug] [-n max_ind] [-s digits] 
#:#       [-w max_width] [-q initial queue element]
#------------------------------
use strict;
use Math::BigInt;
use Math::BigInt':constant';

my $debug     = 0;
my $max_ind   = 1000;
my $subset    = "0146"; # A136859
my $max_width = 16;
my $que0 = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{\-n}) {
        $max_ind   = shift(@ARGV);
    } elsif ($opt  =~ m{\-q}) {
        $que0      = shift(@ARGV);
    } elsif ($opt  =~ m{\-s}) {
        $subset    = shift(@ARGV);
    } elsif ($opt  =~ m{\-w}) {
        $max_width = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
my @digs = split(//, $subset); # single digits
my $diglen = length($subset);
my $index = 1;

my $rest  = "0123456789";
$rest =~ s{[$subset]}{}og;
my @queue = ($que0); # all possible endings of numbers still to be investigated
my $width = 1; # number of digits in $num
my $minbl = 0; # start of block in @queue
my $maybl = scalar(@queue); # asserted, 1 behind end of block
my $num;   # BigInt
my $num1;  # num + 1
my $squa0; # num**2, BigInt
my $squa1; # (num + 1)**2 - 1, BigInt
my $snum;  # $num as string
my $start = time();
while ($width <= $max_width && $index <= $max_ind) {
    my $ibl = $minbl;
    while ($ibl < $maybl) {
        foreach my $dig (@digs) {
            $snum  = "$queue[$ibl]$dig";
            $num   = Math::BigInt->new($snum); # contains proper digits by construction
            $squa0 = $num->copy()->bmul($num); # ->bstr();
            $num1  = $num->copy()->binc();
            $squa1 = $squa0->copy()->badd($num->copy()->blsft(1));
            if ($squa0 !~ m{[$rest]}) { # leading part of square has proper digits
                print "$index $snum\n"; $index ++;
                if (substr($snum, 0, 1) ne "0") { # no leading zero
                    &enqueue("full");
                }
            } else { # 
                my $lpre20 = length($`); # length of leading allowed digits in n^2 
                $squa1 =~ m{[$rest]};
                my $lpre21 = length($`); # length of leading allowed digits in (n+1)^2 - 1
                if (0) {
                } elsif ($lpre20 < $lpre21) { 
                    &enqueue("pre<"); # squa1 has longer allowed head
                } elsif ($lpre20 > $lpre21) { 
                    &enqueue("pre>"); # squa0 has longer allowed head
                } else { # allowed heads are equal
                    my $char0  = substr($squa0, $lpre20, 1); 
                    my $char1  = substr($squa1, $lpre21, 1);
                    if ($debug >= 2) {
                        print "chars: $char0 $char1\n";
                    }
                    if (0) {
                    } elsif ($char0 eq $char1) {
                        if ($debug >= 2) {
                            &output ("dro=");
                        }
                    } elsif ($char0 !~ m{[$rest]}) { # prefix(squa0) has all allowed
                        &enqueue("pre0");
                    } elsif ($char1 !~ m{[$rest]}) { # prefix(squa1) has all allowed
                        &enqueue("pre1");
                    } else { # both are not allowed - look whether there is one between
                        my $found = 0;
                        $char0 ++;
                        while ($char0 < $char1 and $found == 0) {
                            if ($char0 !~ m{[$rest]}) {
                                $found = 1;
                            }
                            $char0 ++;
                        } # while
                        if ($found == 1) {
                            &enqueue("preb");
                        } else {
                            if ($debug >= 2) {
                                &output ("drob");
                            }
                        }
                    } # both not allowed
                } # allowed heads are equal
            }       
        } # foreach $dig
        $ibl ++;
    } # while $ibl
    $minbl = $maybl;
    $maybl = scalar(@queue);
    $width ++; # enter next level
    if ($debug > 0) {
        print "----------------\n";
        print "push 9 9999999999999999999999999999999999\n"; # makes a sep
    }
} # while $width
my $time_diff = time() - $start;
print "# elapsed: $time_diff s, queue $minbl:$maybl\n";

sub enqueue {
    my ($text) = @_;
    push(@queue, $snum);
    &output($text);
} # enqueue

sub output {
    if ($debug >= 1) {
        my ($text) = @_;
        print sprintf("# %-8s %6d %10s: %16s %16s -> %s\n", $text, scalar(@queue), "$num-$num1", $squa0, $squa1, $snum);
    }
} # output
__DATA__
