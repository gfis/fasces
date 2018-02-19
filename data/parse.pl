#!/usr/bin/perl

# Read syntax descriptions of FASS curves and expand the nodes
# @(#) $Id$
# 2018-02-18, Georg Fischer
# usage:
#   perl Kn_syntex.pl n | perl parse.pl
#---------------------------------------------
use strict;
my %hash = (); # stores the generated subcurves

while (<>) {
	print;
	s/\s+\Z//; # chompr
	next if m{\s*\#}; # starts with comment
	my ($var, $pdesc) = split(/\s*\=\s*/, $_);
	$pdesc =~ s{[\;\[\] ]}{}g; # remove all superfluous chars.
	my @path = ();
	foreach my $desc (split(/\,/, $pdesc)) {
		# print "$desc\n";
		if (length($desc) == 0) { # empty (A0 only)
			push(@path, "");
		} elsif ($desc =~ m{\A\d}) { # digits only
			push(@path, $desc);
		} else { # length > 0
			my $reverse = 0;
			if ($desc =~ m{\A\/}) {
				$desc = substr($desc, 1);
				$reverse = 1;
			}
			my ($name, $pos, $val) = ("", "", "");
			($name, $pos, $val) = split(/[\+\.]/, $desc);
			my @temp = split(/\,/, $hash{$name});
			my @previous = $reverse > 0 ? reverse(@temp) : @temp;
			# print "# read $name+$pos.$val = [" . join(",", @previous) . "]\n";
			if (scalar(@previous) == 0) {
				push(@path, $val);
			} else {
				foreach my $node (@previous) {
					my $len = length($node);
					if ($pos ne "") {
						$node = substr($node, 0, $len - $pos) . $val 
						      . substr($node, $len - $pos);
					}
					push(@path, $node);
				} # foreach $node
			} # scalar > 0
		} # length > 0
	} # foreach	
	print "   = [" . join(",", @path) . "];\n";
	$hash{$var} = join(",", @path);
} # while <>

sub genInner { # generate a path description for the "inner S" structure from [1,2,3]
    my ($width) = @_;
    my $result = "";
    return $result;
} # genInner

sub genOuter { # generate a path description for the "outer meander" structure from [0, inner, 4]
    my ($width, $level) = @_;
    my $result = "";
    return $result;
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
