#!perl
# a(1) = 1; for n > 1, a(n) = 100*a(n - 1) + 22*n - 21
use strict;

my @a = (0,1);
for (my $n = 2; $n < 1000; $n ++) {
	$a[$n] = 100 * $a[$n - 1] + 22 * $n - 21;
	print "$n $a[$n]\n";
}
__DATA__
0 0
1 1                                            1 1                       
2 12                                           2 123                     
3 123                                          3 12345                   
4 1234                                         4 1234567                 
5 12345                                        5 123456789               
6 123456                                       6 12345679011             
7 1234567                                      7 1234567901233           
8 12345678                                     8 123456790123455         
9 123456789                                    9 12345679012345677       
10 1234567900                                  10 1234567901234567899    
11 12345679011                                 11 123456790123456790121  
12 123456790122                                12 12345679012345679012343
13 1234567901233                                  12345679012345679012343
14 12345679012344
15 123456790123455
16 1234567901234566
17 12345679012345677
18 123456790123456788
19 1234567901234567899
20 12345679012345679010
21 123456790123456790121
22 1234567901234567901232
23 12345679012345679012343
24 123456790123456790123454
25 1234567901234567901234565
26 12345679012345679012345676
27 123456790123456790123456787
28 1234567901234567901234567898