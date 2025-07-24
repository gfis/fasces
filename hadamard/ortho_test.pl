#!perl

# ortho_test.pl test for orthogonality
# @(#) $Id$
# 2024-07-23, Georg Fischer

use strict;
use warnings;
use integer;

my $debug = 0;
my $paint = "0";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{p}) {
        $paint = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt 

# read the matrices
my @planes = (); 
my @plane = ( # default planes[0]
 [ 1, 1 ],
 [ 1, 0 ]
);   

my $iplane = -1;
while(<DATA>) {  
  s/\s+\Z//;
  my $line = $_; 
  #                1   1
  if ($line =~ m{\[(\d+)\]}) {
    $iplane = $1; 
    push(@planes, [@plane]);
    @plane = ();
    #                          (1       1 
  } elsif ($line =~ m{\A[\(\,]\(([01\,]+)}) {
    my @terms = split(/\,/, $1);
    push(@plane, [@terms]);
  }
} # while
push(@planes, [@plane]);

# dump the matrices
for my $iplane (0..$#planes) { 
  print "planes[$iplane]\n" if $debug >= 2;
  for my $irow (0..$#{$planes[$iplane]}) { 
    print "planes[$iplane,$irow]\n" if $debug >= 2;
    my $sep = "[";
    for my $icol (0..$#{$planes[$iplane][$irow]}) {
      print "planes[$iplane][$irow][$icol]\n" if $debug >= 2; 
      print "$sep$planes[$iplane][$irow][$icol]" if $debug >= 1;
      $sep = ",";
    } # for $icol 
    print "]\n" if $debug >= 1;
  } # for $irow 
  print "\n";
} # for $iplane

# check the matrices
for my $iplane (0..$#planes) {
  for my $irow (0..$#{$planes[$iplane]} - 1) { 
    my $rowlen = $#{$planes[$iplane][$irow]} + 1;
    for my $jrow ($irow + 1 .. $#{$planes[$iplane]}) { 
      my $sum = 0;
      for my $icol (0..$#{$planes[$iplane][$irow]}) {
        if ($planes[$iplane][$irow][$icol] == $planes[$iplane][$jrow][$icol]) {
          $sum ++;
        }
      } # for $icol 
      if ($sum != $rowlen / 2) {
        print "difference for $planes[$iplane], irow=$irow, jrow=$jrow, sum=$sum\n";
      }
    } # for $jrow
  } # for $irow 
} # for $iplane

__DATA__
$planes[1] = 
((1,1,1,1)
,(1,0,1,0)
,(1,1,0,0)
,(1,0,0,1)
);
$planes[2] = 
((1,1,1,1,1,1,1,1)
,(1,0,1,0,1,0,1,0)
,(1,1,0,0,1,1,0,0)
,(1,0,0,1,1,0,0,1)
,(1,1,1,1,0,0,0,0)
,(1,0,1,0,0,1,0,1)
,(1,1,0,0,0,0,1,1)
,(1,0,0,1,0,1,1,0)
);
