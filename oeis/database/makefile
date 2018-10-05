#!make

# Examine stripped.gz
# @(#) $Id$
# 2018-09-30, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=500

all: sim2
sim1:
	perl similiar_sequences.pl -h $(H) < stripped | sort    > stripsort.tmp
sim2:
	perl similiar_sequences.pl -p 2 -min $(MIN) -max $(MAX) < stripsort.tmp 
deploy:
	scp similiar_sequences.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database

