# derived from A322469
  use integer; my $n = 1; my $i = 1; my $an; my $limit = shift(@ARGV);
  while ($i <= $limit) { # next row
    $an = 4 * $i - 1; &term();
    while ($an % 3 == 0) {
      $an /= 3; &term();
      $an *= 2; &term();
    } # while divisible by 3
    $i ++;
  } # while next row
  sub term {
    if (($an + 2) % 6 == 0) {
      my $bn = ($an + 2) / 6;
      print "$n $bn\n"; $n ++;
    }
  }
