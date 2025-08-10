#!perl

# hamop.pl - operations on Hadamard matrices
# @(#) $Id$
# 2024-08-10, Georg Fischer
#:#
#:# Usage:
#:#   perl hamop.pl [-d debug] op1 op2 ...
#:#       help         print usage info
#:#       debug mode   0=none, 1=some, 2=more debuging output
#:#       read1 file   read binary matrices
#:#       read4 file   read hexadecimal matrices
#:#       to4          convert from binary to hexadecimal
#:#       to1          convert from hexadecmal to binary
#:#       check        test (binary) for 2/2 condition
#:#       svg   dir    generate SVG files in dir from hex
#:#       dump1        write bin with no separators
#:#       dump4        write hex with no separators
#----------------
use strict;
use warnings;
use integer;

my $debug = 0;
my $oper  = "help";
if (scalar(@ARGV) == 0) {
  &help();
  exit;
}
while (scalar(@ARGV) > 0) {
  $oper = shift(@ARGV);
  if (0) {
  } elsif ($oper eq "help") {
    &help();
  } elsif ($oper eq "debug") {
    $debug     = shift(@ARGV);
  } elsif ($oper eq "dump1") {
    &dump1();
  } elsif ($oper eq "dump4") {
    &dump4();
  } elsif ($oper eq "read1") {
    &read1(shift(@ARGV));
  } elsif ($oper eq "read4") {
    # &read4(shift(@ARGV));
  } else {
      die "# invalid operation \"$oper\"\n";
  }
} # while arguments
#--------
sub help {
    open(IN, "<", $0);
    while (<IN>) {
      if ($_ =~ m{\A\#\:\#}) {
        print substr($_, 3);
      }
    }
} # help

my @hma1   = (); # binary matrices
my @hma4   = (); # hexadecimal matrices
my @counts = (); # counts of bits [0, 1] or hexadecimal digits in one matrix
#----
sub show_counts {
  my ($unit, $ihm) = @_; # unit=[1,4]
  if (0) {
  } elsif ($unit == 1) {
    my $diff  = abs($counts[1] - $counts[0]);
    my $diff4 = $diff / 4;
    print STDERR "# plane [$ihm]: $counts[0]*0, $counts[1]*1, diff=$diff, diff/4=$diff4\n";
  } elsif ($unit == 4) {
    print STDERR "# plane [$ihm]: $counts[0]*0, $counts[1]*1\n";
  }
} # show_counts
#----
sub read1 { # read an array of binary (1,-1) matrices with separators from a file
  my ($file) = @_;
  if ($file eq "-") {
  } else {
    open(STDIN, "<", $file) or die "# cannot read \"$file\"\n";
  }

  @hma1 = ();
  my @hmi = ( # default hma1[0]
    [ 1, 1 ],
    [ 1, 0 ]
  );
  @counts = (1, 3);

  my $ihm = 0;
  while(<STDIN>) {
    s/\s+\Z//;
    my $line = $_;
    if ($debug >= 1) {
      print "# read1: $line\n";
    }
    #                1   1
    if ($line =~ m{\[ *(\d+) *\]}) { # plane header line
      my $iplane = $1;
      &show_counts(1, $ihm);
      $ihm = $iplane;
      push(@hma1, [@hmi]); # previous accumulated plane
      @hmi = ();
      @counts = (0, 0);
    } elsif ($line =~ m{\A(\[ *\-?1)}) { # raw Sage output
      $line =~ s{\-1}{0}g;
      $line =~ s{[^01]+}{ }g;
      $line =~ s{\A +}{};
      $line =~ s{ +\Z}{};
      my @terms = map {
            $counts[$_] ++;
            $_
          } split(/ +/, $line);
      push(@hmi, [@terms]);
    }
  } # while <IN>
  push(@hma1, [@hmi]); # last accumulated plane
  &show_counts(1, $ihm);
  if ($file ne "-") {
    close(STDIN);
  }
} # read1
#----
sub read4 { # read an array of hexadecimal [0-9a-f] matrices with*OUT* separators from a file
  my ($file) = @_;
  if ($file eq "-") {
  } else {
    open(STDIN, "<", $file) or die "# cannot read \"$file\"\n";
  }

  @hma4 = ();
  my @hmi = ( # default hma4[0]
    [ 0xe ]
  );
  @counts = (1, 3);
  my %bit_counts = qw(
    0 0    1 1    2 1    3 2
    4 1    5 2    6 2    7 3
    8 1    9 2    a 2    b 3
    c 2    d 3    e 3    f 4
    );

  my $ihm = 0;
  while(<STDIN>) {
    s/\s+\Z//;
    my $line = $_;
    if ($debug >= 1) {
      print "# read4: $line\n";
    }
    #                1   1
    if ($line =~ m{\[ *(\d+) *\]}) { # plane header line
      my $iplane = $1;
      &show_counts(1, $ihm);
      $ihm = $iplane;
      push(@hma4, [@hmi]); # previous accumulated plane
      @hmi = ();
      @counts = (0, 0);
    } elsif ($line =~ m{\A[0-9a-fA-F])}) { # hex line
      my @terms = map {
            $counts[1] = $bit_counts[$_]; ++;
            $counts[0] = 16 - $bit_counts[$_];
            hex($_)
          } split(//, lc($line));
      push(@hmi, [@terms]);
    }
  } # while <IN>
  push(@hma4, [@hmi]); # last accumulated plane
  &show_counts(1, $ihm);
  if ($file ne "-") {
    close(STDIN);
  }
} # read4
#----
sub dump1 { # write matrices as bin digits without separators 
  for my $ihm (0..$#hma1) {
    print "==== hma1[$ihm]\n"; # start of 1 matrix
    for my $irow   (0..$#{$hma1[$ihm]}) {
      for my $icol (0..$#{$hma1[$ihm][$irow]}) {
        print             $hma1[$ihm][$irow][$icol];
      } # for $icol
      print "\n";
    } # for $irow
    print "\n"; # at end of 1 matrix
  } # for $ihm
} # dump1
#----
sub dump4 { # write matrices as hex digits without separators 
  for my $ihm (0..$#hma4) {
    print "==== hma4[$ihm]\n"; # start of 1 matrix
    for my $irow   (0..$#{$hma4[$ihm]}) {
      for my $icol (0..$#{$hma4[$ihm][$irow]}) {
        print             $hma4[$ihm][$irow][$icol];
      } # for $icol
      print "\n";
    } # for $irow
    print "\n"; # at end of 1 matrix
  } # for $ihm
} # dump4
__DATA__


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
            | $planes[$ipla][$irow + 1][$icol + 1] << 0;
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
