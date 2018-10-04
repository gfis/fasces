#!perl

# Remove all lower values from stripped
# @(#) $Id$
# 2018-10-01, Georg Fischer 
#---------------------------------
use strict;
use integer;
my $higher = 8;
my $debug = 0;

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{h}) {
        $higher = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

print <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Similiar OEIS Sequences</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/database/subseq.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; vertical-align:top; }
.arr    { background-color: white          ; color: black; }
.bor    { border-left  : 1px solid gray    ; border-top   : 1px solid gray ;
.seg    { font-weight: bold; }
.sei    { font-weight: bold; font-style    : italic; }
</style>
</head>
<body>
<h2>Similiar OEIS Sequences</h2>
<table>
GFis

my ($omid, $oleft, $oseqno) = ("", "", "Axxxxxx");
my $count = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my ($nmid, $nleft, $nseqno) = split(/\t/);
    if (($nmid =~ m{^$omid}) or ($omid =~ m{^$nmid})) {
        if ($oseqno lt $nseqno) {
            &check($omid, $oleft, $oseqno, $nmid, $nleft, $nseqno);
        } else {
            &check($nmid, $nleft, $nseqno, $omid, $oleft, $oseqno);
        }
    } # if substring
    ($omid, $oleft, $oseqno) = ($nmid, $nleft, $nseqno);
} # while <>
print <<"GFis";
</table>
</body>
</html>
GFis
#-------------------
sub check {
        my ($omid, $oleft, $oseqno, $nmid, $nleft, $nseqno) = @_;
        my $oname = substr(`grep -E \"^$oseqno\" names`, 8);
        my $nname = substr(`grep -E \"^$nseqno\" names`, 8);
        if (  ($oname !~ m{$nseqno}               ) and ($nname !~ m{$oseqno}               ) ) {
        if (  ($oname !~ m{Coxeter}               ) and ($nname !~ m{Coxeter}               ) ) {
        if (!(($oname =~ m{ Weyl group }i         ) and ($nname =~ m{ Weyl group }          ))) {
        if (!(($oname =~ m{McKay\-Thompson series}) and ($nname =~ m{McKay\-Thompson series}))) {
            $count ++;
            print <<"GFis";
<tr><td class="bor">
    <a href="http://oeis.org/$oseqno" target="_new">$oseqno</a> $oname<br />
    <a href="http://oeis.org/$nseqno" target="_new">$nseqno</a> $nname<br />
    <em>[$count]</em> <strong>$oleft</strong><br />
    <em>[$count]</em> <strong>$nleft</strong><br />
    $omid<br />
    $nmid</td></tr> 
GFis
        } # not both "McKay-Thompson series"
        } # not both " Weyl group "i
        } # not some "Coxeter"
        } # not referenced in other name
} # check
__DATA__
