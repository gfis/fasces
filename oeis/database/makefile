#!make

# Examine stripped.gz
# @(#) $Id$
# 2018-09-30, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000

all: s8 
s8:
	perl higher.pl -h $(H) stripped | sort > s8.tmp
sub8:
	perl subseq.pl             s8.tmp > s8.htm
sim1:
	perl similiar_sequences.pl -h $(H) < stripped | sort    > stripsort.tmp
sim2:
	perl similiar_sequences.pl -p 2 -min $(MIN) -max $(MAX) < stripsort.tmp 
deploy:
	scp similiar_sequences.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database

