#!make

# for OEIS sequences defined by Clark Kimberling
# @(#) $Id$
# 2018-02-26: RULE=
# 2018-02-23, Georg Fischer
# 
TARGET=negpos
LIMIT=2000

all: rule1 rule2 rule3 rule4
#----------------------------------------------------------------
# Rule 1: Step 1 downwards, Step 2 upwards
rule1: np131388 np257705 np257879 np257905
np131388: 131388
131388: 131389 175007 175008 131390 131391 131392 
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=1 D1=0
131389: 
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=1 D1=0
175007:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=d0 A1=1 D1=0
175008:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dn A1=1 D1=0
131390:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=in A1=1 D1=0
	# last 11 lines of b-file are wrong
131391:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=cp A1=1 D1=0
131392:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=cn A1=1 D1=0
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
# Rule 1: Step 1 downwards, Step 2 upwards
np257705: 257705 257876 257877 257915 257878
257705:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=0
257876:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=2
257877:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=3
257915:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=0 D1=3
257878:
	make $(TARGET) RULE=1 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=1 D1=1
#--------
np257879: 257706 257879 257880 257881 257882 257918
# wrong descriptions with S=1 instead of 0
257706:
	make $(TARGET) RULE=1 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=1
257879:
	make $(TARGET) RULE=1 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=2 D1=0
257880:
	make $(TARGET) RULE=1 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=2 D1=0
257881:
	make $(TARGET) RULE=1 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=2 D1=1
257882:
	make $(TARGET) RULE=1 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=2 D1=2
257918:
	make $(TARGET) RULE=1 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=2 D1=2
#----------------------------------------------------------------
rule2: np131393
# Rule 2 like Rule 1 with different start of $dk
np131393: 131393 131394 131395 131396 131397
131393:
	make $(TARGET) RULE=2 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=1 D1=0
131394: 
	make $(TARGET) RULE=2 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=1 D1=0
131395:
	make $(TARGET) RULE=2 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=in A1=1 D1=0
	# last 8 lines of b-file are wrong
131396:
	make $(TARGET) RULE=2 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=cp A1=1 D1=0
131397:
	make $(TARGET) RULE=2 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=cn A1=1 D1=0
#----------------------------------------------------------------
# Rule 3: 
rule3:
	# echo Rule 3 
#----------------------------------------------------------------
# Rule 4: upwards from lowest
rule4: np257883
np257883: 257883 257884 257885 257903 175498 257905 175499 257908 257909 257910 257911  
257883:
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=0
# A175499 except for first initial terms

257884: 175499
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=1
175499:
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=0 D1=1

257885: 257902
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=2
257902:
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=0 D1=2

257903: 257904
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=3
257904:
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=0 D1=3

175498:
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=1 D1=0
# A175499 except for first term 

257908: 257909
	make $(TARGET) RULE=3 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=2
257909:
	make $(TARGET) RULE=3 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=0 D1=2

257910: 
	make $(TARGET) RULE=3 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=3
# A257909 except for initial terms

257911: 257912
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=2 D1=2
257912:
	make $(TARGET) RULE=4 S=0 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=2 D1=2

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
#--------
np257905: \
	257905      258047 \
	257906      257907 \
	257908      257909 \
	257910      257980 \
	258046      258047 \
	257981      257982 \
	257983      257909 \
	257985      258047 \
	257986      257982 \
	257987      257909
257905: 258047
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=0
258047:
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=1 D1=0

257906: 257907
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=0 D1=1
257907:
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=0 D1=1

257980:
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=0 D1=3

258046: 258047
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=1 D1=0

257981: 257982
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=1 D1=1
257982:
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=dk A1=1 D1=1

257983: 
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=1 D1=2
# 257909.112:

257985: 
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=2 D1=0
# 258047

257986: 257982
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=2 D1=1
# 257982.121:

257987:
	make $(TARGET) RULE=3 S=1 NOEIS=$@ LEN=$(LIMIT) OPER=ak A1=2 D1=2
# 257909.122:

# from A257905:
# a(1)  d(1)      (a(n))       (d(n))
# 0       0      A257905      A258047
# 0       1      A257906      A257907
# 0       2      A257908      A257909
# 0       3      A257910      A257980
# 1       0      A258046      A258047
# 1       1      A257981      A257982
# 1       2      A257983      A257909
# 2       0      A257985      A257047
# 2       1      A257986      A257982
# 2       2      A257987      A257909
#---------------------------------------------------------------
negpos:
	# -------------------------------------------------------
	echo perl negpos.pl $(RULE) $(S) $(NOEIS) $(LEN) $(OPER) $(A1) $(D1)
	test -s b$(NOEIS).txt || wget http://oeis.org/A$(NOEIS)/b$(NOEIS).txt
	perl negpos.pl $(RULE) $(S) $(NOEIS) $(LEN) $(OPER) $(A1) $(D1) > A$(NOEIS).pn.tmp
	grep -Ev "^ *#" b$(NOEIS).txt | head -n $(LIMIT) > bf.tmp 
	grep -Ev "^ *#" A$(NOEIS).pn.tmp | head -n `wc -l bf.tmp | cut -d " " -f 1` > pn.tmp
#	diff -w -y                         --width=32  bf.tmp pn.tmp || :
	diff -w -y --suppress-common-lines --width=32  bf.tmp pn.tmp || :
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
#-------------------------------------------
# get the list of relevant sequence numbers
nplists: Anoeis npname npseqs
Anoeis:
	grep -E "^[0-9]" makefile | sed -e "s/^/A/" \
	| cut -b 1-7 | sort | uniq | tee $@.tmp
	wc $@.tmp
#----
# prepare the descriptions
npname: Anoeis
	grep -f Anoeis.tmp ../names    | sort \
	| sed -e "s/generated by/ /" -e "s/(in Comments) with//" \
	 -e "s/Sequence//i" \
	 -e "s/Conjectured permutation of the //" \
	 -e "s/conjectured permutation//" \
	| cut -b 1-80 \
	| tee $@.tmp
	wc $@.tmp
#----
# compare the sequence lists to the b-files
npseqs: Anoeis wgetrest
	grep -f $@.tmp ../stripped | sort | tee npseqs.tmp
	perl npseqs.pl < npseqs.tmp
#----
wgetrest: Anoeis
	cut -b 2-7 Anoeis.tmp > noeis.tmp
	cat noeis.tmp | xargs -l -i{} make wget1 NOEIS={}
wget1:
	test -s b$(NOEIS).txt || wget http://oeis.org/A$(NOEIS)/b$(NOEIS).txt
#----
listing:
	make -s all TARGET=list1 | sort \
	| sed -e "s/ ak / a  /" -e "s/ dk / d  /"\
	| tee listing.tmp
	wc listing.tmp
list1: 
	echo $(NOEIS) Rule $(RULE).$(S)  $(OPER)  $(A1) $(D1)
#----
# e.g. https://oeis.org/search?q=id:A257908&fmt=text
internal: Anoeis
	cat Anoeis.tmp | xargs -l -i{} make intern1 ANOEIS={}
intern1:
	test -s $(ANOEIS).int || \
	wget -O $(ANOEIS).int "http://oeis.org/search?q=id:$(ANOEIS)\&fmt=text" 
