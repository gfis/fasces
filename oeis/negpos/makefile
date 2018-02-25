#!make

# for OEIS sequences A1313nn, nn=88,89,93,94,
# and others defined by Clark Kimberling
# @(#) $Id$
# 2018-02-23, Georg Fischer
# 
all: np88 np93
#--------
np88: A131388 A131389 A131390 A131391 A131392 
A131388:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=1 D1=0
A131389: 
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=dk A1=1 D1=0
A131390:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=in A1=1 D1=0
	# last 11 lines of b-file are wrong
A131391:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=dp A1=1 D1=0
A131392:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=dn A1=1 D1=0
#--------
np93: A131393 A131394 A131395 A131396 A131397
A131393:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=200 OPER=ak A1=1 D1=0
A131394: 
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=200 OPER=dk A1=1 D1=0
A131395:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=200 OPER=in A1=1 D1=0
	# last 8 lines of b-file are wrong
A131396:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=200 OPER=dp A1=1 D1=0
A131397:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=200 OPER=dn A1=1 D1=0
#--------
# from A257705:
# a(1)  d(1)      (a(n))             (d(n))
# 0       0      A257705      A131389 except for initial terms
# 0       1      A257706      A131389 except for initial terms
# 0       2      A257876      A131389 except for initial terms
# 0       3      A257877      A257915
# 1       0      A131388      A131389
# 1       1      A257878      A131389 except for initial terms
# 2       0      A257879      A257880
# 2       1      A257881      A257880 except for initial terms
# 2       2      A257882      A257918
np705: A257705 A257706 A257876 A257877 A257915 A257878 A257879 A257880 A257881 A257882 A257918
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
A257883:
	make negpos NOEIS=`echo $@ | cut -b 2-7` LEN=1000 OPER=ak A1=0 D1=0
	# bad
# from A257883:
# a(1)   d(1)    (a(n))       (d(n))
# 0      0      A257883      A175499 except for initial terms
# 0      1      A257884      A175499
# 0      2      A257885      A257902
# 0      3      A257903      A257904
# 1      0      A175498      A175499 except for first term
# 1      1      A257905      A175499
# 2      0      A257908      A257909
# 2      1      A257910      A257909 except for initial terms
# 2      2      A257911      A257912

LINKS
#--------
negpos:
	test -s b$(NOEIS).txt || wget http://oeis.org/A$(NOEIS)/b$(NOEIS).txt
	perl $@.pl A$(NOEIS) $(LEN)   $(OPER) $(A1) $(D1) > A$(NOEIS).pn.tmp
	grep -Ev "^ *#" b$(NOEIS).txt > bf.tmp 
	grep -Ev "^ *#" A$(NOEIS).pn.tmp | head -n `wc -l bf.tmp | cut -d " " -f 1` > pn.tmp
#	diff -w -y                         --width=32  bf.tmp pn.tmp || :
	diff -w -y --suppress-common-lines --width=32  bf.tmp pn.tmp || :
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
