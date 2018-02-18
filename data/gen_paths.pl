#!/usr/bin/perl
# 2017-08-23, Georg Fischer
# Program in the public domain
# c.f. https://oeis.org/A220952
# Generate paths
# C.f. Knuth's meander sequence, OEIS A220952
# usage:
#   perl gen_paths [[-b] base] [-s] [-dn] 
#   -b  base (default 5)
#   -s  symmetric (default: false)
#   -dn debug level n (default: 0) 
#-------------------------
use strict;
use integer; # avoid division problems with reals

my $debug  = 0;
my $base   = 5; 
my $maxexp = 2;  # compute b-file up to $base**$maxexp
my $symm   = 0;
my $rule   = 0;  # for stronger condition
my $vert   = "||";
my $hori   = "==";
my $blan   = "  ";
my $letters = "abcdefghijklmnopqrstuvwxyz";

while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if ($opt =~ m{\A(\-b)?(\d+)\Z}) {
        $base  = $2;
    }
    if ($opt =~ m{r}) {
        $rule  = 1;
    }
    if ($opt =~ m{s}) {
        $symm  = 1;
    }
    if ($opt =~ m{d(\d+)}) {
        $debug = $1;
    }
} # while opt

my $pathno = 0;

my @matrix = ();
my @filled = ();
my $corner = $base * $base;
my $full = $corner - 1;
my $last = $full;
if ($symm == 1) {
    $last /= 2;
}
my @path = ();
if (0) {
    $base = 5;
    @path =  (0,1,2,3,4,9,14,19,18,17,16);
    &draw_path();
    exit(0);
}
my 
$ind = 0;
while ($ind < $corner) { # preset filled
    $filled[$ind] = 0;
    $ind ++;
} # preset filled

my $sep = ",";
my @queue = (); # entries are "path_index${sep}value"
$ind = 0;
&mark($ind); $ind ++;
&mark($ind); $ind ++;
# normalized start: 00->01
&push_urdl();

while (scalar(@queue) > 0) { # pop
    my ($dir, $pind, $pval) = split(/$sep/, pop(@queue));
    while (scalar(@path) > $pind) {
        &unmark();
    } # while unmark
    # @path = splice(@path, 0, $pind);
    print "queue[" . sprintf("%3d", scalar(@queue)) . "]\@$pind $dir: " 
            . join(",", map { &based0($_) } @path) . " ". &based0($pval) 
            . "?\n" if $debug >= 2;
    if ($debug >= 2) {
        my $ifil = 0;
        # print "filled:";
        while ($ifil < scalar(@filled)) {
            print &based0($ifil) . ";$filled[$ifil] ";
            $ifil ++;
        } 
        print "\n";
    }
    
    &mark($pval);
    my $plen = scalar(@path);
    if (0) {
    } elsif ($rule or $pval == $last) {
        print "pval=$pval, plen=$plen, last=$last, full=$full\n" if $debug >= 1;
        if ($plen == $last + 1) { # really at the end or in the center
            while ($plen < $corner) { # fill 2nd half in case of $symm
                push(@path, $full - $path[$full - $plen]);
                $plen ++;
            } # fill
            print "scalar(path)=" . scalar(@path) . ", plen=$plen, last=$last, full=$full\n" if $debug >= 1;
            print join("/", map { &based0($_) } @path) . "\n" if $debug >= 1;;
            &output_path();
            @path = splice(@path, 0, $last + 1);
        } else {
            &push_urdl();
        }
    } else {
        &push_urdl();
    }
} # while popping

exit(0);

