#!/usr/bin/perl
# read a b-file (e.g. for OEIS sequence A220952) 
# and determine building blocks of lower dimension
# 2017-08-30, Georg Fischer
# Program in the public domain
#
# dimensions
# y : -down   +up     -0 +0
# x : -left   +right  -1 +1
# z : -back   +forth  -2 +2
# w : -narrow +wide   -3 +3

# parts
# a - not used
# b - simple bars, shapes u, s, d3, d4
# c - flat meander part {prev}blocks(next)
# d - simple bar with 3d-ending 


use strict;
use integer; # avoid division problems with reals
my $debug  = 0;
my $base   = 5; 
my $fbase  = 10;
my $tbase  =  $base;
my $graph  = 1;
my $maxdim = 2;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # start with hyphen
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt eq "\-b") {
        $base   = shift(@ARGV);
    } elsif ($opt eq "\-d") {
        $debug  = shift(@ARGV);
    } elsif ($opt eq "\-g") {
        $graph  = 1;
    } elsif ($opt eq "\-m") {
        $maxdim = shift(@ARGV);
    }
} # while opt

# read b-file and convert to $base
my $ind = 0;
my $bval = 0;
my $bmax = 0;
my @bvals = ();
while (<>) {
    next if m{[\<\=\#\@\|]}; # comments or XML tags
    next if m{\A\s*\Z}; # empty line
    s{\s+\Z}{}; # chompr
    ($ind, $bval) = split(/\s+/, $_);
    $bmax = $bval > $bmax ? $bval : $bmax;
    push(@bvals, $bval);
} # while <>

my $maxexp = 0;  # maximum exponent for $base
$maxexp = length($bmax);
$ind = 0;
while ($ind < scalar(@bvals)) {
    if (length($bvals[$ind]) < $maxexp) {
        $bvals[$ind] = substr("0000000000000000", 0, $maxexp - length($bvals[$ind])) . $bvals[$ind];
    }
    print "$ind $bvals[$ind]\n" if $debug >= 2;
    $ind ++;
} # while $ind

my %parts = ();
my %axis  = ();
my $blok  = "b/{-" . ($maxexp - 1) . "}";
my $segm  = "c/";
my $segno = 0;
my %parts = ();
my $cpinit = 0; # initial change position
my $cp    = $cpinit;
my $move  = "";
my %sums  = (); # count of part codes

$ind = 1; # $vals[0] is always fixed = 0
while ($ind < scalar(@bvals)) {
    $cp = &get_change_pos($bvals[$ind - 1], $bvals[$ind]);
    $axis{$cp} = 1;
    my $c0 = &get_digit($bvals[$ind - 1], $cp);
    my $c1 = &get_digit($bvals[$ind    ], $cp);
    my $idir = $c1 - $c0 + 1; # values 0 (-), 1 (not used), 2 (+)
    my $diff = $c1 - $c0;
    $move = ($diff < 0 ? "-" : "+") . $cp;
    if ($cp == $cpinit) {
        $blok .= $move;
    } else { # switch to different axis
        my $oldb = substr($blok, -2); # last 2 characters
        $blok .= "($move)";
        print " -> $blok" if ($debug >= 1);
        $segm .= substr($blok, 2);
        &store_part($blok);
        $cpinit = $cp;
        $blok  = "b/{$oldb}$move";
    } # different axis   
    if (scalar(keys(%axis)) > $maxdim) { # e.g. 3-dimensional cut
        print " -> $segm" if ($debug >= 1);
        $segm =~ s{\A(\w)}{"$1" . sprintf("%02d", $segno)}e;
        $segno ++;
        &store_part($segm);
        $segm = "c/";
        print "\n------- cut" if ($debug >= 1);
        %axis = ();
        $axis{$cp} = 1;
    }
    print "\nchange $bvals[$ind - 1],$bvals[$ind]: $c0$c1 @ $cp" if ($debug >= 1);
    $ind ++;
} # while $ind
print "\n" if ($debug >= 1);
$blok .= "(+4)";
&store_part($blok);

$segm .= substr($blok, 2);
$segm =~ s{\A(\w)}{"$1" . sprintf("%02d", $segno)}e;
$segno ++;
&store_part($segm);

foreach my $part (sort(keys(%parts))) {
    my $attrs = &get_attributes($part);
    print "<part occurs=\"$parts{$part}\" name=\"$part\"" 
        . (length($attrs) > 0 ? " attrs=\"$attrs\"" : "") 
        . " />\n";
} # foreach

foreach my $part_code (sort(keys(%sums))) {
    print "<sum part-code=\"$part_code\" occurs=\"$sums{$part_code}\" />\n";
} # foreach
#--------
# extract segments
my @segms = ();
foreach my $part (keys(%parts)) {
    if ($part =~ m{\A\w(\d+)}) {
        my $segno = $1;
        $part =~ s{\A\w\d*\/}{}; # remove leading name
        $segms[$segno] = $part;
    } # if seg
} # foreach $part
#--------
sub store_part {
    # b/{-1}+0+0+0(+1){+0}+1(-0){+1}-0-0(+1){-0}+1(+0){+1}+0+0(+2)
    my ($part) = @_;
    my $praw = $part;
    my $result = "";
    $praw =~ s{\A(\w)(\d*)\/}{}; # remove start of name
    my $part_code = $1;
    my $segno = $2;
    $praw =~ s{\s*\{([\+\-\d]+)\}}{}g;  # remove predecessors
    my $pred = $1;
    $praw =~ s{\(([\+\-\d]+)\)\s*}{ }g; # replace successors by spaces
    my $succ = $1;
    my $digs = join("", sort(split(/[\+\- ]+/, $praw))); # remove directions
    $result = "length:" . length($digs);
    
    if (0) {
    } elsif ($part_code eq "a") {
    } elsif ($part_code eq "b") {
        if (0) {
        } elsif (substr($pred, 1) ne substr($succ, 1)) {
            my $pc2 = "d" . ((($pred . $succ) !~ m{3}) ? 3 : 4);
            $result .= " shape:$pc2";
            &store_part("$pc2/$part");
        } else {
            if (substr($pred, 0, 1) ne substr($succ, 0, 1)) {
                $result .= " shape:u";
                $praw =~ s{[\+\-]}{}g;
                &store_part("u/" . &norm_digits($praw, 1));
                print "\nshape:u part=\"$part\" praw=\"$praw\"" if $debug >= 1;
            } else {
                $result .= " shape:s";
                $praw =~ s{[\+\-]}{}g;
                &store_part("s/" . &norm_digits($praw, 1));
                print "\nshape:s part=\"$part\" praw=\"$praw\"" if $debug >= 1;
            }
        }
    } elsif ($part_code eq "c") {
        # c1/{-1}+0+0+0(+1){+0}+1(-0){+1}-0-0(+1){-0}+1(+0){+1}+0+0(+2)
        $result = &norm_digits($praw, 2);
        print "eval: part=$part, praw=$praw, result=$result\n" if $debug >= 2;
        if ($result !~ m{\A[\+\-]0}) { # exchange x and y
            $result =~ tr/01/10/;
        }   
        if ($result !~ m{\A[\+]}) { # mirror on 1st coordinate
            $result =~ tr/\+\-/\-\+10/;
        }   
    } else {
        $result = "";
    }
    $part =~ s{\)\{}{\) \{}g;
    $parts{$part} = defined($parts{$part}) ? $parts{$part} + 1 : 1;
    $part_code = substr($part, 0, 1);
    $sums{$part_code} = defined($sums{$part_code}) ? $sums{$part_code} + 1 : 1;
    return $result;
} # store_part
#--------
sub get_attributes {
    # b/{-1}+0+0+0(+1){+0}+1(-0){+1}-0-0(+1){-0}+1(+0){+1}+0+0(+2)
    my ($part) = @_;
    my $praw = $part;
    my $result = "";
    $praw =~ s{\A(\w)(\d*)\/}{}; # remove start of name
    my $part_code = $1;
    my $segno = $2;
    $praw =~ s{\{([\+\-\d]+)\}}{}g;  # remove predecessors
    my $pred = $1;
    $praw =~ s{\(([\+\-\d]+)\)}{ }g; # replace successors by spaces
    my $succ = $1;
    my $digs = join("", sort(split(/[\+\- ]+/, $praw))); # remove directions
    $result = "length:" . length($digs);
    
    if (0) {
    } elsif ($part_code eq "a") {
    } elsif ($part_code eq "b") {
        if (0) {
        } elsif (substr($pred, 1) ne substr($succ, 1)) {
            $result .= " shape:d" . ((($pred . $succ) !~ m{3}) ? 3 : 4);
        } elsif (substr($pred, 0, 1) ne substr($succ, 0, 1)) {
            $result .= " shape:u";
        } else {
            $result .= " shape:s";
        }
    } elsif ($part_code eq "c") {
        # c1/{-1}+0+0+0(+1){+0}+1(-0){+1}-0-0(+1){-0}+1(+0){+1}+0+0(+2)
        $result = &norm_digits($praw, 2);
        print "eval: part=$part, praw=$praw, result=$result\n" if $debug >= 2;
        if ($result !~ m{\A[\+\-]0}) { # exchange x and y
            $result =~ tr/01/10/;
        }   
        if ($result !~ m{\A[\+]}) { # mirror on 1st coordinate
            $result =~ tr/\+\-/\-\+10/;
        }   
    } else {
        $result = "";
    }
    return $result;
} # get_attributes
#--------
sub norm_digits {
    my ($praw, $len) = @_;
    my $digs = join("", sort(split(/[\+\- ]+/, $praw))); # remove directions
    my $uniq = $digs;
    $uniq =~ s{(\d)\1+}{\1}g; # reduce to single digits
    my $norm = substr("0123456789", 0, $len);
    $_ = $praw;
    eval "tr/$uniq/$norm/, 1" or die $@; # nomalize $praw to "01"
    return $_; 
} # norm_digits
#--------
sub get_digit {
    # gets the digit for base**n
    my ($bnum, $bexp) = @_;
    return substr($bnum, length($bnum) - 1 - $bexp, 1);
} # get_digit
#--------
sub get_change_pos {
    # determine the position which changed between 2 nodes
    # assume that only one position changes
    my ($prev, $curr) = @_;
    while (length($prev) < length($curr)) { # adjust length
        $prev = "0$prev"; # prefix with 0
    } # while adjusting
    my $result = -1;
    my $bexp = 0;
    while ($result < 0 and $bexp < $maxexp) {
        if (&get_digit($prev, $bexp) ne 
            &get_digit($curr, $bexp)) {
            $result = $bexp;
        }
        $bexp ++;
    } # while $bexp
    return $result;
} # get_change_pos
#--------
sub to_base {
    # return a normal integer as number in base $tbase
    my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $tbase;
        $result =  $digit . $result;
        $num /= $tbase;
    } # while > 0
    return $result eq "" ? "0" : $result; 
} # to_base
#--------
__DATA__
#--------
sub draw {
    sub nested {
    } # nested
    
} # draw
