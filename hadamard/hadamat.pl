#!perl

# hadamat.pl - operations on Hadamard matrices
# @(#) $Id$
# 2026-06-08: copied from hamop.pl; only 1 matrix, no oper4; *FP=12; *RP=78
# 2024-08-10, Georg Fischer
#:#
#:# Usage:
#:#   perl hadamat.pl [-d debug] op1 op2 ...
#:#     debug    mode      0=none, 1=some, 2=more debugging output
#:#     dump<i>            write terms in "1-" format, optionally separate in <i> subblocks
#:#     help               print usage info
#:#     read     file      read matrices in "sage", "10" or "+-" format
#:#     order    n         specify the desired order for gen (must be a multiply of 4)
#:#     gen      method    generate a Hadamard matrix with method 
#:#     coltest            test columns for 1/2 condition and show triangle
#:#     rowtest            test rows for 1/2 condition and show triangle
#:#     ortest             test rows and columns for 1/2 condition and show summary only
#:#     legendre p         compute the legendre symbols (a/p) for a=0..p-1 (p prime), with debug >= 1
#:#     svg                generate an SVG file
#
# C.f. https://en.wikipedia.org/wiki/Paley_construction -> Jacobsthal matrix -> Legendre symbol
#----------------
use strict;
use warnings;
use integer;

my $debug  = 0;
my $oper   = "help";
my $sep    = ""; 
my $order  = 7;
my $method = "paleyI";
if (scalar(@ARGV) == 0) {
  &help();
  exit;
}
my $letters = "=abcdefghijklmnopqrstuvwxyz"; # for rowtest, coltest
my @hm      = (); # the matrix
my @chi; # stores the Legendre symbol of (n/p) for n=0..p-1 
my %squares; # maps n -> sqrt(n)
for my $n (0..100) {
  $squares{$n**2} = $n;
}
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
  } elsif ($oper eq  "help") {
                     &help();
  } elsif ($oper eq  "debug") {
                     $debug     = shift(@ARGV);
  } elsif ($oper eq  "coltest") {
                     &coltest(1);
  } elsif ($oper eq  "legendre") {
                     &legendre(shift(@ARGV));
  } elsif ($oper =~ m{dump\d*}) {
                     &dump0($oper);
  } elsif ($oper eq  "order") { 
                     $order = shift(@ARGV);;
  } elsif ($oper eq  "ortest") { 
                     &ortest();
  } elsif ($oper eq  "gen") {
                     &gen(shift(@ARGV));
  } elsif ($oper eq  "read") {
                     &read_hm(shift(@ARGV));
  } elsif ($oper eq  "rowtest") {
                     &rowtest(1);
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
sub legendre { # parameter: p 
  # from https://en.wikipedia.org/wiki/Paley_construction
  my ($q) = @_;
  @chi = (0); # [0] is always 0
  for my $a (1..$q - 1) {
    my $result = 0; # assume non-square
    my $busy = 1;
    my $b = 1;
    while ($busy == 1 && $b < $q) {
      my $b2 = $b**2;
      if ($debug >= 2) {
        print "a=$a, busy=$busy, result=$result, b=$b, b2=$b2, q=$q, b2 % q= " . ($b2 % $q) . "\n";
      }
      if ($b2 % $q == $a) { # quadratic residue
        $busy = 0;
        $result = 1;
      }
      $b++;
    } 
    push(@chi, $result);
  } # for $a
  if ($debug >= 1) {
    print join(",", @chi) . "\n";
  }
} # legendre
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
  my ($show) = @_;
  my $result = 1;
  if ($debug >= 1) {
    print "# rowtest\n";
  }
  my $rowlen = $#hm + 1;
  my $collen = $rowlen;
  for my $irow0 (0..$#hm) {
    if ($show > 0) {
      print "" . (" " x $irow0);
    }
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
      if ($show > 0) {
        print &get_diff($iscoin - $nocoin);
      }
      if ($iscoin != $nocoin) {
        $result = 0;
      }
    } # for $irow1
    if ($show > 0) {
      print "\n";
    }
  } # for $irow0
  return $result;
} # rowtest

