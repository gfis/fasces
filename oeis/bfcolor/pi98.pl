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
</html>
GFis
#----
sub out1 {
    my ($ch, $class) = @_;
    if ($class ne $old_class) {
        print "</span><span class=\"$class\""
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
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; vertical-align:top; }
.cn     { color: black        ;  background-color: white  ; }
.c0,.c1,.c2,.c3,.c4
        { color: darkorange   ;  background-color: crimson   ; }
.c5,.c6,.c7,.c8,.c9
        { color: firebrick    ;  background-color: orange    ; }
.c98
        { color: lightyellow  ;  
          animation: mymove 1s infinite;
        }
\@keyframes mymove {
    0\%  {background-color: darkred;}
   50\%  {background-color: indianred;}
  100\%  {background-color: darksalmon;}
}
</style>
</head>
<body>
<pre>
GFis
} # get_html_head
#--------------------------------------
__DATA__
.c0,.c1,.c2,.c3,.c4
        { color: black  ;  background-color: yellow ; }
.c5,.c6,.c7,.c8,.c9
        { color: white  ;  background-color: red    ; }



.c0,.c2,.c4,.c6,.c8
        { color: black  ;  background-color: yellow ; }
.c1,.c3,.c5,.c7,.c9
        { color: white  ;  background-color: red    ; }



.c0     { color: black  ;  background-color: yellow ; }
.c1     { color: black  ;  background-color: lime   ; }
.c2     { color: black  ;  background-color: red    ; }
.c3     { color: yellow ;  background-color: blue   ; }
.c4     { color: white  ;  background-color: fuchsia; }
.c5     { color: white  ;  background-color: green  ; }
.c6     { color: yellow ;  background-color: purple ; }
.c7     { color: black  ;  background-color: aqua   ; }
.c8     { color: red    ;  background-color: silver ; }
.c9     { color: white  ;  background-color: black  ; }
                           
.d0     { color: yellow ;  background-color: yellow ; }
.d1     { color: lime   ;  background-color: lime   ; }
.d2     { color: red    ;  background-color: red    ; }
.d3     { color: blue   ;  background-color: blue   ; }
.d4     { color: fuchsia;  background-color: fuchsia; }
.d5     { color: green  ;  background-color: green  ; }
.d6     { color: purple ;  background-color: purple ; }
.d7     { color: aqua   ;  background-color: aqua   ; }
.d8     { color: silver ;  background-color: silver ; }
.d9     { color: black  ;  background-color: black  ; }
