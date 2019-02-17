#!perl

# When do  mod 3 and mod 8 sequences meet?
# 2019-02-17, Georg Fischer

use strict;
use integer; 

my $an1 = 1; 
my $an2 = 2;
my $ind = 0; 
while ($ind < 100000) {
    my $mask = 0;
    if ($an1 % 6 == 4 and $an1 % 8 == 2) {
        $mask |= 1;
    }
    my $rig = " ";
    if ($an2 % 6 == 4 and $an2 % 3 == 1) {
        $mask |= 2;
    }
    if ($mask > 0) {
        print sprintf("%6d: %s%6d %3s%6d%s\n"    , $ind
            , (($mask & 1) == 1 ? ">"   : " ") 
            , $an1
            , (($mask & 3) == 3 ? "===" : "   ")
            , $an2
            , (($mask & 2) == 2 ? "<"   : " ")
            );
    } else {
        print sprintf("%6d: %s%6d %3s%6d%s\n"    , $ind
            , " "
            , $an1
            , "   "
            , $an2
            , " "
            );
    }
    $an1 += 3;
    $an2 += 8;
    $ind ++; 
} # while $ind
__DATA__
>    4     10<
>   10     26
    13     34<
>   16     42
>   22     58<
>   28     74
    31     82<
>   34     90
>   40    106<
>   46    122
    49    130<
>   52    138
>   58    154<
>   64    170
    67    178<
>   70    186
>   76    202<
>   82    218
    85    226<
>   88    234
>   94    250<
>  100    266
   103    274<
>  106    282
>  112    298<
>  118    314
   121    322<
>  124    330
>  130    346<
>  136    362
   139    370<
>  142    378
>  148    394<
>  154    410
   157    418<
>  160    426
>  166    442<
>  172    458
   175    466<