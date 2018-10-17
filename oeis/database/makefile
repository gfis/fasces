#!make

# Examine stripped.gz
# @(#) $Id$
# 2018-10-17: P=3
# 2018-10-09: gen_all, my_mails
# 2018-09-30, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000
S=8
P=3

all: 
	# targets: new = prepare newseq regen (in that order)
new: prepare newseq regen
#----
# get base data files 'names' and 'stripped' and 
# preprocess/sort the latter
prepare: prep1 prep2 prep3
prep1:
	wget https://oeis.org/stripped.gz
	rm -f stripped
	gzip -d stripped.gz
prep2:
	wget https://oeis.org/names.gz
	rm -f names
	gzip -d names.gz
prep3:
	perl similiar_sequences.pl -a prep -h $(H) < stripped | sort    > stripsort.tmp
#----
# regenerate lists for all sequences
regen: regen1 index deploy
regen1:
	make regen4 2>&1 | tee regen.`date +%Y-%m-%d`.log
regen4:	A000 A100 A200 A300
A000:	A00 A05 
A100:	A10 A15
A200:	A20 A25
A300:	A30 A35
A00:
	perl similiar_sequences.pl -p $(P) -min 000000 -max 049999 < stripsort.tmp 
A05:
	perl similiar_sequences.pl -p $(P) -min 050000 -max 099999 < stripsort.tmp 
A10:
	perl similiar_sequences.pl -p $(P) -min 100000 -max 149999 < stripsort.tmp 
A15:
	perl similiar_sequences.pl -p $(P) -min 150000 -max 199999 < stripsort.tmp 
A20:
	perl similiar_sequences.pl -p $(P) -min 200000 -max 249999 < stripsort.tmp 
A25:
	perl similiar_sequences.pl -p $(P) -min 250000 -max 299999 < stripsort.tmp 
A30:
	perl similiar_sequences.pl -p $(P) -min 300000 -max 349999 < stripsort.tmp 
A35:
	perl similiar_sequences.pl -p $(P) -min 350000 -max 399999 < stripsort.tmp 
#------------
index:
	grep warnings                         regen.`date +%Y-%m-%d`.log
	perl similiar_sequences.pl -a index < regen.`date +%Y-%m-%d`.log > index.html
#------------
deploy: 
	scp *.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
deplin:
	scp index.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
#------------
# delete sequences modified by me
# (1) place new reply emails "Re  changes to A067482 - ..." into ../temp
# (2) make my_mails
newseq: news1 news2
news1:
	ls -1 ../temp/*.eml | cut -d" " -f 5 | sort | uniq | tee newseq.`date +%Y-%m-%d`.lst
	wc -l newseq*.lst
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	mv ../temp/*.eml ../archive
#------------
wellons:
	perl similiar_sequences.pl -a wget < ../A136nnn/seqno.tmp
#------------
# old targets
sim2:
	perl similiar_sequences.pl -p $(P) -min $(MIN) -max $(MAX) < stripsort.tmp 
#------------
