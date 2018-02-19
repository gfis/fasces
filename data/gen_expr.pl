#!/usr/bin/perl

# Generate path expressions for FASS curves
# @(#) $Id$
# 2018-02-18, Georg Fischer
# usage:
#     perl gen_expr.pl n
#
# Path expressions are built with 2 operations:
# "/X"    - reverse the sequence of elements in X
# "X.n+m" - insert digit m after the digit for 5^n in each element of X
# Examples: [].0+1 = [1]; [12].0+3 = [123]; [12].2+3 = [312]; [1234].1+0 = [12304];
# the "inner" expression always has the form A99 = [A98.98+1,/A98.98+2,A98.98+3];
#---------------------------------------------
use strict;

my $max_width = shift(@ARGV); # maximum number of digits for nodes of the generated curve
my $letters = "ABCDEFGHIJKLMNOPQRSTUVWXY"; # for widht <= 25
my %lengths = (); # stores the lengths of the subexpressions

print <<'GFis';
A0 = []; len = 1;
#----
GFis
$lengths{"A0"} = 1; # strange, empty = 1 element?

my $width = 1;
while ($width <= $max_width) {
    my $level = 0;
    while ($level <= $width) {
        my $letter = substr($letters, $level, 1);
        &genOuter($width, $level);
        $level ++;
    } # while $Level
    print "#--------\n";
    $width ++;
} # while $width

sub genInner { # generate a path description for the "inner S" structure from [1,2,3]
    # A99= [A98.98+1,/A98.98+2,A98.98+3];
    my ($width, $level) = @_;
    my $width_1 = $width - 1;
    my $name_00 = substr($letters, $level, 1) . $width;
    my $name_01 = substr($letters, $level, 1) . $width_1;
    my $result;
    if (1) {
        $result = "[$name_01.$width_1+1"
                .",/$name_01.$width_1+2"
                . ",$name_01.$width_1+3]";
    }
    $lengths{$name_00} = $lengths{$name_01} * 3;
    print "$name_00 = " . $result . "; len = " . $lengths{$name_00} . ";\n";
    return $result;
} # genInner

sub genOuter { # generate a path description for the "outer meander" structure from [0, inner, 4]
    my ($width, $level) = @_;
    my $width_1 = $width - 1;
    my $level_1 = $level - 1;
    my $name_00 = substr($letters, $level  , 1) . $width;
    my $name_10 = substr($letters, $level_1, 1) . $width;
    my $name_11 = substr($letters, $level_1, 1) . $width_1;
    #                          even  odd
    my $x0 = $level % 2 != 0 ? "0" : "4"; 
    my $x4 = $level % 2 != 0 ? "4" : "0";
    if ($width %2 != 0) { # exchange $x0 with $x4
        my $temp = $x0; $x0 = $x4; $x4 = $temp;
    }
    my $result;
    if ($level == 0) {
        $result = &genInner($width, $level);
    } else {
        if ($level == 1) {
            if ($width % 2 == 0) { # even
            $result = "[$name_11.$level_1+$x4"
                    .",/$name_10"
                    . ",$name_11.$level_1+$x0]";
            } else {               # odd
            $result ="[/$name_11.$level_1+$x4"
                    . ",$name_10"
                    .",/$name_11.$level_1+$x0]";
            }
        } else {
            $result = "[$name_11.$level_1+$x4"
                    . ",$name_10"
                    . ",$name_11.$level_1+$x0]";
        }
        $lengths{$name_00} = $lengths{$name_11} + $lengths{$name_10} + $lengths{$name_11};
        print "$name_00 = " . $result . "; len = " . $lengths{$name_00} . ";\n";
    }
    return $result;
} # genOuter
__DATA__
georg@nunki:~/work/gits/fasces/data$ perl gen_expr.pl 5 
A0 = []; len = 1;
#----
A1 = [A0.0+1,/A0.0+2,A0.0+3]; len = 3;
B1 = [/A0.0+0,A1,/A0.0+4]; len = 5;
#--------
A2 = [A1.1+1,/A1.1+2,A1.1+3]; len = 9;
B2 = [A1.0+4,/A2,A1.0+0]; len = 15;
C2 = [B1.1+0,B2,B1.1+4]; len = 25;
#--------
A3 = [A2.2+1,/A2.2+2,A2.2+3]; len = 27;
B3 = [/A2.0+0,A3,/A2.0+4]; len = 45;
C3 = [B2.1+4,B3,B2.1+0]; len = 75;
D3 = [C2.2+0,C3,C2.2+4]; len = 125;
#--------
A4 = [A3.3+1,/A3.3+2,A3.3+3]; len = 81;
B4 = [A3.0+4,/A4,A3.0+0]; len = 135;
C4 = [B3.1+0,B4,B3.1+4]; len = 225;
D4 = [C3.2+4,C4,C3.2+0]; len = 375;
E4 = [D3.3+0,D4,D3.3+4]; len = 625;
#--------
A5 = [A4.4+1,/A4.4+2,A4.4+3]; len = 243;
B5 = [/A4.0+0,A5,/A4.0+4]; len = 405;
C5 = [B4.1+4,B5,B4.1+0]; len = 675;
D5 = [C4.2+0,C5,C4.2+4]; len = 1125;
E5 = [D4.3+4,D5,D4.3+0]; len = 1875;
F5 = [E4.4+0,E5,E4.4+4]; len = 3125;
#--------
georg@nunki:~/work/gits/fasces/data$ 
