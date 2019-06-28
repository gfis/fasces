#!perl
#
# BasicSwingFactorial
# @(#) $Id$
# 2019-04-15, Georg Fischer: rewritten from Julia module of Peter Luschny (cf. below, behind _DATA_)
#
# Usage:
#   perl BasicSwingFactorial -n number [-d debug]
#--------------------------------------------
use strict;
use integer;
use Math::BigInt;
use Math::BigInt':constant'; # $a[$n] = Math::BigInt->new(1);
# get options

my $debug = 1;
my @smallOddFactorial =             ( "0", "0x0000000000000000000000000000001"
    , "0x0000000000000000000000000000001", "0x0000000000000000000000000000001"
    , "0x0000000000000000000000000000003", "0x0000000000000000000000000000003"
    , "0x000000000000000000000000000000f", "0x000000000000000000000000000002d"
    , "0x000000000000000000000000000013b", "0x000000000000000000000000000013b"
    , "0x0000000000000000000000000000b13", "0x000000000000000000000000000375f"
    , "0x0000000000000000000000000026115", "0x000000000000000000000000007233f"
    , "0x00000000000000000000000005cca33", "0x0000000000000000000000002898765"
    , "0x00000000000000000000000260eeeeb", "0x00000000000000000000000260eeeeb"
    , "0x0000000000000000000000286fddd9b", "0x00000000000000000000016beecca73"
    , "0x000000000000000000001b02b930689", "0x00000000000000000000870d9df20ad"
    , "0x0000000000000000000b141df4dae31", "0x00000000000000000079dd498567c1b"
    , "0x00000000000000000af2e19afc5266d", "0x000000000000000020d8a4d0f4f7347"
    , "0x000000000000000335281867ec241ef", "0x0000000000000029b3093d46fdd5923"
    , "0x0000000000000465e1f9767cc5866b1", "0x0000000000001ec92dd23d6966aced7"
    , "0x0000000000037cca30d0f4f0a196e5b", "0x0000000000344fd8dc3e5a1977d7755"
    , "0x000000000655ab42ab8ce915831734b", "0x000000000655ab42ab8ce915831734b"
    , "0x00000000d10b13981d2a0bc5e5fdcab", "0x0000000de1bc4d19efcac82445da75b"
    , "0x000001e5dcbe8a8bc8b95cf58cde171", "0x00001114c2b2deea0e8444a1f3cecf9"
    , "0x0002780023da37d4191deb683ce3ffd", "0x002ee802a93224bddd3878bc84ebfc7"
    , "0x07255867c6a398ecb39a64b83ff3751", "0x23baba06e131fc9f8203f7993fc1495"
    );

    sub oddProduct { my ($m, $len) = @_;
        if ($len < 24) {
            my $p = Math::BigInt->new($m);
            my $k = 2;
            while ($k <= 2 * ($len - 1)) { # for k in 2:2:2(len-1) { ???
                $p->bmul(Math::BigInt->new($m)->bsub(Math::BigInt->new($k)));
                $k += 2;
            } # for $k
            return $p->copy();
        } else {
            my $hlen = $len >> 1;
            return &oddProduct($m->bsub(2)->bmul($hlen), $len - $hlen)->bmul(&oddProduct(Math::BigInt->new($m), $hlen));
        }
    } # oddProduct

    sub oddFactorial { my ($n) = @_;
        my ($sqrOddFact, $oddFact, $oldOddFact);
        print "oddFactorial(n) with n=$n" if $debug >= 1;
        if ($n < scalar(@smallOddFactorial) - 1) { # 41
        	  print ", then part\n" if $debug >= 1;
            $oddFact    = Math::BigInt->from_hex($smallOddFactorial[1 + $n]);
            $sqrOddFact = Math::BigInt->from_hex($smallOddFactorial[1 + $n / 2]);
        #   $oddFact    =                  ($smallOddFactorial[$n]);
        #   $sqrOddFact =                  ($smallOddFactorial[$n / 2]);
        } else {
        	  print ", else part\n" if $debug >= 1;
            ($sqrOddFact, $oldOddFact) = &oddFactorial($n / 2);
            my $len = ($n - 1) / 4;
            if ($n % 4 != 2) {
                $len ++;
            }
            my $high = $n - (($n + 1) & 1);
        #   high = n - ((n + 1) & 1)
        #   oddSwing = div(oddProduct(high, len), oldOddFact)
        #   oddFact = sqrOddFact^2 * oddSwing
            my $oddSwing = &oddProduct($high, $len)->btdiv($oldOddFact);
            $oddFact  = $sqrOddFact->bpow(2)->bmul($oddSwing);
        }
        return ($oddFact->copy(), $sqrOddFact->copy());
    } # oddFactorial
            
    sub SwingFactorial { my ($n) = @_;
        my $result;
        if ($n < 0) {
            print STDERR "n must be ≥ 0\n";
        } elsif ($n == 0) {
            $result = Math::BigInt->new(1);
        } else {
        		my ($p0, $p1) = &oddFactorial($n);
            $result = $p0->blsft($n - &popcount($n));
        }
        return $result->copy();
    } # SwingFactorial
    
