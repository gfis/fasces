#!/usr/bin/make

# Hadamard pyramid
# @(#) $Id$
# 2026-06-08: new attempt, single matrix only; *FP=12
# 2025-08-09: *VF=44
# 2025-07-21, Georg Fischer

APPL=fasces
SRC=src/main/java/org/teherba/fasces
TESTDIR=test
D=0

all:
	grep -P "^[a-z]" makefile
#----------------
prep: # prepare the matrices obtained from SageMath
	perl hadamard_prep.pl from_sage_1-33.txt | tee planes.inc

#--
square: # show notation for 2x2 blocks
	perl hadamard.pl -d $(D) -m square planes.inc | tee planes.tmp
svgen:
	perl svgen.pl planes.tmp
#----------------
sagen: # generate Hadamard matrices with sage in raw format; must be called under Ubuntu in directory /mnt/c/Users/drgeo/work/gits/fasces/hadamard
	mkdir -p raw
	seq 0 2 256 | xargs -innn make sagen1 SEQ=nnn
sagen1:
	sage hadamard.sage $(SEQ) > raw/h$(SEQ).raw
	echo raw/h$(SEQ) generated
h92:
	perl hadamard_prep.pl from_sage.92.txt | tee plane.$@.inc
	perl hadamard.pl -d $(D) -m square plane.$@.inc | tee plane.$@.tmp
	perl svgen.pl plane.$@.tmp
h65:
	perl hadamard_prep.pl from_sage.1-65.txt        > plane.$@.inc
	perl hadamard.pl -d $(D) -m square plane.$@.inc > plane.$@.tmp
	perl svgen.pl                                     plane.$@.tmp
#----------------
do10: # H= ; convert from ./ranew/$(H).raw to ./10/$(H).10
	perl hadamard_prep.pl ranew/$(H).raw \
	| sed -e "s/[\,\)\(]//g"  | tee 10/$(H).10

# h11 -> 13913485480364
#----
paleyI:
	grep -iH "paleyI " ranew/*
#----
paley1_test:
	rm -f    $@.tmp
	seq 4 4 256 \
	| xargs -innn perl hadamat.pl order nnn gen paley1 ortest | tee -a $@.tmp
	wc -l    $@.tmp
#----
paley2_test:
	rm -f    $@.tmp
	seq 4 4 256 \
	| xargs -innn perl hadamat.pl order nnn gen paley2 ortest | tee -a $@.tmp
	wc -l    $@.tmp
paley3_flip2: # works 2026-06-12
	perl hadamat.pl read ranew/h1.raw debug 1 order 12 gen paley2 dump6  ortest # uses h0.raw
	perl hadamat.pl read ranew/h1.raw debug 1 order 24 gen paley3 dump6  ortest
	perl hadamat.pl read ranew/h2.raw debug 1 order 48 gen paley3 dump24 ortest
	perl hadamat.pl read ranew/h4.raw debug 1 order 96 gen paley3 dump48 ortest
