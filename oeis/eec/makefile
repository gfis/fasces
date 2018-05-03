#!make

# Generate OEIS sequences related to Euler's extended conjecture
# @(#) $Id$
# 2018-05-02, Georg Fischer 
# Unix tools diff, echo, grep, head, make, perl, sed, tee, test, 
# wget, pdftohtml, gawk
#---------------------------------
SRC=paper625.lst
TAR=b301nnn.txt
POLY=java -cp ../../../ramath/dist/ramath.jar org.teherba.ramath.symbolic.Polynomial

all: paper625  eval bfile
#---------------------------------------------------------------
paper625:
	test -s $@.pdf || wget https://arxiv.org/pdf/1108.0462.pdf
	pdftohtml -q -noframes $@.pdf $@.html
	grep -E "\^6" $@.html | cut -d ";" -f 2 | cut -d "<" -f 1 > $@.lst
	wc -l $@.lst
eval:
	$(POLY) -eval -f $(SRC)
e2:
	$(POLY) -eval "245597^6+205010^6=205923^6+70550^6+34860^6+66234^6+245182^6"
bfile:
	echo "# $(TAR) - k,a(k) for k=1..7*377" > $(TAR)
	echo '# 7-tuples (a,b,c,d,e,f,g) with a>b, c>d>e>f>g and a^6 + b^6 = c^6 + d^6 + e^6 + f^6 + g^6' >> $(TAR)
	sed -e "s/\^6//g" -e "s/[^0-9]/\n/g" $(SRC) \
	| gawk '{ sum ++; print sum, $$1; }' >> $(TAR)
	head -16 $(TAR)
#-------------------------------------
rest:
	grep -E "^[0-9]" b$(NOEIS).txt    | head -n $(LEN)                           > bf.tmp
#	wc -l bf.tmp
	perl cumulcount.pl -m $(METHOD) -r $(ROW) -n $(NOEIS) -l $(LEN) -a $(APPEAR) -f $(FIRST) -o $(OFFSET) -s $(START) -p $(PARM) -w $(WITH0) -d $(DEBUG) > A$(NOEIS).pn.tmp
	grep -E "^[0-9]" A$(NOEIS).pn.tmp | head -n `wc -l bf.tmp | cut -d " " -f 1` > pn.tmp
#	diff -w -y                         --width=32  bf.tmp pn.tmp || :
	diff -w -y --suppress-common-lines --width=32  bf.tmp pn.tmp | head -n 8
#
debug:
	# -------------------------------------------------------
	perl cumulcount.pl -m $(METHOD) -r $(ROW) -n $(NOEIS) -l $(LEN) -a $(APPEAR) -f $(FIRST) -o $(OFFSET) -s $(START) -p $(PARM) -w $(WITH0) -d 1 | less
#--------
list1:
	perl cumulcount.pl -m $(METHOD) -r $(ROW) -n $(NOEIS) -l $(LEN) -a $(APPEAR) -f $(FIRST) -o $(OFFSET) -s $(START) -p $(PARM) -w $(WITH0) -d 99 
#	echo " " [https://oeis.org/A$(NOEIS) A$(NOEIS)] Rule $(RULE).$(ROW) $(ORD) $(P1) $(P2) " "\
#	`wc -l b$(NOEIS).txt | cut -d " " -f 1`
listing:
	make -s all TARGET=list1 | sort \
	| tee listing.tmp
	wc -l listing.tmp
#--------
# e.g. https://oeis.org/search?q=id:A257908&fmt=text
intern1:
	test -s A$(NOEIS).int || wget -O A$(NOEIS).int "http://oeis.org/search?q=id:A$(NOEIS)\&fmt=text" 
internal: 
	make $(SIL) all TARGET=intern1