#!make

# OEIS Sequences A116094-A116224 by Giovanni Resta
# @(#) $Id$
# 2018-10-31, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000
S=8
CODE=0146

all: getseq
#----
getseq: getseq0 getseq1 getseq2 getseq3 dupl
getseq0:
	grep -iE " n such that (n|the) concatenat" ../database/names \
	| grep -E "square|product" \
	| grep -vE "prime|biperiod|perfect|\\*" \
	| tee names0.tmp
	grep -E "^A11[56]" ../database/stripped > strip1.tmp
getseq1:
	sed -e "s/the concatenation of n/n concatenated/" names0.tmp \
	| sed -e "s/ itself / n+0 /" \
	| sed -e "s/ is a square/ gives a square/" \
	| sed -e "s/Numbers n such that n concatenated with/n \/\//" \
	| sed -e "s/gives the product of two numbers which differ by \([0-9]*\)./= m * (m+\\1)/" \
	| sed -e "s/gives a square./= m * (m+0)/" \
	| tee names1.tmp
getseq2:
	cut -b 1-7 names1.tmp > seqno.tmp
	grep -f seqno.tmp strip1.tmp \
	| sed -e "s/,//" > strip2.tmp
	wc -l strip2.tmp
getseq3:
	sed -e "s/^//" names1.tmp > names3.tmp
	join names3.tmp strip2.tmp > concatprod.tmp
	cut -b 1-80 concatprod.tmp \
	| sed -e "s/^/ /" | sed -e "s/$$/.../" \
	| tee ccp.tmp
dupl:
	cut -b 8- strip2.tmp | sort | uniq -c | grep -v "   1 " | sed -e "s/  */ /g" \
	| cut -d" " -f 3- | tee dupl1.tmp
	grep -f dupl1.tmp concatprod.tmp | sort -k9 \
	| cut -b 1-80 \
	| sed -e "s/^/ /" | sed -e "s/$$/.../" \
	| tee dupl2.tmp
# | sed -e "s/\(^A[0-9]*\)/<a href=\"https:\/\/oeis.org\/\\1\" target=\"_new\">\\1<\/a> /" 
#----
wget_bf:
	cut -b 1-7 squaredig.tmp | sed -e "s/A/b/" > bseqno.tmp
	perl ../database/simseq.pl -a wget < bseqno.tmp
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
#------------
deploy:
	scp A*-A*.html index.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database
#------------
test:
	perl a136859.pl -w 16     > a136859.test
	perl ../database/bfcolor.pl -r < a136859.test \
	| sed -e "s/class=\"c[0146]\"/class=\"c0\"/g" \
	| sed -e "s/class=\"c[235789]\"/class=\"c2\"/g" \
	> a136859.html
