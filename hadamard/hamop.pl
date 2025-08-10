#!perl

# hamop.pl - operations on Hadamard matrices
# @(#) $Id$
# 2024-08-10, Georg Fischer
#:#
#:# Usage:
#:#   perl hamop.pl [-d debug] op1 op2 ...
#:#       debug mode     0=none, 1=some, 2=more debuging output
#:#       dump1          write bin with no separators
#:#       dump4          write hex with no separators
#:#       fill4          convert from binary to hexadecimal
#:#       fill1          convert from hexadecmal to binary
#:#       help           print usage info
#:#       range min-max  range of matrix indexes
#:#       read1 file     read binary matrices
#:#       read4 file     read hexadecimal matrices
#:#       rowtest        test (binary) rows for 2/2 condition
#:#       separ ","      use separators for output
#:#       svg   dir      generate SVG files in dir from hex
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
my $letters = "=abcdefghijklmnopqrstuvwxyz"; # for rowtest, coltest
my $ihmin = 2961947; # very high; set by "range" operation
my $ihmax = 0;
my $ok1 = 0; # whether @hma1 is complete
my $ok4 = 0; # whether @hma4 is complete
my $sep = ""; # separator (for input and output)
my @hma1    = (); # binary matrices
my @hma4    = (); # hexadecimal matrices
my %counts1 = (); # counts of binary      digits in one matrix
my %counts4 = (); # counts of hexadecimal digits in one matrix
my %bit_counts = qw(
    0 0    1 1    2 1    3 2
    4 1    5 2    6 2    7 3
    8 1    9 2   10 2   11 3
   12 2   13 3   14 3   15 4
    );
if ($debug >= 2) {
  foreach my $ix (keys(%bit_counts))  {
    print "# init: bit_counts{$ix} = $bit_counts{$ix}\n";
  }
}

