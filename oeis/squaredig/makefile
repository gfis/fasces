#!make

# "squaredig" OEIS Sequences A136nnn from Jonathan Wellons
# @(#) $Id$
# 2018-10-15, Georg Fischer 
#---------------------------------
D=0
NT=1000
WIDTH=16
SC=0146

all: 
#----
sqd: sqd2 sqd3 sqd4
sqd1:
	perl squaredig.pl -s $(SC) -n $(NT) -w $(WIDTH) -d $(D)
dummy:
	| grep -v "46" \
	| sed -e "s/46/33/g" \
	
sqd2:
	perl square_digits.pl -s $(SC) -w $(WIDTH) -d 1  -q 46\
	| grep "push" | gawk '{ print $$3 }' \
	| cat -n \
		>         $@.tmp
	head -n 4 $@.tmp
	wc   -l   $@.tmp
sqd3:
	perl ../bfcolor/bfcolorize.pl -m 4 -r sqd2.tmp \
	> $@.html
sqd4:
	cmd /C "start sqd3.html"
s0146:
	perl square_digits.pl -w 15 -s 0146 -d 1 | grep "46:" | grep -v drop \
	| sed -e "s/^[^0-9]*//" | gawk '{ print $$2, $$3 }' \
	| cat -n \
	> $@.txt
	perl ../bfcolor/bfcolorize.pl -m 4 -r $@.txt > $@.html
	cmd /C "start $@.html"
s61046:
	perl square_digits.pl -w 15 -s 0146 -d 1 | grep -E "044*61046:" | grep -v drop \
	| sed -e "s/^[^0-9]*//" | gawk '{ print $$2, $$3 }' \
	| cat -n \
	> $@.txt
	perl ../bfcolor/bfcolorize.pl -m 4 -r $@.txt > $@.html
	cmd /C "start $@.html"
#----
getseq: getseq1 getseq2
getseq1:
	rm -f *.tmp
	grep -E "^A13[67]" ../database/names      > names1.tmp
	grep -E " and the square of "  names1.tmp > names2.tmp
	wc -l names2.tmp
	grep -E "^A13[67]" ../database/stripped   > strip1.tmp
getseq2:
	cut -b 1-7 names2.tmp                     > seqno.tmp
	grep -f seqno.tmp strip1.tmp              > strip2.tmp
	wc -l strip2.tmp
getseq3:
	sed -e "s/Numbers/;/g" -e "s/ and /,/g" -e "s/[Na-z., ]//g" -e "s/;/ /g" \
		names2.tmp                            > names3.tmp
	join names3.tmp strip2.tmp                > squaredig.tmp
gettext:
	perl ../database/similiar_sequences.pl -a wget < seqno.tmp
#----
polish:
	perl polish_squaredig.pl < wellons-restored.html 
	cp -v squaredig.html a136809.html
#----
deploy: 
	scp a136809.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/
