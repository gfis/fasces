#!perl

# hadamard.plcondense.pl test for orthogonality
# @(#) $Id$
# 2024-07-24, Georg Fischer
#:#
#:# Usage:
#:#   perl hadamard.pl [-d debug] [-m mode]
#:#       -d 0=none, 1=some, 2=more debuging output
#:#       -m dump   print the matrices with 0/1
#:#       -m half   check whether all rows coincide in exactly half of the columns
#:#       -m square condensed notation for 2x2 cells
#----------------
use strict;
use warnings;
use integer;
use utf8;

binmode(STDOUT, ":utf8");
my $debug = 0;
my $mode  = "dump";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#--------
# read the matrices
my @planes = ();
my @plane = ( # default planes[0]
 [ 1, 1 ],
 [ 1, 0 ]
);

my $ipla = -1;
while(<>) {
  s/\s+\Z//;
  my $line = $_;
  #                1   1
  if ($line =~ m{\[(\d+)\]}) { # plane header line
    $ipla = $1;
    push(@planes, [@plane]); # previous accumulated plane
    @plane = ();
    #                          (1       1
  } elsif ($line =~ m{\A[\(\,]\(([01\,\-]+)}) { # line with matrix elements
    my @terms = map {
          if ($_ ne "1") {
            $_ = 0;
          }
          $_
        } split(/ *\, */, $1);
    push(@plane, [@terms]);
  }
} # while <>
push(@planes, [@plane]); # last accumulated plane
#--------
# evaluate the mode(s)
if (0) {

} elsif ($mode =~ m{dump}) { # dump the matrices
  for my $ipla (0..$#planes) {
    print "planes[$ipla]\n" if $debug >= 2;
    for my $irow (0..$#{$planes[$ipla]}) {
      print "planes[$ipla,$irow]\n" if $debug >= 2;
      my $sep = "[";
      for my $icol (0..$#{$planes[$ipla][$irow]}) {
        print "planes[$ipla][$irow][$icol]\n" if $debug >= 2;
        print "$sep$planes[$ipla][$irow][$icol]" if $debug >= 1;
        $sep = ",";
      } # for $icol
      print "]\n" if $debug >= 1;
    } # for $irow
    print "\n";
  } # for $ipla

} elsif ($mode =~ m{half}) { # check for half coincidence
  for my $ipla (0..$#planes) {
    my $plane_ok = 1; # assume success
    for my $irow (0..$#{$planes[$ipla]} - 1) {
      my $rowlen = $#{$planes[$ipla][$irow]} + 1;
      for my $jrow ($irow + 1 .. $#{$planes[$ipla]}) { # pairs of rows
        my $coins = 0; # number of coincidences
        for my $icol (0..$#{$planes[$ipla][$irow]}) {
          if ($planes[$ipla][$irow][$icol] == $planes[$ipla][$jrow][$icol]) {
            $coins ++;
          }
        } # for $icol
        if ($plane_ok && $coins != $rowlen / 2) { # coincide in 1/2 of the columns?
          $plane_ok = 0;
          print "# first difference for planes[$ipla][$irow][$jrow], rowlen=$rowlen, coincidences=$coins\n";
        }
      } # for $jrow
    } # for $irow 
    if ($plane_ok) {
    	print "# planes[$ipla] ok\n";
    }
  } # for $ipla

} elsif ($mode =~ m{square}) { # condensed notation for 2x2 cells 
  my %codes;
  %codes = 
    ( 14, "\x{259b}" # F
    ,  1, "\x{2597}" # .
    , 11, "\x{2599}" # 'L'
    ,  4, "\x{259d}" # 'l'
    , 13, "\x{259c}" # 'T'
    ,  8, "\x{2598}" # "j"
    ,  7, "\x{259f}" # 'J'
    ,  2, "\x{2596}" # 't'
    , 12, "\x{2594}" # '='
    , 15, "\x{2588}" # '#'
    ,  6, "\x{259e}" # '/'
    ,  9, "\x{259a}" # \\
    ,  0, "\x{2591}" # ' '
    , 10, "\x{258c}" # '|'
    );
  %codes = 
    (  0, " "
    ,  1, "."
    ,  2, "t"
    ,  3, "_"
    ,  4, "l"
    ,  5, "I"
    ,  6, "/"
    ,  7, "J"
    ,  8, "j"
    ,  9, "\\"
    , 10, "|" 
    , 11, "L"
    , 12, "="
    , 13, "T"
    , 14, "F"
    , 15, "#"
    );
  %codes = 
    (  0, "0"
    ,  1, "1"
    ,  2, "2"
    ,  3, "3"
    ,  4, "4"
    ,  5, "5"
    ,  6, "6"
    ,  7, "7"
    ,  8, "8"
    ,  9, "9"
    , 10, "a" 
    , 11, "b"
    , 12, "c"
    , 13, "d"
    , 14, "e"
    , 15, "f"
    );
  for my $ipla (1..$#planes) {  
    my $rowlen = $#{$planes[$ipla][0]} + 1; 
    my %counts = ();
    print "# planes[$ipla], rowlen=$rowlen\n";
    for (my $irow = 0; $irow < $rowlen; $irow += 2) {
      my $nota22 = "";
      for (my $icol = 0; $icol < $rowlen; $icol += 2) { 
        my $mask 
            = $planes[$ipla][$irow + 0][$icol + 0] << 3
            | $planes[$ipla][$irow + 0][$icol + 1] << 2
            | $planes[$ipla][$irow + 1][$icol + 0] << 1
            | $planes[$ipla][$irow + 1][$icol + 1];
        $counts{$mask} = defined($counts{$mask}) ? $counts{$mask} + 1 : 1;
        if (defined($codes{$mask})) {
            $nota22 .= $codes{$mask};
        } else {
            $nota22 .= "?$mask";
        }
      } # for $icol
      print "$nota22\n";
    } # for $irow 
    print "\n";
    foreach my $key (sort(keys(%counts))) {
    	print "  $counts{$key}*\"$codes{$key}\"";
    }
    print "\n\n";
  } # for $ipla

} else {
  print STDERR "# invalid mode \"$mode\"\n";
}
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
