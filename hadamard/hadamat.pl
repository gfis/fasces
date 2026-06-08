#!perl

# hadamat.pl - operations on Hadamard matrices
# @(#) $Id$
# 2026-06-08: copied from hamop.pl; only 1 matrix, no oper4; *FP=12
# 2024-08-10, Georg Fischer
#:#
#:# Usage:
#:#   perl hadamat.pl [-d debug] op1 op2 ...
#:#       debug mode     0=none, 1=some, 2=more debuging output
#:#       dump           write binary terms with no separators
#:#       help           print usage info
#:#       read  file     read matrices in "sage", "10" or "+-" format
#:#       coltest        test columns for 1/2 condition
#:#       rowtest        test rows for 1/2 condition
#:#       svg            generate an SVG file
#----------------
use strict;
use warnings;
use integer;

my $debug = 0;
my $oper  = "help";
my $sep   = "";
if (scalar(@ARGV) == 0) {
  &help();
  exit;
}
my $letters = "=abcdefghijklmnopqrstuvwxyz"; # for rowtest, coltest
my @hm      = (); # the matrix
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
  } elsif ($oper eq "dump") {
                    &dump_hm();
  } elsif ($oper eq "fill1") {
    # nyi
  } elsif ($oper eq "read") {
                    &read_hm(shift(@ARGV));
  } elsif ($oper eq "rowtest") {
                    &rowtest();
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
  if ($debug >= 1) {
    print "# rowtest\n";
  }
  my $rowlen = scalar($hm[0]);
  my $collen = $rowlen;
  for (my $irow0 = 0; $irow0 < $rowlen; $irow0 ++) {
    print "" . (" " x $irow0);
    for (my $irow1 = $irow0 + 1; $irow1 < $rowlen; $irow1 ++) {
      my $iscoin = 0; # number of coincidences
      my $nocoin = 0; # number of non-coincidences
      for (my $icol = 0; $icol < $collen; $icol ++) {
        if ($hm[$irow0][$icol] == $hm[$irow1][$icol]) {
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
} # rowtest

sub coltest { # test all pairs of columns whether one half of the rows is coincident and one half is not
  if ($debug >= 1) {
    print "# coltest\n";
  }
  my $rowlen = scalar($hm[0]);
  my $collen = $rowlen;
  for (my $icol0 = 0; $icol0 < $collen; $icol0 ++) {
    print "" . (" " x $icol0);
    for (my $icol1 = $icol0 + 1; $icol1 < $collen; $icol1 ++) {
      my $iscoin = 0; # number of coincidences
      my $nocoin = 0; # number of non-coincidences
      for (my $irow = 0; $irow < $rowlen; $irow ++) {
        if ($hm[$irow][$icol0] == $hm[$irow][$icol1]) {
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
} # coltest
#----
sub dump_hm { # write matrices as binary digits 0,1
  for my $irow   (0..$#hm) {
    for my $icol (0..$#{$hm[$irow]}) {
      if ($icol > 0) {
        print $sep;
      }
      my $ch = $hm[$irow][$icol];
      if ($ch == 0) {
        $ch = "-";
      }
      print $ch;
    } # for $icol
    print "\n";
  } # for $irow
  print "\n"; # at end of 1 matrix
} # dump_hm
#----
sub read_hm { # read an array of binary (1,-1) matrices from a file
  my ($file) = @_;
  if ($file eq "-") {
  } else {
    open(STDIN, "<", $file) or die "# read_hm: cannot read \"$file\"\n";
  }
  @hm = ();
  my $first = 1;
  my $informat = "sage";
  while(<STDIN>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($debug >= 2) {
      print "# read_hm: $line\n";
    }
    #                1   1
    if (($line =~ m{plane}) || ($line =~ m{\A\s*\Z}) ) { # plane header or empty line 
      next;
    } 
    if ($line =~ m{\A\[[\+\-]*\]}) { # sage separator line
      next;
    } 
    if ($first) { #determine input format from first line: "sage", "10", "+-"
      $first = 0;
      if (0) {
      } elsif ($line =~ m{\A\[ *\-?1}) { # raw Sage output
        $informat = "sage";
      } elsif ($line =~ m{\A *[\+\- ]+\Z}) { # +-
        $informat = "+-";
      } elsif ($line =~ m{\A *[10 ]+\Z}) { # 10
        $informat = "10";
      } else {
        die "cannot recognize input format of \"$line\"\n";
      }
    } # if first
    my $found = 0;
    if (0) {
    } elsif ($informat eq "sage") {
      if ($line =~ m{\A\[ *\-?1}) {
        $line =~ s{\-1}{0}g;
        $line =~ s{[^01]}{}g; # remove any non-binary characters
        $found = 1;
      }
    } elsif ($informat eq "10") {
      if ($line =~ m{\A *[\+\- ]+\Z}) {
        $line =~ s{[^01]}{}g; # remove any other characters
        $found = 1;
      }
    } elsif ($informat eq "+-") {
      if ($line =~ m{\A *[10 ]+\Z}) {
        $line =~ s{[^\+\-]}{}g; # remove any other characters
        $line =~ tr{\+\-}{10};
        $found = 1;
      }
    }
    if ($found) {
      my @row = split(//, $line);
      push(@hm, [ @row ]);
    }
  } # while <STDIN>
  # &show_counts(1, $ihm); 
  if ($#hm != $#{$hm[0]}) {
    print STDERR "non-square matrix: $#hm x $#{$hm[0]}\n";
  }
  if ($file ne "-") {
    close(STDIN);
  }
} # read_hm
__DATA__
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
    $hm = [ @hmi ];
    &show_counts(1, $ihm);
  } # for $ihm
  $ok1 = 1;
} # fill1
#----
__DATA__

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

planes[ 9 ]
[ 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1]
[ 1 -1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1]
[-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----]
[ 1 -1| 1 -1| 1  1| 1  1|-1 -1| 1  1|-1 -1|-1 -1|-1 -1| 1  1| 1  1|-1 -1|-1 -1|-1 -1| 1  1|-1 -1| 1  1| 1  1]
[ 1  1|-1 -1| 1 -1| 1 -1|-1  1| 1 -1|-1  1|-1  1|-1  1| 1 -1| 1 -1|-1  1|-1  1|-1  1| 1 -1|-1  1| 1 -1| 1 -1]
[-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----]
[ 1 -1| 1  1| 1 -1| 1  1| 1  1|-1 -1| 1  1|-1 -1|-1 -1|-1 -1| 1  1| 1  1|-1 -1|-1 -1|-1 -1| 1  1|-1 -1| 1  1]

