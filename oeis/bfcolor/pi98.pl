#!perl

# Output a file as colorized HTML
# @(#) $Id$
# 2022-08-09: -vf; VF=41
# 2019-07-13: -m multi
# 2018-10-28, Georg Fischer
#
#:# Usage:
#:#     perl pi98.pl > output.html
#
# CF. https://www.angio.net/pi/piquery
# https://www.angio.net/pi/digits/10000.txt
#---------------------------------
use strict;
use integer;
use warnings;

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug  = 0;
my $filename = "pi10k.txt";
my $title  = "Pi 9.8.";
my $mode   = "vf";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    =  shift(@ARGV);
    } elsif ($opt =~ m{\-v?f}) {
        $filename =  $ARGV[0];
        $mode     = "vf";
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

print &get_html_head($title);
my $old_class = "";
my $ix;
my $id = 0;
if (0) {
} elsif ($mode eq "vf") {
    $title = "Pi 9.8.";
    my $buffer;
    open(FIL, "<", $filename) || die "cannot read $filename";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);
    $buffer = substr($buffer, 2);
    my $len = length($buffer);
    print "<span class=\"cn\">3.";
    $ix = 0;
    $len = 4096;
    while($ix < $len) {
        my $a2 = substr($buffer, $ix, 2);
        my $an = substr($a2, 0, 1);
        if (0) {
        } elsif ($a2 eq "98") {
            &out1($an, "c98");
            $an = substr($a2, 1, 1);
            &out1($an, "c98");
        } else {
            &out1($an, "c$an");
        }
    }
} else {
    die "invalid mode $mode";
}
print <<"GFis";
</pre>

</body>
<table width="720px"><tr><td>
This image was created for Veronika Fischer on her forty-first birthday. 
The square of sixty-four rows with sixty-four columns shows the first four thousand ninety-six 
decimal digits of Archimedes&apos; number <strong>&pi; (Pi)</strong>, the most important transcendental mathematical constant.
The digits below six are shown in red, while the other digits are in orange, and occurences 
of the digit pairs nine, eight are successively highlighted.
</td></tr>
</table>
</html>
GFis
#----
sub out1 {
    my ($ch, $class) = @_;
    if ($class ne $old_class) {
        print "</span><span class=\"$class\"";
        if ($class eq "c98") {
            $id ++;
            print " id=\"$id\"";
        }
        print ">";
        $old_class = $class;
    }
    print " $ch";
    $ix ++;
    if ($ix % 64 == 0) {
        print "</span>\n  <span class=\"$class\"";
        if ($class eq "c98") {
            $id ++;
            print " id=\"$id\"";
        }
        print ">";
    }
}   
#-----------------------------
sub get_html_head {
    my ($title) = @_;
    return <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$title</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/database/pi98.pl" />
<meta name="author"    content="Georg Fischer" />
<meta name="date"      content="2022-08-09" />
<style type="text/css">
body,table,p,td,th
        { font-family: Lucida console,monospace; font-weight: normal; font-size: 10px; line-height: 10px }
table   { border-collapse: collapse; font-family: Arial }
td      { padding-left: 10px; }
tr,td,th{ text-align: left; vertical-align:top; }
.cn     { color: black        ;  background-color: white  ; }
.c0,.c1,.c2,.c3,.c4
        { color: darkorange   ;  background-color: crimson   ; }
.c5,.c6,.c7,.c8,.c9
        { color: firebrick    ;  background-color: orange    ; }
.c98
        { color: orange       ;  background-color: firebrick ; }
.c98i
        { color: black        ;  background-color: yellow      }
</style>
</head>
<script language="javascript">
function delay(){
    return new Promise((resolve) => {
         setTimeout(() => resolve(), 1600)
    });
}
async function high98() 
{
  while (true) 
  {
    for (var ix=1; ix <= 49; ix ++){
          var elem =  document.getElementById(ix)
          elem.className = "c98i";
          await delay();
          elem.className = "c98";
    }
  }
}
</script>
<body onload="high98()">
<pre>
GFis
} # get_html_head
#--------------------------------------
__DATA__
.c0,.c1,.c2,.c3,.c4
        { color: black  ;  background-color: yellow ; }
.c5,.c6,.c7,.c8,.c9
        { color: white  ;  background-color: red    ; }

/*
.c98
        { color: lightyellow  ;  
          animation: mymove 1s infinite;
        }
\@keyframes mymove {
    0\%  {background-color: darkred;}
   50\%  {background-color: indianred;}
  100\%  {background-color: darksalmon;}
}
*/
