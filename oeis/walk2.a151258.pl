#!perl

# 2019-06-23, Georg Fischer
# (Mathematica)

use strict;
use integer;
use List::Util qw[min max];
use Math::BigInt;
use Math::BigInt':constant';

# my $n = Math::BigInt->new(1);
my %cube;
my ($i, $j, $k, $n);
$n = 0;
for ($k = 0; $k <= 100; $k ++) {
    my $sum = 0;
    for ($i = 0; $i <= $k; $i ++) {
        for ($j = 0; $j <= $k; $j ++) {
            $sum += &aux($i, $j, $k);
        } # for $j
    } # for $i
    print "$n $sum\n";
    $n ++;
} # for $k
#--------
sub aux {
    my ($i, $j, $k) = @_;
    my $result;
    if (defined(  $cube{"$i,$j,$k"})) {
        $result = $cube{"$i,$j,$k"};
    } else {
        $result = Math::BigInt->new(0);
        if (0) {
        } elsif (min($i, $j, $k) < 0 or max($i, $j) > $k) {
            $result = Math::BigInt->new(0);
        } elsif ($k == 0) {
            $result = Math::BigInt->new(($i == $j and $j == $k) ? 1 : 0);
        } else {
            $result 
            = &aux(-1 + $i,  1 + $j, -1 + $k) 
            + &aux(     $i, -1 + $j, -1 + $k) 
            + &aux( 1 + $i, -1 + $j, -1 + $k) 
            + &aux( 1 + $i,  1 + $j, -1 + $k)
            ;
        }
        $cube{"$i,$j,$k"} = $result;
    }
    # print "aux($i, $j, $k) = $result\n";
    return $result;
} # aux
__DATA__
# A151258 Number of walks within N^2 (the first quadrant of Z^2) starting at (0,0) 
# and consisting of n steps taken from {(-1, -1), (-1, 1), (0, 1), (1, -1)}
# MMA:
(* KroneckerDelta[n1, n2, ...] gives the Kronecker delta, 
   equal to 1 if all the ni are equal, and 0 otherwise.
*)
aux[i_Integer, j_Integer, n_Integer] := Which
[ Min[i, j, n] < 0 || Max[i, j] > n, 0
, n == 0, KroneckerDelta[i, j, n]
, True, aux[     i,      j,      n] 
      = aux[-1 + i,  1 + j, -1 + n] 
      + aux[     i, -1 + j, -1 + n] 
      + aux[ 1 + i, -1 + j, -1 + n] 
      + aux[ 1 + i,  1 + j, -1 + n]
]; 
Table[Sum[aux[i, j, n], {i, 0, n}, {j, 0, n}], {n, 0, 25}]

------------------
# A147999 Number of walks within N^3 (the first octant of Z^3) starting at (0,0,0) 
# and consisting of n steps taken from {(-1, -1, -1), (-1, -1, 1), (-1, 1, 0), (1, 0, 0)}
# MMA:
aux[i_Integer, j_Integer, k_Integer, n_Integer] := Which
[Min[i, j, k, n] < 0 || Max[i, j, k] > n, 0
, n == 0, KroneckerDelta[i, j, k, n]
, True, aux[     i,      j,      k,      n] 
      = aux[-1 + i,      j,      k, -1 + n] 
      + aux[ 1 + i, -1 + j,      k, -1 + n] 
      + aux[ 1 + i,  1 + j, -1 + k, -1 + n] 
      + aux[ 1 + i,  1 + j,  1 + k, -1 + n]
]; Table[Sum[aux[i, j, k, n], {i, 0, n}, {j, 0, n}, {k, 0, n}], {n, 0, 10}]

A151238
C:\Users\User\work\gits\OEIS-mat\contrib>perl a151258.pl
0 1
1 1
2 2
3 4
4 12
5 28
6 86
7 228
8 736
9 2070
10 6868
11 20212
12 68300
13 207620
14 711694
15 2217096
16 7683384
17 24405062
18 85318256
19 275290932
20 969323508
21 3168559356
22 11223800316
23 37092325140
24 132060026316
25 440527174396
26 1575294513724
27 5297495810812
28 19015832114996
29 64400390557052
30 231947048982446
31 790430109713200
32 2855318303724920
33 9784298708618454
34 35438371918665448
35 122038559268824740
36 443075689660059108
37 1532623504100334884
38 5576402237374374968
39 19367029709294767228
40 70604807545129482204
41 246114343208288860280
42 898849739182600935420
43 3143739802934631408116
44 11500358452830071089844
45 40346705728027246389852
46 147819261754572908551276
47 520067526741471955774836
48 1908055560813041235554204
49 6730676399203076894719004
50 24726013033010206004646668
51 87433549864514717287499532
52 321586754858430939403888244
53 1139737117833090599217590524
54 4196759257825392821459211484
55 14905170267236980830785435700
56 54941921427869631916579040340
57 195516537865549423674429902924
58 721405143365372034234183760204
59 2571945892694775466455816565716
60 9498617217872970575991970726484
61 33923223065807755139011774247228
62 125393446234400554641845850644158

C:\Users\User\work\gits\OEIS-mat\contrib>