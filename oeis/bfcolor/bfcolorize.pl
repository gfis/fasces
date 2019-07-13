#!perl

# Output a b-file as colorized HTML
# @(#) $Id$
# 2019-07-13: -m multi
# 2018-10-28, Georg Fischer
#
#:# Usage:
#:#     perl bfcolorize.pl  [-d 0] [-m 1] [-b bseqno|-r title infile] > output.html
#:#         -b b-number to be read from https://oeis.org/b-number.txt
#:#         -r title if input from STDIN
#:#         -d debug info, 0 = none (default), 1 = some, 2 = more
#:#         -m multiple: 1 = single (default), 2 = double, 4 = 4 chars. per digit
#---------------------------------
use strict;
use integer;
use warnings;

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug  = 0;
my $bseqno = "b136808";
my $filename = "";
my $multi  = 1;
my $sleep  = 2; # seconds
my @pairs = ();
my $title;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-b}) {
        $bseqno   =  shift(@ARGV);
        $title    =  $bseqno;
        @pairs    =  &wget($bseqno);
    } elsif ($opt =~ m{\-d}) {
        $debug    =  shift(@ARGV);
    } elsif ($opt =~ m{\-r}) {
        $filename =  $ARGV[0];
        $title    = $filename;
        @pairs    = ();
        while (<>) { # read from STDIN
            my $line = $_;
            $line =~ s{\s+\Z}{};
            $line =~ s{\A\s+}{};
            if (length($line) > 0 and ($line !~ m{\A\s*\#})) { # non-empty, no comment
                push(@pairs, $line);
            }
        } # while <>
    } elsif ($opt =~ m{\-m}) {
        $multi    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

print &get_html_head($title);
foreach my $pair(@pairs) {
    my ($n, $an) = split(/\s+/, $pair, 2);
    if ($debug >= 1) {
        print "$pair - $n: $an\n";
    }
    if (0) {
    } elsif ($multi == 4) { # 4 chars without digit
    	$an =~ s{((\d)\2*)}{\<span class\=\"d$2\"\>$1$1$1$1<\/span\>}g;
    } elsif ($multi == 2) { # 2 chars without digit
    	$an =~ s{((\d)\2*)}{\<span class\=\"d$2\"\>$1$1\<\/span\>}g;
    } else  { #     == 1    # 1 char with digit (default)
    	$an =~ s{((\d)\2*)}{\<span class\=\"c$2\"\>$1\<\/span\>}g;
    }
    print sprintf("%5d ", $n) . $an . "\n";
} # foreach
print <<"GFis";
</pre>
</body>
</html>
GFis
#----------------------
sub wget {
    # old call: my $otext = &wget("https://oeis.org/search?q=id:$oseqno\\&fmt=text", "$oseqno.text");
    # my ($src_url, $tar_file) = @_;
    my ($xseqno) = @_;
    my $src_url;
    my $tar_file;
    my @result;
    if (0) {
    } elsif ($xseqno =~ m{^A}) {
        $src_url  = "https://oeis.org/search?q=id:$xseqno\\&fmt=text";
        $tar_file = "../store/$xseqno.text";
    } elsif ($xseqno =~ m{^b}) {
        $src_url  = "https://oeis.org/$xseqno.txt";
        $tar_file = "../bfiles/$xseqno.txt";
    } else {
        die "wrong parameter in \"\&wget($xseqno)\"\n";
    }
    if (! -r $tar_file) {
        print STDERR "sleeping $sleep s before wget $tar_file\n";
        sleep $sleep;
        print `wget -o log.tmp -O $tar_file $src_url`;
    }
    my $buffer;
    open(FIL, "<", $tar_file) or die "cannot read $tar_file\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);

    if (0) {
    } elsif ($xseqno =~ m{^b}) {
        @result = grep { m{\S} } # keep non-empty lines only
            map {
                s{\#.*}{};   # remove comments
                s{^\s+}{};   # remove leading whitespace
                s{\s+\Z}{};  # trailing whitespace
                s{\s\s+}{ }; # single space
                $_
            } split(/\r?\n/, $buffer);
        if ($debug >= 3) {
            print "wget: ". join("/", @result) . "\n";
        }
    } else {
        die "wrong parameter in \"\&wget($xseqno)\"\n";
    }
    return @result;
} # wget
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
<meta name="generator" content="https://github.com/gfis/fasces/blob/master/oeis/database/bfcolor.pl" />
<meta name="author"    content="Georg Fischer" />
<meta name="date"      content="2018-10-31" />
<style type="text/css">
body,table,p,td,th
        { font-family: Lucida console,monospace; font-weight: normal; }
table   { border-collapse: collapse; }
td      { padding-right: 4px; }
tr,td,th{ text-align: left; vertical-align:top; }
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
</style>
</head>
<body>
<h2>$title</h2>
<p align="right">
<span class="c0">00</span><span class="c1">11</span><span class="c2">22</span><span class="c3">33</span><span class="c4">44</span><span class="c5">55</span><span class="c6">66</span><span class="c7">77</span><span class="c8">88</span><span class="c9">99</span>
</p>
<pre>
GFis
} # get_html_head
#--------------------------------------
__DATA__
