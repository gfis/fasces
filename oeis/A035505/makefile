#!make

# Generate Kimberling's expulsion array in a triangle
# @(#) $Id$
# 2018-05-02, Georg Fischer 
# Unix tools diff, echo, grep, head, make, perl, sed, tee, test, 
# wget, pdftohtml, gawk
#---------------------------------
N=100

all: kea
kea:
	perl kea_html.pl $(N) > kea.html
#---------------------------------------------------------------
exp1:
	perl expell.pl 40 | tee expell.tmp
exp2:
	perl expell.pl 120 | tee expell.tmp
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