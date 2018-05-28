#!/usr/bin/perl

# Generate path expressions for FASS curves
# @(#) $Id$
# 2018-02-21: for "Fs" also
# 2018-02-19: determine a single element (x1000000)
# 2018-02-18, Georg Fischer
# Program in the public domain
# c.f. <http://www.teherba.org/index.php/OEIS/A220952>
#
# usage:
#     perl gen_expr.pl n  mtype  - compute up to level n
#     perl gen_expr.pl -n mtype  - compute enough levels in order to determine element -n
#         mtype = Kn | Fs
#
# Path expressions are built with 2 operations:
# "/X"    - reverse the sequence of elements in X
# "X.n+m" - insert digit m after the digit for 5^n in each element of X
# Examples: [].0+1 = [1]; [12].0+3 = [123]; [12].2+3 = [312]; [1234].1+0 = [12304];
# For Kn, the "inner" expression always has the form 
# A99 = [A98.98+1,/A98.98+2,A98.98+3];
#---------------------------------------------
use strict;

my $max_width = shift(@ARGV); # maximum number of digits for nodes of the generated curve
my $max_size  = 0x7ffffff; # very high
if ($max_width < 0) {
    $max_size = - $max_width;
    $max_width = 256; # very high
}
my $mtype = "Kn"; # default
if (scalar(@ARGV) >= 1) {
    $mtype = shift(@ARGV); # "Kn" or "Fs"
}
# global variables
my $letters = "ABCDEFGHIJKLMNOPQRSTUVWXY"; # for width <= 25
my %pexprs  = (); # stores the generated subexpressions
my %lengths = (); # stores the lengths of the subexpressions
my $last_name; # name of last path expression generated
print <<"GFis";
A0 = []; len = 1; # mtype = \"$mtype\", max_width = $max_width
#----
GFis
$lengths{"A0"} = 1; # strange, empty = 1 element?

my $width = 1;
my $size = 0; # of generated path expression
while ($width <= $max_width and $size <= $max_size) {
    my $level = 0;
    while ($level <= $width) {
        my $letter = substr($letters, $level, 1);
        $size = genExpressions($mtype, $width, $level);
        $level ++;
    } # while $level
    print "#--------\n";
    $width ++;
} # while $width
if ($max_width == 256) { # max_size was specified: get a single element
    &getSingle($last_name, $max_size);
} # single
# end of main
#-------------------------------
sub genExpressions { # generate a path description for the "outer meander" structure from [0, inner, 4]
    my ($mtype, $width, $level) = @_;
    my $width_1 = $width - 1;
    my $level_1 = $level - 1;
    my $name_00 = substr($letters, $level  , 1) . $width;
    my $name_01 = substr($letters, $level  , 1) . $width_1;
    my $name_10 = substr($letters, $level_1, 1) . $width;
    my $name_11 = substr($letters, $level_1, 1) . $width_1;
    #                          even  odd
    my $x0 = $level % 2 != 0 ? "0" : "4"; 
    my $x4 = $level % 2 != 0 ? "4" : "0";
    if ($width %2 != 0) { # exchange $x0 with $x4
        my $temp = $x0; $x0 = $x4; $x4 = $temp;
    }
    my $pexpr;
    if (0) {
    #-------------------------
    } elsif ($mtype eq "Kn") {
        if (0) {
        } elsif ($level == 0) { # AAAAAAAA
            if ($width % 2 == 0) { # even
                $pexpr =  "[$name_01.$width_1+1"   . ",/$name_01.$width_1+2" .  ",$name_01.$width_1+3]";
            } else {               # odd
                $pexpr =  "[$name_01.$width_1+1"   . ",/$name_01.$width_1+2" .  ",$name_01.$width_1+3]";
            }
        } elsif ($level == 1) { # BBBBBBBB
            if ($width % 2 == 0) { # even
                $pexpr =  "[$name_11.$level_1+$x4" . ",/$name_10"            .  ",$name_11.$level_1+$x0]";
            } else {               # odd
                $pexpr = "[/$name_11.$level_1+$x4" .  ",$name_10"            . ",/$name_11.$level_1+$x0]";
            }
        } else { # $level > 1:    CCCC,D,E...
            if ($width % 2 == 0) { # even
                $pexpr =  "[$name_11.$level_1+$x4" .  ",$name_10"            .  ",$name_11.$level_1+$x0]";
            } else {               # odd
                $pexpr =  "[$name_11.$level_1+$x4" .  ",$name_10"            .  ",$name_11.$level_1+$x0]";
            }
        } # Kn
    #-------------------------
    } elsif ($mtype eq "Fs") {
        if (0) {
        } elsif ($level == 0) { # AAAAAAAA
            if ($width % 2 == 0) { # even
                $pexpr = "[/$name_01.0+3"          .  ",$name_01.0+2"        . ",/$name_01.0+1]";
            } else {               # odd
                $pexpr = "[/$name_01.0+1"          .  ",$name_01.0+2"        . ",/$name_01.0+3]";
            }
        } elsif ($level == 1) { # BBBBBBBB
            if ($width % 2 == 0) { # even
                $pexpr =  "[$name_11.$level_1+$x4" .  ",$name_10"            .  ",$name_11.$level_1+$x0]";
            } else {               # odd
                $pexpr =  "[$name_11.$level_1+$x4" .  ",$name_10"            .  ",$name_11.$level_1+$x0]";
            }
        } else { # $level > 1:    CCCC,D,E...
            if ($width % 2 == 0) { # even
                $pexpr =  "[$name_11.$level_1+$x4" .  ",$name_10"            .  ",$name_11.$level_1+$x0]";
            } else {               # odd
                $pexpr =  "[$name_11.$level_1+$x4" .  ",$name_10"            .  ",$name_11.$level_1+$x0]";
            }
        } # Fs
    } else {
        die "invalid meander type \"$mtype\"";
    }
    my $terms = $pexpr;
    $terms =~ s{\.\d+\+\d+}{}g;   #  "[I8.8+0,/I9,I8.8+4]" -> "[I8,I9,I8]"
    $terms =~ s{[\[\]\; \/]}{}g; #  "[I8,I9,I8]" -> "I8,I9,I8"
    $terms = join(" + ", map { $lengths{$_} } split(/\,/, $terms));
    my $result = eval($terms);
    $lengths{$name_00} = $result;
    $pexprs{$name_00}  = $pexpr;
    print "$name_00 = " . $pexpr . "; len = " . $result . " = $terms;\n";
    $last_name = $name_00;
    return $result;
} # genKn
#-------------------------------
sub getSingle { # gets a single element from a path expression
    my ($last_name, $last_index) = @_;
    my $pname = $last_name;  # of current pexpr
    my $index = $last_index; # always in current pexpr
    if ($index >= $lengths{$pname}) {
        print STDERR "element [$last_index] is not contained in $last_name\n";
        return 0;
    }
    my $loop_check = 128;
    my @inserts = ();
    while ($pname ne "A0" and $loop_check >= 0) {
        $loop_check --;
        my $pexpr = $pexprs{$pname};
        # print "# $pname = $pexpr; len = $lengths{$pname}; index = $index;\n";
        $pexpr =~ s{[\;\[\] ]}{}g; # remove all superfluous chars.
        my @parts = split(/\,/, $pexpr);
        my $ipart = 0;
        my $busy = 1;
        # find out in which of the parts the element [$index] is contained
        my $sum = 0;
        my $old_sum = 0;
        while ($busy == 1 and $ipart < scalar(@parts)) {
            my $pelem = $parts[$ipart];
            my ($name, $exp, $digit) = ("", "", "");
            ($name, $exp, $digit) = split(/[\+\.]/, $pelem);
            my $reversed = 0;
            if ($name =~ m{\A\/}) {
                $reversed = 1;
                $name =~ s{\A\/}{};
            }
            my $size = $lengths{$name};
            $old_sum = $sum;
            $sum += $size;
            if ($index < $sum) { # it is contained in this part
                my $old_index = $index;
                $index -= $old_sum;
                if ($reversed != 0) {
                    $index = $size - $index - 1; 
                }
                $busy = 0; # now examine $name
                my $insert = "";
                if ($exp ne "") {
                    $insert = "$exp+$digit";
                    push(@inserts, $insert);
                }
                print "# $pname" . "[$old_index] -> [$pexpr]{$ipart}" . " -> " 
                        . $name . "[$index].$insert\n";
                $pname = $name;
            } # if contained
            $ipart ++;
        } # while parts
    } # while ne "A0"
    print "# inserts = (" . join(",", @inserts) . ");\n";
    # inserts = (2+0,1+0,0+0,1+3,0+2);
    # now pop all inserts and build the final element
    my $elem = "";
    while (scalar(@inserts) > 0) {
        my $insert = pop(@inserts);
        my ($exp, $digit) = split(/\+/, $insert);
        my $len = length($elem);
        $elem = substr($elem, 0, $len - $exp) . $digit 
              . substr($elem, $len - $exp);
        # print "# elem = $elem\n";
    } # while @inserts
    print $last_name . "[$last_index] = $elem(5);\n";
} # getSingle
#-------------------------------
__DATA__
georg@nunki:~/work/gits/fasces/data$ make single
perl gen_expr.pl -1000000
A0 = []; len = 1;
#----
A1 = [A0.0+1,/A0.0+2,A0.0+3]; len = 3 = 1 * 3;
B1 = [/A0.0+0,A1,/A0.0+4]; len = 5 = 1 + 3 + 1;
#--------
A2 = [A1.1+1,/A1.1+2,A1.1+3]; len = 9 = 3 * 3;
B2 = [A1.0+4,/A2,A1.0+0]; len = 15 = 3 + 9 + 3;
C2 = [B1.1+0,B2,B1.1+4]; len = 25 = 5 + 15 + 5;
#--------
A3 = [A2.2+1,/A2.2+2,A2.2+3]; len = 27 = 9 * 3;
B3 = [/A2.0+0,A3,/A2.0+4]; len = 45 = 9 + 27 + 9;
C3 = [B2.1+4,B3,B2.1+0]; len = 75 = 15 + 45 + 15;
D3 = [C2.2+0,C3,C2.2+4]; len = 125 = 25 + 75 + 25;
#--------
A4 = [A3.3+1,/A3.3+2,A3.3+3]; len = 81 = 27 * 3;
B4 = [A3.0+4,/A4,A3.0+0]; len = 135 = 27 + 81 + 27;
C4 = [B3.1+0,B4,B3.1+4]; len = 225 = 45 + 135 + 45;
D4 = [C3.2+4,C4,C3.2+0]; len = 375 = 75 + 225 + 75;
E4 = [D3.3+0,D4,D3.3+4]; len = 625 = 125 + 375 + 125;
#--------
A5 = [A4.4+1,/A4.4+2,A4.4+3]; len = 243 = 81 * 3;
B5 = [/A4.0+0,A5,/A4.0+4]; len = 405 = 81 + 243 + 81;
C5 = [B4.1+4,B5,B4.1+0]; len = 675 = 135 + 405 + 135;
D5 = [C4.2+0,C5,C4.2+4]; len = 1125 = 225 + 675 + 225;
E5 = [D4.3+4,D5,D4.3+0]; len = 1875 = 375 + 1125 + 375;
F5 = [E4.4+0,E5,E4.4+4]; len = 3125 = 625 + 1875 + 625;
#--------
A6 = [A5.5+1,/A5.5+2,A5.5+3]; len = 729 = 243 * 3;
B6 = [A5.0+4,/A6,A5.0+0]; len = 1215 = 243 + 729 + 243;
C6 = [B5.1+0,B6,B5.1+4]; len = 2025 = 405 + 1215 + 405;
D6 = [C5.2+4,C6,C5.2+0]; len = 3375 = 675 + 2025 + 675;
E6 = [D5.3+0,D6,D5.3+4]; len = 5625 = 1125 + 3375 + 1125;
F6 = [E5.4+4,E6,E5.4+0]; len = 9375 = 1875 + 5625 + 1875;
G6 = [F5.5+0,F6,F5.5+4]; len = 15625 = 3125 + 9375 + 3125;
#--------
A7 = [A6.6+1,/A6.6+2,A6.6+3]; len = 2187 = 729 * 3;
B7 = [/A6.0+0,A7,/A6.0+4]; len = 3645 = 729 + 2187 + 729;
C7 = [B6.1+4,B7,B6.1+0]; len = 6075 = 1215 + 3645 + 1215;
D7 = [C6.2+0,C7,C6.2+4]; len = 10125 = 2025 + 6075 + 2025;
E7 = [D6.3+4,D7,D6.3+0]; len = 16875 = 3375 + 10125 + 3375;
F7 = [E6.4+0,E7,E6.4+4]; len = 28125 = 5625 + 16875 + 5625;
G7 = [F6.5+4,F7,F6.5+0]; len = 46875 = 9375 + 28125 + 9375;
H7 = [G6.6+0,G7,G6.6+4]; len = 78125 = 15625 + 46875 + 15625;
#--------
A8 = [A7.7+1,/A7.7+2,A7.7+3]; len = 6561 = 2187 * 3;
B8 = [A7.0+4,/A8,A7.0+0]; len = 10935 = 2187 + 6561 + 2187;
C8 = [B7.1+0,B8,B7.1+4]; len = 18225 = 3645 + 10935 + 3645;
D8 = [C7.2+4,C8,C7.2+0]; len = 30375 = 6075 + 18225 + 6075;
E8 = [D7.3+0,D8,D7.3+4]; len = 50625 = 10125 + 30375 + 10125;
F8 = [E7.4+4,E8,E7.4+0]; len = 84375 = 16875 + 50625 + 16875;
G8 = [F7.5+0,F8,F7.5+4]; len = 140625 = 28125 + 84375 + 28125;
H8 = [G7.6+4,G8,G7.6+0]; len = 234375 = 46875 + 140625 + 46875;
I8 = [H7.7+0,H8,H7.7+4]; len = 390625 = 78125 + 234375 + 78125;
#--------
A9 = [A8.8+1,/A8.8+2,A8.8+3]; len = 19683 = 6561 * 3;
B9 = [/A8.0+0,A9,/A8.0+4]; len = 32805 = 6561 + 19683 + 6561;
C9 = [B8.1+4,B9,B8.1+0]; len = 54675 = 10935 + 32805 + 10935;
D9 = [C8.2+0,C9,C8.2+4]; len = 91125 = 18225 + 54675 + 18225;
E9 = [D8.3+4,D9,D8.3+0]; len = 151875 = 30375 + 91125 + 30375;
F9 = [E8.4+0,E9,E8.4+4]; len = 253125 = 50625 + 151875 + 50625;
G9 = [F8.5+4,F9,F8.5+0]; len = 421875 = 84375 + 253125 + 84375;
H9 = [G8.6+0,G9,G8.6+4]; len = 703125 = 140625 + 421875 + 140625;
I9 = [H8.7+4,H9,H8.7+0]; len = 1171875 = 234375 + 703125 + 234375;
J9 = [I8.8+0,I9,I8.8+4]; len = 1953125 = 390625 + 1171875 + 390625;
#--------
# J9[1000000] -> [I8.8+0,I9,I8.8+4]{1} -> I9[609375].
# I9[609375] -> [H8.7+4,H9,H8.7+0]{1} -> H9[375000].
# H9[375000] -> [G8.6+0,G9,G8.6+4]{1} -> G9[234375].
# G9[234375] -> [F8.5+4,F9,F8.5+0]{1} -> F9[150000].
# F9[150000] -> [E8.4+0,E9,E8.4+4]{1} -> E9[99375].
# E9[99375] -> [D8.3+4,D9,D8.3+0]{1} -> D9[69000].
# D9[69000] -> [C8.2+0,C9,C8.2+4]{1} -> C9[50775].
# C9[50775] -> [B8.1+4,B9,B8.1+0]{2} -> B8[7035].1+0
# B8[7035] -> [A7.0+4,/A8,A7.0+0]{1} -> A8[1712].
# A8[1712] -> [A7.7+1,/A7.7+2,A7.7+3]{0} -> A7[1712].7+1
# A7[1712] -> [A6.6+1,/A6.6+2,A6.6+3]{2} -> A6[254].6+3
# A6[254] -> [A5.5+1,/A5.5+2,A5.5+3]{1} -> A5[231].5+2
# A5[231] -> [A4.4+1,/A4.4+2,A4.4+3]{2} -> A4[69].4+3
# A4[69] -> [A3.3+1,/A3.3+2,A3.3+3]{2} -> A3[15].3+3
# A3[15] -> [A2.2+1,/A2.2+2,A2.2+3]{1} -> A2[2].2+2
# A2[2] -> [A1.1+1,/A1.1+2,A1.1+3]{0} -> A1[2].1+1
# A1[2] -> [A0.0+1,/A0.0+2,A0.0+3]{2} -> A0[0].0+3
# inserts = (1+0,7+1,6+3,5+2,4+3,3+3,2+2,1+1,0+3);
J9[1000000] = 132332103(5);
# Kn[1000000] 132332103(5)
georg@nunki:~/work/gits/fasces/data$
