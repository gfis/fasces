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
getseq: getseq1 getseq2
getseq1:
	rm -f *.tmp
	# grep -i " n such that the concatenation of n with " ../database/names | tee names1.tmp
	grep -i " n such that n concatenated with "         ../database/names | tee names2.tmp
	wc -l names*.tmp
	grep -E "^A116[012]" ../database/stripped   > strip1.tmp
getseq2:
	cut -b 1-7 names2.tmp > seqno.tmp
	grep -f seqno.tmp strip1.tmp > strip2.tmp
	wc -l strip2.tmp
dupl:
	cut -b 8- strip2.tmp | sort | uniq -c | grep -v "   1 " | sed -e "s/  */ /g" \
	| cut -d" " -f 3- | tee dupl1.tmp
	grep -f dupl1.tmp strip2.tmp | sort -k2 | cut -b 1-8,10-50 \
	| sed -e "s/\(^A[0-9]*\)/<a href=\"https:\/\/oeis.org\/\\1\" target=\"_new\">\\1<\/a> /" \
	| sed -e "s/$$/ .../" -e "s/^/ /" | tee dupl2.tmp
getseq3:
	sed -e "s/Numbers/;/g" -e "s/ and /,/g" -e "s/[Na-z., ]//g" -e "s/;/ /g" \
		names2.tmp > names3.tmp
	join names3.tmp strip2.tmp > squaredig.tmp
getseq4:
	grep -i " n such that n concatenated with " ../database/names \
	| grep -E "square|product" | tee names4.tmp
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