sub coltest { # test all pairs of columns whether one half of the rows is coincident and one half is not
  my ($show) = @_;
  my $result = 1;
  if ($debug >= 1) {
    print "# coltest\n";
  }
  my $rowlen = $#hm + 1;
  my $collen = $rowlen;
  for my $icol0 (0..$#hm) {
    if ($show > 0) {
      print "" . (" " x $icol0);
    }
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
      if ($show > 0) {
        print &get_diff($iscoin - $nocoin);
      }
      if ($iscoin != $nocoin) {
        $result = 0;
      }
    } # for $icol1
    if ($show > 0) {
      print "\n";
    }
  } # for $icol0
  return $result;
} # coltest

sub ortest {
  my $sum = 0;
  $sum += &rowtest(0);
  $sum += &coltest(0);
  print "# ortest=$sum, order=$order, order/4=" . ($order/4) . "\n";
} # ortest
#----
sub dump0 { # write matrices as binary digits 0,1
  my ($name) = @_;
  my $ord4 = 19470629; # very high
  if ($name =~ m{dump(\d+)}) {
    my $div = $1;
    $ord4 = ($#hm + 1) / $div;
  }
  # print STDERR "dump0: name=$name, ord4=$ord4\n";
  for my $irow   (0..$#hm) {
    if ($irow > 0 && $irow % $ord4 == 0) {
      print "\n";
    }
    for my $icol (0..$#{$hm[$irow]}) {
      if ($icol > 0) {
        print $sep;
      }
      my $ch = $hm[$irow][$icol];
      if ($ch == 0) {
        $ch = "-";
      }
      if ($icol > 0 && $icol % $ord4 == 0) {
        print " ";
      }
      print $ch;
    } # for $icol
    print "\n";
  } # for $irow
  print "\n"; # at end of 1 matrix
} # dump0
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
    if ($line =~ m{\A\[?[\+\-]*\]}) { # sage separator line
      next;
    } 
    if ($first) { #determine input format from first line: "sage", "10", "+-", "1-"
      $first = 0;
      if (0) {
      } elsif ($line =~ m{\A\[? *\-?1}) { # raw Sage output
        $informat = "sage";
      } elsif ($line =~ m{\A *[\+\- ]+\Z}) { # +-
        $informat = "+-";
      } elsif ($line =~ m{\A *[1\- ]+\Z}) { # 1-
        $informat = "1-";
      } elsif ($line =~ m{\A *[10 ]+\Z}) { # 10
        $informat = "10";
      } else {
        die "cannot recognize input format of \"$line\"\n";
      }
    } # if first
    my $found = 0;
    if (0) {
    } elsif ($informat eq "sage") {
      if ($line =~ m{\A\[? *\-?1}) {
        $line =~ s{\-1}{0}g; # negative -> 0
        $line =~ s{[^01]}{}g; # remove any non-binary characters
        $found = 1;
      }
    } elsif ($informat eq "10") {
      if ($line =~ m{\A *[10 ]+\Z}) {
        $line =~ s{[^01]}{}g; # remove any other characters
        $found = 1;
      }
    } elsif ($informat eq "1-") {
      if ($line =~ m{\A *[1\- ]+\Z}) {
        $line =~ s{[^1\-]}{}g; # remove any other characters
        $line =~ tr{1\-}{10};
        $found = 1;
      }
    } elsif ($informat eq "+-") {
      if ($line =~ m{\A *[\+\- ]+\Z}) {
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
  $order = $#hm + 1;
  if ($file ne "-") {
    close(STDIN);
  }
} # read_hm
#----
sub gen { # (method); fill @hm
  my ($method) = @_;
  @hm = ();
  my @row  = ();
  if (0) {
  } elsif ($method =~ m{paley(I|1)\Z}i) {
  #--------
    &legendre($order - 1);
    for (my $icol = 0; $icol < $order; $icol ++) { # row 0 = ones
      push(@row, 1);
    } # for $icol
    push(@hm, [ @row ]);
    for (my $irow = 0; $irow < $order - 1; $irow ++) { # rows 1..order = Legendre symbols (skew)
      @row = (0); # column 0 = 0 (originally -1)
      for (my $icol = 0; $icol < $order - 1; $icol ++) {
        my $elem = $chi[$irow - $icol]; 
        if ($irow == $icol) {
          $elem = 1;
        }
        push(@row, $elem);
      } # for $icol
      push(@hm, [ @row ]);
    } # for $irow
  #--------
  } else {
    die "unknown method $method\n";
  }
} # gen
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

