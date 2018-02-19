#!/usr/bin/perl

# Read path expressions for FASS curves and expand them into plain element vectors
# @(#) $Id$
# 2018-02-18, Georg Fischer
# usage:
#     perl gen_expr.pl n | perl expand_expr.pl
#
# Path expressions are built with 2 operations:
# "/X"    - reverse the sequence of elements in X
# "X.n+m" - insert digit m after the digit for 5^n in each element of X
# Examples: [].0+1 = [1]; [12].0+3 = [123]; [12].2+3 = [312]; [1234].1+0 = [12304];
# the "inner" expression always has the form A99 = [A98.98+1,/A98.98+2,A98.98+3];
#---------------------------------------------
use strict;

my %pexprs = (); # stores the generated subexpressions

while (<>) { # read output of gen_expr.pl
    print;
    s/\s+\Z//; # chompr
    next if m{\s*\#}; # starts with comment
    s{\;.*}{}; # remove lengths
    my ($var, $pexpr) = split(/\s*\=\s*/, $_);
    $pexpr =~ s{[\;\[\] ]}{}g; # remove all superfluous chars.
    my @new_path = ();
    foreach my $pelem (split(/\,/, $pexpr)) {
        # print "$pelem\n";
        if (length($pelem) == 0) { # empty (A0 only)
            push(@new_path, "");
        } elsif ($pelem =~ m{\A\d+\Z}) { # digits only
            push(@new_path, $pelem);
        } else { # length > 0
            my $reverse = 0;
            if ($pelem =~ m{\A\/}) {
                $pelem = substr($pelem, 1);
                $reverse = 1;
            }
            my ($name, $exp, $digit) = ("", "", "");
            ($name, $exp, $digit) = split(/[\+\.]/, $pelem);
            my @old_path = split(/\,/, $pexprs{$name});
            if ($reverse > 0) {
                @old_path = reverse(@old_path);
            }
            # print "# read $name+$exp.$digit = [" . join(",", @old_path) . "]\n";
            if (scalar(@old_path) == 0) { # empty so far
                push(@new_path, $digit);
            } else { # not empty
                foreach my $elem (@old_path) {
                    my $len = length($elem);
                    if ($exp ne "") {
                        $elem = substr($elem, 0, $len - $exp) . $digit 
                              . substr($elem, $len - $exp);
                    }
                    push(@new_path, $elem);
                } # foreach $elem
            } # not empty
        } # length > 0
    } # foreach 
    print "   = [" . join(",", @new_path) . "];\n";
    $pexprs{$var} = join(",", @new_path);
} # while <>
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
