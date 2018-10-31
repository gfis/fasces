#!perl

# output a b-file as colorized HTML
# @(#) $Id$
# 2018-10-28, Georg Fischer
#---------------------------------
use strict;
use integer;

my $debug  = 0;
my $minlen = 6;
my $bseqno = "b136808";
my $filename = "";
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
    } elsif ($opt =~ m{m}) {
        $minlen   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

print &get_html_head($title);
foreach my $pair(@pairs) {
    my ($n, $an) = split(/\s/, $pair, 2);
    if ($debug >= 1) {
        print "$pair - $n: $an\n";
    }
    $an =~ s{((\d)\2*)}{\<span class\=\"c\2\"\>\1\<\/span\>}g;
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
/*
.c0     { color: black;  background-color: yellow    ;    }
.c1     { color: black;  background-color: lime;    }
.c2     { color: black;  background-color: red ;     }
.c3     { color: yellow; background-color: blue   }
.c4     { color: white;  background-color: fuchsia }
.c5     { color: white;  background-color: green   ;     }
.c6     { color: yellow; background-color: purple ;          }
.c7     { color: black;  background-color: aqua        }
.c8     { color: red;    background-color: silver; }
.c9     { color: white;  background-color: black        ;     }
*/               
.c0     { color: black;  background-color: yellow    ;    }
.c1     { color: black;  background-color: lime;    }
.c2     { color: black;  background-color: red ;     }
.c3     { color: yellow; background-color: blue   }
.c4     { color: white;  background-color: fuchsia }
.c5     { color: white;  background-color: green   ;     }
.c6     { color: yellow; background-color: purple ;          }
.c7     { color: black;  background-color: aqua        }
.c8     { color: red;    background-color: silver; }
.c9     { color: white;  background-color: black        ;     }
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
