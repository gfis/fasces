#!make

# Examine stripped.gz
# @(#) $Id$
# 2018-10-09: gen_all, my_mails
# 2018-09-30, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000
S=8

all: gen_all
#----
# get base data files 'names' and 'stripped' and preprocess/sort the latter
wg_base: wg_stripped wg_names preprocess
wg_stripped:
	wget https://oeis.org/stripped.gz
	rm -f stripped
	gzip -d stripped.gz
wg_names:
	wget https://oeis.org/names.gz
	rm -f names
	gzip -d names.gz
preprocess:
	perl similiar_sequences.pl -h $(H) < stripped | sort    > stripsort.tmp
#----
# regenerate lists for all sequences
gen_all:	a0 a1 a2 a3
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
#------------
deploy: deplin
	scp A*-A*.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
deplin:
	scp index.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
#------------
# delete sequences modified by me
# (1) place new reply emails "Re  changes to A067482 - ..." into ../temp
# (2) make my_mails
my_mails:
	ls -1 ../temp/*.eml | cut -d" " -f 5 | sort | uniq | tee newseq.`date +%Y-%m-%d`.lst
	wc -l newseq*.lst
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	mv ../temp/*.eml ../archive
#------------
# old targets
sim2:
	perl similiar_sequences.pl -p 2 -min $(MIN) -max $(MAX) < stripsort.tmp 
#------------
