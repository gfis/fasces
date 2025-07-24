#!perl

# Generate an SVG matrix from the output of
#   perl hadamard-pl -m square
# @(#) $Id$
# Copyright (c) 2025 Dr. Georg Fischer
# 2025-07-23: copied from ramath/data/presvg1.pl

use strict;
use integer;
use warnings;
#----
# read the raw matrix (hex codes for 2x2 blocks)
# read the matrices
my @planes = ();
my @plane = ( # default planes[0]
 [ 1, 1 ],
 [ 1, 0 ]
);

my $ipla = -1;
while(<DATA>) {
  s/\s+\Z//;
  my $line = $_;
  #                1   1
  if ($line =~ m{\[(\d+)\]}) { # plane header line
    $ipla = $1;
    push(@planes, [@plane]); # previous accumulated plane
    @plane = ();
    #                          (1       1
  } elsif ($line =~ m{\A[0-9a-z]+}) { # line with block codes
    my @terms = split(//, $line);
    push(@plane, [@terms]);
  }
} # while <>
push(@planes, [@plane]); # last accumulated plane
my $rowlen = $ipla * 2; # should be *4, but we read codes [0-9a-f] for 16 possible condensed 2x2 blocks
#--------
# print the SVG header
my $width  = 1600;
my $height = $width;
    my $dx = 1;
    my $dy = $dx;
    my $w  = 1;
    my $h  = $w;
print <<"GFis";
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN"
 "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd" [
 <!ATTLIST svg xmlns:xlink CDATA #FIXED "http://www.w3.org/1999/xlink">
]>
<!--
    2025-07-23, Dr. Georg Fischer: show a Hadamard matrix
-->
<svg width="${width}px" height="${height}px"
  viewBox="0 0 ${rowlen} ${rowlen}"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  >
  <defs>
    <style type="text/css"><![CDATA[
      .k0 { fill: black           }
      .k1 { fill: lightblue       }
      .k2 { fill: lightgreen      }
      .k3 { fill: lightred        }
      .k4 { fill: lightyellow     }
      .k5 { fill: lightorange     }
      .k6 { fill: lightmagenta    }
      .k7 { fill: cyan            }
      .k8 { fill: darkcyan        }
      .k9 { fill: darkmagenta     }
      .ka { fill: darkorange      }
      .kb { fill: darkyellow      }
      .kc { fill: crimson         }
      .kd { fill: forestgreen     }
      .ke { fill: darkblue        }
      .kf { fill: white           }
      rect {
          stroke: black;  stroke-width: 0.02;
          width:  $w;
          height: $h;
      }
    ]]></style>
  </defs>
<title>Hadamard matrix $ipla</title>
<g style="font-size:10">
GFis

if (1) {
  for my $ipla ($#planes..$#planes) {  
    my $x  = 0;
    my $y  = $x;
    my $rowlen = $#{$planes[$ipla][0]} + 1; 
    print "<!-- planes[$ipla], rowlen=$rowlen -->\n";
    for (my $irow = 0; $irow < $rowlen; $irow += 1) {
      for (my $icol = 0; $icol < $rowlen; $icol += 1) { 
        my $x = $icol * $dx;
        my $y = $irow * $dy;
        my $code = $planes[$ipla][$irow][$icol];
        print "<rect class=\"k$code\" y=\"$y\" x=\"$x\" width=\"$w\" height=\"$h\" />\n";
      } # for $icol
    } # for $irow 
  } # for $ipla
}
print <<"GFis";
</g>
</svg>
GFis
__DATA__
# planes[17], rowlen=68
eeddcfcdfeefffcecefefccceecdfcfdde
b42994b0df66ffb4246f6b004620db4b9d
eb42994b0df66ffb4246f6b004620db4b9
e6b42994b0df66ffb4246f6b004620db4b
f66b42994b0df66ffb4246f6b004620db4
ad66b42994b0df66ffb4246f6b004620db
f2d66b42994b0df66ffb4246f6b004620d
ef2d66b42994b0df66ffb4246f6b004620
a4f2d66b42994b0df66ffb4246f6b00462
b04f2d66b42994b0df66ffb4246f6b0046
b904f2d66b42994b0df66ffb4246f6b004
a9904f2d66b42994b0df66ffb4246f6b00
a09904f2d66b42994b0df66ffb4246f6b0
a009904f2d66b42994b0df66ffb4246f6b
f2009904f2d66b42994b0df66ffb4246f6
bd2009904f2d66b42994b0df66ffb4246f
fbd2009904f2d66b42994b0df66ffb4246
bdbd2009904f2d66b42994b0df66ffb424
a9dbd2009904f2d66b42994b0df66ffb42
b09dbd2009904f2d66b42994b0df66ffb4
a909dbd2009904f2d66b42994b0df66ffb
f2909dbd2009904f2d66b42994b0df66ff
ff2909dbd2009904f2d66b42994b0df66f
fff2909dbd2009904f2d66b42994b0df66
bdff2909dbd2009904f2d66b42994b0df6
b9dff2909dbd2009904f2d66b42994b0df
fb9dff2909dbd2009904f2d66b42994b0d
efb9dff2909dbd2009904f2d66b42994b0
a4fb9dff2909dbd2009904f2d66b42994b
f24fb9dff2909dbd2009904f2d66b42994
ad24fb9dff2909dbd2009904f2d66b4299
e2d24fb9dff2909dbd2009904f2d66b429
e62d24fb9dff2909dbd2009904f2d66b42
b462d24fb9dff2909dbd2009904f2d66b4