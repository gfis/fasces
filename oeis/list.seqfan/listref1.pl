#!perl

# References auf sequences in list.seqfan.eu
# @(#) $Id$
# 2018-10-28, Georg Fischer
#
# usage:
#   (1) perl listref.pl -a prep [-d 0] -h 4 -l 8 < stripped | sort > stripsort.tmp
#   (2) perl simseq.pl [-a gen] [-d 0] [-min 0] [-max 999999] -p 2 [-s 8] [-n] < stripsort.tmp
#   (3) perl simseq.pl -a index < regen.date.log > index.html
#   (4) perl simseq.pl -a wget  < newseq.data.lst
#   (5) perl simseq.pl -a name  < names > namurl.tmp
#   (6) perl simseq.pl -a bfc   Ammmmmm-Annnnnn
#       -a      action:
#          "gen"erate HTML list (default),
#          "prep"rocess,
#          "index".html,
#          "wget" only
#          "name" preprocessing,
#          "bfc"  fetch and compare b-files
#       -d      debug level, 0 (none), 1 (some), 2 (more)
#       -h      minimum sequence value where comparision starts
#       -l      minimum length for both sequences
#       -min    minimal sequence number
#       -max    maximal sequence number
#       -n      = 1 (0) do (not) read file namurl.tmp
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
my $commandline = join(" ", @ARGV);

# get options
my $action = "gen"; # "prep"rocess for sort, "gen"erate HTML lists
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $higher = 4; # minimum sequence value where comparision starts
my $minlen = 8; # minimum length for both sequences
my $minseq = 0;
my $maxseq = 999999; # all
my $readnu = 1; # = 1 (0) do (not) read file namurl.tmp
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
    } elsif ($opt =~ m{\-n}  ) {
        $readnu = shift(@ARGV);
    } elsif ($opt =~ m{\-p}) {
        $pow10  = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $sleep  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
my $range = sprintf("A%06d-A%06d", $minseq, $maxseq);
my @names; # with links to http://oeis.org/Axxxxxx
my @nawol; # without links
#----------------------------------------------
my $state = "init";
my @buffer = ();
my $sender;
my $header;
my $subject;
my $date;
my $messid;
my $pempty = 1; # whether previous line was empty
while (<>) {
	my $line = $_;
	$line =~ s{\s+\Z}{}; # trim  trailing whitespace
	if ($debug >= 1) {
		print "state=$state line=$line\n";
	}
	if ($pempty == 1 and ($line =~ m{^From (\S+) at (\S+)\s+(\w{3}\s+\w{3}\s+\d+\s+\d+\:\d+\:\d+\s+\d{4})})) {
		# start of new message
		($sender, $subject, $messid) = ("","","","");
		$date = $3;
		$state = "head";
		@buffer = ();
	} elsif ($state eq "head") {
		if (length($line) == 0) {
			$state = "body";
			&process();
		} elsif ($line =~ m{^From\: (\S+) at (\S+)}) {
			$sender = "$1 at $2";
		} elsif ($line =~ m{^Date\: (.+)}) {
		} elsif ($line =~ m{^Subject\: (.+)}) {
			$subject = $1;
		} elsif ($line =~ m{^Message-ID\: (.+)}) {
			$messid = $1;
		} else {
		}
	} elsif ($state eq "body") {
		push(@buffer, $line);
	} else {
	}
	$pempty = length($line) == 0 ? 1 : 0;
} # while <>
#-------------
sub process {
	print "$date\t$subject\t$sender\n";
} # process
#-------------
__DATA__
From georg.fischer at t-online.de  Wed Oct 10 11:48:24 2018
From: georg.fischer at t-online.de (Georg.Fischer)
Date: Wed, 10 Oct 2018 11:48:24 +0200
Subject: [seqfan]  Coincidence search lists
In-Reply-To: <5BBBD5BC.1020301@uni-kassel.de>
References: <5BBBD5BC.1020301@uni-kassel.de>
Message-ID: <a1aa88af-bbd2-ff24-5c4f-9a336e91be0e@t-online.de>

Hello seqfans,

