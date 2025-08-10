#!perl

# hamop.pl - operations on Hadamard matrices
# @(#) $Id$
# 2024-08-10, Georg Fischer
#:#
#:# Usage:
#:#   perl hamop.pl [-d debug] op1 op2 ...
#:#       debug mode   0=none, 1=some, 2=more debuging output
#:#       dump1        write bin with no separators
#:#       dump4        write hex with no separators
#:#       fill4        convert from binary to hexadecimal
#:#       fill1        convert from hexadecmal to binary
#:#       help         print usage info
#:#       range lo-hi  range of matrix indexes
#:#       read1 file   read binary matrices
#:#       read4 file   read hexadecimal matrices
#:#       rowtest      test (binary) rows for 2/2 condition
#:#       separ ","    use separators for input or output
#:#       svg   dir    generate SVG files in dir from hex
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
my $ihmin = 1; # set by "range" operation
my $ihmax;
my $ok1 = 0; # whether @hma1 is complete
my $ok4 = 0; # whether @hma4 is complete
my $sep = ""; # separator (for input and output)

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
  } elsif ($oper eq "fill4") {
    &fill4();
  } elsif ($oper eq "range") {
    my $range = shift(@ARGV);
    ($ihmin, $ihmax) = split(/\D+/, $range); # split by non-digits 
    if (! defined($ihmax)) {
      $ihmax = $ihmin;
    }
  } elsif ($oper eq "read1") {
    &read1(shift(@ARGV));
  } elsif ($oper eq "read4") {
    # &read4(shift(@ARGV));
  } elsif ($oper eq "separ") {
    $sep = shift(@ARGV);
    $sep =~ s{[\'\"]}{}; # remove quotes
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

my @hma1    = (); # binary matrices
my @hma4    = (); # hexadecimal matrices
my %counts1 = (); # counts of binary      digits in one matrix
my %counts4 = (); # counts of hexadecimal digits in one matrix
my %bit_counts = qw(
    0x0 0    0x1 1    0x2 1    0x3 2    0x4 1    0x5 2    0x6 2    0x7 3
    0x8 1    0x9 2    0xa 2    0xb 3    0xc 2    0xd 3    0xe 3    0xf 4
    );

#----
sub show_counts {
  my ($unit, $ih) = @_; # unit=[1,4]
  if ($debug == 0) {
    return;
  }
  if (0) {
  } elsif ($unit == 1) {
    my $diff  = abs($counts1{1} - $counts1{0});
    my $diff4 = $diff / 4;
    my $rest  = ($diff4 == $ih) ? "" : (", /$ih=" . $diff4/$ih);
    print "# matrix [$ih]: $counts1{0}*0 $counts1{1}*1, diff=$diff, diff/4=$diff4$rest\n";
  } elsif ($unit == 4) {
    print "# matrix [$ih]:";
    foreach my $hx (sort(keys(%counts4))) {
      print " $counts4{$hx}*" . sprintf("%01x", $hx);
    } # foreach $hx
    print "\n";
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
  %counts1 = (0, 1, 1, 3); # 1*0, 3*1

  my $ihm = 0;
  while(<STDIN>) {
    s/\s+\Z//;
    my $line = $_;
    if ($debug >= 1) {
      print "# read1: $line\n";
    }
    #                1   1
    if ($line =~ m{\[ *(\d+) *\]}) { # plane header line
      my $ihtemp = $1;
      &show_counts(1, $ihm);
      $ihm = $ihtemp;
      push(@hma1, [@hmi]); # previous accumulated plane
      @hmi = ();
      %counts1 = (0, 0, 1, 0);
    } elsif ($line =~ m{\A(\[ *\-?1)}) { # raw Sage output
      $line =~ s{\-1}{0}g;
      $line =~ s{[^01]+}{ }g;
      $line =~ s{\A +}{};
      $line =~ s{ +\Z}{};
      my @temp = map {
            $counts1{$_} ++;
            $_
          } split(/ +/, $line);
      push(@hmi, [ @temp ]);
    }
  } # while <IN>
  push(@hma1, [ @hmi ]); # last accumulated plane
  &show_counts(1, $ihm);
  if ($file ne "-") {
    close(STDIN);
  }
  $ihmax = $ihm;
  $ok1 = 1;
} # read1
#----
sub fill4 { # fill @hma4 from @hma1
  if ($ok4 == 1) { # is already filled
  	print "# hma4 already filled\n";
    return;
  }
        if ($debug >= 2) {
          print "ihmin=$ihmin, ihmax=$ihmax\n";
        }
  @hma4 = ();
  my @hmi = ( # default hma4[0]
    [ 0xe ]
  ); 
  push(@hma4, [ @hmi ]);
  %counts4 = ();
  for my $ihm ($ihmin..$ihmax) {
    @hmi  = ();
    for (my $irow = 0; $irow <= $#{$hma1[$ihm]}; $irow += 2) {
      my @temp = ();
      for (my $icol = 0; $icol <= $#{$hma1[$ihm][$irow]}; $icol += 2) { 
        if ($debug >= 2) {
          print "ihm=$ihm, irow=$irow, icol=$icol\n";
        }
        my $mask
            = $hma1[$ihm][$irow + 0][$icol + 0] << 3
            | $hma1[$ihm][$irow + 0][$icol + 1] << 2
            | $hma1[$ihm][$irow + 1][$icol + 0] << 1
            | $hma1[$ihm][$irow + 1][$icol + 1] << 0;
        $counts4{$mask} = defined($counts4{$mask}) ? $counts4{$mask} + 1 : 1;
        push(@temp, $mask);
      } # for $icol
      push(@hmi, [ @temp ]);
    } # for $irow
    push(@hma4, [ @hmi ]);
    &show_counts(4, $ihm);
  } # for $ihm
  $ok4 = 1;
} # fill4
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
  %counts4 = (0xe, 1);
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
      %counts4 = ();
    } elsif ($line =~ m{\A[0-9a-fA-F]}) { # hex line
      my @temp = map {
            my $hx = hex($_);
            $counts4{$hx} = defined($counts4{$hx}) ? $counts4{$hx} + 1 : 1;
            $hx
          } split(//, lc($line));
      push(@hmi, [@temp]);
    }
  } # while <IN>
  push(@hma4, [@hmi]); # last accumulated plane
  &show_counts(1, $ihm);
  if ($file ne "-") {
    close(STDIN);
  }
  $ihmax = $ihm;
  $ok4 = 1;
} # read4
#----
sub dump1 { # write matrices as bin digits
  if ($ok1 == 0) {
  # &fill1();
  }
  for my $ihm ($ihmin..$ihmax) {
    print "==== hma1[$ihm]\n"; # start of 1 matrix
    for my $irow   (0..$#{$hma1[$ihm]}) {
      for my $icol (0..$#{$hma1[$ihm][$irow]}) {
        if ($icol > 0) {
          print $sep;
        }
        print             $hma1[$ihm][$irow][$icol];
      } # for $icol
      print "\n";
    } # for $irow
    print "\n"; # at end of 1 matrix
  } # for $ihm
} # dump1
#----
sub dump4 { # write matrices as hex digits
  if ($ok4 == 0) {
    &fill4();
  }
  for my $ihm ($ihmin..$ihmax) {
    print "==== hma4[$ihm]\n"; # start of 1 matrix
    for my $irow   (0..$#{$hma4[$ihm]}) {
      for my $icol (0..$#{$hma4[$ihm][$irow]}) {
        if ($icol > 0) {
          print $sep;
        }
        print sprintf("%01x", $hma4[$ihm][$irow][$icol]);
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
