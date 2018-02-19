#!/usr/bin/perl

# Generate syntax descriptions of FASS curves
# @(#) $Id$
# 2018-02-18, Georg Fischer
# usage:
#   perl Kn_syntex.pl n
#---------------------------------------------
use strict;
my $max_width = shift(@ARGV); # maximum number of digits for nodes of the generated curve
my $letters = "ABCDEFGHIJKLMNOPQRSTUVWXY"; # for widht <= 25

print <<'GFis';
A0 = [];
#----
GFis
my $width = 1;
while ($width<= $max_width) {
    my $level = 0;
    while ($level <= $width) {
        my $letter = substr($letters, $level, 1);
        print "$letter$width = " . &genOuter($width, $level) . ";\n";
        $level ++;
    } # while $Level
    print "#--------\n";
    $width ++;
} # while $width

sub genInner { # generate a path description for the "inner S" structure from [1,2,3]
    my ($width) = @_;
    my $width_1 = $width - 1;
    my $letter  = substr($letters, 0, 1);
    my $result;
    if (1) {
        # A99= [A98.98+1,/A98.98+2,A98.98+3];
        $result = "[$letter$width_1.$width_1+1"
                .",/$letter$width_1.$width_1+2"
                . ",$letter$width_1.$width_1+3]";
    }
    return $result;
} # genInner

sub genOuter { # generate a path description for the "outer meander" structure from [0, inner, 4]
    my ($width, $level) = @_;
    my $width_1 = $width - 1;
    my $level_1 = $level - 1;
    my $level_2 = $level - 2;
    my $letter   = substr($letters, $level  , 1);
    my $letter_1 = substr($letters, $level_1, 1);
    #                          even  odd
    my $x0 = $level % 2 != 0 ? "0" : "4"; 
    my $x4 = $level % 2 != 0 ? "4" : "0";
    if ($width %2 != 0) { # exchange $x0 with $x4
        my $temp = $x0;
        $x0 = $x4;
        $x4 = $temp;
    }
    my $result;
    if ($level == 0) {
        $result = &genInner($width);
    } elsif ($level == 1) {
        if ($width % 2 == 0) { # even
        $result = "[$letter_1$width_1.$level_1+$x4"
                .",/$letter_1$width"
                . ",$letter_1$width_1.$level_1+$x0]";
        } else {               # odd
        $result ="[/$letter_1$width_1.$level_1+$x4"
                . ",$letter_1$width"
                .",/$letter_1$width_1.$level_1+$x0]";
        }
    } else {
        $result = "[$letter_1$width_1.$level_1+$x4"
                . ",$letter_1$width"
                . ",$letter_1$width_1.$level_1+$x0]";
    }
} # genOuter
__DATA__
georg@nunki:~/work/gits/fasces/data$ perl Kn_syntax.pl 5
A0 = [];
#----
A1 = [A0+0.1,/A0+0.2,A0+0.3];
B1 = [/A0+0.0,A1,/A0+0.4];
#--------
A2 = [A1+1.1,/A1+1.2,A1+1.3];
B2 = [A1+1.4,/A2,A1+1.0];
C2 = [B1+1.0,B2,B1+1.4];
#--------
A3 = [A2+2.1,/A2+2.2,A2+2.3];
B3 = [/A2+2.0,A3,/A2+2.4];
C3 = [B2+2.4,B3,B2+2.0];
D3 = [C2+2.0,C3,C2+2.4];
#--------
A4 = [A3+3.1,/A3+3.2,A3+3.3];
B4 = [A3+3.4,/A4,A3+3.0];
C4 = [B3+3.0,B4,B3+3.4];
D4 = [C3+3.4,C4,C3+3.0];
E4 = [D3+3.0,D4,D3+3.4];
#--------
A5 = [A4+4.1,/A4+4.2,A4+4.3];
B5 = [/A4+4.0,A5,/A4+4.4];
C5 = [B4+4.4,B5,B4+4.0];
D5 = [C4+4.0,C5,C4+4.4];
E5 = [D4+4.4,D5,D4+4.0];
F5 = [E4+4.0,E5,E4+4.4];
#--------
