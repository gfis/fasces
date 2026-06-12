#!perl

# hadamat.pl - operations on Hadamard matrices
# @(#) $Id$
# 2026-06-11: non-square matrices, +1/0/-1, product, slice; +ML=10
# 2026-06-08: copied from hamop.pl; only 1 matrix, no oper4; *FP=12; *RP=78
# 2024-08-10, Georg Fischer
#:#
#:# Usage:
#:#   perl hadamat.pl [-d debug] arg1 arg2 ...
#:#     coltest            test columns for 1/2 condition and show triangle
#:#     debug    mode      0=none, 1=some, 2=more debugging output
#:#     dump<i>            write terms in "1-" format, optionally separate in <i> subblocks
#:#     gen      method    generate a Hadamard matrix with method
#:#     help               print usage info
#:#     legendre p         compute the legendre symbols (a/p) for a=0..p-1 (p prime), with debug >= 1
#:#     order    n         specify the desired order for gen (must be a multiply of 4)
#:#     ortest             test rows and columns for 1/2 condition and show summary only
#:#     product            Kronecker product hma = hma (x) hmb (after push)
#:#     push               copy the accumlator hma to the auxiliary matrix hmb
#:#     read     file      read a matrix in "sage", "10", "1-" or "+-" format
#:#     rowtest            test rows for 1/2 condition and show triangle
#:#     slice    rxc,hxw   extract a submatrix height x width at upper left corner row x col (implies push)
#:#     write    file      write hma in "1-0" format
#:#     svg                generate an SVG file
#:#
#:# Input formats may be either:
#:#   sage                 [1,-1 ...
#:#   +-                   only "+" for +1, "-" for -1
#:#   1-                   1 and -1 for -1
#:#   10                   1 and 0 for -1
#:#
#:# Generation methods:
#:#   paley1, paleyI
#:#   paley2, paleyII
#:#   sylvester            doubling (implies push)
#--------
# Internally the matrices are represented by $POS1 (1) and $NEG1 (0).
# Multiplication and division of 1/-1 elements is replaced by "coincides" (not differs, not xor) of 1/0 elements,
# and negation ix replaced by xor with 1,
# according to the following table:
#  a  b  a*b  a/b  -a | a  b  a xor b  a coin b  1 xor a
# -1 -1   1    1    1 | 0  0     0        1         1
# -1  1  -1   -1    1 | 0  1     1        0         1
#  1 -1  -1   -1   -1 | 1  0     1        0         0
#  1  1   1    1   -1 | 1  1     0        1         0
#
# C.f.
# https://en.wikipedia.org/wiki/Hadamard_matrix
# https://en.wikipedia.org/wiki/Paley_construction -> Jacobsthal matrix
# https://en.wikipedia.org/wiki/Legendre_symbol
# https://www.cs.ox.ac.uk/teaching/courses/projects/sample/3rdYear/Implementing%20Hadamard%20Matrices%20in%20SageMath.pdf
#
# The method paley1 yields skew matrices for order/4 =
# 1,2,3,5,6,8,11,12,15,17,18,20,21,26,27,32,33,35,38,41,42,45,48,50,53,56,57,60,63 ...
# -> OEIS A005099: Numbers k such that 4*k - 1 is prime.
#--------
use strict;
use warnings;
use integer;

my $POS1   = +1; # 1st sort of matrix element
my $NEG1   = -1; # 2nd sort of matrix element
my $NULL   =  0; # 3rd sort of matrix element (from Legendre symbol)
my $debug  = 0;
my $oper   = "help";
my $sep    = "";
my $method = "paleyI";
my $order  = 8; # from GF(7)
if (scalar(@ARGV) == 0) {
  &help();
  exit;
}
my $letters = "=abcdefghijklmnopqrstuvwxyz"; # for rowtest, coltest
my @hma      = (); # accumulator   matrix
my @hmb      = (); # 1st auxiliary matrix
my @hmc      = (); # 2nd auxiliary matrix
my @hm0      = (); # matrix for 0 elements in product
my @chi; # stores the Legendre symbols of (n/p) for n=0..p-1
my %squares; # maps n -> sqrt(n)
for my $n (0..100) {
  $squares{$n**2} = $n;
}

