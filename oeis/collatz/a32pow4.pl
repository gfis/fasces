#!perl

# Determine positions of powers of 4
# 2020-10-14, Georg Fischer

use integer; 
use strict;
my $n = 1;
my $limit = shift(@ARGV); 
my $index = 1;
my $pow4 = 1;
my $min4 = 0;
my $an;
my $irow = 1;
my $alert = 0;
while ($n < $limit) {
  $an = 4 * $irow - 1; 
  &output();
  while ($an % 3 == 0) {
    $an /= 3; 
    if ($an == $pow4) {
      print "* ";
      $min4 = $pow4;
      $pow4 *= 4;
      $alert = 1;
      exit(1) if $pow4 <= 0;
    }
    &output();
    $an *= 2; 
    &output();
  } 
  $irow ++;
} # while limit
#----
sub output {
  if ($alert) {
    print "$index $an \n";
    $alert = 0;
  } else {
    if ($min4 >= $an) {
      print "assertion failed: $min4 >= $an\n";
    }
  }
  $n ++;
  $index ++;
}
__DATA__
16 4  <--
126 16  <--
1100 64  <--
9850 256  <--
88584 1024  <--
797174 4096  <--
7174468 16384  <--
64570098 65536  <---

16
126
1100
9850
88584
797174
7174468
64570098
581130752

16,126,1100,9850,88584,797174,7174468,64570098

Out[1]= {16, 126, 1100, 9850, 88584, 797174, 7174468, 64570098}
In[3]:= FindGeneratingFunction[Out[1]]
Out[3]= (-2*(8 - 25*#1 + 9*#1^2))/((-1 + #1)^2*(-1 + 9*#1)) &
In[4]:= FindLinearRecurrence[Out[1]]
Out[4]= {11, -19, 9}

16, 126, 1100, 9850, 88584, 797174, 7174468, 64570098, 581130752, 5230176622, 47071589436, 423644304746, 3812798742520, 34315188682470, 308836698142004, 2779530283277794, 25015772549499888, 225141952945498718, 2026277576509488172, 18236498188585393242, 164128483697268538856

f:= gfun:-rectoproc({a(n)=11*a(n-1)-19*a(n-2)+9*a(n-3), a(0)=16, a(1)=126, a(2)=1100}, a(n), remember): map(f, [$0..20]);

my(x='x+O('x^20)); Vec(2*(8-25*x+9*x^2)/((1-x)^2*(1-9*x)))