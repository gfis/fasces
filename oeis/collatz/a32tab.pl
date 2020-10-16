use integer; use strict;
my $n = 1; my $i = 1; my $limit = shift(@ARGV); while ($i < $limit) {
  my $an = 4 * $i - 1; print "$an"; $n ++;
  while ($an % 3 == 0) {
    $an /= 3; print " $an"; $n ++;
    $an *= 2; print " $an"; $n ++;
  } $i ++; 
  print "\n";
} # A323232.pl, Georg Fischer Dec. 9 2018 
