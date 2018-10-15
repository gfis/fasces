#!perl

# Polish Wellon's sequence overview for A136xxx
# @(#) $Id$
# 2018-10-15, Georg Fischer 
#
#
# usage:
#   perl polish_squaredig.pl < wellons_restored.html
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $action = "gen"; # "prep"rocess for sort, "gen"erate HTML lists
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
    } elsif ($opt =~ m{\-a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-h}) {
        $higher = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $minlen = shift(@ARGV);
    } elsif ($opt =~ m{\-min}) {
        $minseq = shift(@ARGV);
    } elsif ($opt =~ m{\-max}) {
        $maxseq = shift(@ARGV);
    } elsif ($opt =~ m{\-p}) {
        $pow10  = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $sleep  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

#----------------------------------------------
# perform one of the actions
if (0) {
} elsif($action =~ m{^prep}) { # preprocess for sort
    exit(0);
#----------------------
} elsif ($action =~ m{^dumm}) { # yet another?preprocess for sort
    exit(0);
#----------------------------------------------
} # else ($action =~ m{^gen}) { # generate
# read file "names"
my %terms; # aseqno . $term indexed by $digits
my $count = 0;
my @buffer;
open(SIP, "<", "squaredig.tmp") || die "cannot read file \"names\"\n";
while (<SIP>) {
    s/\s+\Z//; # chompr
    next if m{\A\s*\#}; # skip comments
    my $line   = $_;
    $line =~ m{^(\w+)\s+(\d+)\s*(.*)};
    my $aseqno = $1;
    my $digits = $2;
    my $term   = $3;
    if (! defined($terms{$digits})) {
        $terms{$digits} = "$aseqno $term";
        # print STDERR "terms{$digits} = \"$aseqno $term\"\n";
    } else {
        print "duplicate $digits\n";
    }
    push(@buffer, " <a href=\"https://oeis.org/$aseqno\" target=\"_new\">$aseqno</a> $digits $term");
    $count ++;
} # while SIP
close(SIP);
print "Terms for $count sequences read\n";

# print HTML header
my $range = sprintf("A%06d-A%06d", $minseq, $maxseq);
open(HTM, ">", "squaredig.html") or die "cannot write HTML file\n";        
print HTM &get_html_head("Same Digits in Squares");

# process file wellons-restored.html
$count = 0;
while (<>) {
    s/\s+\Z//; # chompr
    # [<a href="http://jonathanwellons.com/shared-digits/data/0-1-2-3-4.html">0,1,2,3,4</a>]  ... 
    my $line = $_;
    $line =~ s{\s*\.\.\.\s*}{ }g;
    if ($line =~ m{\.html\"\>([0-9\,]+)\<\/a\>}) { # link line
        my $digits = $1;
        my $cdigs  = $digits;
        $digits =~ s{\,}{}g;
        if (defined($terms{$digits})) {
            my ($aseqno, $term) = split(/ /, $terms{$digits});
            $line =~ s{\"http[^\"]+\"}{\"https\:\/\/oeis.org\/$aseqno\" target\=\"_new\" title\=\"$terms{$digits}\"};
            print HTM "$line\n";
            # print "$aseqno $digits $terms{$digits}\n";
            $count ++;
        } else {
            print HTM "($cdigs) ";
        }
    } else {
        print HTM "$line\n";
    }
} # while <>

print "$count links replaced\n";
#-------------------
print HTM <<"GFis";
<h3>List of OEIS Sequences</h3>
<pre>
GFis
print HTM join("\n", @buffer) . "\n";
print HTM <<"GFis";
</pre>
</body>
</html>
GFis
close(HTM);

# end action eq "gen"
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
.gyel   { border-left  : 2px solid gray    ; border-right : 2px solid gray ; 
          background-color: greenyellow; }
.warn   { border-left  : 2px solid gray    ; border-right : 2px solid gray ; 
          background-color: yellow; }
.more   { color:white  ; background-color: blue; }
.dead   { color:white  ; background-color: gray   ; }
.fini   { color:black  ; background-color: turquoise  ; }
</style>
</head>
GFis
} # get_html_head
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
#----------------------
regen.date.log:

make[1]: Entering directory '/cygdrive/c/Users/User/work/gits/fasces/oeis/database'
perl similiar_sequences.pl -p 2 -min 000000 -max 049999 < stripsort.tmp 
320328 sequence names read
128 pairs
256 pairs
384 pairs
512 pairs
A000000-A049999 608 pairs total - 2018-10-11 09:35:26
perl similiar_sequences.pl -p 2 -min 050000 -max 099999 < stripsort.tmp 
320328 sequence names read
128 pairs
256 pairs
384 pairs
512 pairs
640 pairs
A050000-A099999 762 pairs total - 2018-10-11 09:35:53
