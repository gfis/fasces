#!make

# OEIS Sequences A136nnn from Jonathan Wellons
# @(#) $Id$
# 2018-10-15, Georg Fischer 
#---------------------------------
H=4
MIN=0
MAX=10000
S=8
CODE=0146

all: 
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
polish:
	perl polish_squaredig.pl < wellons-restored.html 
	cp -v squaredig.html a136809.html
#----
deploy: 
	scp a136809.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/
