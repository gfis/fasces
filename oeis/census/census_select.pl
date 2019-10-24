#!perl

# Split a CAT25 file with the internal format, separated by empty lines
# @(#) $Id$
# 2019-03-01, Georg Fischer
#
#:# usage:
#:#   perl uncat25.pl [-m mode] [-d debug] [-i] [-o tardir] input > output
#:#   perl uncat25.pl -m text cat25.txt (split into tardir/*.txt, default)
#:#   perl uncat25.pl -m json cat25.txt (split into tardir/*.json, nyi)
#:#   perl uncat25.pl -m comp cat25.txt (compare with tardir/*.json)
#:#       -o target directory, default "./atext"
#:#       -d 0 (none), 1 (more), 2 (most)
#:#       -i (do not ignore missing JSON "id")
#---------------------------------
use strict;
use integer;

# defaults
my $mode    = "text";
my $debug   = 0;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\+01:00"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
if (scalar(@ARGV) == 0) { # print help text
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
#----
# get options
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----

while (<>) {
    s{\A\s+}{}; # leading space
    s{\#.*}{}; # comments
    s{\s+\Z}{}; # trailing whiespace
    s{\s\s+}{ }g; # make a single space
    next if length == 0; # ignore comments and empty lines
    my ($index, $term) = split(/ /);
    if ($term =~ m{0}) { #ignore
    } else {
        my @pairs = $term =~ m{(\d\d)}g;
        my $valid = 1;
        my %hash = ();
        my $count;
        my $digit;
        map { 
            $count = substr($_, 0, 1);
            $digit = substr($_, 1, 1);
            if (defined($hash{$digit})) {
                $valid = 0;
            } else {
                $hash{$digit} = $count;
            }
        } @pairs;
        if ($valid == 1) {
            # print "$index: " . join(", ", @pairs) . "\n";
            my @list = ();
            foreach $digit (sort(keys(%hash))) {
                push(@list, "$hash{$digit},$digit");
            }
            my $census = join(", ", @list);
            my $test   = &census_test($census);
            if ($census eq $test) {
                print "$census\n";
            } else {
                print "invalid: \"$census\" ne \"$test\"\n";
            }
        } # if $valid
    }
} # while <>
#--------
sub census_test {
    my ($parm) = @_;
    $parm =~ s{\A\D+}{}; # leading non-digits
    $parm =~ s{\D+\Z}{};
    my @nums = split(/\D+/, $parm);
    # print "/" . join("/", @nums) . "/\n";
    my %hash = ();
    my $digit;
    foreach $digit (@nums) {
        if (defined($hash{$digit})) {
            $hash{$digit} ++;
        } else {
            $hash{$digit} = 1;
        }
    } # foreach $num
    my @list = ();
    foreach $digit (sort(keys(%hash))) {
        push(@list, "$hash{$digit},$digit");
    }
    return join(", ", @list);   
} # census_test
#================
__DATA__
