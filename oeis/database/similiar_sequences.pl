#!perl

# Detect similiar OEIS sequences
# @(#) $Id$
# 2018-10-05: reads &fmt=text
# 2018-10-04: copied from subseq.pl
# 2018-10-01, Georg Fischer 
#
# usage:
#   (1) perl similiar_sequences.pl [-d 0] -h 4 -l 6 < stripped | sort > stripsort.tmp
#   (2) perl similiar_sequences.pl [-d 0] [-min 0] [-max 999999] -p 2 [-s 8] < stripsort.tmp
#       -d      debug level, 0 (none), 1 (some), 2 (more)
#       -h      minimum sequence value where comparision starts 
#       -l      minimum length for both sequences
#       -min    minimal sequence number 
#       -max    maximal sequence number 
#       -p      there must be values >= 10**p in both sequences to be compared
#       -s      sleep so many seconds before each wget request 
#
# file usage:
#   <  stripsort        sequence values sorted by subsequence starting with value >= h
#   <  names            sequence names (titles)
#   <> ../store         directory for locally saved A*.text and b*.txt files
#   >  Amin-Amax.html   resulting output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $action = 2; # 1 = preprocess for sort, 2 = write HTML list
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $higher = 4; # minimum sequence value where comparision starts 
my $minlen = 6; # minimum length for both sequences
my $minseq = 0;
my $maxseq = 999999; # all
my $pow10  = 2; # there must be values >= 10**p in both sequences to be compared
my $sleep  = 8; # sleep 8 s before all wget requests
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{h}) {
        $higher = shift(@ARGV);
        $action = 1;
    } elsif ($opt =~ m{l}) {
        $minlen = shift(@ARGV);
    } elsif ($opt =~ m{min}) {
        $minseq = shift(@ARGV);
    } elsif ($opt =~ m{max}) {
        $maxseq = shift(@ARGV);
    } elsif ($opt =~ m{p}) {
        $pow10  = shift(@ARGV);
        $action = 2;
    } elsif ($opt =~ m{s}) {
        $sleep  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

#----------------------------------------------
# perform one of the actions
if ($action == 1) { # preprocess for sort
    # read file "stripped"
    open(SIP, "<", "stripped") || die "cannot read file \"stripped\"\n";
    while (<SIP>) {
        next if m{\A\s*\#};
        s/\s+\Z//; # chompr
        my ($seqno, $list) = split(/\s+\,/);
        my @sequence = split(/\,/, $list);
        my $ind = 0;
        while ($ind < scalar(@sequence) and $sequence[$ind] < $higher) { # start point
            $ind ++;
        } # while $ind
        if (scalar(@sequence) - $ind >= $minlen) { # long enough
            print join(" ", splice(@sequence, $ind)) 
                . "\t" . join(" ", splice(@sequence, 0, $ind)) 
                . "\t$seqno\n";
        } # long enough
    } # while <>
    close(SIP);
    exit(0); # skip the rest
} # action 1
#----------------------------------------------
# else action == 2
# read file "names"
my @names;
my $seqno; # is printed behind the loop
open(NAM, "<", "names") || die "cannot read file \"names\"\n";
while (<NAM>) {
    s/\s+\Z//; # chompr
    next if m{\A\s*\#}; # skip comments
    my $line = $_;
    $line =~ m{\A(\w)(\d+)\s+(.*)};
    $seqno = $2;
    my $name = $3;
    $name =~ s{\&}{\&amp\;}g;
    $name =~ s{\<}{\&lt\;}g;
    $name =~ s{\>}{\&gt\;}g;
    $name =~ s{(A\d{6})}
              {\<a href\=\"https\:\/\/oeis.org\/search\?q\=id\:$1\" target\=\"_new\"\>$1\<\/a\>}g; 
    $names[$seqno] = $name;
} # while NAM
close(NAM);
print STDERR "$seqno sequence names read\n";

# print HTML header
my $range = sprintf("A%06d-A%06d", $minseq, $maxseq);
open(HTM, ">", "$range.html") or die "cannot write HTML file\n";        
print HTM <<"GFis";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" [
]>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$range - OEIS Similiarities</title>
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/database/subseq.pl" />
<meta name="author"    content="Georg Fischer" />
<style>
body,table,p,td,th
        { font-family: Verdana,Arial,sans-serif; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; vertical-align:top; }
.arr    { background-color: white          ; color: black; }
.bor    { border-left  : 2px solid gray    ; border-top   : 2px solid gray ;  
          border-right : 2px solid gray    ;                                 }
.ref    { border-left  : 2px solid gray    ; border-right : 2px solid gray ; 
          background-color: lightgreen; }
.yel    { border-left  : 2px solid gray    ; border-right : 2px solid gray ; 
          background-color: greenyellow; }
.red    { border-left  : 2px solid gray    ; border-right : 2px solid gray ; 
          background-color: yellow; }
.more   { color:white  ; background-color: blue; }
.dead   { color:white  ; background-color: gray   ; }
.fini   { color:black  ; background-color: turquoise  ; }
</style>
</head>
<body>
<h2>Similiar OEIS Sequences in the Range $range</h2>
<p>
Generated by <a href="https://github.com/gfis/fasces/blob/master/oeis/database/similiar_sequences.pl"
 target="_new">oeis/database/similiar_sequences.pl</a>  $timestamp.<br />
Questions: email <a href="https://oeis.org/wiki/User:Georg_Fischer" target="_new">OEIS user</a> 
<a href="mailto:dr.georg.fischer\@gmail.com">Georg Fischer</a>
<br /><a href=".">all ranges</a>
</p>
<table>
GFis

# process file stripsort
my ($omid, $oleft, $oseqno) = ("a,a,a", "b,b,b", "Axxxxxx");
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

# print HTML trailer
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
$timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
print HTM <<"GFis";
<tr><td class="bor">
$count pairs - $timestamp
    </td></tr> 
</table>
</body>
</html>
GFis
close(HTM);
print "$range $count pairs total - $timestamp\n";

# end main
#-------------------
sub check {
    my ($omid, $oleft, $oseqno, $nmid, $nleft, $nseqno) = @_;
    my $ono   = substr($oseqno, 1) + 0;
    my $nno   = substr($nseqno, 1) + 0;
    if ($nno >= $minseq and $nno <= $maxseq) {
        if (!(($omid  !~ m{\d{$pow10}}o           ) and ($nmid  !~ m{\d{$pow10}}o           ))) {
        my $oname = $names[$ono];
        my $nname = $names[$nno];
        # print STDERR "names: $oname\n       $nname\n";
        if (  ($oname !~ m{$nseqno}               ) and ($nname !~ m{$oseqno}               ) ) {
        if (  ($oname !~ m{Coxeter}               ) and ($nname !~ m{Coxeter}               ) ) {
        if (!(($oname =~ m{ Weyl group }i         ) and ($nname =~ m{ Weyl group }i         ))) {
        if (!(($oname =~ m{McKay\-Thompson series}) and ($nname =~ m{McKay\-Thompson series}))) {
            
            $count ++;
            if (($count & 0x7f) == 0) {
                print STDERR "$count pairs\n";
            }
            my $otext = &wget("https://oeis.org/search?q=id:$oseqno\\&fmt=text", "$oseqno.text");
            my $ntext = &wget("https://oeis.org/search?q=id:$nseqno\\&fmt=text", "$nseqno.text");
            my $obf   = &get_bf($oseqno, $otext);
            my $nbf   = &get_bf($nseqno, $ntext);
            print HTM <<"GFis";
<tr><td class="bor">
    <a href="http://oeis.org/$oseqno" target="_new">$oseqno</a> $oname<br />
    <a href="http://oeis.org/$nseqno" target="_new">$nseqno</a> $nname<br />
    <em>[$count]</em> <strong>$oleft</strong><br />
    <em>[$count]</em> <strong>$nleft</strong><br />
    $omid $obf<br />
    $nmid $nbf</td></tr> 
GFis
            print HTM &compare_content($oseqno, $otext, $nseqno, $ntext);
        } # not both "McKay-Thompson series"
        } # not both " Weyl group "i
        } # not some "Coxeter"
        } # not referenced in other name
        } # numbers >= 10 somewhere
    } # $nseqno in range
} # check
#----------------------
sub compare_content {
    my ($oseqno, $otext, $nseqno, $ntext) = @_;
    my $result ="";
    if ($otext =~ m{$nseqno}) {
        $result .= &get_refs($oseqno, $nseqno, $otext);
    } else {
        $result .= &get_extract($oseqno, "yel", $otext);
    } # $nseqno in $obuf
    if ($ntext =~ m{$oseqno}) {
        $result .= &get_refs($nseqno, $oseqno, $ntext);
    } else {
        $result .= &get_extract($nseqno, "red", $ntext);
    } # $oseqno in $nbuf
    return $result;
} # compare_content
#----------------------
sub get_bf { # extract the range of the b-file, if any
    my ($oseqno, $otext) = @_;
    $oseqno =~ s{\D}{}g;
    my @obuf = split(/\n/, $otext);
    my $result = join("", grep { m{^\%[H]} and m{\>Table of n\,\s*a\(n\) }} @obuf);
    if ($result =~ m{n\s*\=\s*(\d+)\D+(\d+)}) {
        $result = " -&gt; <a href=\"https://oeis.org/A$oseqno/b$oseqno.txt\" target=\"_new\">b$oseqno.txt($1..$2)</a>";
    } else {
        $result = " (gen. b-file)";
    }
    return $result;
} # get_bf
#----------------------
sub get_refs { # extract any lines which refer the other seqno
    my ($oseqno, $nseqno, $otext) = @_;
    my @obuf = map { 
            s{\>($nseqno)\<}{\>\<strong\>$1\<\/strong\>\<}g; 
            $_ 
            } split(/\n/, $otext);
    return "<tr><td class=\"ref\">" 
        . "<a href=\"https://oeis.org/search?q=id:$oseqno\" target=\"_new\">$oseqno</a> "
        . join("", grep { m{$nseqno} } @obuf) . "</td></tr>\n";
} # get_refs
#----------------------
sub get_extract { # extract OFFSET, KEYWORDS and AUTHOR
    my ($oseqno, $class, $otext) = @_;
    my @obuf = split(/\n/, $otext);
    my $result = join(" ", grep { m{^\%[KOA]} } @obuf);
    # A004279 %K easy,nonn %O 0,2 %A _N. J. A. Sloane_.
    $result =~ s{\%A\s*\_([^\_]+)\_}
        {\%A \<a href\=\"https:\/\/oeis.org\/wiki\/User\:$1\" target\=\"_new\"\>$1\<\/a\>};
    $result =~ s{\<br\s*\/\>}{ }g;
    $result =~ s{(\W)more(\W)}{$1\<span class\=\"more\"\>more\<\/span\>$2};
    $result =~ s{(\W)dead(\W)}{$1\<span class\=\"dead\"\>dead\<\/span\>$2};
    return "<tr><td class=\"$class\">"
        . "<a href=\"https://oeis.org/search?q=id:$oseqno\" target=\"_new\">$oseqno</a> "
        . "$result</td></tr>\n";
} # get_extract
#----------------------
sub wget {
    my ($url, $filename) = @_;
    $filename = "../store/$filename";
    my $result;
    if (! -r $filename) {
        print STDERR "sleeping $sleep s before wget $filename\n";
        sleep $sleep;
        print STDERR `wget -o log.tmp -O $filename $url`;
    }
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    read(FIL, $result, 100000000); # 100 MB
    close(FIL); 
    my @buf = map {
        s{^(\%\w)\s+(\w+)\s+}{$1 }; 
        s{(A\d{6})}{\<a href\=\"https\:\/\/oeis.org\/search\?q\=id\:$1\" target\=\"_new\"\>$1\<\/a\>}g; 
        $_ 
        } grep { m{^\%} } split(/\r?\n/, $result);
    $result = join("<br />\n", @buf);
    return $result;
} # wget
#--------------------------------------
__DATA__
https://oeis.org/search?q=id:A007079&fmt=text
# Greetings from The On-Line Encyclopedia of Integer Sequences! http://oeis.org/

Search: id:a007079
Showing 1-1 of 1

%I A007079 M2142
%S A007079 1,2,24,2640,3230080,48251508480,9307700611292160,
%T A007079 24061983498249428379648,855847205541481495117975879680,
%U A007079 427102683126284520201657800159366676480,3035991776725501434069099002640396043332019814400,311112533558482034321687955029997989477274014274150137856000
%N A007079 Number of labeled regular tournaments with 2n+1 nodes.
%D A007079 N. J. A. Sloane and Simon Plouffe, The Encyclopedia of Integer Sequences, Academic Press, 1995 (includes this sequence).
%H A007079 B. D. McKay, <a href="http://cs.anu.edu.au/~bdm/papers/LabelledEnumeration.pdf">Applications of a technique for labeled enumeration</a>, Congress. Numerantium, 40 (1983), 207-221.
%H A007079 B. D. McKay, <a href="http://users.cecs.anu.edu.au/~bdm/papers/rt.pdf">The asymptotic numbers of regular tournaments, Eulerian digraphs and Eulerian oriented graphs</a>, Combinatorica 10 (1990), 367-377.
%H A007079 <a href="/index/To#tournament">Index entries for sequences related to tournaments</a>
%F A007079 a(n) = coefficient of (x1 x2 ... xn)^((n-1)/2) in (x1+x2)(x1+x3)...(x(n-1)+xn) - Jim Ferry (ferry(AT)metsci.com), Sep 29 2005
%t A007079 (* This program is not convenient for more than 5 terms *)
%t A007079 a[n_] := (xx = Sequence @@ Table[ {x[k], 0, n}, {k, 1, 2*n + 1}]; Coefficient[ Normal @ Series[ Product[x[j] + x[k], {j, 1, (2*n + 1) - 1}, {k, j + 1, (2*n + 1)}], xx], Product[x[j] , {j, 1, (2*n + 1)}]^(((2*n + 1) - 1)/2)]); a[0] = 1; Table[a[n], {n, 0, 4}] (* _Jean-François Alcover_, Apr 10 2013 *)
%o A007079 (PARI) /* not convenient for more than 5 terms: */
%o A007079 sym(k)=eval(Str("x" k));
%o A007079 pr(n)=prod(j=1,n-1, prod(k=j+1, n, sym(j) + sym(k) ) );
%o A007079 a(n)=
%o A007079 {
%o A007079     my( p = pr(2*n+1) );
%o A007079     for (k=1, 2*n+1, p = polcoeff(p, n, sym(k) );  );
%o A007079     return( p );
%o A007079 } \\ _Joerg Arndt_, Apr 10 2013
%o A007079 (PARI)
%o A007079 a(n)={ local(M=Map());
%o A007079 my(acc(p, v)=my(z); mapput(M, p, if(mapisdefined(M, p, &z), z+v, v)));
%o A007079 my(recurse(p, i, q, v, e)=if(e<=n, if(i<0, acc(x^e+q, v), my(t=polcoeff(p, i)); for(k=0, if(i==n, 0, t), self()(p, i-1, (t-k+x*k)*x^i+q, binomial(t, k)*v, e+t-k)))));
%o A007079 my(iterate(v, k, f)=for(i=1, k, v=f(v)); v);
%o A007079 iterate(Mat([1, 1]), 2*n, src->M=Map(); for(i=1, matsize(src)[1], my(p=src[i, 1]); recurse(p, poldegree(p), 0, src[i, 2], 0)); Mat(M))[1,2]
%o A007079 } \\ _Andrew Howroyd_, Jan 08 2018
%K A007079 nonn,nice
%O A007079 0,2
%A A007079 _N. J. A. Sloane_, _Mira Bernstein_
%E A007079 a(11) from _Andrew Howroyd_, Jan 08 2018

# Content is available under The OEIS End-User License Agreement: http://oeis.org/LICENSE