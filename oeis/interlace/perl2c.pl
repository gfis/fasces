#!/usr/bin/perl

#------------------------------------------------------------------ 
# convert simple Perl programs to C++
# @(#) $Id: perl2c.pl 221 2009-08-11 06:08:05Z gfis $
# 2009-06-17, Georg Fischer: copied from parm2.pl
# Usage: 
#   perl perl2c.pl perl-file > c-file
#------------------------------------------------------------------ 
#
#  Copyright 2009 Dr. Georg Fischer <punctum at punctum dot kom>
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

use strict;

    while (<>) {
        if (s[\#][\/\*] > 0) {
            s[(\r?\n)][ */$1];
        }
        s[\s*use\s+strict\s*\;][int main(argc, argv) int argc; char *argv\[\]; \{];
        s[\A(\s*)my(\s)][${1}int$2]g;
        s[\&(\w+)][$1]g;
        s[\Asub\s+(\w+)][int $1()];
        s[\selsif\s][ else if ];
        s[\$][]g;
        s{\@(\w+)}{$1\[4095\]};
        s[print\s+sprintf][printf]g;
        print;
    } # while <>
    print "} /* main */\n";
__DATA__