# from <https://www.perlmonks.org/?node_id=1199987>
sub popcount {
    my ($parm) = @_;
    my $result = (Math::BigInt->new($parm)->as_bin()) =~ tr/1//;
    return $result;
} # popcount

#START-TEST-################################################
#   $old2->bmul($old);

# main()
    my $debug  = 0; # 0 (none), 1 (some), 2 (more)
    my $number = 29;
    while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # get options
        my $opt = shift(@ARGV);
        if (0) {
        } elsif ($opt =~ m{d}) {
            $debug  = shift(@ARGV);
        } elsif ($opt =~ m{n}) {
            $number = shift(@ARGV);
        } else {
            die "invalid option \"$opt\"\n";
        }
    } # while ARGV

    my $n;
    for $n (0..99) {
        # print "n = $n\n";
        my $s = &SwingFactorial($n);
        my $b = Math::BigInt->new($n);
        $b->bfac(); # conventional factorial with the built-in function
        if ($s->bne($b)) {
            print "difference at n = $n: $s <> $b\n";
        }
    } # for $n
exit;
    # GC.gc() ??
    $n = $number;
    print "start " . &get_timestamp() . "\n";
    my $b = Math::BigInt->new($n)->bfac(); 
    # &SwingFactorial($n);
    print "end   " . &get_timestamp() . "\n";
    exit();
#----
sub get_timestamp {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
    my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
    return $timestamp;
} # get_timestamp

#--------
__DATA__
# Copyright Peter Luschny. License is MIT.

module BasicSwingFactorial
export SwingFactorial

"""
Return the factorial of ``n``. Implementation of the swing algorithm using no
primes. An advanced version based on prime-factorization which is much faster
is available as the prime-swing factorial. However the claim is that this is 
the fastest algorithm not using prime-factorization. It has the same recursive
structure as his big brother.
"""
function SwingFactorial(n::Int)::BigInt

    smallOddFactorial = BigInt[        0x0000000000000000000000000000001,
    0x0000000000000000000000000000001, 0x0000000000000000000000000000001,
    0x0000000000000000000000000000003, 0x0000000000000000000000000000003,
    0x000000000000000000000000000000f, 0x000000000000000000000000000002d,
    0x000000000000000000000000000013b, 0x000000000000000000000000000013b,
    0x0000000000000000000000000000b13, 0x000000000000000000000000000375f,
    0x0000000000000000000000000026115, 0x000000000000000000000000007233f,
    0x00000000000000000000000005cca33, 0x0000000000000000000000002898765,
    0x00000000000000000000000260eeeeb, 0x00000000000000000000000260eeeeb,
    0x0000000000000000000000286fddd9b, 0x00000000000000000000016beecca73,
    0x000000000000000000001b02b930689, 0x00000000000000000000870d9df20ad,
    0x0000000000000000000b141df4dae31, 0x00000000000000000079dd498567c1b,
    0x00000000000000000af2e19afc5266d, 0x000000000000000020d8a4d0f4f7347,
    0x000000000000000335281867ec241ef, 0x0000000000000029b3093d46fdd5923,
    0x0000000000000465e1f9767cc5866b1, 0x0000000000001ec92dd23d6966aced7,
    0x0000000000037cca30d0f4f0a196e5b, 0x0000000000344fd8dc3e5a1977d7755,
    0x000000000655ab42ab8ce915831734b, 0x000000000655ab42ab8ce915831734b,
    0x00000000d10b13981d2a0bc5e5fdcab, 0x0000000de1bc4d19efcac82445da75b,
    0x000001e5dcbe8a8bc8b95cf58cde171, 0x00001114c2b2deea0e8444a1f3cecf9,
    0x0002780023da37d4191deb683ce3ffd, 0x002ee802a93224bddd3878bc84ebfc7,
    0x07255867c6a398ecb39a64b83ff3751, 0x23baba06e131fc9f8203f7993fc1495]

    function oddProduct(m, len)
        if len < 24
            p = BigInt(m)
            for k in 2:2:2(len-1)
                p *= (m - k)
            end
            return p
        end
        hlen = len >> 1
        oddProduct(m - 2 * hlen, len - hlen) * oddProduct(m, hlen)
    end

    function oddFactorial(n)
        if n < 41
            oddFact = smallOddFactorial[1+n]
            sqrOddFact = smallOddFactorial[1+div(n, 2)]
        else
            sqrOddFact, oldOddFact = oddFactorial(div(n, 2))
            len = div(n - 1, 4)
            (n % 4) != 2 && (len += 1)
            high = n - ((n + 1) & 1)
            oddSwing = div(oddProduct(high, len), oldOddFact)
            oddFact = sqrOddFact^2 * oddSwing
        end
        (oddFact, sqrOddFact)
    end

    n < 0 && ArgumentError("n must be ≥ 0")
    if n == 0 return 1 end
    sh = n - count_ones(n)
    oddFactorial(n)[1] << sh
end

#START-TEST-################################################
using Test

function main()
    @testset "SwingFactorial" begin
        for n in 0:999
            S = SwingFactorial(n)
            B = Base.factorial(BigInt(n))
            @test S == B
        end
    end

    GC.gc()
    n = 1000000
    @time SwingFactorial(n)
end

main()

end # module
