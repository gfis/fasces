#!make

# for OEIS sequences A1313nn, nn=88,89,93,94
# @(#) $Id$
# 2018-02-23, Georg Fischer
# 
all: A131388 A131393
#--------
A131388: A131389
	perl a1313.pl $@ 1000 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131388.txt $@.pn.tmp || :
A131389: 
	perl a1313.pl $@ 1000 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131389.txt $@.pn.tmp || :
#--------
A131393: A131394
	perl a1313.pl $@ 72 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131393.txt $@.pn.tmp || :
A131394: 
	perl a1313.pl $@ 72 > $@.pn.tmp
	diff -y --suppress-common-lines --width=32  b131394.txt $@.pn.tmp || :
#--------
wgetall:
	wget http://oeis.org/A131388/b131388.txt
	wget http://oeis.org/A131389/b131389.txt
	wget http://oeis.org/A131393/b131393.txt
	wget http://oeis.org/A131394/b131394.txt
