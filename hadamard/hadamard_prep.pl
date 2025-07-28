#!perl

# hadamard_prep.pl convert raw output of SageMath to Javascript assignments
# @(#) $Id$
# 2024-07-21, Georg Fischer

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

if (0) {
print <<GFis;
my \@planes = ();
\$planes[0] = 
((1,1)
,(1,0)
GFis
}
my $iplane = 0;
my $sep;
while (<>) {
  s/\s+\Z//; # chompr
  my $line = $_;
  if (0) {
  } elsif ($line =~ m{\Aplanes\D*(\d+)}) { # plane index
    $iplane = $1;
    print ");\n";
    $sep = "(";
    print "\$planes[$iplane] = \n";
  } elsif ($line =~ m{\A(\[ *\-?1)}) {  
    if ($paint == 0) {
      $line =~ s{\-1}{0}g;
      $line =~ s{\A\[ *}{\[};
      $line =~ s{\|}{ }g;
      $line =~ s{ +}{\,}g;
    } else { 
      $line =~ s{\-1}{\.}g;
      $line =~ s{1}{O}g;
      $line =~ s{\A\[ *}{\[};
      $line =~ s{\|}{}g;
      $line =~ s{ +}{}g;
    }  
    $line =~ tr{\[\]}{\(\)};
    print "$sep$line\n";
    $sep = ",";
  }
} # while <>
print <<'GFis'; # postlude
);
GFis
__DATA__

https://sagecell.sagemath.org/
2025-07-19: for *VF=44, *CZ=73

from sage.combinat.matrices.hadamard_matrix import hadamard_matrix, skew_hadamard_matrix
for i in range(1,65):
  H = hadamard_matrix(4*i)
  print ("planes[", i, "]")
  print (H.str())

4 =================
[ 1  1  1  1]
[ 1 -1  1 -1]
[ 1  1 -1 -1]
[ 1 -1 -1  1]
8 =================
[ 1  1  1  1  1  1  1  1]
[ 1 -1  1 -1  1 -1  1 -1]
[ 1  1 -1 -1  1  1 -1 -1]
[ 1 -1 -1  1  1 -1 -1  1]
[ 1  1  1  1 -1 -1 -1 -1]
[ 1 -1  1 -1 -1  1 -1  1]
[ 1  1 -1 -1 -1 -1  1  1]
[ 1 -1 -1  1 -1  1  1 -1]
12 =================
[ 1  1| 1  1| 1  1| 1  1| 1  1| 1  1]
[ 1 -1|-1  1|-1  1|-1  1|-1  1|-1  1]
[-----+-----+-----+-----+-----+-----]
[ 1 -1| 1 -1| 1  1|-1 -1|-1 -1| 1  1]
[ 1  1|-1 -1| 1 -1|-1  1|-1  1| 1 -1]
[-----+-----+-----+-----+-----+-----]
[ 1 -1| 1  1| 1 -1| 1  1|-1 -1|-1 -1]
[ 1  1| 1 -1|-1 -1| 1 -1|-1  1|-1  1]
[-----+-----+-----+-----+-----+-----]
[ 1 -1|-1 -1| 1  1| 1 -1| 1  1|-1 -1]
[ 1  1|-1  1| 1 -1|-1 -1| 1 -1|-1  1]
[-----+-----+-----+-----+-----+-----]
[ 1 -1|-1 -1|-1 -1| 1  1| 1 -1| 1  1]
[ 1  1|-1  1|-1  1| 1 -1|-1 -1| 1 -1]
[-----+-----+-----+-----+-----+-----]
[ 1 -1| 1  1|-1 -1|-1 -1| 1  1| 1 -1]
[ 1  1| 1 -1|-1  1|-1  1| 1 -1|-1 -1]
16 =================
