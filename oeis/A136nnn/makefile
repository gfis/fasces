#!make

# OEIS Sequences A136nnn from Jonathan Wellons
# @(#) $Id$
# 2018-10-11, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000
S=8
CODE=0146

all: eval
#----
eval:
	perl a136nnn.pl -c $(CODE)
#----
getseq: getseq1 getseq2
getseq1:
	rm -f *.tmp
	grep -E "^A13[67]" ../database/names      > names1.tmp
	grep -E " and the square of "    names1.tmp > names2.tmp
	wc -l names2.tmp
	grep -E "^A13[67]" ../database/stripped   > strip1.tmp
getseq2:
	cut -b 1-7 names2.tmp > seqno.tmp
	grep -f seqno.tmp strip1.tmp > strip2.tmp
	wc -l strip2.tmp
getseq3:
	sed -e "s/Numbers/;/g" -e "s/ and /,/g" -e "s/[Na-z., ]//g" -e "s/;/ /g" \
		names2.tmp > names3.tmp
	join names3.tmp strip2.tmp > squaredig.tmp
#----
dummy:
	make regen 2>&1 | tee regen.`date +%Y-%m-%d`.log
	grep total        regen.`date +%Y-%m-%d`.log
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
regen:	a0 a1 a2 a3
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
	scp A*-A*.html index.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
deplin:
	scp index.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
#------------
# delete sequences modified by me
# (1) place new reply emails "Re  changes to A067482 - ..." into ../temp
# (2) make my_mails
my_mails: mail1 mail2
mail1:
	ls -1 ../temp/*.eml | cut -d" " -f 5 | sort | uniq | tee newseq.`date +%Y-%m-%d`.lst
	wc -l newseq*.lst
mail2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	mv ../temp/*.eml ../archive
#------------
# old targets
sim2:
	perl similiar_sequences.pl -p 2 -min $(MIN) -max $(MAX) < stripsort.tmp 
#------------