#--------
sub mark {
    my ($val) = @_;
    push(@path, $val);
    $filled[$val]                   = 1;
    if ($symm == 1) {
        $filled[$full - $val] = 1;
    }
} # mark
#--------
sub unmark {
    my $val = pop(@path);
    $filled[$val]                   = 0;
    if ($symm == 1) {
        $filled[$full - $val] = 0;
    }
} # unmark
#--------
sub is_free {
    my ($vnext) = @_;
    return ($filled[$vnext] == 0 and ($symm == 0 or $filled[$corner - 1 - $vnext] == 0)) ? 1 : 0;
} # is_free
#--------
sub push_urdl {
    # determine and push possible followers of last vertex
    my $len = scalar(@path);
    my $vlast = $path[$len - 1];
    my $vprev = $path[$len - 2];
    my $xlast = &get_digit($vlast, 1);
    my $ylast = &get_digit($vlast, 0);
    my
    $vnext = $vlast + 1    ; # up
    if ($ylast < $base - 1 and &is_free($vnext) == 1) {
        push(@queue, "u$sep$len$sep$vnext");
    }
    $vnext = $vlast - 1    ; # down
    if ($ylast > 0         and &is_free($vnext) == 1) {
        push(@queue, "d$sep$len$sep$vnext");
    }
    $vnext = $vlast + $base; # right
    if ($xlast < $base - 1 and &is_free($vnext) == 1) {
        push(@queue, "r$sep$len$sep$vnext");
    }
    $vnext = $vlast - $base; # left
    if ($xlast > 0         and &is_free($vnext) == 1) {
        push(@queue, "l$sep$len$sep$vnext");
    }
    print "push_urdl: vlast=$vlast, xlast=$xlast, ylast=$ylast, " 
            . join("/", @queue) . "\n" if $debug >= 2;
} # push_urdl
#--------
sub output_path {
    $pathno ++;
    print "<!-- ========================== -->\n";
	my $attrs = &get_attributes();
    print "<matrix id=\"$pathno\" attrs=\"$attrs\" base\"$base\"\n";
   	print "     path=\""  . join(",", map {         $_  } @path) . "\"\n"
    	. "     bpath=\"" . join("/", map { &based0($_) } @path) . "/\"\n"
    	. "     >\n";
    if (1) {
    	&draw_path(@path);
    }
    print "</matrix>\n";
} # output_path
#--------
sub get_attributes {
	# determine general properties of the path
    my $result = "";
    my $last = $path[scalar(@path) - 1];
	#----
	if ($last == $full) {
		$result .=",diagonal";
	}
	#----
	my $dig0 = $last % $base;
	my $dig1 = ($last / $base) % $base;
	if (($dig0 != 0 and $dig0 != $base - 1) or
        ($dig1 != 0 and $dig1 != $base - 1)) {
		$result .=",inside";
	}
	#----
	my $ipa = 0;
	my $half = $full / 2;
	my $compl = 1;
	while ($compl == 1 and $ipa <= $half) {
		$compl = $path[$ipa] == $full - $path[$full - $ipa] ? 1 : 0;
		$ipa ++;
	}
    if ($compl == 1) {
    	$result .= ",symmetrical";
    }
	#----
    return substr($result, 1);
} # get_attributes
#--------
sub draw_path {
    # initialize the matrix
    my @path = @_;
    my $x = 0;
    my $y = 0;
    while ($x < $base) {
        $y = 0;
        while ($y < $base) {
            my $mp = &get_matrix_pos($x, $y);
            $matrix[$mp] = "$x$y";
            if ($x < $base - 1) {
                $matrix[$mp + 1] = $blan; # right
            }
            if ($y > 0) {
                $matrix[$mp + $base * 2 - 1] = $blan; # down
                if ($x < $base - 1) {
                    $matrix[$mp + $base * 2 - 1 + 1] = $blan; # down
                }                   
            }
            $y ++;
        } # while y
        $x ++;
    } # while $x

    my $ipa = 1;
    while ($ipa < scalar(@path)) {
        &connect($path[$ipa - 1], $path[$ipa]);
        $ipa ++;
    } # while $ipa 
	print "<draw-path>\n\n";
    my $imp = 0;
    while ($imp < scalar(@matrix)) { # print
        print "$matrix[$imp]";
        $imp ++;
        if ($imp % ($base * 2 - 1) == 0) {
            print "\n";
        }
    } # printing
	print "\n</draw-path>\n";
} # draw_path
#---------
sub get_matrix_pos {
    my ($x, $y) = @_;
    my $base2_1 = $base * 2 - 1; # 9  for base=5
    return $x * 2 + ($base2_1 - 1) * $base2_1 - $y * 2 *$base2_1; 
} # get_matrix_pos
#----------
sub connect {
    my ($pa0, $pa1) = @_;
    if ($pa0 > $pa1) { # exchange, make p1 smaller
        my $temp = $pa0;
        $pa0 = $pa1;
        $pa1 = $temp;
    } # pa0 <= pa1
    my $ba0 = &based0($pa0);
    my $ba1 = &based0($pa1);
    print "ba0=$ba0, ba1=$ba1" if $debug >= 2;
    my $x0 = &get_digit($pa0, 1);
    my $y0 = &get_digit($pa0, 0);
    my $x1 = &get_digit($pa1, 1);
    my $y1 = &get_digit($pa1, 0);
    print ", x0=$x0, y0=$y0, x1=$x1, y1=$y1" if $debug >= 2;
    my $mp0 = &get_matrix_pos($x0, $y0);
    if ($x0 eq $x1) { # up
        $matrix[$mp0 - ($base * 2 - 1)] = $vert; # up
        print " $vert\n" if $debug >= 2;
    } else {
        $matrix[$mp0 + 1]               = $hori; # right
        print " $hori\n" if $debug >= 2;
    }
} # connect
#---------
sub get_digit {
    # return the value of a digit from a string in $base representation
    # $base <= 10 for the moment, but hex is prepared
    my ($num, $pos) = @_; # pos is 0 for last character
    my $bum = &based0($num);
    return substr($bum, length($bum) - 1 - $pos, 1);
} # get_digit
#--------
sub based0 {
    # return a number in base $base, 
    # filled to $maxexp - 1 with leading zeroes
    my ($num) = @_;
    my $result = "";
    my $ind = 0;
    while ($ind < $maxexp) {
       $result = ($num % $base) . $result;
       $num    /= $base;
       $ind ++;
    } # while $idig
    return $result; 
} # based0
#--------
__DATA__