while (scalar(@ARGV) > 0) {
  $oper = shift(@ARGV);
  if (0) {
  } elsif ($oper eq "help") {
    &help();
  } elsif ($oper eq "debug") {
    $debug     = shift(@ARGV);

  } elsif ($oper eq "coltest") {
    &coltest();
  } elsif ($oper eq "dump1") {
    &dump1();
  } elsif ($oper eq "dump4") {
    &dump4();
  } elsif ($oper eq "fill1") {
    &fill1();
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
    &read4(shift(@ARGV));
  } elsif ($oper eq "rowtest") {
    &rowtest();
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
#----
sub show_counts {
  my ($unit, $ih) = @_; # unit=[1,4]
  if ($debug == 0) {
    return;
  }
  print "# show counts$unit $ih\n";
  if (0) {
  } elsif ($unit == 1) {
    my $diff  = abs($counts1{1} - $counts1{0});
    my $diff4 = $diff / 4;
    my $rest  = ($diff4 == $ih) ? "" : (", /$ih=" . $diff4/$ih);
    print "# matrix $ih: $counts1{0}*0 $counts1{1}*1, diff=$diff, diff/4=$diff4$rest\n";
  } elsif ($unit == 4) {
    print "# matrix $ih:";
    foreach my $hx (sort(keys(%counts4))) {
      print " $counts4{$hx}*" . sprintf("%01x", $hx);
    } # foreach $hx
    print "\n";
  }
} # show_counts
#----
sub dump1 { # write matrices as binary digits
  print "# dump1 $ihmin..$ihmax\n" if ($debug >= 1);
  if ($ok1 == 0) {
    &fill1();
  }
  for my $ihm ($ihmin..$ihmax) {
    print "==== hma1[$ihm]\n"; # start of 1 matrix
    for my $irow   (0..$#{$hma1[$ihm]}) {
      for my $icol (0..$#{$hma1[$ihm][$irow]}) {
        if ($icol > 0) {
          print $sep;
        }
        print $hma1[$ihm][$irow][$icol];
      } # for $icol
      print "\n";
    } # for $irow
    print "\n"; # at end of 1 matrix
  } # for $ihm
} # dump1
#----
sub dump4 { # write matrices as hexadecimal digits
  print "# dump4 $ihmin..$ihmax\n" if ($debug >= 1);
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
#----
sub fill1 { # fill @hma1 from @hma4
  print "# fill1 $ihmin..$ihmax\n" if ($debug >= 1);
  if ($ok1 == 1) { # is already filled
    print "# fill1: @hma1 already filled\n";
    return;
  }
  @hma1 = ();
  my @hmi = ( # default hma1[0]
    [ 1, 1 ],
    [ 1, 0 ]
  );
  push(@hma1, [ @hmi ]);
  %counts1 = (0, 0, 1, 0);
  for my $ihm ($ihmin..$ihmax) {
    @hmi  = ();
    for (my $irow = 0; $irow <= $#{$hma4[$ihm]}; $irow ++) {
      my @temp0 = (); # upper row
      my @temp1 = (); # lower row
      for (my $icol = 0; $icol <= $#{$hma4[$ihm][$irow]}; $icol ++) {
        my $mask = $hma4[$ihm][$irow][$icol];
        if ($debug >= 2) {
          print "# fill1: ihm=$ihm, irow=$irow, icol=$icol, mask=$mask, bit_counts{$mask}=$bit_counts{$mask}\n";
        }
        $counts1{0} += 16 - $bit_counts{$mask};
        $counts1{1} +=      $bit_counts{$mask};
        push(@temp0, ($mask >> 3) & 1, ($mask >> 2) & 1);
        push(@temp1, ($mask >> 1) & 1, ($mask >> 0) & 1);
      } # for $icol
      push(@hmi, [ @temp0 ]);
      push(@hmi, [ @temp1 ]);
    } # for $irow
    $hma1[$ihm] = [ @hmi ];
    &show_counts(1, $ihm);
  } # for $ihm
  $ok1 = 1;
} # fill1
#----
sub fill4 { # fill @hma4 from @hma1
  print "# fill1 $ihmin..$ihmax\n" if ($debug >= 1);
  if ($ok4 == 1) { # is already filled
    print "# fill4: @hma4 already filled\n";
    return;
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
          print "# fill4: ihm=$ihm, irow=$irow, icol=$icol\n";
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
    $hma4[$ihm] = [ @hmi ];
    &show_counts(4, $ihm);
  } # for $ihm
  $ok4 = 1;
} # fill4
#----
sub read1 { # read an array of binary (1,-1) matrices from a file
  my ($file) = @_;
  if ($file eq "-") {
  } else {
    open(STDIN, "<", $file) or die "# read1: cannot read \"$file\"\n";
  }
  @hma1 = ();
  my @hmi = ( # default hma1[0]
    [ 1, 1 ],
    [ 1, 0 ]
  );
  %counts1 = (0, 1, 1, 3); # 1*0, 3*1
  my $ihm = 0;
  while(<STDIN>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($debug >= 2) {
      print "# read1: $line\n";
    }
    #                1   1
    if ($line =~ m{\[ *(\d+) *\]}) { # plane header line
      my $ihnext = $1;
      $hma1[$ihm] = [ @hmi ]; # previous accumulated plane
      &show_counts(1, $ihm);
      $ihmin = $ihnext < $ihmin ? $ihnext : $ihmin;
      $ihmax = $ihnext > $ihmax ? $ihnext : $ihmax;
      $ihm   = $ihnext;
      @hmi = ();
      %counts1 = (0, 0, 1, 0);
    } elsif ($line =~ m{\A(\[ *\-?1)}) { # raw Sage output
      $line =~ s{\-1}{0}g;
      $line =~ s{[^01]}{}g; # remove any non-bin characters
      my @temp = map {
            $counts1{$_} ++;
            $_
          } split(//, $line);
      push(@hmi, [ @temp ]);
    } else {
      # separator line - ignore
    }
  } # while <IN>
  $hma1[$ihm] = [ @hmi ]; # last accumulated plane
  &show_counts(1, $ihm);
  if ($file ne "-") {
    close(STDIN);
  }
  $ok1 = 1;
  print "# read1 $ihmin..$ihmax\n" if ($debug >= 1);
} # read1
#----
sub read4 { # read an array of hexadecimal [0-9a-f] matrices from a file
  my ($file) = @_;
  if ($file eq "-") {
  } else {
    open(STDIN, "<", $file) or die "# read4: cannot read \"$file\"\n";
  }

  @hma4 = ();
  my @hmi = ( # default hma4[0]
    [ 0xe ]
  );
  %counts4 = (0xe, 1);
  my $ihm = 0;
  while(<STDIN>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($debug >= 2) {
      print "# read4: $line\n";
    }
    #                1   1
    if ($line =~ m{\[ *(\d+) *\]}) { # plane header line
      my $ihnext = $1;
      $hma1[$ihm] = [ @hmi ]; # previous accumulated plane
      &show_counts(4, $ihm);
      $ihmin = $ihnext < $ihmin ? $ihnext : $ihmin;
      $ihmax = $ihnext > $ihmax ? $ihnext : $ihmax;
      $ihm   = $ihnext;
      @hmi = ();
      %counts4 = ();
    } elsif ($line =~ m{\A[0-9a-fA-F]}) { # hex line
      $line = lc($line);
      $line =~ s{[^0-9a-f]}{}g; # remove any non-hex characters
      my @temp = map {
            my $hx = hex($_);
            $counts4{$hx} = defined($counts4{$hx}) ? $counts4{$hx} + 1 : 1;
            $hx
          } split(//, lc($line));
      push(@hmi, [@temp]);
    }
  } # while <IN>
  $hma4[$ihm] = [ @hmi ]; # last accumulated plane
  &show_counts(4, $ihm);
  if ($file ne "-") {
    close(STDIN);
  }
  $ok4 = 1;
  print "# read4 $ihmin..$ihmax\n" if ($debug >= 1);
} # read4
#----
sub get_diff {
  my ($diff) = @_;
  if (abs($diff) >= length($letters)) {
    $diff = "*";
  } elsif ($diff < 0) {
    $diff = uc(substr($letters, -$diff, 1));
  } elsif ($diff > 0) {
    $diff = lc(substr($letters, -$diff, 1));
  } else { # $diff == 0
    $diff = "=";
  }
} # get_diff

sub rowtest { # test all pairs of rows whether one half of the columns is coincident and one half is not
  # the diagonal is also shown, though it never fulfills the condition
  print "# rowtest $ihmin..$ihmax\n" if ($debug >= 1);
  if ($ok1 == 0) {
    &fill1();
  }
  for my $ihm ($ihmin..$ihmax) {
    print "# rowtest $ihm\n";
    for (my $irow0 = 0; $irow0 <= $#{$hma1[$ihm]} - 1; $irow0 ++) {
      print "" . (" " x $irow0);
      for (my $irow1 = $irow0; $irow1 <= $#{$hma1[$ihm]}; $irow1 ++) {
        my $rowlen = $#{$hma1[$ihm][$irow0]} + 1;
        my $iscoin = 0; # number of coincidences
        my $nocoin = 0; # number of non-coincidences
        for (my $icol = 0; $icol < $rowlen; $icol ++) {
          if ($hma1[$ihm][$irow0][$icol] == $hma1[$ihm][$irow1][$icol]) {
            $iscoin ++;
          } else {
            $nocoin ++;
          }
        } # for $icol
        print &get_diff($iscoin - $nocoin);
      } # for $irow1
      print "\n";
    } # for $irow0
    print "\n"; # at end of 1 matrix
  } # for $ihm
} # rowtest

sub coltest { # test all pairs of columns whether one half of the rows is coincident and one half is not
  # the diagonal is also shown, though it never fulfills the condition
  print "# coltest $ihmin..$ihmax\n" if ($debug >= 1);
  if ($ok1 == 0) {
    &fill1();
  }
  for my $ihm ($ihmin..$ihmax) {
    print "# coltest $ihm\n";
    for (my $icol0 = 0; $icol0 <= $#{$hma1[$ihm][0]} - 1; $icol0 ++) {
      print "" . (" " x $icol0);
      for (my $icol1 = $icol0; $icol1 <= $#{$hma1[$ihm][0]}; $icol1 ++) {
        my $collen = $#{$hma1[$ihm]} + 1;
        my $iscoin = 0; # number of coincidences
        my $nocoin = 0; # number of non-coincidences
        for (my $irow = 0; $irow < $collen; $irow ++) {
          if ($hma1[$ihm][$irow][$icol0] == $hma1[$ihm][$irow][$icol1]) {
            $iscoin ++;
          } else {
            $nocoin ++;
          }
        } # for $irow
        print &get_diff($iscoin - $nocoin);
      } # for $icol1
      print "\n";
    } # for $icol0
    print "\n"; # at end of 1 matrix
  } # for $ihm
} # coltest
__DATA__

