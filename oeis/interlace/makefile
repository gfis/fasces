#!make

# for OEIS sequences defined by Clark Kimberling
# @(#) $Id$
# 2018-02-27, Georg Fischer
# 
N=4

all: diff2
#------------------
diff1:
	./armleg $(N) 1 | grep -vE "^#" | cut -d " " -f $$(($(N)+2)) \
	| perl diffs.pl
diff2:
	./armleg $(N) 1 | grep -vE "^#" | cut -d " " -f $$(($(N)+2)) \
	| sort -n | uniq \
	| perl diffs.pl
#--------------------------------------
intrian: intrian3
intrian3:
	perl intrian.pl 3 0 | grep -v "^#" > $@.in.tmp
	sort $@.in.tmp | uniq | wc
intrian4:
	perl intrian.pl 4 0 | grep -v "^#" > $@.in.tmp
	sort $@.in.tmp | uniq | wc

# perm3 perm6 inter10.0
# perm10

perm3:
	echo "------------------------"
	time java -cp ~/work/gits/ramath/dist/ramath.jar org.teherba.ramath.util.Permutator 3 > $@.tmp
	wc $@.tmp
	# 3! = 6
	perl interlace.pl  3 0 < $@.tmp
	perl interlace.pl  3 1 < $@.tmp
perm6:
	echo "------------------------"
	time java -cp ~/work/gits/ramath/dist/ramath.jar org.teherba.ramath.util.Permutator 6 > $@.tmp
	wc $@.tmp
	# 6! = 720
	perl interlace.pl  6 0 < $@.tmp
	perl interlace.pl  6 1 < $@.tmp
perm10:
	time java -cp ~/work/gits/ramath/dist/ramath.jar org.teherba.ramath.util.Permutator 10 > $@.tmp
	wc $@.tmp
	# 10! = 3628800
inter6.0:
	echo "------------------------"
	perl interlace.pl 6 0 < perm6.tmp | tee $@.tmp
	perl ilcount.pl < $@.tmp
inter6.1:
	echo "------------------------"
	perl interlace.pl 6 1 < perm6.tmp | tee $@.tmp
	perl ilcount.pl < $@.tmp
inter10.0:
	echo "------------------------"
	perl interlace.pl 10 0 < perm10.tmp | tee $@.tmp
	perl ilcount.pl < $@.tmp
inter10.1:
	echo "------------------------"
	perl interlace.pl 10 1 < perm10.tmp > $@.tmp
	perl ilcount.pl < $@.tmp
#
perm15:
	java -cp ~/work/gits/ramath/dist/ramath.jar org.teherba.ramath.util.Permutator 15 > $@.tmp
	wc $@.tmp
#-------------------------------
gen:
	perl perl2c.pl connected.pl > connected.tmp
connected: connected.c
	gcc -Ofast -c -o $@.o $@.c
	gcc -o $@ $@.o
	chmod 755 $@
armleg: armleg.c
	gcc -Ofast  -c -o $@.o $@.c
	gcc -o $@ $@.o
	chmod 755 $@
armcount:
	./armleg $(N) 1 | grep -vE "^#" | cut -d " " -f $$(($(N)+2)) | sort | uniq -c
arm5:
	./armleg 5 1 | grep -v "#" | sort | uniq | wc
