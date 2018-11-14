#!perl

# Evaluate connection rules
# @(#) $Id$
# 2018-11-14, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl eval_rule.pl [-n maxn] [-r rule]
#------------------------------------------------------
use strict;
use integer;

my $debug  = 0;
my $maxn   = 4096; # max. start value
my $start  = 4;
my $incr   = 6;
my $MAX_RULE = 32;
my $rule   = 5;
while (scalar(@ARGV) > 0) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{n}) {
        $maxn   = shift(@ARGV);
    } elsif ($opt =~ m{r}) {
        $rule   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my @rules = ("0,0", "1,1"
    , "3,4"     # 2
    , "5,4"     # 3
    , "2,8"     # 4
    , "6,8"     # 5
    , "12,16"   # 6
    , "4,16"    # 7
    , "8,32"    # 8
    , "24,32"   # 9
    , "48,64"   # 10
    , "16,64"   # 11
    );
($start, $incr) = split(/\,/, $rules[$rule]);
my @len = (0, 1, 7, 61, 547, 4921, 44287, 398581, 3587227); # OEIS 066443
my $irow = $start;
while ($irow < $maxn) {
    my $result = &get_rule($irow);
    my ($nrule, $tar) = split(/\-\>/, $result);
    print sprintf("%8d%4s:", $irow, &get_degree($irow));
    &output($nrule, $tar);
    my $busy = 1;
    while ($busy == 1) {
		if ($nrule >= 5 and $nrule != 6 and $nrule != 8 and $tar != 1) {
		} else {
			$busy = 0;
		}
        my $src = $tar;
        $result = &get_rule($src);
        ($nrule, $tar) = split(/\-\>/, $result);
        &output($nrule, $tar);
    } # while same isrc
    print "\n";
    $irow += $incr;
} # while $irow
#------------------------
sub output {
    my ($nrule, $tar) = @_;
#   print " ($nrule)->$tar";
#   if ($nrule >= 5 and $nrule != 6 and $nrule != 8) {
        print " $nrule" . &get_degree($tar);
#    }
} # output
#------------------------
sub get_degree {
    my ($irow) = @_;
    my $result = "    ";
    if (0) {
    } elsif (1 and $irow % 7776 - 7776 == -3110) {
        $result = "5";
    } elsif (1 and $irow % 1296 - 1296 ==  -518) {
        $result = "4";
    } elsif (1 and $irow %  216 -  216 ==   -86) {
        $result = "3";
    } elsif (1 and $irow %   36 -  36  ==   -14) {
        $result = "2";
    } elsif (1 and $irow %    6 -   6  ==    -2) {
        $result = "1";
    } else {
        $result = "";
    }
    return $result eq "" ? "    " : "(S$result)";
} # get_degree
#------------------------
sub get_rule {
    my ($irow) = @_;
    my $result = "-1->0";
    my $rule   = 2;
    my $busy   = 1;
    my $tog31  = 3;
    my $exp2_2 = 1;
    my $exp2   = 4;
    my $exp3   = 1;
    my $ilen   = 1;
    while ($busy == 1 and $rule <= $MAX_RULE) {
        my $subconst = $exp2_2 * $tog31;
        if ($irow % $exp2 == $subconst) { # mod cond.
            $busy = 0;
            $result = $rule;
            my $newnode = $exp3 * ($irow - $subconst) / $exp2 + $len[$ilen];
            $result .= "->$newnode";
            if ($debug >= 1) {
                print "rule $rule, exp2 $exp2, exp2-2 $exp2_2, exp3 $exp3 subconst $subconst, ilen $ilen, len[] $len[$ilen]\n";
            }
        } else {
            $rule ++;
            if ($rule % 4 == 1) {
                $ilen ++;
            }
            if ($rule % 2 == 0) {
                $exp2   *= 2;
                $exp2_2 *= 2;
            } else {
                $exp3   *= 3;
                $tog31 = 4 - $tog31;
            }
        } # mod cond.
    } # while rules
    return $result;
} # get_rule
#------------------------
sub get_rule_99 {
    my ($irow) = @_;
    my $rule = 1;
    my $busy = 1;
    while ($busy == 1 and $rule <= $MAX_RULE) {
        $rule ++;
        if (0) {
        } elsif ($irow %    4 ==    3) { $busy = 0; $rule =  2;
        } elsif ($irow %    4 ==    1) { $busy = 0; $rule =  3;
        } elsif ($irow %    8 ==    2) { $busy = 0; $rule =  4;
        } elsif ($irow %    8 ==    6) { $busy = 0; $rule =  5;
        } elsif ($irow %   16 ==   12) { $busy = 0; $rule =  6;
        } elsif ($irow %   16 ==    4) { $busy = 0; $rule =  7;
        } elsif ($irow %   32 ==    8) { $busy = 0; $rule =  8;
        } elsif ($irow %   32 ==   24) { $busy = 0; $rule =  9;
        } elsif ($irow %   64 ==   48) { $busy = 0; $rule = 10;
        } elsif ($irow %   64 ==   16) { $busy = 0; $rule = 11;
        } elsif ($irow %  128 ==   32) { $busy = 0; $rule = 12;
        } elsif ($irow %  128 ==   96) { $busy = 0; $rule = 13;
        } elsif ($irow %  256 ==  192) { $busy = 0; $rule = 14;
        } elsif ($irow %  256 ==   64) { $busy = 0; $rule = 15;
        } elsif ($irow %  512 ==  128) { $busy = 0; $rule = 16;
        } elsif ($irow %  512 ==  384) { $busy = 0; $rule = 17;
        } elsif ($irow % 1024 ==  768) { $busy = 0; $rule = 18;
        } elsif ($irow % 1024 ==  256) { $busy = 0; $rule = 19;
        } elsif ($irow % 2048 ==  512) { $busy = 0; $rule = 20;
        } elsif ($irow % 2048 == 1536) { $busy = 0; $rule = 21;
        } elsif ($irow % 4096 == 3072) { $busy = 0; $rule = 22;
        } elsif ($irow % 4096 == 1024) { $busy = 0; $rule = 23;
        }
    } # while rules
    if ($busy == 0) {
    } else {
        $rule = -1;
    }
    return $rule;
} # get_rule
__DATA__
C:\Users\User\work\gits\fasces\oeis\collatz>perl rule_1_4_7.pl
     4:     7->7    10:     4->4    16:   11->61    22:    5->25
    28:    6->16    34:    4->13    40:    8->34    46:    5->52
    52:    7->88    58:    4->22    64:  15->547    70:    5->79
    76:    6->43    82:    4->31    88:   9->223    94:   5->106
   100:   7->169   106:    4->40   112:  10->142   118:   5->133
   124:    6->70   130:    4->49   136:   8->115   142:   5->160
   148:   7->250   154:    4->58   160:  12->304   166:   5->187
   172:    6->97   178:    4->67   184:   9->466   190:   5->214
   196:   7->331   202:    4->76   208:  11->790   214:   5->241
   220:   6->124   226:    4->85   232:   8->196   238:   5->268
   244:   7->412   250:    4->94   256: 19->4921   262:   5->295
   268:   6->151   274:   4->103   280:   9->709   286:   5->322
   292:   7->493   298:   4->112   304:  10->385   310:   5->349
   316:   6->178   322:   4->121   328:   8->277   334:   5->376
   340:   7->574   346:   4->130   352: 13->2005   358:   5->403
   364:   6->205   370:   4->139   376:   9->952   382:   5->430
   388:   7->655   394:   4->148   400: 11->1519   406:   5->457
   412:   6->232   418:   4->157   424:   8->358   430:   5->484
   436:   7->736   442:   4->166   448: 14->1276   454:   5->511
   460:   6->259   466:   4->175   472:  9->1195   478:   5->538
   484:   7->817   490:   4->184   496:  10->628   502:   5->565
   508:   6->286   514:   4->193   520:   8->439   526:   5->592
   532:   7->898   538:   4->202   544: 12->1033   550:   5->619
   556:   6->313   562:   4->211   568:  9->1438   574:   5->646