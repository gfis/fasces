#!make

# for OEIS sequences A1313nn, nn=88,89,93,94,
# and others defined by Clark Kimberling
# @(#) $Id$
# 2018-02-23, Georg Fischer
# 
all: A131388 A131393
#--------
A131388: A131389
	perl negpos.pl $@ 1000 ak 1 0 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131388.txt $@.pn.tmp || :
A131389: 
	perl negpos.pl $@ 1000 dk 1 0 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131389.txt $@.pn.tmp || :
#--------
A131393: A131394
	perl negpos.pl $@   72 ak 1 0 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131393.txt $@.pn.tmp || :
A131394: 
	perl negpos.pl $@   69 dk 1 0 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131394.txt $@.pn.tmp || :
#--------
A257705:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=0 D1=0
A257706:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=0 D1=1
	# some differences
A257876:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=0 D1=2
A257877:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=0 D1=3
A257915:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=dk A1=0 D1=3
A257878:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=1 D1=1
A257879:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=2 D1=0
	# bad
A257880:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=dk A1=2 D1=0
	# bad
A257881:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=2 D1=1
	# bad
#--
A257882:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=2 D1=2
	# bad
A257918:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=dk A1=2 D1=2
	# bad
#--------
negpos:
	test -s b$(NOEIS).txt || wget http://oeis.org/A$(NOEIS)/b$(NOEIS).txt
	perl $@.pl A$(NOEIS) $(LEN)   $(OPER) $(A1) $(D1)       | grep -Ev "#" > A$(NOEIS).pn.tmp
	diff -w -y                         --width=32  b$(NOEIS).txt A$(NOEIS).pn.tmp || :
#	diff -w -y --suppress-common-lines --width=32  b$(NOEIS).txt A$(NOEIS).pn.tmp || :
#--------
xA131388: xA131389
	perl a1313.pl $@ 1000 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131388.txt $@.pn.tmp || :
xA131389: 
	perl a1313.pl $@ 1000 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131389.txt $@.pn.tmp || :
#--------
xA131393: xA131394
	perl a1313.pl $@ 72 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131393.txt $@.pn.tmp || :
xA131394: 
	perl a1313.pl $@ 69 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131394.txt $@.pn.tmp || :
#--------
# chain, c.f. http://faculty.evansville.edu/ck6/integer/unsolved.html, Problem 13
chain389:
	perl a1313.pl A131389 100000 > t32k.tmp
	perl chain389.pl t32k.tmp
	# no output => no counterexample up to 100000
chain394:
	perl a1313.pl A131394 10000  > u32k.tmp
	perl chain389.pl u32k.tmp
	# no output => no counterexample up to 10000
block389:
	perl block2.pl t32k.tmp
block394:
	perl block2.pl u32k.tmp
#--------
wgetall:
	wget http://oeis.org/A131388/b131388.txt
	wget http://oeis.org/A131389/b131389.txt
	wget http://oeis.org/A131393/b131393.txt
	wget http://oeis.org/A131394/b131394.txt
