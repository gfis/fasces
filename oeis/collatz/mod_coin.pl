#!perl

# Modular coincidences
# @(#) $Id$
# 2018-11-11, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl mod_coin.pl [-n maxn] [-d debug] [-p "sm,sa,sd,tm,ta,td"]
#
# Print chains where
#   (sm * n + sa) / sd = (tm * n + ta) / td for n >= 0.
#------------------------------------------------------
use strict;
use integer;

my $debug  = 0;
my $maxn   = 100; # max. start value
my $smult  = 4; my $sadd = 1; my $sdiv = 4;
my $tmult  = 3; my $tadd = 1; my $tdiv = 4;
my $parm   = "4,1,4,3,1,4";
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{p}) {
        $parm   = shift(@ARGV);
        ($smult, $sadd, $sdiv, $tmult, $tadd, $tdiv) = split(/\D+/, $parm);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $src = $sadd;
while ($src < $maxn) {
    my $tar = ($tmult * $src + $tadd) / $tdiv;
    print " $src->$tar";
    my $scoin = $src;
    my $tcoin = $tar;
    my $busy  = 1;
    my $len = 1;
    while ($busy == 1 and $tcoin % $sdiv == $sadd) { 
    	$len ++;
        if ($scoin == $tcoin) {
            $busy = 0;
            print " ...";
        } else {
            $scoin = $tcoin;
            $tcoin = ($tmult * $scoin + $tadd) / $tdiv;
            print "=>$tcoin";
        }
    } # while coin
    if ($busy > 0 and $len > 2) {
    	# print "\t # $len";
    }
    print "\n";
    $src += $smult;
} # while $src
__DATA__
----
Was Sie vielleicht auf Anhieb wissen: Es kommen bei meinem
Ansatz immer wieder - abgewandelte - "ruler functions" (A001511) 
vor. 
 

Please consider a map from, for example, 
A016813(n) = 4*n + 1 to
A016777(n) = 3*n + 1, n >= 0:
  1->1->1 ...
  5->4
  9->7
  13->10
  17->13->10
  21->16
  25->19
  29->22
  33->25->19
  37->28
and so on, with the following "long" chains:
  65->49->37->28   # 3
  129->97->73->55  # 3
  193->145->109->82        # 3
  257->193->145->109->82   # 4
  321->241->181->136       # 3
  385->289->217->163       # 3
  449->337->253->190       # 3
  513->385->289->217->163  # 4
  577->433->325->244       # 3
  641->481->361->271       # 3
  705->529->397->298       # 3
  769->577->433->325->244  # 4
  833->625->469->352       # 3
  897->673->505->379       # 3
  961->721->541->406       # 3
...
For n = 16*k + 1 the mapping can be repeated, 
and the corresponding chains have lengths 
depending on the power of 2 in k.