while (scalar(@ARGV) > 0) {
  $oper = shift(@ARGV);
  if (0) {
  } elsif ($oper =~ m{\Acolt(est)?}     ) { &coltest    (1);
  } elsif ($oper =~ m{\Adebug}          ) { $debug     = shift(@ARGV);
  } elsif ($oper =~ m{\Adump\d*}        ) { &dump_hm    ($oper);
  } elsif ($oper =~ m{\Agen}            ) { &gen        (shift(@ARGV));
  } elsif ($oper =~ m{\Ahelp}           ) { &help       ();
  } elsif ($oper =~ m{\Alegendre}       ) { &legendre   (shift(@ARGV));
  } elsif ($oper =~ m{\Amul(t(iply)?)?} ) { &product    ();
  } elsif ($oper =~ m{\Aorder}          ) { $order =     shift(@ARGV);;
  } elsif ($oper =~ m{\Apr(od(uct)?)?}  ) { &product    ();
  } elsif ($oper =~ m{\Aort(est)?}      ) { &ortest     ();
  } elsif ($oper =~ m{\Apush}           ) { &push_hm    ();
  } elsif ($oper =~ m{\Aread}           ) { &read_hm    (shift(@ARGV));
  } elsif ($oper =~ m{\Arowt(est)?}     ) { &rowtest    (1);
  } elsif ($oper =~ m{\Aslice}          ) { &slice      (shift(@ARGV));
  } elsif ($oper =~ m{\Awrite}          ) { &write_hm   (shift(@ARGV));
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
sub legendre { # parameter: p; compute @chi for prime p
  # from https://en.wikipedia.org/wiki/Paley_construction
  my ($q) = @_;
  @chi = ($NULL); # [0] is always 0
  for (my $a = 1; $a <= $q - 1; $a ++) {
    my $result = $NEG1; # assume non-square
    my $busy = 1;
    my $b = 1;
    while ($busy == 1 && $b < $q) {
      my $b2 = $b**2;
      if ($debug >= 2) {
        print "a=$a, busy=$busy, result=$result, b=$b, b2=$b2, q=$q, b2 % q= " . ($b2 % $q) . "\n";
      }
      if ($b2 % $q == $a) { # quadratic residue found
        $busy = 0;
        $result = $POS1;
      }
      $b++;
    }
    push(@chi, $result);
  } # for $a
  if ($debug >= 1) { 
    # print join(" ", @chi) . "\n";
    my $orig = join("", map { my $a = $_;           $a =~ s{\-1}{\-}; $a } @chi);
    my $nega = join("", map { my $a = $_; $a *= -1; $a =~ s{\-1}{\-}; $a } @chi);
    print "original: " . $orig          . "\n";
    print "negated : " . $nega          . "\n";
    print "orig rev: " . reverse($orig) . "\n";
    print "neg  rev: " . reverse($nega) . "\n";
  }
} # legendre
#----
sub eval_sums { # evaluate the sum of coincidences minus the sum of differences; "=" if both sums are equal.
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
} # eval_sums

sub rowtest { # (show); test all pairs of rows whether one half of the columns is coincident and one half is not
  my ($show) = @_;
  my $result = 1;
  my $rowlen = scalar(@hma);
  my $collen = $#{$hma[0]} + 1;
  if ($show > 0) {
    print "# rowtest: $rowlen x $collen\n";
  }
  for (my $irow0 = 0; $irow0 < $rowlen - 1; $irow0 ++) {
    if ($show > 0) {
      print " " . (" " x $irow0);
    }
    for (my $irow1 = $irow0 + 1; $irow1 < $rowlen; $irow1 ++) {
      my $iscoin = 0; # number of coincidences
      my $nocoin = 0; # number of non-coincidences
      for (my $icol = 0; $icol < $collen; $icol ++) {
        if ($hma[$irow0][$icol] == $hma[$irow1][$icol]) {
          $iscoin ++;
        } else {
          $nocoin ++;
        }
      } # for $icol
      if ($show > 0) {
        print &eval_sums($iscoin - $nocoin);
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

sub coltest { # (show); test all pairs of columns whether one half of the rows is coincident and one half is not
  my ($show) = @_;
  my $result = 1;
  my $rowlen = scalar(@hma);
  my $collen = $#{$hma[0]} + 1;
  if ($show > 0) {
    print "# coltest: $rowlen x $collen\n";
  }
  for (my $icol0 = 0; $icol0 < $collen - 1; $icol0 ++) {
    if ($show > 0) {
      print " " . (" " x $icol0);
    }
    for (my $icol1 = $icol0 + 1; $icol1 < $collen; $icol1 ++) {
      my $iscoin = 0; # number of coincidences
      my $nocoin = 0; # number of non-coincidences
      for (my $irow = 0; $irow < $rowlen; $irow ++) {
        if ($hma[$irow][$icol0] == $hma[$irow][$icol1]) {
          $iscoin ++;
        } else {
          $nocoin ++;
        }
      } # for $irow
      if ($show > 0) {
        print &eval_sums($iscoin - $nocoin);
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
  print "# orthogonality test: " . (($sum == 2) ? "ack" : "NAK") . ", order $order = 4*" . ($order/4) . "\n";
} # ortest
#----
sub dump_hm { # write matrices as binary digits 0,1
  my ($name) = @_;
  my $rowlen = scalar(@hma);
  my $collen = $#{$hma[0]} + 1;
  my $block_len = 19470629; # very high - avoid separting lines
  if ($name =~ m{dump(\d+)}) {
    my $div = $1;
    $block_len = $rowlen / $div;
  }
  print "# dump: $rowlen x $collen\n";
  for (my $irow = 0; $irow < $rowlen; $irow ++) {
    if ($irow > 0 && $irow % $block_len == 0) {
      print "\n";
    }
    for (my $icol = 0; $icol < $collen; $icol ++) {
      if ($icol > 0) {
        print $sep;
      }
      my $ch = $hma[$irow][$icol];
      if ($ch == $NEG1) {
        $ch = "-";
      } # else $POS1 remains unchanged
      if ($icol > 0 && $icol % $block_len == 0) {
        print " ";
      }
      print $ch;
    } # for $icol
    print "\n";
  } # for $irow
} # dump_hm
#----
sub push_hm { # copy hma to hmb
  @hmb = ();
  my $rowlen = scalar(@hma);
  my $collen = $#{$hma[0]} + 1;
  for (my $irow = 0; $irow < $rowlen; $irow ++) {
    my @row = ();
    for (my $icol = 0; $icol < $collen; $icol ++) {
      push(@row, $hma[$irow][$icol]);
    }
    push(@hmb, [ @row ]);
  } # for $irow
  if ($debug >= 1) {
    print "# hma $rowlen x $collen copied to hmb\n";
  }
} # push_hm
#----
sub slice { # slice    rxc,hxw   extract a submatrix height x width at upper left corner row x col (zero based, implies push)
  my ($geom) = @_;
  my ($start, $block)   = split(/\,/, $geom);
  my ($rowsta, $colsta) = split(/x/ , $start);
  my ($height, $width)  = split(/x/ , $block);
  my $rowlen = scalar(@hma);
  my $collen = $#{$hma[0]} + 1;
  if ($debug >= 1) {
    print "# slice $rowsta x $colsta, $height x $width\n";
  }
  &push_hm();
  @hma = ();
  for (my $irow = $rowsta; $irow < $rowsta + $height; $irow ++) {
    my @row = ();
    for (my $icol = $colsta; $icol < $colsta + $width; $icol ++) {
      push(@row, $hmb[$irow][$icol]);
    }
    push(@hma, [ @row ]);
  } # for $irow
} # slice
#----
sub read_hm { # read an array of binary matrices from a file and generate a 0/1-matrix
  my ($file) = @_;
  open(SRC, "<", $file) or die "#** hadamat.pl: cannot read \"$file\"\n";
  @hma = ();
  my $first = 1;
  my $informat = "sage";
  while(<SRC>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($debug >= 1) {
      print "# read: $line\n";
    }
    if (($line =~ m{\A\s*\#}) || ($line =~ m{plane}) || ($line =~ m{\A\s*\Z}) || ($line =~ m{\A\[?[\+\- ]*\]})) {
      # ignore comment or plane header or empty or sage separator lines
      next;
    }
    if ($first) { #determine input format from first line: "sage", "10", "+-", "1-"
      $first = 0;
      if (0) {
      } elsif ($line =~ m{\A *\[ *\-?1}) { # raw Sage output
        $informat       = "sage";
      } elsif ($line =~ m{\A[0\+\- ]+\Z}) { # 0+-
        $informat       = "0+-";
      } elsif ($line =~ m{\A[10\- ]+\Z})  { # 10-
        $informat       = "10-";
      } elsif ($line =~ m{\A[10 ]+\Z})    { # 10-
        $informat       = "10";
      } else {
        die "#** hadamat.pl: cannot recognize input format of \"$line\"\n";
      }
    } # if first
    my $found = 0;
    if (0) {
    } elsif ($informat eq "sage") {
      if (     $line =~ m{\A *\[? \+*\-?1}) {
        $line =~ s{\+1}{1}g;
        $line =~ s{\-1}{-}g;
        $line =~ s{[^10\-]}{}g; # remove any other characters
        $found = 1;
      }
    } elsif ($informat eq "0+-") {
      if (     $line =~ m{\A[\+\- ]+\Z}) {
        $line =~ s{[^0\+\-]}{}g; # remove any other characters
        $line =~ tr{\+}{1};
        $found = 1;
      }
    } elsif ($informat eq "10-") {
      if (    $line =~ m{\A[10\- ]+\Z}) {
        $line =~ s{[^10\-]}{}g; # remove any other characters
        $found = 1;
      }
    } elsif ($informat eq "10") { # never reached, maybe later if explicitly specified
      if (    $line =~ m{\A[10 ]+\Z}) {
        $line =~ s{[^10]}{}g; # remove any other characters
        $line =~ s{0}{\-}g; # such "0" means $NEG1
        $found = 1;
      }
    }
    if ($debug >= 2) {
      print "# read: found= $found, informat=$informat, line=$line\n";
    }
    if ($found) {
      my @row = map { ($_ eq "-") ? -1 : $_ } split(//, $line);
      push(@hma, [ @row ]);
    }
  } # while <STDIN>
  close(SRC);
  if (scalar(@hma) != $#{$hma[0]}) {
    print STDERR "# read: non-square matrix: " . scalar(@hma) . " x " . ($#{$hma[0]} + 1) . "\n";
  }
  $order = scalar(@hma);
} # read_hm
#----
sub write_hm { # write hma in "1-0" format to the specified file
  my ($file) = @_;
  my $rowlen = scalar(@hma);
  my $collen = $#{$hma[0]} + 1;
  open(TAR, ">", $file) or die "#** hadamat.pl: cannot write \"$file\"\n";
  for (my $irow = 0; $irow < $rowlen; $irow ++) {
    for (my $icol = 0; $icol < $collen; $icol ++) {
      my $ch = $hma[$irow][$icol];
      if ($ch == $NEG1) {
        $ch = "-"; 
      } # else $POS1 and 0 remain unchanged
      print TAR $ch;
    } # for $icol
    print TAR "\n";
  } # for $irow 
  close(TAR);
} # write_hm
#----
sub product { # multiply, Kronecker product C = A (x) B; for 0 take from hm0 instead of hmb
  my $rowlena = scalar(@hma);
  my $collena = $#{$hma[0]} + 1;
  my $rowlenb = scalar(@hmb);
  my $collenb = $#{$hmb[0]} + 1;
  $order = $rowlena * $rowlenb;
  @hmc = ();
  for (my $irow = 0; $irow < $order; $irow ++) {
    my @row = ();
    for (my $icol = 0; $icol < $order; $icol ++) {
      my $elema = $hma[$irow / $rowlenb][$icol / $collenb];
      my $elemb = $hmb[$irow % $rowlenb][$icol % $collenb];
      my $elemc = $elema != 0
          ? $elema * $elemb
          : $hm0[$irow % $rowlenb][$icol % $collenb]
          ;
      push(@row, $elemc);
    } # for icol
    push(@hmc, [ @row ]);
  } # for irow
  @hma = @hmc;
} # product
#----
sub jacobsthal { # compute J = ((0, j transposed), (-j, Q)), used by paley{1|2}
    @hma = ();
    &legendre($order - 1);
    if ($debug >= 1) {
      print "# jacobsthal $order x $order\n";
    }
    my @row = ($NULL); # [0,0] = 0
    for (my $icol = 1; $icol < $order; $icol ++) { # row 0 = ones
      push(@row, $POS1);
    } # for $icol
    push(@hma, [ @row ]); # top row

    for (my $irow = 1; $irow < $order; $irow ++) { # rows 1..order = Legendre symbols (skew)
      @row = ($POS1); # column 0
      for (my $icol = 1; $icol < $order; $icol ++) { # compute the Jacobsthal matrix Q
        my $elem = $chi[$irow - $icol];
        if ($irow == $icol) { # on the diagonal
          $elem = $NULL;
        }
        push(@row, $elem);
      } # for $icol
      push(@hma, [ @row ]);
    } # for $irow
} # jacobsthal
#----
sub gen { # (method); fill @hma
  my ($method) = @_;
  if ($debug >= 1) {
    print "# gen $method $order x $order\n";
  }
  my @row;
  if (0) {
  #--------
  } elsif ($method =~ m{paley(I|1)\Z}i) {
    &jacobsthal();
    for (my $irow = 0; $irow < $order; $irow ++) { # rows 1..order = Legendre symbols (skew)
      $hma[$irow][0] = $NEG1; # column 0 = -1;
      $hma[$irow][$irow] = $POS1; # identity matrix -> diagonal
    } # for $irow
  #--------
  } elsif ($method =~ m{paley(II|2)\Z}i) {
  	$order /= 2;
    &jacobsthal();
    @hmb = ();
    push(@hmb, [ ( 1, 1) ]);
    push(@hmb, [ ( 1,-1) ]);
    @hm0 = ();
    push(@hm0, [ ( 1,-1) ]);
    push(@hm0, [ (-1,-1) ]);
    &product();
  #--------
  } elsif ($method =~ m{\Asyl}i) { # Sylvester
    &push_hm();
    my $rowlen = scalar(@hmb);
    my $collen = $rowlen; # matrix must be quadratic
    $order = 2*$rowlen;
    @hma = ();
    for (my $irow = 0; $irow < $order; $irow ++) {
      my @row = ();
      for (my $icol = 0; $icol < $order; $icol ++) {
        my $elem = $hmb[$irow % $rowlen][$icol % $collen]; # take it from upper left block
        if ($irow >= $rowlen && $icol >= $collen) {      # negate it for lower right block
          $elem = -$elem; # NEGATE
        }
        push(@row, $elem);
      } # for $icol
      push(@hma, [ @row ]);
    } # for $irow
  #--------
  } else {
    die "#** hadamat.pl: unknown method \"$method\"\n";
  }
} # gen
#----
__DATA__
planes[ 9 ] (Sage format)
[ 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1| 1  1]
[ 1 -1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1|-1  1]
[-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----]
[ 1 -1| 1 -1| 1  1| 1  1|-1 -1| 1  1|-1 -1|-1 -1|-1 -1| 1  1| 1  1|-1 -1|-1 -1|-1 -1| 1  1|-1 -1| 1  1| 1  1]
[ 1  1|-1 -1| 1 -1| 1 -1|-1  1| 1 -1|-1  1|-1  1|-1  1| 1 -1| 1 -1|-1  1|-1  1|-1  1| 1 -1|-1  1| 1 -1| 1 -1]
[-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----]
[ 1 -1| 1  1| 1 -1| 1  1| 1  1|-1 -1| 1  1|-1 -1|-1 -1|-1 -1| 1  1| 1  1|-1 -1|-1 -1|-1 -1| 1  1|-1 -1| 1  1]

