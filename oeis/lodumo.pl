#!perl

# lodumo.pl - transform
# 2019-02-15, Georg Fischer: adapted from Maple 
use strict;

my $m = 2;
# my @list = 
# 	( 0, 4, 19, 54, 124, 250, 459, 784, 1264, 1944
# 	, 2875, 4114, 5724, 7774, 10339, 13500, 17344, 21964
# 	, 27459, 33934, 41500, 50274, 60379, 71944, 85104
# 	, 100000, 116779, 135594, 156604, 179974, 205875
# 	, 234484, 265984, 300564, 338419, 379750, 424764)
# 	;
my @a = ();

my @list = ();
while (<>) { # read a b-file
	next if m{\A\s*\#};
	next if m{\A\s*\Z};
	m{\A\s*\d+\s+(\d+)};
	push(@list, $1);
} #  while <>

# print a b-file

my @a = &lodumo($m, @list);
for (my $n = 0; $n < scalar(@list); $n ++) {
	print "$n $a[$n]\n";
} # for

sub lodumo { #  Georg Fischer, Feb 15 2019
    my ($m, @list) = @_;
    my @a = ();
    my $il = 0;
    while ($il < scalar(@list)) {
        my $busy = 1;
        my $an = $list[$il] % $m; 
        while ($busy == 1) {
            if (scalar(grep {$_ == $an} @a) == 0) {
                push(@a, $an);
                $busy = 0;
            }
            $an += $m;
        } # while $busy
        $il ++;
    } # while
    return @a;
} # sub lodumo

__DATA__
# from <https://oeis.org/transforms.txt>:
#
# Deleham's Lodumo_m transform of a sequence L.
# The list a(n) is returned and defined by the smallest number not yet in
# the list a(.) satisfying a(n)=L(n) (mod m).
# @param L the input list of non-negative numbers 
# @param m  the remainder of the modulo operation. This is  only useful
#           if it's a number larger than 1.
# @return the sequence of nonnegative numbers a(n)
#
# Example: generate A160016 from A159833:
#     A159833 := [seq(n^2*(n^2+15)/4,n=0..100) ];
#     LODUMO(A159833,2) ;
#
# Example: generate A160081 from A000045:
#     A000045 := [combinat[fibonacci](n),n=0..100) ];
#     LODUMO(A000045,5) ;
#
# Richard J. Mathar, 2009-04-30
LODUMO := proc(L,m)
	local a,n, an;
	if not type(L,'list') then
		ERROR("Expected list type argument instead of ",whattype(L) ) ;
	end if;
	a := [] ;
	for n from 1 to nops(L) do
		for an from op(n,L) mod m by m do
			if not an in a then
				a := [op(a),an] ;
				break;
			fi;
		od:
	end do;
	a ;
end proc:
