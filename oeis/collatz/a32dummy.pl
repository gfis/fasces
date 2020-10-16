use integer; my $n = 1; my $i = 1; 

  while ($i <= 1000) { # next row 

    my $an = 4 * $i - 1; print "$n $an\n"; $n ++;

    while ($an % 3 == 0) {

      $an /= 3; print "$n $an\n"; $n ++;

      $an *= 2; print "$n $an\n"; $n ++;

    } # while divisible by 3

    $i ++;

  } # while next row / ~~~~
  