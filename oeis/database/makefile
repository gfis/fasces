#!make

# Examine stripped.gz
# @(#) $Id$
# 2018-09-30, Georg Fischer 
#---------------------------------
H=4

all: s8 sub8
s8:
	perl higher.pl -h $(H) stripped | sort > s8.tmp
sub8:
	perl subseq.pl s8.tmp > s8.htm
