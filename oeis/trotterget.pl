#!perl

# get all URLs contained in an HTML file and/or clean off wayback inserts
# @(#) $Id$
# 2018-04-05, Georg Fischer
# usage:
#   perl trotterget.pl -u contents.html             - download and clean all files from the Internet archive
#   perl trotterget.pl -l contents.html             - list all files in contents.html
#   diff .. | perl trotterget.pl -a                 - generate hidden_contents.html
#   perl -i.way trotterget.pl -i subdir/file.html   - clean a single file in place
#--------------------------------
use LWP::Simple;
my $fetched = "/web/20041209003827/http://www.trottermath.net:80";
$fetched = "/web/20051108141455/http://www.trottermath.net:80";
my $prefix = "https://web.archive.org$fetched";
my $local  = "trottermath.net";
my $content;

my $mode = shift(@ARGV);
if (0) {
} elsif ($mode =~ m{\-a}) {
    print <<'GFis';
<html>
<head>
<title>Hidden WTM Contents</title>
</head><body>
<h2>Hidden WTM Contents</h2>
The following files with a size &gt; 0 were not linked in Terry Trotter's main <a href="contents.html">contents</a>
page of 2004. The files with size 0 were contained in the WordPress site up to 2012, but they were hacked
and therefore they are omitted here.
<pre>
GFis
    while (<>) {
        s{\s+\Z}{}; # chompr
        s{\s+\>\s+trottermath.net\/}{};
        my $name = $_;
        my $size = -s "trottermath.net/$name";
        if ($size > 0) {
	        print sprintf("%8d  ", $size) . "<a href=\"$name\">$name</a>\n";
        } else {
	        print sprintf("%8d  ", $size) . "$name\n";
        }
    } # while <>
    print <<'GFis';
</pre>
</body>
</html>
GFis
} elsif ($mode =~ m{\-i}) {
    undef $/;
    $content = <>;
    my $lenorg = length($content);
    &process(); # slurp mode
    print STDERR "$ARGV[0]: length $lenorg -> " . length($content) . "\n";
    print $content;
} elsif ($mode =~ m{\-l}) {
    while (<>) {
        if (m{a\s+href\=\"([a-z]+)\/([^\"]+)\"}) { # single URL
            my $dir  = $1;
            my $file = $2;
            my $name = "trottermath.net/$dir/$file";
            my $size = -s $name;
           	print "$name\n";
        } # single URL
    } # while <>
} elsif ($mode =~ m{\-u}) {
    while (<>) {
        if (m{a\s+href\=\"([a-z]+)\/([^\"]+)\"}) { # single URL
            my $dir  = $1;
            my $file = $2;
            my $url = "$dir/$file";
            mkdir $dir;
            $content = get("$prefix/$url");
            &process();
            print STDERR "fetched $prefix/$url " . length($content) . " chars.\n";
            open(OUT, ">", "$local/$url") or die "cannot write $local/$url\n";
            print OUT $content;
            close(OUT);
        } # single URL
    } # while <>
} else {
    die "invalid mode \"$mode\"\n";
}
#----
sub process {
    &cut("<!--\nplayback timings (ms):"
        ,"-->"                                      );
    &cut("<script"
        ,"<!-- End Wayback Rewrite JS Include -->"  );
    &cut("<!-- BEGIN WAYBACK TOOLBAR INSERT -->"
        ,"<!-- END WAYBACK TOOLBAR INSERT -->"      );
    $content =~ s{(src|href)=\"\/web\/200\w*\/http\:\/\/www\.trottermath\.net\:80\/([^\"]+)\"}{\1=\"../\2\"}g;
    $content =~ s{\<\/font\>\<\/body\>}{\n</font></body>}g;
    $content = join("\n", grep { ! m{viagra} } split(/\n/, $content));
} # process
#----
sub cut {
    my ($init, $term) = @_;
    my $posi = index($content, $init);
    if ($posi >= 0) {
        my $post = index($content, $term, $posi);
        if ($post > $posi) {
            $content = substr($content, 0, $posi) . substr($content, $post + length($term));
        }
    }
} # cut
