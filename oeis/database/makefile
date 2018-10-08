#!make

# Examine stripped.gz
# @(#) $Id$
# 2018-09-30, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000
S=8

all: sim2
sim1:
	perl similiar_sequences.pl -h $(H) < stripped | sort    > stripsort.tmp
sim2:
	perl similiar_sequences.pl -p 2 -min $(MIN) -max $(MAX) < stripsort.tmp 
deploy:
	scp similiar_sequences.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
#------------
a0:	a00 a05 
a1:	a10 a15
a2:	a20 a25
a3:	a30 a35
a00:
	perl similiar_sequences.pl -p 2 -min 000000 -max 049999 < stripsort.tmp 
a05:
	perl similiar_sequences.pl -p 2 -min 050000 -max 099999 < stripsort.tmp 
a10:
	perl similiar_sequences.pl -p 2 -min 100000 -max 149999 < stripsort.tmp 
a15:
	perl similiar_sequences.pl -p 2 -min 150000 -max 199999 < stripsort.tmp 
a20:
	perl similiar_sequences.pl -p 2 -min 200000 -max 249999 < stripsort.tmp 
a25:
	perl similiar_sequences.pl -p 2 -min 250000 -max 299999 < stripsort.tmp 
a30:
	perl similiar_sequences.pl -p 2 -min 300000 -max 349999 < stripsort.tmp 
a35:
	perl similiar_sequences.pl -p 2 -min 350000 -max 399999 < stripsort.tmp 

